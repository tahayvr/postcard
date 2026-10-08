import QtQuick
import QtQuick.Controls as QQC
import QtQuick.Shapes
import qs.Commons
import "controls"
import "../lib/Model.js" as Model

// Which Postcard this is, where to get help, and the keys no button shows.
// It takes the inspector's place like the settings do.
Flickable {
    id: about
    property var manifest: null
    readonly property string repoUrl: "https://github.com/tahayvr/postcard"
    readonly property string sponsorUrl: "https://github.com/sponsors/tahayvr"

    // The overlay covers the screen, so the browser would open behind it.
    signal linkOpened()

    // A dotted rule for the keys table, across or, with vertical, down.
    component Dots: Shape {
        id: dots
        property bool vertical: false
        width: 1
        height: 1
        ShapePath {
            strokeColor: Ui.tint(0.3)
            strokeWidth: 1
            strokeStyle: ShapePath.DashLine
            dashPattern: [1, 3]
            fillColor: "transparent"
            startX: dots.vertical ? 0.5 : 0
            startY: dots.vertical ? 0 : 0.5
            PathLine {
                x: dots.vertical ? 0.5 : dots.width
                y: dots.vertical ? dots.height : 0.5
            }
        }
    }

    function open(url) {
        Qt.openUrlExternally(url);
        about.linkOpened();
    }

    contentWidth: width
    contentHeight: col.implicitHeight + Ui.pad * 2
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    QQC.ScrollBar.vertical: QQC.ScrollBar {
        id: vbar
        policy: QQC.ScrollBar.AlwaysOn
        visible: vbar.size < 1
        hoverEnabled: true
        background: null
        contentItem: Rectangle {
            implicitWidth: Style.space(3)
            color: Ui.tint(vbar.pressed ? 0.45 : vbar.hovered ? 0.32 : 0.18)
        }
    }

    Column {
        id: col
        x: Ui.pad
        y: Ui.pad
        width: about.width - Ui.pad * 2
        spacing: Ui.section

        Column {
            width: parent.width
            spacing: Ui.row

            Wordmark {
                anchors.horizontalCenter: parent.horizontalCenter
                markHeight: Style.font.bodySmall * 2
                tint: Ui.text
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: [about.manifest && about.manifest.version ? "Version " + about.manifest.version : "",
                       about.manifest && about.manifest.license ? about.manifest.license + " license" : ""]
                      .filter(function (s) { return s !== ""; }).join("  ·  ")
                visible: text !== ""
                color: Ui.textMuted
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Ui.gap
                IconButton {
                    glyph: "\uf004"
                    label: "Sponsor"
                    primary: true
                    tip: "Support Postcard on GitHub Sponsors"
                    onClicked: about.open(about.sponsorUrl)
                }
                IconButton {
                    glyph: "\uf09b"
                    label: "GitHub"
                    tip: "Postcard on GitHub"
                    onClicked: about.open(about.repoUrl)
                }
            }
        }

        Column {
            width: parent.width
            spacing: Ui.row

            // A Section's title, centred like the rest of this block.
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Help"
                color: Ui.textMuted
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                font.capitalization: Font.AllUppercase
                font.letterSpacing: 1
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Ui.gap
                IconButton {
                    glyph: "\uf02d"
                    label: "Guide"
                    tip: "How to use Postcard"
                    onClicked: about.open(about.repoUrl + "#readme")
                }
                IconButton {
                    glyph: "\uf188"
                    label: "Report a problem"
                    onClicked: about.open(about.repoUrl + "/issues/new")
                }
            }
        }

        Section {
            title: "Keys"

            Column {
                width: parent.width

                Dots { width: parent.width }
                Repeater {
                    model: Model.KEYS.filter(function (k) { return !k[2]; })
                    delegate: Column {
                        id: entry
                        required property var modelData
                        width: parent.width

                        Item {
                            readonly property real keyWidth: Math.round(entry.width * 0.42)
                            width: entry.width
                            height: Math.max(keys.implicitHeight, does.implicitHeight) + Ui.gap * 2

                            Text {
                                id: keys
                                x: Ui.gap
                                y: Ui.gap
                                width: parent.keyWidth - Ui.gap * 2
                                text: entry.modelData[0].replace(/`/g, "")
                                wrapMode: Text.WordWrap
                                color: Ui.text
                                font.family: Style.font.family
                                font.pixelSize: Style.font.caption
                            }
                            Dots {
                                x: parent.keyWidth
                                height: parent.height
                                vertical: true
                            }
                            Text {
                                id: does
                                x: parent.keyWidth + Ui.gap
                                y: Ui.gap
                                width: parent.width - x - Ui.gap
                                text: entry.modelData[1].replace(/`/g, "")
                                wrapMode: Text.WordWrap
                                color: Ui.textMuted
                                font.family: Style.font.family
                                font.pixelSize: Style.font.caption
                            }
                        }
                        Dots { width: entry.width }
                    }
                }
            }
        }
    }
}
