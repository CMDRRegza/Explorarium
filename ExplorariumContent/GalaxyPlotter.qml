import QtQuick
import QtQuick.Controls
import QtQuick.Studio.DesignEffects

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#2e2e2e"

    Behavior on opacity { NumberAnimation { duration: 500}}
    property real sidebarwidth: 3.5
    signal turnthisoff() // REMEMBER THIS

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
        id: leftSidebar
        color: "#1a1a1a"
        gradient: Gradient {
            GradientStop { position: 0; color: "#2a2a2a" }
            GradientStop { position: 1; color: "#1a1a1a" }
        }
        width: root.width / root.sidebarwidth
        height: root.height

        RButton {
            id: backbtn
            width: parent.width / 6
            height: parent.height / 12
            radii: 0
            canHover: false
            bcolor: "transparent"
            pressedColor: "dark orange"
            Image {
                id: image
                anchors.fill: parent
                source: "images/arrow-left-line.svg"
                fillMode: Image.PreserveAspectFit
            }

            onTapped: {
                turnthisoff()
            }
        }

        Column {
            width: parent.width
            height: parent.height - (parent.height / 11)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: parent.height / 11
            spacing: parent.height / 80

            TextField {
                id: sourceSystem
                width: parent.width - (parent.width / 12)
                height: parent.height / 15
                readonly property real h: parent.height / 15
                placeholderText: "Source System"

                leftPadding: h * 0.35
                rightPadding: h * 0.35
                topPadding: h * 0.22
                bottomPadding: h * 0.22

                anchors.horizontalCenter: parent.horizontalCenter
                color: "white"
                font.pixelSize: h * 0.42
                selectionColor: "#ff9a00"
                font.family: loraFont.name
                selectedTextColor: "white"

                placeholderTextColor: "#8bffdda0"

                background: Rectangle {
                    radius: sourceSystem.h * 0.35
                    color: "#1a1a1a88"
                    border.width: 2
                    border.color: sourceSystem.activeFocus ? "#1a1a1a" : "orange"

                    Behavior on border.color {
                        ColorAnimation { duration: 120 }
                    }
                }
            }

            RButton {
                id: setCurrentSystem
                width: parent.width - (parent.width / 12)
                height: parent.height / 20
                hoverColor: "#a45a00"
                pressedColor: "#834800"
                anchors.horizontalCenter: parent.horizontalCenter
                bcolor: "orange"

                onTapped: {
                    sourceSystem.text = JournalManager.location
                }

                Text {
                    color: "#ffffff"
                    anchors.centerIn: parent
                    text: "Set as current system"
                    font.pixelSize: parent.width / 18
                    font.family: loraFont.name
                }
            }

            RButton {
                id: flipSelection
                width: parent.width - (parent.width / 12)
                height: parent.height / 16
                hoverColor: "#363636"
                pressedColor: "#2e2e2e"
                anchors.horizontalCenter: parent.horizontalCenter
                bcolor: "#595959"

                onTapped: {
                    var source = sourceSystem.text
                    var dest = destination.text
                    sourceSystem.text = dest
                    destination.text = source
                }

                Text {
                    id: reversetext
                    color: "#ffffff"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: -flipicon.width / 1.5
                    text: "Reverse"
                    font.pixelSize: parent.width / 18
                    font.family: loraFont.name
                }

                Image {
                    id: flipicon
                    source: "images/arrow-left-right-line.svg"
                    fillMode: Image.PreserveAspectFit
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: reversetext.width / 2
                    width: height
                    height: parent.height / 1.4
                }
            }

            TextField {
                id: destination
                width: parent.width - (parent.width / 12)
                height: parent.height / 15
                readonly property real h: parent.height / 15
                placeholderText: "Destination System"

                leftPadding: h * 0.35
                rightPadding: h * 0.35
                topPadding: h * 0.22
                bottomPadding: h * 0.22

                anchors.horizontalCenter: parent.horizontalCenter
                color: "white"
                font.pixelSize: h * 0.42
                selectionColor: "#ff9a00"
                font.family: loraFont.name
                selectedTextColor: "white"

                placeholderTextColor: "#8bffdda0"

                background: Rectangle {
                    radius: destination.h * 0.35
                    color: "#1a1a1a88"
                    border.width: 2
                    border.color: destination.activeFocus ? "#1a1a1a" : "orange"

                    Behavior on border.color {
                        ColorAnimation { duration: 120 }
                    }
                }
            }

            Rectangle {
                id: cargo
                width: parent.width - (parent.width / 12)
                height: parent.height / 15
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: true
                color: "#2a2a2a"
                border.width: 2
                border.color: "#464646"
                radius: height * 0.35
                Text {
                    id: cargoText
                    color: "white"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: parent.width / 30
                    text: "Cargo"
                    font.pixelSize: parent.width / 18
                    font.family: loraFont.name
                }

                TextField {
                    id: cargoNum
                    width: parent.width / 2
                    height: parent.height
                    readonly property real h: parent.height
                    placeholderText: "Cargo"
                    validator: IntValidator { bottom: 0; top: 2000 }
                    inputMethodHints: Qt.ImhDigitsOnly
                    text: "0"

                    onTextChanged: {
                        if (!acceptableInput && text !== "") {
                            text = Math.min(Math.max(parseInt(text), 0), 2000).toString()
                        }
                    }

                    leftPadding: h * 0.35
                    rightPadding: h * 0.35
                    topPadding: h * 0.22
                    bottomPadding: h * 0.22

                    anchors.verticalCenter: parent.verticalCenter

                    anchors.right: parent.right
                    color: "white"
                    font.pixelSize: h * 0.42
                    selectionColor: "#ff9a00"
                    font.family: loraFont.name
                    selectedTextColor: "white"

                    background: Rectangle {
                        radius: cargoNum.h * 0.35
                        color: "#1a1a1a88"
                        border.width: 2
                        border.color: cargoNum.activeFocus ? "#1a1a1a" : "orange"

                        Behavior on border.color {
                            ColorAnimation { duration: 120 }
                        }
                    }
                }
            }

            Rectangle {
                id: reserveFuel
                width: parent.width - (parent.width / 12)
                height: parent.height / 15
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: true
                color: "#2a2a2a"
                border.width: 2
                border.color: "#464646"
                radius: height * 0.35
                Text {
                    id: reserveFuelText
                    color: "white"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: parent.width / 30
                    text: "Reserve Fuel (t)"
                    font.pixelSize: parent.width / 18
                    font.family: loraFont.name
                }

                TextField {
                    id: reserveFuelNum
                    width: parent.width / 2
                    height: parent.height
                    readonly property real h: parent.height
                    placeholderText: "Reserve Fuel"
                    validator: IntValidator { bottom: 0; top: 32 }
                    inputMethodHints: Qt.ImhDigitsOnly
                    text: "0"

                    onTextChanged: {
                        if (!acceptableInput && text !== "") {
                            text = Math.min(Math.max(parseInt(text), 0), 32).toString()
                        }
                    }

                    leftPadding: h * 0.35
                    rightPadding: h * 0.35
                    topPadding: h * 0.22
                    bottomPadding: h * 0.22

                    anchors.verticalCenter: parent.verticalCenter

                    anchors.right: parent.right
                    color: "white"
                    font.pixelSize: h * 0.42
                    selectionColor: "#ff9a00"
                    font.family: loraFont.name
                    selectedTextColor: "white"

                    background: Rectangle {
                        radius: reserveFuelNum.h * 0.35
                        color: "#1a1a1a88"
                        border.width: 2
                        border.color: reserveFuelNum.activeFocus ? "#1a1a1a" : "orange"

                        Behavior on border.color {
                            ColorAnimation { duration: 120 }
                        }
                    }
                }
            }

            Rectangle {
                id: alreadysupercharged
                width: parent.width - (parent.width / 12)
                height: parent.height / 20
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: true
                color: "#2a2a2a"
                border.width: 2
                border.color: "#464646"
                radius: height * 0.35

                property bool yes: false

                TapHandler {
                    onTapped: {
                        alreadysupercharged.yes = !alreadysupercharged.yes
                    }
                }

                Rectangle {
                    width: parent.width / 12
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
                        source: "images/check-line.svg"
                        fillMode: Image.PreserveAspectFit
                        anchors.centerIn: parent
                        width: parent.width
                        opacity: alreadysupercharged.yes ? 1 : 0
                    }
                }

                Text {
                    color: "white"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: parent.width / 20 + (parent.width / 9)
                    text: "Already Supercharged?"
                    fontSizeMode: Text.Fit
                    font.pixelSize: parent.width / 16
                    font.family: loraFont.name
                }
            }

            Rectangle {
                id: usesupercharge
                width: parent.width - (parent.width / 12)
                height: parent.height / 20
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: true
                color: "#2a2a2a"
                border.width: 2
                border.color: "#464646"
                radius: height * 0.35

                property bool yes: false

                TapHandler {
                    onTapped: {
                        usesupercharge.yes = !usesupercharge.yes
                    }
                }

                Rectangle {
                    width: parent.width / 12
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
                        source: "images/check-line.svg"
                        fillMode: Image.PreserveAspectFit
                        anchors.centerIn: parent
                        width: parent.width
                        opacity: usesupercharge.yes ? 1 : 0
                    }
                }

                Text {
                    color: "white"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: parent.width / 20 + (parent.width / 9)
                    text: "Use neutron supercharges?"
                    font.pixelSize: parent.width / 16
                    fontSizeMode: Text.Fit
                    font.family: loraFont.name
                }
            }

            Rectangle {
                id: useinjections
                width: parent.width - (parent.width / 12)
                height: parent.height / 20
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: true
                color: "#2a2a2a"
                border.width: 2
                border.color: "#464646"
                radius: height * 0.35

                property bool yes: false

                TapHandler {
                    onTapped: {
                        useinjections.yes = !useinjections.yes
                    }
                }

                Rectangle {
                    width: parent.width / 12
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
                        source: "images/check-line.svg"
                        fillMode: Image.PreserveAspectFit
                        anchors.centerIn: parent
                        width: parent.width
                        opacity: useinjections.yes ? 1 : 0
                    }
                }

                Text {
                    color: "white"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: parent.width / 20 + (parent.width / 9)
                    text: "Use FSD Injections?"
                    font.pixelSize: parent.width / 16
                    fontSizeMode: Text.Fit
                    font.family: loraFont.name
                }
            }

            Rectangle {
                id: excludestars
                width: parent.width - (parent.width / 12)
                height: parent.height / 20
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: true
                color: "#2a2a2a"
                border.width: 2
                border.color: "#464646"
                radius: height * 0.35

                property bool yes: false

                TapHandler {
                    onTapped: {
                        excludestars.yes = !excludestars.yes
                    }
                }

                Rectangle {
                    width: parent.width / 12
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
                        source: "images/check-line.svg"
                        fillMode: Image.PreserveAspectFit
                        anchors.centerIn: parent
                        width: parent.width
                        opacity: excludestars.yes ? 1 : 0
                    }
                }

                Text {
                    color: "white"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: parent.width / 20 + (parent.width / 9)
                    text: "Exclude Secondary Stars?"
                    font.pixelSize: parent.width / 16
                    fontSizeMode: Text.Fit
                    font.family: loraFont.name
                }
            }

            Rectangle {
                id: refuelevery
                width: parent.width - (parent.width / 12)
                height: parent.height / 20
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: true
                color: "#2a2a2a"
                border.width: 2
                border.color: "#464646"
                radius: height * 0.35

                property bool yes: false

                TapHandler {
                    onTapped: {
                        refuelevery.yes = !refuelevery.yes
                    }
                }

                Rectangle {
                    width: parent.width / 12
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
                        source: "images/check-line.svg"
                        fillMode: Image.PreserveAspectFit
                        anchors.centerIn: parent
                        width: parent.width
                        opacity: refuelevery.yes ? 1 : 0
                    }
                }

                Text {
                    color: "white"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: parent.width / 20 + (parent.width / 9)
                    text: "Refuel Every Scoopable Star?"
                    font.pixelSize: parent.width / 16
                    fontSizeMode: Text.Fit
                    font.family: loraFont.name
                }
            }

            Rectangle {
                id: flipviewer
                width: parent.width - (parent.width / 12)
                height: parent.height / 4.8
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: true
                color: "#2a2a2a"
                border.width: 2
                border.color: "#464646"
                radius: height * 0.05

                property int view: 4 // 1-5

                RButton {
                    id: leftbutton
                    width: parent.width / 10
                    height: width
                    radii: height * 0.35
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: width / 10
                    bcolor: "#4c4c4c"
                    pressedColor: "#2c2c2c"
                    hoverColor: "#414141"

                    onTapped: {
                        if(flipviewer.view > 1) {
                            flipviewer.view -= 1
                        }
                    }

                    Image {
                        anchors.fill: parent
                        source: "images/arrow-left-line.svg"
                    }
                }

                RButton {
                    id: rightbutton
                    width: parent.width / 10
                    height: width
                    radii: height * 0.35
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: width / 10
                    pressedColor: "#2c2c2c"
                    hoverColor: "#414141"
                    bcolor: "#4c4c4c"

                    onTapped: {
                        if(flipviewer.view < 5) {
                            flipviewer.view += 1
                        }
                    }

                    Image {
                        anchors.fill: parent
                        source: "images/arrow-left-line.svg"
                        rotation: 180
                    }
                }

                Text {
                    id: maintitle
                    color: "#ffffff"
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: {
                        switch(flipviewer.view) {
                        case 1:
                            return "Fuel"
                        case 2:
                            return "Fuel Jumps"
                        case 3:
                            return "Guided"
                        case 4:
                            return "Optimistic"
                        case 5:
                            return "Pessimistic"
                        }
                    }
                    font.family: loraFont.name
                    font.pixelSize: parent.width / 10
                    font.bold: true
                    anchors.top: parent.top
                    anchors.topMargin: parent.height / 10
                }

                Text {
                    id: minitext
                    color: "#ffffff"
                    width: parent.width - (parent.width / 10 * 2.5)
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: {
                        switch(flipviewer.view) {
                        case 1:
                            return "Prioritises saving fuel, will not scoop fuel or supercharge. Will make the smallest jumps possible in order to preserve fuel as much as possible."
                        case 2:
                            return "Prioritises saving fuel, will not scoop fuel or supercharge. Will make the smallest jumps possible in order to preserve fuel as much as possible. Once it has generated a route it will then attempt to minimise the number of jumps to use the entire fuel tank. It will attempt to save only enough fuel to recharge the internal fuel tank once. If you have generated a particularly long route it is likely that you will need to recharge more than once and as such you will most likely run out of fuel."
                        case 3:
                            return "Generates a standard Neutron Plotter Route and then uses that as a guide to follow. Penalises routes which diverge more than 100LY off the guide, meaning it preserves the general path of a typical Neutron Plotter route, but does not account for more optimal routes farther than 100LY away, and the calculation might time out if jumping through regions of space with sparse stars."
                        case 4:
                            return "Prioritises Neutron jumps. Penalises areas of the galaxy which have large gaps between neutron stars. Typically generates the fastest route with fewest total jumps."
                        case 5:
                            return "Prioritises calculation speed. Overestimates the average star distance to filter out routes. This means it calculates routes faster but the routes are typically less optimal."
                        }
                    }

                    font.family: loraFont.name
                    font.pixelSize: {
                        switch(flipviewer.view) {
                        case 1:
                            return parent.width / 25
                        case 2:
                            return parent.width / 45
                        case 3:
                            return parent.width / 42
                        case 4:
                            return parent.width / 30
                        case 5:
                            return parent.width / 30
                        }
                    }

                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    fontSizeMode: Text.FixedSize
                    anchors.top: maintitle.top
                    anchors.topMargin: parent.height / 3
                }
            }
        }
    }

    Item {
        id: mainfield
        width: root.width - leftSidebar.width
        height: root.height
        anchors.right: parent.right

        property string expectedCurrentSystem: ""
        property string lastCopiedName: ""

        property bool seededFirstHop: false

        function snapToCurrentSystemAndCopy() {
            if (!routebox.enabled) return
            if (!SpanshPlotter.route || SpanshPlotter.route.length === 0) return

            var route = SpanshPlotter.route
            var current = (JournalManager.location || "").trim()
            if (current.length === 0) return

            var idx = -1
            for (var i = 0; i < route.length; i++) {
                var name = (route[i].name || "").trim()
                if (name === current) {
                    idx = i
                    break
                }
            }

            if (idx === -1) {
                if (seededFirstHop) return

                var first = (route[0].name || "").trim()
                if (first.length === 0) return

                seededFirstHop = true
                expectedCurrentSystem = first

                if (lastCopiedName !== first) {
                    lastCopiedName = first
                    swiper.goTo(0)
                    SupabaseClient.texttoClipboard(first)
                }
                return
            }

            var nextIndex = idx + 1
            if (nextIndex >= route.length)
                nextIndex = route.length - 1

            var nextName = (route[nextIndex].name || "").trim()
            if (nextName.length === 0) return

            expectedCurrentSystem = nextName

            if (lastCopiedName === nextName)
                return

            lastCopiedName = nextName
            swiper.goTo(nextIndex)
            SupabaseClient.texttoClipboard(nextName)
        }

        Connections {
            target: JournalManager

            function onLocationChanged() {
                mainfield.snapToCurrentSystemAndCopy()
            }
        }

        Connections {
            target: SpanshPlotter

            function onFatal(operation, title, error) {
                starLayer.driftX = -35
                starLayer.driftY = -15
                loading.opacity = 0
                noRoute.enabled = true
                noRoute.opacity = 1
                titleText.text = title
                description.text = "Something went wrong while " + operation + ".\n\nError: " + error
            }

            function onGeneratedRoute() {
                starLayer.driftX = -35
                starLayer.driftY = -15
                loading.opacity = 0
                routebox.enabled = true
                routebox.opacity = 1

                mainfield.seededFirstHop = false
                mainfield.expectedCurrentSystem = ""
                mainfield.lastCopiedName = ""

                Qt.callLater(function () {
                    swiper.goTo(0)
                    mainfield.snapToCurrentSystemAndCopy()
                })
            }
        }

        Connections {
            target: SupabaseClient

            function onBackerroroccurred(operation, title, error) {
                starLayer.driftX = -35
                starLayer.driftY = -15
                noRoute.enabled = true
                noRoute.opacity = 1
                loading.opacity = 0
                titleText.text = title
                description.text = "Something went wrong while " + operation + ".\n\nError: " + error
            }
        }

        Item {
            id: routebox
            anchors.fill: parent
            enabled: false
            opacity: 0
            z: 9999

            Behavior on opacity { NumberAnimation { duration: 500 }}

            PageIndicator {
                z: 999999
                id: indicator
                enabled: swiper.counter <= 70
                opacity: enabled ? 1 : 0

                count: swiper.counter
                currentIndex: swiper.currentIndex

                delegate: Rectangle {
                    required property int index
                    implicitWidth: 16
                    implicitHeight: 16
                    radius: width / 2
                    color: "#ffe4ba"

                    TapHandler {
                        onTapped: {
                            swiper.goTo(index)
                        }
                    }
                    opacity: index === indicator.currentIndex ? 0.95 : 0.35
                    Behavior on opacity { OpacityAnimator { duration: 120 } }
                }

                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
            }

            RButton {
                id: deleteRoute
                width: parent.width / 16
                anchors.right: parent.right
                height: width
                radii: 0
                canHover: false
                bcolor: "transparent"
                pressedColor: "dark orange"
                z: 99999999999
                Image {
                    anchors.fill: parent
                    source: "images/close-large-line.svg"
                    fillMode: Image.PreserveAspectFit
                }

                onTapped: {
                    SpanshPlotter.clearRoute()
                    routebox.enabled = false
                    routebox.opacity = 0
                    noRoute.enabled = true
                    noRoute.opacity = 1
                    titleText.text = "No route found.."
                    description.text = description.defaultText
                    Qt.callLater(function () {
                        swiper.currentIndex = 0
                    })
                }
            }

            ListView {
                id: swiper
                anchors.fill: parent
                orientation: ListView.Horizontal
                snapMode: ListView.SnapOneItem
                boundsBehavior: Flickable.StopAtBounds
                interactive: true
                clip: true
                cacheBuffer: Math.max(0, width * 2)
                reuseItems: true
                model: SpanshPlotter.route

                property bool programmaticMove: false

                Behavior on contentX {
                    NumberAnimation { duration: 420; easing.type: Easing.InOutCubic }
                }

                function goTo(i) {
                    if (i < 0 || i >= count) return

                    programmaticMove = true
                    cancelFlick()
                    interactive = false

                    currentIndex = i
                    contentX = i * width

                    Qt.callLater(function () {
                        interactive = true
                        programmaticMove = false
                    })
                }

                onMovementEnded: {
                    if (programmaticMove) return
                    var page = Math.round(contentX / width)
                    if (page !== currentIndex)
                        currentIndex = page
                }

                property int counter: model ? model.length : 0

                delegate: Item {
                    width: swiper.width
                    height: swiper.height
                    property var d: modelData

                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"

                        Text {
                            id: sysName
                            color: "#ffffff"
                            text: d.name
                            font.family: loraFont.name
                            font.bold: true
                            font.pixelSize: parent.width / 15
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            anchors.margins: parent.width / 15

                            Item {
                                id: hitbox
                                x: parent.padding
                                y: parent.padding

                                width: sysName.contentWidth
                                height: sysName.contentHeight

                                HoverHandler {
                                    id: hoverHandler
                                    cursorShape: Qt.PointingHandCursor
                                    onHoveredChanged: {
                                        if (hovered) {
                                            sysName.color = "dark orange"
                                        } else {
                                            sysName.color = "#ffffff"
                                        }
                                    }
                                }

                                TapHandler {
                                    gesturePolicy: TapHandler.DragThreshold
                                    grabPermissions: PointerHandler.ApprovesTakeOverByAnything

                                    onTapped: {
                                        SupabaseClient.texttoClipboard(sysName.text)
                                    }
                                    onPressedChanged: {
                                        if (pressed) {
                                            sysName.color = "orange"
                                        } else {
                                            sysName.color = "#ffffff"
                                        }
                                    }
                                }
                            }

                            DesignEffect {
                                effects: [
                                    DesignDropShadow {
                                        color: "#c3000000"
                                        blur: 9
                                        offsetY: 0
                                    }
                                ]
                            }
                        }

                        Text {
                            id: startype
                            color: {
                                if (d.has_neutron && !d.is_scoopable) {
                                    return "#00AEFF"
                                } else if (d.has_neutron && d.is_scoopable) {
                                    return "#FFFFFF"
                                } else {
                                    return "#FF9600"
                                }
                            }

                            text: {
                                if (d.has_neutron && !d.is_scoopable) {
                                    return "Neutron Star"
                                } else if (d.has_neutron && d.is_scoopable) {
                                    return "Neutron Star + Star"
                                } else {
                                    return "Star"
                                }
                            }
                            font.family: loraFont.name
                            font.bold: true
                            font.pixelSize: parent.width / 25
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: sysName.top
                            anchors.margins: parent.width / 15

                            DesignEffect {
                                effects: [
                                    DesignDropShadow {
                                        color: "#c3000000"
                                        blur: 9
                                        offsetY: 0
                                    }
                                ]
                            }
                        }

                        Text {
                            id: distance
                            color: "#ffffff"
                            text: d.distance.toFixed(2) + " LY"
                            font.family: loraFont.name
                            font.bold: true
                            font.pixelSize: parent.width / 25
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: logic.top
                            anchors.margins: 0

                            DesignEffect {
                                effects: [
                                    DesignDropShadow {
                                        color: "#c3000000"
                                        blur: 9
                                        offsetY: 0
                                    }
                                ]
                            }
                        }

                        Text {
                            id: distanceleft
                            color: "#ffffff"
                            text: "Distance to Destination: "
                                  + Number(d.distance_to_destination).toLocaleString(Qt.locale(), 'f', 2)
                                  + " LY"
                            font.family: loraFont.name
                            font.bold: true
                            font.pixelSize: parent.width / 35
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            anchors.margins: parent.width / 25

                            DesignEffect {
                                effects: [
                                    DesignDropShadow {
                                        color: "#c3000000"
                                        blur: 9
                                        offsetY: 0
                                    }
                                ]
                            }
                        }

                        Text {
                            id: logic
                            color: "#ffc17b"
                            text: {
                                if (Number(d.distance_to_destination) <= 0) {
                                    return "Arrived at destination."
                                } else if (d.must_refuel && !d.has_neutron) {
                                    return "Must refuel here"
                                } else if (d.must_refuel && d.has_neutron) {
                                    return "Supercharge FSD & Refuel"
                                } else if (!d.must_refuel && d.has_neutron) {
                                    return "Supercharge FSD then jump"
                                } else {
                                    return "Continue jumping"
                                }
                            }
                            font.family: loraFont.name
                            font.bold: false
                            font.pixelSize: parent.width / 25
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.margins: parent.width / 20

                            DesignEffect {
                                effects: [
                                    DesignDropShadow {
                                        color: "#c3000000"
                                        blur: 9
                                        offsetY: 0
                                    }
                                ]
                            }
                        }

                        Image {
                            id: neutronstar
                            enabled: d.has_neutron
                            opacity: enabled ? 1 : 0
                            fillMode: Image.PreserveAspectCrop
                            height: root.height * 1.8
                            width: root.width * 1.8
                            source: "images/New Project.png"
                            rotation: 0
                            anchors.centerIn: parent
                            transformOrigin: Item.Center
                            z: -1

                            SequentialAnimation {
                                loops: Animation.Infinite
                                running: true
                                paused: !neutronstar.enabled

                                NumberAnimation {
                                    target: neutronstar
                                    property: "rotation"
                                    from: -18.5
                                    to: 18.5
                                    duration: 1500
                                    easing.type: Easing.InOutSine
                                }

                                NumberAnimation {
                                    target: neutronstar
                                    property: "rotation"
                                    from: 18.5
                                    to: -18.5
                                    duration: 1500
                                    easing.type: Easing.InOutSine
                                }
                            }
                        }

                        Image {
                            id: scoopable
                            enabled: d.is_scoopable || !d.has_neutron
                            opacity: enabled ? 1 : 0
                            source: "images/mdwarf.png"
                            fillMode: Image.PreserveAspectFit
                            anchors.centerIn: parent
                            height: parent.height / 1.5
                            width: parent.width / 1.5
                            z: -2

                            DesignEffect {
                                effects: [
                                    DesignDropShadow {
                                        color: "#c9ff4405"
                                        offsetY: 0
                                        blur: 100
                                    }
                                ]
                            }

                            RotationAnimation {
                                target: scoopable
                                paused: !scoopable.enabled
                                loops: -1
                                duration: 100000
                                property: "rotation"
                                running: true
                                to: 360
                            }
                        }
                    }
                }
            }
        }

        // SwipeView {
        //     id: swiper
        //     currentIndex: 0
        //     anchors.fill: parent
        //     interactive: true
        //     clip: true

        //     Repeater {
        //         id: repeatington
        //         model: SpanshPlotter.route
        //         // model:1

        //         delegate: Item {
        //             width: swiper.width
        //             height: swiper.height
        //             Rectangle {
        //                 anchors.fill: parent
        //                 color: "transparent"

        //                 Text {
        //                     id: sysName
        //                     color: "#ffffff"
        //                     text: d.name
        //                     font.family: loraFont.name
        //                     font.bold: true
        //                     font.pixelSize: parent.width / 15
        //                     anchors.horizontalCenter: parent.horizontalCenter
        //                     anchors.top: parent.top
        //                     anchors.margins: parent.width / 15

        //                     Item {
        //                         id: hitbox
        //                         x: parent.padding
        //                         y: parent.padding

        //                         width: sysName.contentWidth
        //                         height: sysName.contentHeight

        //                         HoverHandler {
        //                             id: hoverHandler
        //                             cursorShape: Qt.PointingHandCursor
        //                             onHoveredChanged: {
        //                                 if(hovered) {
        //                                     sysName.color = "dark orange"
        //                                 } else {
        //                                     sysName.color = "#ffffff"
        //                                 }
        //                             }
        //                         }

        //                         TapHandler {
        //                             onTapped: {
        //                                 SupabaseClient.texttoClipboard(sysName.text)
        //                             }
        //                             onPressedChanged: {
        //                                 if(pressed) {
        //                                     sysName.color = "orange"
        //                                 } else {
        //                                     sysName.color = "#ffffff"
        //                                 }
        //                             }
        //                         }
        //                     }

        //                     DesignEffect {
        //                         effects: [
        //                             DesignDropShadow {
        //                                 color: "#c3000000"
        //                                 blur: 9
        //                                 offsetY: 0
        //                             }
        //                         ]
        //                     }
        //                 }

        //                 Text {
        //                     id: startype
        //                     color: {
        //                         if(d.has_neutron && !d.is_scoopable) {
        //                             return "#00AEFF"
        //                         } else if(d.has_neutron && d.is_scoopable) {
        //                             return "#FFFFFF"
        //                         } else {
        //                             return "#FF9600"
        //                         }
        //                     }

        //                     text: {
        //                         if(d.has_neutron && !d.is_scoopable) {
        //                             return "Neutron Star"
        //                         } else if(d.has_neutron && d.is_scoopable) {
        //                             return "Neutron Star + Star"
        //                         } else {
        //                             return "Star"
        //                         }
        //                     }
        //                     font.family: loraFont.name
        //                     font.bold: true
        //                     font.pixelSize: parent.width / 25
        //                     anchors.horizontalCenter: parent.horizontalCenter
        //                     anchors.top: sysName.top
        //                     anchors.margins: parent.width / 15

        //                     DesignEffect {
        //                         effects: [
        //                             DesignDropShadow {
        //                                 color: "#c3000000"
        //                                 blur: 9
        //                                 offsetY: 0
        //                             }
        //                         ]
        //                     }
        //                 }

        //                 Text {
        //                     id: distance
        //                     color: "#ffffff"
        //                     text: d.distance.toFixed(2) + " LY"
        //                     font.family: loraFont.name
        //                     font.bold: true
        //                     font.pixelSize: parent.width / 25
        //                     anchors.horizontalCenter: parent.horizontalCenter
        //                     anchors.bottom: logic.top
        //                     anchors.margins: 0

        //                     DesignEffect {
        //                         effects: [
        //                             DesignDropShadow {
        //                                 color: "#c3000000"
        //                                 blur: 9
        //                                 offsetY: 0
        //                             }
        //                         ]
        //                     }
        //                 }

        //                 Text {
        //                     id: distanceleft
        //                     color: "#ffffff"
        //                     text: "Distance to Destination: "
        //                           + Number(d.distance_to_destination)
        //                     .toLocaleString(Qt.locale(), 'f', 2)
        //                     + " LY"
        //                     font.family: loraFont.name
        //                     font.bold: true
        //                     font.pixelSize: parent.width / 35
        //                     anchors.horizontalCenter: parent.horizontalCenter
        //                     anchors.top: parent.top
        //                     anchors.margins: parent.width / 25

        //                     DesignEffect {
        //                         effects: [
        //                             DesignDropShadow {
        //                                 color: "#c3000000"
        //                                 blur: 9
        //                                 offsetY: 0
        //                             }
        //                         ]
        //                     }
        //                 }

        //                 Text {
        //                     id: logic
        //                     color: "#ffc17b"
        //                     text: {
        //                         if (Number(d.distance_to_destination) <= 0) {
        //                             return "Arrived at destination."
        //                         } else if(d.must_refuel && !d.has_neutron) {
        //                             return "Must refuel here"
        //                         } else if(d.must_refuel && d.has_neutron) {
        //                             return "Supercharge FSD & Refuel"
        //                         } else if (!d.must_refuel && d.has_neutron) {
        //                             return "Supercharge FSD then jump"
        //                         } else {
        //                             return "Continue jumping"
        //                         }
        //                     }
        //                     font.family: loraFont.name
        //                     font.bold: false
        //                     font.pixelSize: parent.width / 25
        //                     anchors.horizontalCenter: parent.horizontalCenter
        //                     anchors.bottom: parent.bottom
        //                     anchors.margins: parent.width / 20

        //                     DesignEffect {
        //                         effects: [
        //                             DesignDropShadow {
        //                                 color: "#c3000000"
        //                                 blur: 9
        //                                 offsetY: 0
        //                             }
        //                         ]
        //                     }
        //                 }

        //                 Image {
        //                     id: neutronstar
        //                     enabled: d.has_neutron
        //                     opacity: enabled ? 1 : 0
        //                     fillMode: Image.PreserveAspectCrop
        //                     height: root.height * 1.8
        //                     width: root.width * 1.8
        //                     source: "images/New Project.png"
        //                     rotation: 0
        //                     anchors.centerIn: parent
        //                     transformOrigin: Item.Center
        //                     z: -1

        //                     SequentialAnimation {
        //                         loops: Animation.Infinite
        //                         running: true
        //                         paused: !neutronstar.enabled

        //                         NumberAnimation {
        //                             target: neutronstar
        //                             property: "rotation"
        //                             from: -18.5
        //                             to: 18.5
        //                             duration: 1500
        //                             easing.type: Easing.InOutSine
        //                         }

        //                         NumberAnimation {
        //                             target: neutronstar
        //                             property: "rotation"
        //                             from: 18.5
        //                             to: -18.5
        //                             duration: 1500
        //                             easing.type: Easing.InOutSine
        //                         }
        //                     }
        //                 }

        //                 Image {
        //                     id: scoopable
        //                     enabled: d.is_scoopable || !d.has_neutron
        //                     opacity: enabled ? 1 : 0
        //                     source: "images/mdwarf.png"
        //                     fillMode: Image.PreserveAspectFit
        //                     anchors.centerIn: parent
        //                     height: parent.height / 1.5
        //                     width: parent.width / 1.5
        //                     z: -2

        //                     DesignEffect {
        //                         effects: [
        //                             DesignDropShadow {
        //                                 color: "#c9ff4405"
        //                                 offsetY: 0
        //                                 blur: 100
        //                             }
        //                         ]
        //                     }

        //                     RotationAnimation {
        //                         target: scoopable
        //                         paused: !scoopable.enabled
        //                         loops: -1
        //                         duration: 100000
        //                         property: "rotation"
        //                         running: true
        //                         to: 360
        //                     }
        //                 }
        //             }
        //         }
        // }

        Item {
            id: loading
            anchors.fill: parent
            opacity: 0

            Behavior on opacity { NumberAnimation { duration: 500 }}

            EDLoader {
                id: loadingscreen
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenterOffset: -plottingRouteText.implicitHeight / 2
                width: parent.width / 3
                height: width
            }

            Text {
                id: plottingRouteText
                color: "#ffda94"
                text: 'Plotting Route...'
                width: parent.width / 1.2
                anchors.top: loadingscreen.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: parent.width / 20
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                font.bold: true
                font.family: loraFont.name
            }
        }

        Item {
            id: noRoute
            anchors.fill: parent
            opacity: 1

            Behavior on opacity { NumberAnimation { duration: 500 }}

            Column {
                width: parent.width
                spacing: parent.height / 75
                anchors.centerIn: parent

                Text {
                    id: titleText
                    color: "#ffca68"
                    text: "No route found.."
                    width: parent.width
                    font.pixelSize: parent.width / 15
                    font.family: loraFont.name
                    horizontalAlignment: Text.AlignHCenter
                    font.bold: true
                }

                Text {
                    id: description
                    property string defaultText: 'Press "Generate" to generate a route once you have set all required settings.'
                    color: "#ffffff"
                    text: 'Press "Generate" to generate a route once you have set all required settings.'
                    width: parent.width / 1.2
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: parent.width / 35
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    font.family: loraFont.name
                }

                RButton {
                    width: parent.width / 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: parent.width / 17
                    pressedColor: "#ffd17d"
                    hoverColor: "#ffbe47"
                    bcolor: "#ffa500"

                    onTapped: {
                        if(!sourceSystem.text || sourceSystem.text.trim().length === 0) {
                            description.text = "Source system is empty."
                            return
                        } else if (!destination.text || destination.text.trim().length === 0) {
                            description.text = "Destination is empty."
                            return
                        }
                        noRoute.opacity = 0
                        noRoute.enabled = false
                        starLayer.driftX = -500
                        starLayer.driftY = -150
                        loading.opacity = 1
                        SpanshPlotter.GenerateRoute(sourceSystem.text, destination.text,
                                                    Number(cargoNum.text),
                                                    Number(reserveFuelNum.text),
                                                    alreadysupercharged.yes,
                                                    usesupercharge.yes,
                                                    useinjections.yes,
                                                    excludestars.yes,
                                                    refuelevery.yes,
                                                    maintitle.text,
                                                    JournalManager.shipbuild)
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "Generate"
                        font.pixelSize: parent.width / 12
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                        font.family: loraFont.name
                        color: "#ffffff"
                    }

                }
            }
        }

        Rectangle {
            id: background
            color: "black"
            anchors.fill: parent
            z: -999

            Item {
                id: starLayer
                anchors.fill: parent

                property real driftX: -35
                property real driftY: -15

                Behavior on driftX { NumberAnimation { duration: 1000; easing.type: Easing.OutCubic} }
                Behavior on driftY { NumberAnimation { duration: 1000; easing.type: Easing.OutCubic} }

                Timer {
                    id: startick
                    interval: 16
                    running: true
                    repeat: true

                    property double lastMs: Date.now()

                    onTriggered: {
                        var now = Date.now()
                        var dt = (now - lastMs) / 1000.0
                        lastMs = now
                        if (dt > 0.05) dt = 0.05

                        for (var i = 0; i < starLayer.children.length; i++) {
                            var w = starLayer.children[i]
                            if (!w || !w.isStarWrapper) continue

                            w.x += w.vx * dt
                            w.y += w.vy * dt

                            var pad = 20
                            if (w.x < -pad) w.x = starLayer.width + pad
                            if (w.x > starLayer.width + pad) w.x = -pad
                            if (w.y < -pad) w.y = starLayer.height + pad
                            if (w.y > starLayer.height + pad) w.y = -pad
                        }
                    }
                }

                Repeater {
                    model: 150

                    Item {
                        id: wrap
                        property bool isStarWrapper: true

                        property real vxMul: (Math.random() * 0.8 + 0.4)
                        property real vyMul: (Math.random() * 0.8 + 0.4)

                        property real vx: starLayer.driftX * vxMul
                        property real vy: starLayer.driftY * vyMul

                        width: star.width
                        height: star.height

                        x: Math.random() * starLayer.width
                        y: Math.random() * starLayer.height

                        Rectangle {
                            id: star
                            width: Math.random() * 2 + 0.5
                            height: width
                            radius: width / 2
                            color: Qt.rgba(1, 1, 1, Math.random() * 0.8 + 0.2)

                            // Subtle twinkling
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation {
                                    to: Math.random() * 0.3 + 0.2
                                    duration: (Math.random() * 3000) + 2000
                                    easing.type: Easing.InOutQuad
                                }
                                NumberAnimation {
                                    to: Math.random() * 0.9 + 0.1
                                    duration: (Math.random() * 3000) + 2000
                                    easing.type: Easing.InOutQuad
                                }
                            }
                        }
                    }
                }

                Repeater {
                    model: 20

                    Item {
                        id: wrap2
                        property bool isStarWrapper: true

                        property real vMul: (Math.random() * 0.4 + 0.2)
                        property real vx: starLayer.driftX * vMul
                        property real vy: starLayer.driftY * vMul

                        width: star2.width
                        height: star2.height

                        x: Math.random() * starLayer.width
                        y: Math.random() * starLayer.height

                        Rectangle {
                            id: star2
                            width: Math.random() * 4 + 2
                            height: width
                            radius: width / 2
                            color: "#ffffff"
                            opacity: Math.random() * 0.6 + 0.2

                            SequentialAnimation on scale {
                                loops: Animation.Infinite
                                NumberAnimation { to: 1.3; duration: 4000; easing.type: Easing.InOutQuad }
                                NumberAnimation { to: 1.0; duration: 4000; easing.type: Easing.InOutQuad }
                            }
                        }
                    }
                }
            }
        }
    }
}
