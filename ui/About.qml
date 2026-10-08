import QtQuick
import QtQuick.Controls as QQC
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

        Section {
            Wordmark {
                markHeight: Style.font.bodySmall * 2
                tint: Ui.text
            }
            Text {
                text: [about.manifest && about.manifest.version ? "Version " + about.manifest.version : "",
                       about.manifest && about.manifest.license ? about.manifest.license + " license" : ""]
                      .filter(function (s) { return s !== ""; }).join("  ·  ")
                visible: text !== ""
                color: Ui.textMuted
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
            }
            Flow {
                width: parent.width
                spacing: Ui.gap
                IconButton {
                    glyph: ""
                    label: "Sponsor"
                    primary: true
                    tip: "Support Postcard on GitHub Sponsors"
                    onClicked: about.open(about.sponsorUrl)
                }
                IconButton {
                    glyph: ""
                    label: "GitHub"
                    tip: "Postcard on GitHub"
                    onClicked: about.open(about.repoUrl)
                }
            }
        }

        Section {
            title: "Help"

            Flow {
                width: parent.width
                spacing: Ui.gap
                IconButton {
                    glyph: ""
                    label: "Read the guide"
                    onClicked: about.open(about.repoUrl + "#readme")
                }
                IconButton {
                    glyph: ""
                    label: "Report a problem"
                    onClicked: about.open(about.repoUrl + "/issues/new")
                }
            }
        }

        Section {
            title: "Keys"

            Repeater {
                model: Model.KEYS.filter(function (k) { return !k[2]; })
                delegate: Column {
                    id: entry
                    required property var modelData
                    width: parent.width
                    spacing: Style.space(2)
                    Text {
                        width: parent.width
                        text: entry.modelData[0].replace(/`/g, "")
                        wrapMode: Text.WordWrap
                        color: Ui.text
                        font.family: Style.font.family
                        font.pixelSize: Style.font.bodySmall
                    }
                    Text {
                        width: parent.width
                        text: entry.modelData[1].replace(/`/g, "")
                        wrapMode: Text.WordWrap
                        color: Ui.textMuted
                        font.family: Style.font.family
                        font.pixelSize: Style.font.caption
                    }
                }
            }
        }
    }
}
