import QtQuick
import QtQuick.Controls
import Explorarium.Native 1.0
import QtQuick.Studio.DesignEffects

Item {
    id: root
    width: 1920
    height: 1080

    property alias actualPopup: galaxyMapPopup

    signal requestSystemView(string systemName)

    function open() {
        galaxyMapPopup.open()
    }

    Popup {
        id: galaxyMapPopup
        width: parent.width
        height: parent.height
        modal: true
        focus: true
        anchors.centerIn: parent

        enter: Transition {
            OpacityAnimator {
                target: galaxyPopupbg
                to: 1
                duration: 350
            }
            OpacityAnimator {
                target: galaxyHolder
                to: 1
                duration: 350
            }
        }

        exit: Transition {
            OpacityAnimator {
                target: galaxyPopupbg
                to: 0
                duration: 350
            }
            OpacityAnimator {
                target: galaxyHolder
                to: 0
                duration: 350
            }
        }

        background: Rectangle {
            id: galaxyPopupbg
            opacity: 0
            gradient: Gradient {
                GradientStop { position: 0; color: "#2a2a2a" }
                GradientStop { position: 1; color: "#1a1a1a" }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons
                hoverEnabled: true
                onWheel: (wheel) => wheel.accepted = true
            }
        }

        Rectangle {
            id: galaxyHolder
            anchors.fill: parent
            color: "transparent"
            opacity: 0

            Item {
                id: viewport
                anchors.fill: parent
                clip: true
                z: 1000

                Rectangle {
                    id: hangar
                    width: parent.width
                    height: parent.height / 5
                    gradient: Gradient {
                        GradientStop { position: 0; color: "#2a2a2a" }
                        GradientStop { position: 1; color: "#1a1a1a" }
                    }
                    z: 150

                    readonly property real barFontSize: height * 0.25

                    y: -height

                    RButton {
                        id: closeArea
                        bcolor: "#2e2e2e"
                        hoverColor: "#2a2a2a"
                        pressedColor: "#1a1a1a"
                        width: height
                        height: parent.height
                        radii: 0

                        onTapped: {
                            galaxyMapPopup.close()
                        }

                        Image {
                            source: "images/close-circle-line.svg"
                            fillMode: Image.PreserveAspectFit
                            height: parent.height / 2
                            anchors.centerIn: parent
                        }
                    }

                    Rectangle {
                        id: seperator1
                        width: parent.width / 2000
                        height: parent.height * 0.8
                        color: "transparent"
                        anchors.left: closeArea.right
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        id: settings
                        width: parent.width / 5
                        height: parent.height
                        color: "transparent"
                        anchors.left: seperator1.right
                        anchors.leftMargin: parent.width / 25

                        Item {
                            id: starsize
                            width: parent.width / 1.1
                            height: parent.height / 4
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            anchors.topMargin: parent.height / 50

                            Text {
                                id: starSizeText
                                width: parent.width / 3
                                height: parent.height
                                text: "Star Size: "
                                font.family: antonFont.name
                                color: "#767676"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                font.pixelSize: parent.height / 2
                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter
                            }

                            Slider {
                                id: slider
                                value: galaxyMap.starSize / 100
                                onMoved: galaxyMap.starSize = value * 100
                                width: parent.width / 3
                                height: width
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: starSizeText.right
                            }
                        }
                    }

                    Rectangle {
                        id: seperator3
                        width: parent.width / 2000
                        height: parent.height * 0.8
                        color: "#3e3e3e"
                        anchors.left: filters.right
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        id: statistics
                        width: parent.width / 5
                        height: parent.height
                        color: "transparent"
                        anchors.left: seperator3.right

                        Flow {
                            spacing: parent.height / 25
                            width: parent.width
                            height: parent.height
                            leftPadding: width / 16
                            topPadding: height / 20

                            Text {
                                id: currentSystem
                                color: "#FFFFFF"
                                text: "Current System: " + JournalManager.location
                                font.family: antonFont.name
                                font.pixelSize: parent.width / 15
                            }

                            Text {
                                id: starsLoaded
                                color: "#FFFFFF"
                                text: "Stars Loaded: " + galaxyMap.starsLoaded
                                font.family: antonFont.name
                                font.pixelSize: parent.width / 15
                            }
                        }
                    }

                    Rectangle {
                        id: seperator2
                        width: parent.width / 2000
                        height: parent.height * 0.8
                        color: "#3e3e3e"
                        anchors.left: settings.right
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        id: filters
                        width: parent.width / 5
                        height: parent.height
                        color: "transparent"
                        anchors.left: seperator2.right

                        Item {
                            id: regions
                            width: parent.width / 1.1
                            height: parent.height / 4
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: comboBoxBg.bottom
                            anchors.topMargin: parent.height / 5

                            Text {
                                id: regionText
                                width: parent.width / 3
                                height: parent.height
                                text: "Regions: "
                                font.family: antonFont.name
                                color: "#767676"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: parent.width / 5
                                font.pixelSize: parent.height / 2
                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter
                            }

                            RButton {
                                id: regionButton
                                width: parent.width / 5
                                height: width
                                bcolor: "#2e2e2e"
                                hoverColor: "#2a2a2a"
                                pressedColor: "#1e1e1e"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: regionText.right
                                radii: width / 5

                                property bool region: false

                                onTapped: {
                                    if(!region) {
                                        region = !region
                                        topleft.source = "images/galaxyRegion_0_0.jpg"
                                        topright.source = "images/galaxyRegion_0_1.jpg"
                                        bottomleft.source = "images/galaxyRegion_1_0.jpg"
                                        bottomright.source = "images/galaxyRegion_1_1.jpg"
                                    } else {
                                        region = !region
                                        topleft.source = "images/galaxyDefault_0_0.jpeg"
                                        topright.source = "images/galaxyDefault_0_1.jpeg"
                                        bottomleft.source = "images/galaxyDefault_1_0.jpeg"
                                        bottomright.source = "images/galaxyDefault_1_1.jpeg"
                                    }
                                }

                                Rectangle {
                                    id: checkbox
                                    width: parent.width
                                    height: width
                                    anchors.left: parent.left
                                    anchors.leftMargin: parent.width / 30
                                    anchors.verticalCenter: parent.verticalCenter
                                    radius: width / 5
                                    color: "transparent"
                                    border.width: width / 10
                                    border.color: "dark grey"
                                    z: 1

                                    Image {
                                        id: checkmarkopacity
                                        source: "images/check-line.svg"
                                        fillMode: Image.PreserveAspectFit
                                        anchors.centerIn: parent
                                        width: parent.width
                                        opacity: regionButton.region
                                    }
                                }
                            }
                        }

                        RButton {
                            id: comboBoxBg
                            width: parent.width / 1.1
                            height: parent.height / 4
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            anchors.topMargin: (parent.height / 10) / 2
                            pressedColor: "#c4c4c4"
                            hoverColor: "#626262"
                            radii: width / 100
                            bcolor: "#4f4f4f"
                            z: 4

                            property bool comboEnabled: false

                            onTapped: {
                                if(!openBox.running && !closeBox.running) {
                                    if(comboEnabled === false) {
                                        comboEnabled = !comboEnabled
                                        frameOpenThing.opacity = 1
                                        comboBoxImg.rotation = 180
                                        openBox.start()
                                    } else {
                                        comboEnabled = !comboEnabled
                                        comboBoxImg.rotation = 0
                                        closeBox.start()
                                    }
                                }
                            }

                            Image {
                                id: comboBoxImg
                                height: parent.height
                                source: "images/arrow-down-s-line.svg"
                                fillMode: Image.PreserveAspectFit
                                anchors.right: parent.right
                                anchors.rightMargin: height / 10
                            }
                        }

                        Rectangle {
                            id: filterBorder
                            width: comboBoxBg.width + parent.width / 50
                            height: comboBoxBg.height + parent.height / 40
                            color: "#5f5f5f"
                            x: comboBoxBg.x - (parent.width / 50) / 2
                            y: comboBoxBg.y - (parent.height / 40) / 2
                            z: 2
                            radius: comboBoxBg.radii

                            PropertyAnimation {
                                id: openBorder
                                target: filterBorder
                                property: "height"
                                to: comboBoxBg.height * 6 + filterHolder.height / 40
                                duration: 350
                            }

                            PropertyAnimation {
                                id: closeBorder
                                target: filterBorder
                                property: "height"
                                to: comboBoxBg.height + filterHolder.height / 40
                                duration: 350
                            }
                        }

                        Rectangle {
                            id: frameOpenThing
                            width: comboBoxBg.width // this never changes
                            height: comboBoxBg.height
                            PropertyAnimation {
                                id: openBox
                                target: frameOpenThing
                                property: "height"
                                to: comboBoxBg.height * 6
                                duration: 350
                            }

                            PropertyAnimation {
                                id: closeBox
                                target: frameOpenThing
                                property: "height"
                                to: comboBoxBg.height
                                duration: 350

                                onFinished: {
                                    frameOpenThing.opacity = 0
                                }
                            }

                            anchors.horizontalCenter: comboBoxBg.horizontalCenter
                            y: comboBoxBg.y
                            z: 3
                            radius: comboBoxBg.radii
                            opacity: 0
                            color: comboBoxBg.bcolor

                            ListView {
                                id: filterScroll
                                spacing: parent.height / 40
                                height: parent.height - (parent.height / 6)
                                width: parent.width
                                anchors.top: parent.top
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.topMargin: parent.height / 6
                                clip: true
                                reuseItems: true

                                ScrollBar.vertical: ScrollBar {
                                    policy: ScrollBar.AsNeeded
                                }

                                Component {
                                    id: filterComponent

                                    RButton {
                                        id: clickComponent
                                        width: filterScroll.width
                                        enabled: frameOpenThing.opacity === 1
                                        height: filterScroll.height / 5
                                        radii: 0
                                        bcolor: "grey"
                                        hoverColor: "dark orange"
                                        pressedColor: "orange"

                                        onTapped: {
                                            galaxyMap.toggleCategory(model.category_name)
                                        }

                                        property string currentCategoryUrl: model.category_image

                                        Rectangle {
                                            id: checkbox
                                            width: parent.width / 9
                                            height: width
                                            anchors.left: parent.left
                                            anchors.leftMargin: parent.width / 30
                                            anchors.verticalCenter: parent.verticalCenter
                                            radius: width / 5
                                            color: "transparent"
                                            border.width: width / 10
                                            border.color: "dark grey"
                                            z: 1

                                            Image {
                                                id: checkmarkopacity
                                                source: "images/check-line.svg"
                                                fillMode: Image.PreserveAspectFit
                                                anchors.centerIn: parent
                                                width: parent.width
                                                opacity: !galaxyMap.disallowedCategories.includes(model.category_name) ? 1 : 0
                                            }
                                        }

                                        Text {
                                            id: categoryNameComponent
                                            font.family: antonFont.name
                                            font.pixelSize: parent.width
                                            horizontalAlignment: Text.AlignLeft
                                            verticalAlignment: Text.AlignVCenter
                                            fontSizeMode: Text.Fit
                                            anchors.left: checkbox.right
                                            width: parent.width - (checkbox.width) - leftPadding * 2
                                            height: parent.height
                                            color: "white"
                                            text: model.category_name
                                            leftPadding: parent.width / 40
                                            z: 1

                                            DesignEffect {
                                                effects: [
                                                    DesignDropShadow {
                                                    }
                                                ]
                                            }
                                        }

                                        Image {
                                            id: testbackgroundimage
                                            source: model.category_image
                                            cache: false
                                            fillMode: Image.PreserveAspectCrop
                                            width: parent.width
                                            height: parent.height
                                            opacity: 0.5
                                        }
                                    }
                                }
                                model: SupabaseClient.categoryModel
                                delegate: filterComponent
                            }
                        }
                    }



                    Behavior on y { NumberAnimation { duration: 250 } }
                }

                RButton {
                    id: openHangar
                    width: parent.width / 15
                    height: parent.height / 20
                    anchors.top: hangar.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: width / 100
                    bcolor: "#1e1e1e"
                    hoverColor: "#2e2e2e"
                    pressedColor: "#3e3e3e"

                    property bool isOpen: false

                    onTapped: {
                        if(!isOpen) {
                            isOpen = !isOpen
                            arrowImage.rotation = 180
                            hangar.y = 0
                        } else {
                            isOpen = !isOpen
                            arrowImage.rotation = 0
                            hangar.y = -hangar.height
                        }
                    }

                    Image {
                        id: arrowImage
                        height: parent.height
                        source: "images/arrow-down-s-line.svg"
                        fillMode: Image.PreserveAspectFit
                        anchors.centerIn: parent
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
                        world.scale = 0.1
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

            Rectangle {
                id: world
                width: 20000
                height: 20000
                color: "black"
                scale: 0.1

                transformOrigin: Item.TopLeft

                readonly property real solX: 10000.0
                readonly property real solY: 12500.0
                readonly property real lyScale: 0.1
                property real xCenter: (viewport.width - (width * scale)) / 2
                property real yCenter: (viewport.height - (height * scale)) / 2

                x: xCenter
                y: yCenter

                Grid {
                    id: galaxy
                    anchors.centerIn: parent
                    rows: 2
                    columns: 2
                    width: 9000
                    height: 9000
                    spacing: 0

                    Image {
                        id: topleft
                        width: 4500; height: 4500
                        source: "images/galaxyDefault_0_0.jpeg"
                        asynchronous: true
                    }

                    Image {
                        id: topright
                        width: 4500; height: 4500
                        source: "images/galaxyDefault_0_1.jpeg"
                        asynchronous: true
                    }

                    Image {
                        id: bottomleft
                        width: 4500; height: 4500
                        source: "images/galaxyDefault_1_0.jpeg"
                        asynchronous: true
                    }

                    Image {
                        id: bottomright
                        width: 4500; height: 4500
                        source: "images/galaxyDefault_1_1.jpeg"
                        asynchronous: true
                    }
                }

                Image {
                    id: lmc
                    source: "images/LargeMagellanicCloud.png"
                    fillMode: Image.PreserveAspectFit
                    width: 2000
                    height: width
                    opacity: 0.8
                    x: world.solX + (60000 * world.lyScale) - (width / 2)
                    y: world.solY - (height / 2)
                    rotation: 36
                    asynchronous: true
                }

                Image {
                    id: smc
                    source: "images/SmallMagellanicCloud.png"
                    fillMode: Image.PreserveAspectFit
                    width: 1400
                    height: width
                    opacity: 0.7

                    x: world.solX + (55000 * world.lyScale) - (width / 2)
                    y: world.solY - (20000 * world.lyScale) - (height / 2)
                    rotation: 90
                    asynchronous: true
                }

                DragHandler {
                    target: world
                }

                WheelHandler {
                    target: world
                    property: "scale"
                }
            }

            GalaxyMap {
                id: galaxyMap
                anchors.fill: parent
                systems: SupabaseClient.rawSystems

                viewX: world.x
                viewY: world.y
                zoomLevel: world.scale

                mapWidth: world.width
                mapHeight: world.height

                onSystemRightClicked: (systemName) => {
                    root.requestSystemView(systemName)
                }

                onSystemHovered: (systemName, category, x, y, active) => {
                    if (active) {
                        tooltipText.text = systemName
                        tooltip.targetX = x
                        tooltip.targetY = y
                        tooltip.visible = true
                        categoryMessage.text = category


                        selectionRing.x = x
                        selectionRing.y = y
                        selectionRing.visible = true
                    } else {
                        tooltip.visible = false
                        selectionRing.visible = false
                    }
                }
            }

            Rectangle {
                id: selectionRing
                width: 20
                height: 20
                radius: 10
                color: "transparent"
                border.color: "#00BFFF"
                border.width: 2
                visible: false
                z: 99

                property real targetX: 0
                property real targetY: 0

                x: world.x + (targetX * world.scale) - (width / 2)
                y: world.y + (targetY * world.scale) - (height / 2)
            }

            Rectangle {
                id: tooltip
                visible: false
                width: layoutColumn.width + 40
                height: layoutColumn.height + 20
                color: "#2e2e2e"
                radius: 4
                border.color: "#555"
                border.width: 1
                z: 150

                property real targetX: 0
                property real targetY: 0
                x: world.x + (targetX * world.scale) - (width / 2)
                y: world.y + (targetY * world.scale) - height - 20

                Column {
                    id: layoutColumn
                    anchors.centerIn: parent
                    spacing: 0
                    Image {
                        id: tooltipStarImage
                        source: "images/shining-fill.svg"
                        anchors.horizontalCenter: parent.horizontalCenter
                        fillMode: Image.PreserveAspectFit
                        height: 100
                        RotationAnimation {
                            target: tooltipStarImage
                            paused: !tooltip.visible
                            loops: -1
                            duration: 15000
                            property: "rotation"
                            running: true
                            to: 360
                        }
                    }
                    Text {
                        id: tooltipText
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "white"
                        font.family: antonFont.name
                        font.pixelSize: 38
                        text: "Hydrae Sector DQ-Y b4"
                    }
                    Text {
                        id: categoryMessage
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "#ffed8c"
                        font.family: antonFont.name
                        font.pixelSize: 28
                        text: "Colliding Rings"
                        visible: text !== ""
                    }
                    Text {
                        id: tip
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "#818181"
                        opacity: 1
                        font.family: antonFont.name
                        font.pixelSize: 13
                        text: "Right click to open system"
                    }
                }
            }

            Item {
                id: commanderDot
                visible: true
                width: 80
                height: 80
                z: 101

                scale: world.scale

                property real cmdrX: JournalManager.coordinates[0] || 0
                property real cmdrZ: JournalManager.coordinates[2] || 0

                property real universeX: 10000.0 + (cmdrX * 0.1)
                property real universeY: 12500.0 - (cmdrZ * 0.1)

                x: world.x + (universeX * world.scale) - (width / 2)
                y: world.y + (universeY * world.scale) - (height / 2)

                HoverHandler {
                    onHoveredChanged: {
                        if(hovered) {
                            cmdrTooltip.visible = true
                        } else {
                            cmdrTooltip.visible = false
                        }
                    }
                }

                Image {
                    id: selection
                    source: "images/selection.png"
                    fillMode: Image.PreserveAspectFit
                    width: parent.width * 1.2
                    anchors.bottom: dot.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    z: 1
                }

                Rectangle {
                   id: pulseRing
                   anchors.centerIn: parent
                   width: parent.width
                   height: parent.height
                   radius: width / 2
                   color: "transparent"
                   border.color: "#20fded"
                   border.width: 3
                   opacity: 0

                   SequentialAnimation {
                       running: true
                       loops: Animation.Infinite
                       PropertyAction { target: pulseRing; property: "scale"; value: 1.0 }
                       PropertyAction { target: pulseRing; property: "opacity"; value: 1.0 }
                       ParallelAnimation {
                           NumberAnimation { target: pulseRing; property: "scale"; to: 2.5; duration: 2000; easing.type: Easing.OutQuad }
                           NumberAnimation { target: pulseRing; property: "opacity"; to: 0.0; duration: 2000; easing.type: Easing.OutQuad }
                       }
                   }
               }

                Rectangle {
                    id: dot
                    width: parent.width
                    height: width
                    radius: width
                    color: "transparent"
                    border.color: "#20fded"
                    border.width: parent.width / 5
                }
            }

            Rectangle {
                id: cmdrTooltip
                visible: false
                width: cmdrColumn.width + 40
                height: cmdrColumn.height + 20
                color: "#2e2e2e"
                radius: 4
                border.color: "#555"
                border.width: 1
                z: 120

                x: commanderDot.x + (commanderDot.width / 2) - (width / 2)
                y: (commanderDot.y + commanderDot.height / 2) - ((commanderDot.height * commanderDot.scale) / 2) - height - 10

                Column {
                    id: cmdrColumn
                    anchors.centerIn: parent
                    spacing: 0
                    Image {
                        id: tooltipCmdrImage
                        source: "images/shining-fill.svg"
                        anchors.horizontalCenter: parent.horizontalCenter
                        fillMode: Image.PreserveAspectFit
                        height: 100
                        RotationAnimation {
                            target: tooltipCmdrImage
                            running: cmdrTooltip.visible
                            loops: -1
                            duration: 15000
                            property: "rotation"
                            to: 360
                        }
                    }
                    Text {
                        id: tooltipCmdrText
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "white"
                        font.family: antonFont.name
                        font.pixelSize: 38
                        text: JournalManager.location ? JournalManager.location : "Unknown"
                    }
                    Text {
                        id: position
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "#ffed8c"
                        font.family: antonFont.name
                        font.pixelSize: 28
                        text: "Current Position"
                        visible: text !== ""
                    }
                }
            }
        }
    }
}
