import QtQuick
import QtQuick.Controls
import QtQuick.Studio.DesignEffects
import QtQuick.Dialogs

Item {
    id: root
    width: 1920
    height: 1080

    function open() {
        settingsPopup.open()
    }

    FontLoader {
        id: antonFont
        source: "fonts/Anton-Regular.ttf"
    }

    Popup {
        id: settingsPopup
        width: parent.width
        height: parent.height
        modal: true
        anchors.centerIn: parent

        enter: Transition {
            OpacityAnimator {
                target: settingsBg
                to: 1
                duration: 350
            }
            OpacityAnimator {
                target: settingsHolder
                to: 1
                duration: 350
            }
        }

        exit: Transition {
            OpacityAnimator {
                target: settingsBg
                to: 0
                duration: 350
            }
            OpacityAnimator {
                target: settingsHolder
                to: 0
                duration: 350
            }
        }

        background: Rectangle {
            id: settingsBg
            opacity: 0
            gradient: Gradient {
                GradientStop { position: 0; color: "#2a2a2a" }
                GradientStop { position: 1; color: "#1a1a1a" }
            }
        }

        Rectangle {
            id: settingsHolder
            anchors.fill: parent
            color: "transparent"
            opacity: 0

            RButton {
                id: close
                width: parent.width / 15
                height: width
                pressedColor: "#7bd3d3d3"
                radii: width / 10
                bcolor: "transparent"
                canHover: false
                anchors.margins: width / 5
                anchors.left: parent.left
                anchors.top: parent.top

                onTapped: {
                    settingsPopup.close()
                }

                Image {
                    id: back
                    anchors.fill: parent
                    source: "images/close-large-line.svg"
                    fillMode: Image.PreserveAspectFit
                }
            }

            Column {
                id: column
                height: parent.height
                width: parent.width
                spacing: parent.height / 50
                anchors.top: close.bottom
                anchors.topMargin: height / 50

                Rectangle {
                    width: parent.width
                    height: parent.height / 5
                    radius: width / 50
                    color: "#2a2a2a"

                    Text {
                        text: "Journal Path: "
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        fontSizeMode: Text.Fit
                        font.family: antonFont.name
                        height: parent.height
                        width: parent.width / 3
                        color: "white"
                        font.pixelSize: parent.width / 16
                        leftPadding: parent.width / 16
                    }

                    Rectangle {
                        id: pathHolder
                        width: parent.width / 2
                        height: parent.height / 1.5
                        anchors.right: parent.right
                        anchors.rightMargin: parent.width / 16
                        anchors.verticalCenter: parent.verticalCenter
                        color: "#2e2e2e"
                        radius: parent.radius
                        border.width: parent.width / 200
                        border.color: "#333333"

                        Text {
                            id: pathitself
                            height: parent.height
                            width: parent.width - changePath.width * 1.4
                            text: JournalManager.journalPath
                            elide: Text.ElideMiddle
                            anchors.verticalCenter: parent.verticalCenter
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            fontSizeMode: Text.Fit
                            font.family: antonFont.name
                            color: "#a0a0a0"
                            leftPadding: width / 16
                            font.pixelSize: parent.width / 16
                        }
                        RButton {
                            id: changePath
                            height: width
                            width: parent.width / 7
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.rightMargin: parent.border.width * 3
                            bcolor: "#2e2e2e"
                            hoverColor: "#2a2a2a"
                            pressedColor: "#3d3d3d"
                            radii: width / 10

                            onTapped: pathDialog.open()

                            Image {
                                anchors.fill: parent
                                source: "images/folder-transfer-line.svg"
                                fillMode: Image.PreserveAspectFit
                            }

                            FolderDialog {
                                id: pathDialog
                                title: "Select Elite Dangerous Journal Path"
                                currentFolder: "file:///" + JournalManager.journalPath

                                onAccepted: {
                                    var path = pathDialog.selectedFolder.toString();
                                    path = path.replace(/^(file:\/{3})|(file:)/, "");
                                    path = decodeURIComponent(path);

                                    JournalManager.setJournalPath(path);
                                }
                            }
                        }
                    }

                    DesignEffect {
                        effects: [
                            DesignDropShadow {
                            }
                        ]
                    }
                }

                Rectangle {
                    width: parent.width
                    height: parent.height / 5
                    radius: width / 50
                    color: "#2a2a2a"

                    Text {
                        text: "Clear Cache: "
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        fontSizeMode: Text.Fit
                        font.family: antonFont.name
                        height: parent.height
                        width: parent.width / 3
                        color: "white"
                        font.pixelSize: parent.width / 16
                        leftPadding: parent.width / 16
                    }

                    RButton {
                        id: clickerCacher
                        width: parent.width / 2
                        height: parent.height / 1.5
                        bcolor: "#2e2e2e"
                        hoverColor: "#3d3d3d"
                        pressedColor: "#4d4d4d"
                        anchors.right: parent.right
                        anchors.rightMargin: parent.width / 16
                        anchors.verticalCenter: parent.verticalCenter
                        radii: parent.radius

                        onTapped: SupabaseClient.removeCache()

                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            border.width: clickerCacher.parent.width / 200
                            border.color: "#333333"
                            radius: parent.radii
                        }

                        Text {
                            id: sizeItself
                            font.family: antonFont.name
                            font.pixelSize: parent.width / 16
                            color: "#a0a0a0"
                            text: SupabaseClient.cacheSize
                            anchors.centerIn: parent
                        }
                    }

                    DesignEffect {
                        effects: [
                            DesignDropShadow {
                            }
                        ]
                    }
                }
            }
        }
    }
}
