#!/usr/bin/env python3
"""Exercise the real session helper with controlled picker/encoder processes."""
import json
import os
from pathlib import Path
import queue
import signal
import subprocess
import sys
import tempfile
import threading
import unittest

HELPER = Path(__file__).resolve().parents[1] / 'bin/postcard-record'

FAKE = '''#!/usr/bin/env python3
import json, os, pathlib, signal, sys, time
name = pathlib.Path(sys.argv[0]).name
case = os.environ.get('CASE', '')
if name == 'omarchy-hyprland-monitor-focused':
    print('DP-1')
elif name == 'omarchy-capture-region':
    if case == 'cancel': sys.exit(1)
    if case == 'picker_wait':
        pathlib.Path(os.environ['PICKER_PID']).write_text(str(os.getpid()))
        time.sleep(30)
    print('garbage' if case == 'bad_region' else '-1280,40 640x480')
elif name == 'gpu-screen-recorder':
    pathlib.Path(os.environ['ARGS']).write_text(json.dumps(sys.argv[1:]))
    pathlib.Path(os.environ['ENCODER_PID']).write_text(str(os.getpid()))
    if case == 'encoder_fail':
        print('test encoder failure', file=sys.stderr)
        sys.exit(1)
    def stop(*args):
        pathlib.Path(sys.argv[sys.argv.index('-o') + 1]).write_bytes(b'finished')
        sys.exit(0)
    signal.signal(signal.SIGINT, stop)
    pathlib.Path(sys.argv[sys.argv.index('-o') + 1]).write_bytes(b'header')
    while True: time.sleep(.02)
elif name == 'ffprobe':
    if case == 'invalid_video': sys.exit(1)
    print('video')
'''


class RecordingTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='postcard-record-test-')
        self.root = Path(self.temp.name)
        commands = self.root / 'bin'
        commands.mkdir()
        for name in ('omarchy-hyprland-monitor-focused', 'omarchy-capture-region',
                     'gpu-screen-recorder', 'ffprobe'):
            file = commands / name
            file.write_text(FAKE)
            file.chmod(0o755)
        self.env = dict(os.environ, PATH=str(commands) + ':' + os.environ['PATH'],
                        XDG_RUNTIME_DIR=str(self.root),
                        OMARCHY_SCREENRECORD_DIR=str(self.root / 'videos with spaces'),
                        ARGS=str(self.root / 'args.json'),
                        ENCODER_PID=str(self.root / 'encoder.pid'),
                        PICKER_PID=str(self.root / 'picker.pid'))
        self.processes = []

    def tearDown(self):
        for proc in self.processes:
            if proc.poll() is None:
                proc.terminate()
                proc.wait(timeout=25)
            for stream in (proc.stdin, proc.stdout, proc.stderr):
                if stream and not stream.closed:
                    stream.close()
        self.temp.cleanup()

    def start(self, mode='region', case='', delay=0):
        proc = subprocess.Popen([sys.executable, str(HELPER), mode, '--delay', str(delay)],
                                env=dict(self.env, CASE=case), stdin=subprocess.PIPE,
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        self.processes.append(proc)
        events = queue.Queue()
        def read():
            for line in proc.stdout:
                events.put(json.loads(line))
        threading.Thread(target=read, daemon=True).start()
        return proc, events

    def until(self, events, state):
        while True:
            event = events.get(timeout=8)
            if event['state'] == state:
                return event
            self.assertNotEqual(event['state'], 'error', event)

    def stop(self, proc, events):
        proc.stdin.write('stop\n')
        proc.stdin.flush()
        result = self.until(events, 'saved')
        self.assertEqual(proc.wait(timeout=5), 0)
        self.assertEqual(Path(result['path']).read_bytes(), b'finished')
        return result['path']

    def test_region_geometry_and_graceful_save(self):
        proc, events = self.start()
        self.until(events, 'recording')
        args = json.loads((self.root / 'args.json').read_text())
        self.assertEqual(args[args.index('-w') + 1], '640x480+-1280+40')
        self.assertEqual(args[args.index('-k') + 1], 'h264')
        self.stop(proc, events)

    def test_fullscreen_and_unique_filenames(self):
        paths = []
        for _ in range(2):
            proc, events = self.start(mode='fullscreen')
            self.until(events, 'recording')
            args = json.loads((self.root / 'args.json').read_text())
            self.assertEqual(args[args.index('-w') + 1], 'DP-1')
            paths.append(self.stop(proc, events))
        self.assertNotEqual(*paths)

    def test_cancelled_picker_creates_no_video(self):
        proc, events = self.start(case='cancel')
        self.until(events, 'cancelled')
        self.assertEqual(proc.wait(timeout=5), 0)
        self.assertFalse((self.root / 'args.json').exists())

    def test_stop_during_countdown_never_starts_encoder(self):
        proc, events = self.start(delay=3)
        self.until(events, 'countdown')
        proc.stdin.write('stop\n'); proc.stdin.flush()
        self.until(events, 'cancelled')
        self.assertEqual(proc.wait(timeout=5), 0)
        self.assertFalse((self.root / 'args.json').exists())

    def test_eof_during_selection_cleans_picker(self):
        proc, events = self.start(case='picker_wait')
        self.until(events, 'selecting')
        proc.stdin.close()
        self.until(events, 'cancelled')
        self.assertEqual(proc.wait(timeout=5), 0)
        if (self.root / 'picker.pid').exists():
            with self.assertRaises(ProcessLookupError):
                os.kill(int((self.root / 'picker.pid').read_text()), 0)

    def test_parent_pipe_closing_finalizes_video(self):
        proc, events = self.start()
        self.until(events, 'recording')
        proc.stdin.close()
        result = self.until(events, 'saved')
        self.assertEqual(proc.wait(timeout=5), 0)
        self.assertEqual(Path(result['path']).read_bytes(), b'finished')

    def test_shutdown_signal_finalizes_video(self):
        proc, events = self.start()
        self.until(events, 'recording')
        proc.terminate()
        self.until(events, 'saved')
        self.assertEqual(proc.wait(timeout=5), 0)

    def test_second_session_refused_without_stopping_first(self):
        first, events = self.start()
        self.until(events, 'recording')
        other, rejected = self.start()
        error = self.until(rejected, 'error')
        self.assertIn('already running', error['message'])
        self.assertEqual(other.wait(timeout=5), 1)
        self.assertIsNone(first.poll())
        self.stop(first, events)

    def test_failure_reports_error_and_removes_empty_output(self):
        proc, events = self.start(case='encoder_fail')
        error = self.until(events, 'error')
        self.assertIn('test encoder failure', error['message'])
        self.assertEqual(proc.wait(timeout=5), 1)
        self.assertEqual(list((self.root / 'videos with spaces').glob('*.mp4')), [])

    def test_invalid_video_kept_but_not_reported_as_saved(self):
        proc, events = self.start(case='invalid_video')
        self.until(events, 'recording')
        proc.stdin.write('stop\n'); proc.stdin.flush()
        self.until(events, 'error')
        self.assertEqual(proc.wait(timeout=5), 1)
        self.assertEqual(len(list((self.root / 'videos with spaces').glob('*.mp4'))), 1)

    def test_invalid_geometry_never_starts_encoder(self):
        proc, events = self.start(case='bad_region')
        self.until(events, 'error')
        self.assertEqual(proc.wait(timeout=5), 1)
        self.assertFalse((self.root / 'args.json').exists())

    def test_stop_leaves_unrelated_process_alive(self):
        other = subprocess.Popen(['sleep', '30'])
        try:
            proc, events = self.start()
            self.until(events, 'recording')
            self.stop(proc, events)
            self.assertIsNone(other.poll())
        finally:
            other.terminate(); other.wait()


if __name__ == '__main__':
    unittest.main()
