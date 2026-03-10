import QtQuick
import QtQuick.Controls

Item {
    id: root
    width: 500
    height: 500

    property color bcolor: "#ff8a8a"
    property color pressedColor: "dark cyan"
    property color hoverColor: "#8c0000"
    property bool canHover: true
    property bool canClick: true
    property int animationDuration: 50
    property int radii: 50

    signal hovered()
    signal tapped()

    onBcolorChanged: {
        recta.color = bcolor
    }

    Rectangle {
        id: recta
        anchors.fill: parent
        color: bcolor
        radius: radii

        // CA's, if called. Will animate based on duration and to: color

        ColorAnimation {
            target: recta
            id: onHovered
            property: "color"
            from: recta.color // From current color
            to: hoverColor
            duration: animationDuration
        }

        ColorAnimation {
            target: recta
            id: exitHovered
            property: "color"
            from: recta.color
            to: bcolor
            duration: animationDuration
        }


        // TapHandler {
        //     onPressedChanged: {
        //         if(root.canClick) {
        //             if(pressed) {
        //                 recta.color = pressedColor
        //             } else {
        //                 recta.color = bcolor
        //             }
        //         }
        //     }
        //     onTapped: {
        //         if (root.canClick) {
        //             root.tapped()
        //         }
        //     }
        // }
        // HoverHandler {
        //     onHoveredChanged: {
        //         if(canHover) {
        //             if(hovered) {
        //                 root.hovered()
        //                 onHovered.start()
        //             } else {
        //                 exitHovered.start()
        //             }
        //         }
        //     }
        // }

        MouseArea {
            id: mouseSense
            anchors.fill: parent
            enabled: root.canClick
            hoverEnabled: root.canHover
            preventStealing: true

            onPressed: {
                recta.color = root.pressedColor
            }

            onReleased: {
                if (containsMouse && root.canHover) {
                    recta.color = root.hoverColor
                } else {
                    recta.color = root.bcolor
                }
            }

            onClicked: {
                root.tapped()
            }

            onEntered: {
                if(root.canHover) {
                    root.hovered()
                    onHovered.start()
                }
            }

            onExited: {
                if(root.canHover) {
                    exitHovered.start()
                }
            }
        }
    }
}
