import QtQuick
import QtQuick.Controls
import QtQuick.Studio.DesignEffects
import QtQuick.Layouts

Window {
    id: root
    width: 500
    height: 300
    visible: JournalManager.displayValue !== 1
    objectName: "PopupWindow"

    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool

    property var mapData: ({})

    readonly property var screenGeo: (root.screen && root.screen.availableGeometry)
                                     ? root.screen.availableGeometry
                                     : { x: 0, y: 0, width: Screen.width, height: Screen.height }

    readonly property int shownY: (screenGeo.y + screenGeo.height) - height - height / 20
    readonly property int hiddenY: (screenGeo.y + screenGeo.height) + 10
    readonly property int shownX: screenGeo.x + width / 20

    Connections {
        target: SpanshPlotter

        function onShowWindow(data) {
            if(JournalManager.displayValue === 1) return;
            var spansh = data.spansh
            var edsm = data.edsm

            if(edsm.timestamp === "hidethispls") {
                bodyCountedsm.opacity = 0
                dateEdsm.opacity = 0
                cmdr.opacity = 0
                planetedsm.opacity = 0
                datelogoEdsm.opacity = 0
                useredsm.opacity = 0
            } else {
                bodyCountedsm.opacity = 1
                dateEdsm.opacity = 1
                cmdr.opacity = 1
                planetedsm.opacity = 1
                datelogoEdsm.opacity = 1
                useredsm.opacity = 1
            }

            edsmDescription.text = edsm.description
            bodyCountedsm.text = edsm.body_count
            cmdr.text = edsm.commander
            dateEdsm.text = edsm.timestamp


            // spansh

            if(spansh.timestamp === "hidethispls") {
                bodyCountSpansh.opacity = 0
                dateSpansh.opacity = 0
                planet.opacity = 0
                datelogoSpansh.opacity = 0
            } else {
                bodyCountSpansh.opacity = 1
                dateSpansh.opacity = 1
                planet.opacity = 1
                datelogoSpansh.opacity = 1
            }

            spanshDescription.text = spansh.description
            dateSpansh.text = spansh.timestamp
            bodyCountSpansh.text = spansh.body_count

            showOverlay()
            timer.restart()
        }
    }

    x: shownX
    y: hiddenY

    Timer {
        id: timer
        repeat: false
        interval: 5000
        onTriggered: hideOverlay()
    }

    Behavior on y {
        enabled: SpanshPlotter.myValue !== 1
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    FontLoader {
        id: antonFont
        source: "fonts/Anton-Regular.ttf"
    }

    FontLoader {
        id: loraFont
        source: "fonts/Lora-VariableFont_wght.ttf"
    }

    function showOverlay() {
        y = shownY
        raise()
    }

    function hideOverlay() {
        y = hiddenY
    }

    color: "transparent"

    Rectangle {
        id: overlay
        color: "#d41e1e1e"
        anchors.fill: parent
        radius: width / 20

        Rectangle {
            id: borderColor
            color: "transparent"
            border.width: 5
            border.color: "orange"
            width: parent.width - parent.width / 20
            height: parent.height - parent.height / 20
            anchors.centerIn: parent
            radius: width / 20
        }

        Item {
            id: systemChecker
            anchors.fill: parent

            Column {
                id: dataorsomethingidfk
                width: parent.width - parent.width / 20
                height: parent.height - parent.height / 20
                anchors.centerIn: parent
                spacing: 0
                leftPadding: parent.width / 30
                topPadding: parent.height / 30

                Item {
                    width: parent.width - parent.width / 20 - parent.leftPadding
                    height: parent.height / 2.2

                    Image {
                        id: edsm
                        width: parent.width / 6
                        anchors.verticalCenter: parent.verticalCenter
                        source: "images/edsm.png"
                        fillMode: Image.PreserveAspectFit

                        DesignEffect {
                            effects: [
                                DesignDropShadow {
                                }
                            ]
                        }
                    }

                    Text {
                        id: edsmDescription
                        width: implicitWidth
                        height: implicitHeight
                        color: "#949494"
                        text: "Skaude AA-A h294 is present in EDSM."
                        font.pixelSize: parent.width / 12
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.NoWrap
                        fontSizeMode: Text.Fit
                        anchors.left: edsm.right
                        anchors.right: parent.right
                        anchors.leftMargin: parent.width / 50
                        font.family: loraFont.name

                        DesignEffect {
                            effects: [
                                DesignDropShadow {
                                }
                            ]
                        }
                    }

                    Item {
                        id: edsmBottomLine
                        anchors.left: edsm.right
                        anchors.right: parent.right
                        anchors.top: edsmDescription.bottom
                        height: Math.max(bodyCountedsm.implicitHeight, cmdr.implicitHeight)

                        Item {
                            id: oneThird
                            width: 30
                            height: 0
                            x: parent.width / 3
                        }
                        Item {
                            id: twoThirds
                            width: 30
                            height: 0
                            x: (parent.width * 2) / 3
                        }

                        Text {
                            id: bodyCountedsm
                            color: "#e09232"
                            text: "(???)"
                            font.pixelSize: parent.width / 15
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            anchors.left: parent.left
                            anchors.right: oneThird.left
                            anchors.verticalCenter: parent.verticalCenter
                            fontSizeMode: Text.Fit
                            font.family: loraFont.name

                            DesignEffect {
                                effects: [
                                    DesignDropShadow {
                                    }
                                ]
                            }
                        }

                        Text {
                            id: dateEdsm
                            color: "#f4d6a7"
                            text: "???"
                            font.pixelSize: parent.width / 15
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            anchors.left: oneThird.left
                            anchors.right: twoThirds.left
                            anchors.verticalCenter: parent.verticalCenter
                            fontSizeMode: Text.Fit
                            font.family: loraFont.name

                            DesignEffect {
                                effects: [
                                    DesignDropShadow {
                                    }
                                ]
                            }
                        }

                        Text {
                            id: cmdr
                            color: "#f9c27f"
                            text: "Unknown"
                            font.pixelSize: parent.width / 15
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            anchors.left: twoThirds.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            fontSizeMode: Text.Fit
                            font.family: loraFont.name

                            DesignEffect {
                                effects: [
                                    DesignDropShadow {
                                    }
                                ]
                            }
                        }

                        Image {
                            id: planetedsm
                            width: parent.width / 12
                            source: "images/planet-line.svg"
                            fillMode: Image.PreserveAspectFit
                            anchors.top: bodyCountedsm.bottom
                            anchors.topMargin: width / 5
                            anchors.horizontalCenter: bodyCountedsm.horizontalCenter

                            DesignEffect {
                                effects: [
                                    DesignDropShadow {
                                        color: "#a5000000"
                                        offsetY: 0
                                        blur: 16
                                    }
                                ]
                            }
                        }

                        Image {
                            id: datelogoEdsm
                            width: parent.width / 12
                            source: "images/calendar-event-line.svg"
                            fillMode: Image.PreserveAspectFit
                            anchors.top: dateEdsm.bottom
                            anchors.topMargin: width / 5
                            anchors.horizontalCenter: dateEdsm.horizontalCenter

                            DesignEffect {
                                effects: [
                                    DesignDropShadow {
                                        color: "#a5000000"
                                        offsetY: 0
                                        blur: 16
                                    }
                                ]
                            }
                        }

                        Image {
                            id: useredsm
                            width: parent.width / 12
                            source: "images/orange-user.svg"
                            fillMode: Image.PreserveAspectFit
                            anchors.top: cmdr.bottom
                            anchors.horizontalCenter: cmdr.horizontalCenter
                            anchors.topMargin: width / 5

                            DesignEffect {
                                effects: [
                                    DesignDropShadow {
                                        color: "#a5000000"
                                        offsetY: 0
                                        blur: 16
                                    }
                                ]
                            }
                        }
                    }
                }

                Item {
                    width: parent.width - parent.width / 20 - parent.leftPadding
                    height: parent.height / 2.2

                    Image {
                        id: spansh
                        width: parent.width / 6
                        anchors.verticalCenter: parent.verticalCenter
                        source: "images/spansh.png"
                        fillMode: Image.PreserveAspectFit

                        DesignEffect {
                            effects: [
                                DesignDropShadow {
                                }
                            ]
                        }
                    }

                    Text {
                        id: spanshDescription
                        width: implicitWidth
                        height: implicitHeight
                        color: "#ffffff"
                        text: "Skaude AA-A h294 is present in Spansh."
                        font.pixelSize: parent.width / 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.NoWrap
                        fontSizeMode: Text.Fit
                        anchors.left: spansh.right
                        anchors.right: parent.right
                        anchors.leftMargin: parent.width / 50
                        font.family: loraFont.name

                        DesignEffect {
                            effects: [
                                DesignDropShadow {
                                }
                            ]
                        }
                    }

                    Text {
                        id: bodyCountSpansh
                        width: implicitWidth
                        height: implicitHeight
                        color: "#e09232"
                        text: "(???)"
                        font.pixelSize: parent.width / 15
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        anchors.left: spansh.right
                        anchors.right: spanshDescription.horizontalCenter
                        anchors.top: spanshDescription.bottom
                        font.family: loraFont.name

                        DesignEffect {
                            effects: [
                                DesignDropShadow {
                                }
                            ]
                        }
                    }

                    Text {
                        id: dateSpansh
                        width: implicitWidth
                        height: implicitHeight
                        color: "#e09232"
                        text: "???"
                        font.pixelSize: parent.width / 15
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        anchors.left: spanshDescription.horizontalCenter
                        anchors.right: parent.right
                        anchors.top: spanshDescription.bottom
                        font.family: loraFont.name

                        DesignEffect {
                            effects: [
                                DesignDropShadow {
                                }
                            ]
                        }
                    }

                    Image {
                        id: datelogoSpansh
                        width: parent.width / 12
                        source: "images/calendar-event-line.svg"
                        fillMode: Image.PreserveAspectFit
                        anchors.top: dateSpansh.bottom
                        anchors.topMargin: width / 5
                        anchors.horizontalCenter: dateSpansh.horizontalCenter

                        DesignEffect {
                            effects: [
                                DesignDropShadow {
                                    color: "#a5000000"
                                    offsetY: 0
                                    blur: 16
                                }
                            ]
                        }
                    }

                    Image {
                        id: planet
                        width: parent.width / 12
                        source: "images/planet-line.svg"
                        fillMode: Image.PreserveAspectFit
                        anchors.top: bodyCountSpansh.bottom
                        anchors.topMargin: width / 5
                        anchors.horizontalCenter: bodyCountSpansh.horizontalCenter

                        DesignEffect {
                            effects: [
                                DesignDropShadow {
                                    color: "#a5000000"
                                    offsetY: 0
                                    blur: 16
                                }
                            ]
                        }
                    }
                }
            }
        }
    }
}
