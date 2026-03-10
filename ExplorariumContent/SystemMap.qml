import QtQuick
import QtQuick.Controls
import Qt.labs.animation
import QtQuick.Shapes

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "black"

    Behavior on opacity { NumberAnimation { duration: 500}}
    property real sidebarwidth: 3.5

    FontLoader {
        id: antonFont
        source: "fonts/Anton-Regular.ttf"
    }

    FontLoader {
        id: loraFont
        source: "fonts/Lora-VariableFont_wght.ttf"
    }

    MouseArea {
        anchors.fill: parent
        onClicked: forceActiveFocus()
    }

    Rectangle {
        id: galaxyHolder
        anchors.fill: parent
        color: "transparent"
        opacity: 1

        Item {
            id: viewport
            anchors.fill: parent
            clip: true
            z: 1000

            Rectangle {
                id: world
                width: 20000
                height: 20000
                color: "black"
                scale: 1
                transformOrigin: Item.TopLeft

                property int gridSize: 100
                property int starCount: 2000

                DragHandler {
                    target: world
                }

                Repeater {
                    model: SpanshPlotter.nodesList

                    delegate: Item {
                        id: nodeContainer

                        Rectangle {
                            width: 50; height: 50
                            color: "transparent"
                            anchors.centerIn: parent
                            z: 9999
                            Text { text: modelData.name; anchors.centerIn: parent; color: "white"}
                        }

                        x: modelData.xPos
                        y: modelData.yPos
                        width: 400
                        height: 400

                        Shape {
                            anchors.fill: parent
                            visible: modelData.hasParent
                            z: -1

                            ShapePath {
                                strokeColor: "#a3a3a3"
                                strokeWidth: 3
                                fillColor: "transparent"
                                startX: nodeContainer.width / 2
                                startY: nodeContainer.height / 2

                                pathElements: PathLine {
                                    x: nodeContainer.width/2 + (modelData.parentX - modelData.xPos)
                                    y: nodeContainer.height/2 + (modelData.parentY - modelData.yPos)
                                }
                            }
                        }

                        NodeItem {
                            anchors.centerIn: parent

                            visible: modelData.type !== "Barycentre"
                            showRings: modelData.rings ? true : false
                            labelText: modelData.name
                            planetScale: modelData.superType === "Star" ? 1.5 : 1.0
                        }
                    }
                }

                Repeater {
                    model: world.width / world.gridSize
                    Rectangle {
                        width: 1 / world.scale
                        height: world.height
                        color: "grey"
                        opacity: 0.15
                        x: index * world.gridSize
                        y: 0
                    }
                }

                Repeater {
                    model: world.height / world.gridSize
                    Rectangle {
                        height: 1 / world.scale
                        width: world.width
                        color: "grey"
                        opacity: 0.15
                        y: index * world.gridSize
                        x: 0
                    }
                }

                Repeater {
                    model: world.starCount
                    Rectangle {
                        id: star
                        property real size: Math.random() * 3 + 1
                        width: size
                        height: size
                        radius: size / 2
                        color: "white"

                        opacity: Math.random() * 0.8 + 0.2

                        Component.onCompleted: {
                            x = Math.random() * world.width
                            y = Math.random() * world.height
                        }
                    }
                }

                WheelHandler {
                    target: world
                    property: "scale"
                }

                BoundaryRule on x {
                    maximum: 0
                    minimum: viewport.width - (world.width * world.scale)
                }

                BoundaryRule on y {
                    maximum: 0
                    minimum: viewport.height - (world.height * world.scale)
                }

                BoundaryRule on scale {
                    maximum: 5.0
                    minimum: 0.5
                }

                property real xCenter: (viewport.width - (width * scale)) / 2
                property real yCenter: (viewport.height - (height * scale)) / 2

                Component.onCompleted: {
                    x = xCenter
                    y = yCenter
                }
            }

            RButton {
                width: parent.width / 20
                height: width
                radii: width / 10
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: parent.width / 500
                bcolor: "#1e1e1e"
                hoverColor: "#2e2e2e"
                pressedColor: "#3e3e3e"

                onTapped: {
                    world.scale = 1.0
                    world.x = world.xCenter
                    world.y = world.yCenter
                }

                Image {
                    anchors.fill: parent
                    source: "images/focus-3-line.svg"
                    fillMode: Image.PreserveAspectFit
                }
            }
        }
    }
}
