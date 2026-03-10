import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Studio.DesignEffects
import QtQuick.Controls.Basic.impl
import QtQuick.Dialogs
import Qt.labs.platform

Popup {
    id: root
    width: parent.width * 0.8
    height: parent.height * 0.9
    anchors.centerIn: parent
    modal: true
    focus: true
    dim: true

    signal openImage(var imageUrl)
    signal requestEdit(var data)
    property bool isProcessing: true
    property bool isClaimed: false
    property bool isEditInfoOpen: false
    property bool inGec: false
    property bool isClaimedByOther: false
    property var systemData: null
    property string currentSystemName: root.systemData ? root.systemData.system_name : ""

    onClosed: {
        root.isProcessing = true
    }

    onOpened: {
        root.isProcessing = true
        refreshPopup()
        SupabaseClient.fetchSystemStatus(root.currentSystemName, root.systemData.id64)
    }

    Connections {
        target: SupabaseClient
        function onClaimUpdated(success, message) {
            if (root.visible && message.includes(root.currentSystemName)) {
                refreshPopup()
                root.isProcessing = false
            }
        }
        function onSingleSystemDataUpdated(systemName) {
            if (systemName === root.currentSystemName) {
                console.log("Synced data received for: " + systemName)
                refreshPopup()
                root.isProcessing = false
            }
        }
        function onSystemsLoaded() {
            if (root.visible && root.systemData && root.systemData.system_name) {
                refreshPopup()
            }
        }
    }
    function refreshPopup() {
        if (!root.systemData || !root.systemData.system_name) return;
        console.log("Refreshing SystemViewPopup for: " + root.currentSystemName)
        var freshData = SupabaseClient.getSystem(root.currentSystemName)
        root.systemData = freshData
        console.log("id64:", freshData.id64)

        var gec_url = freshData.gec_url
        if(!gec_url || gec_url === "") {
            root.inGec = false
        } else {
            root.inGec = true
        }

        var owner = freshData.claimed_by
        var me = JournalManager.cmdrName

        root.isClaimed = (owner === me)
        root.isClaimedByOther = (owner !== undefined && owner !== "" && owner !== null && owner !== me)
    }

    enter: Transition {
        OpacityAnimator {
            target: systemViewBg
            to: 1
            duration: 350
        }
        OpacityAnimator {
            target: viewholder
            to: 1
            duration: 350
        }
    }

    exit: Transition {
        OpacityAnimator {
            target: systemViewBg
            to: 0
            duration: 350
        }
        OpacityAnimator {
            target: viewholder
            to: 0
            duration: 350
        }
    }

    background: Rectangle {
        id: systemViewBg
        opacity: 0
        gradient: Gradient {
            GradientStop { position: 0; color: "#2a2a2a" }
            GradientStop { position: 1; color: "#1a1a1a" }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: (mouse) => mouse.accepted = true
            onWheel: (wheel) => wheel.accepted = true
            onPressed: (mouse) => mouse.accepted = true
        }
    }

    Rectangle {
        id: viewholder
        anchors.fill: parent
        color: "transparent"
        opacity: 0

        MouseArea {
            anchors.fill: parent
        }
        Rectangle {
            id: leftBorder
            width: parent.width / 2
            height: parent.height
            color: "transparent"

            Image {
                id: mainImage
                source: (root.systemData && root.systemData.main_image) ? root.systemData.main_image : "images/recordsBg.png"
                fillMode: Image.PreserveAspectCrop
                anchors.top: parent.top
                width: parent.width
                height: parent.height / 2.5

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
                        root.close()
                    }

                    Image {
                        id: back
                        anchors.fill: parent
                        source: "images/close-large-line.svg"
                        fillMode: Image.PreserveAspectFit
                    }
                }

                Text {
                    id: minititle
                    width: parent.width
                    height: parent.width / 30
                    color: "#9e9e9e"
                    anchors.bottom: title.top
                    anchors.bottomMargin: -height
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    fontSizeMode: Text.Fit
                    font.family: antonFont.name
                    font.pixelSize: width / 4
                    text: root.systemData ? "(" + root.systemData.system_name + ")" : "()"
                    z: 1

                    DesignEffect {
                        effects: [
                            DesignDropShadow {
                            }
                        ]
                    }
                }

                Text {
                    id: title
                    width: parent.width
                    height: parent.height / 3.5
                    color: "#ffffff"
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    font.family: antonFont.name
                    font.pixelSize: parent.width / 10
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    fontSizeMode: Text.Fit
                    text: root.systemData ? root.systemData.title : ""
                    z: 1

                    Item {
                        id: hitbox
                        anchors.centerIn: parent

                        width: title.contentWidth
                        height: title.contentHeight

                        HoverHandler {
                            id: hoverHandler
                            cursorShape: Qt.PointingHandCursor
                            enabled: !root.isEditInfoOpen
                            onHoveredChanged: {
                                if(hovered) {
                                    title.color = "dark orange"
                                } else {
                                    title.color = "#ffffff"
                                }
                            }
                        }

                        TapHandler {
                            enabled: !root.isEditInfoOpen
                            onTapped: {
                                SupabaseClient.texttoClipboard(root.systemData.system_name)
                            }
                            onPressedChanged: {
                                if(pressed) {
                                    title.color = "orange"
                                } else {
                                    title.color = "#ffffff"
                                }
                            }
                        }
                    }

                    Behavior on color { ColorAnimation { duration: 20 }}

                    Rectangle {
                        id: randomlinebru1
                        width: parent.width / 2
                        height: parent.height / 50
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "orange"
                    }

                    DesignEffect {
                        effects: [
                            DesignDropShadow {
                            }
                        ]
                    }
                }

                Rectangle {
                    id: dropshadow1
                    anchors.fill: parent

                    gradient: Gradient {
                        GradientStop { position: 0.8; color: "#00000000" }  // Transparent
                        GradientStop { position: 1.0; color: "#242424" }  // Semi-transparent black
                    }
                }
            }

            Row {
                id: categories
                height: leftBorder.height / 10
                anchors.top: mainImage.bottom
                anchors.topMargin: height / 10
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: leftBorder.width / 50

                Repeater {
                    model: root.systemData ? root.systemData.category : []
                    delegate: Rectangle {
                        width: categoryText.contentWidth + (leftBorder.width / 50)
                        height: categories.height * 0.5
                        color: "dark orange"
                        radius: height / 5

                        Text {
                            id: categoryText
                            anchors.centerIn: parent
                            text: modelData
                            font.family: antonFont.name
                            font.pixelSize: leftBorder.width / 50 - contentWidth
                            wrapMode: Text.Wrap
                            fontSizeMode: Text.Fit
                            minimumPixelSize: 10
                            color: "white"
                        }
                    }
                }
            }

            Rectangle {
                id: descCard
                width: parent.width / 1.03
                height: parent.height / 2
                anchors.top: categories.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: -categories.height / 4
                radius: width / 30
                color: "#333333"
                Rectangle {
                    id: descCardholder
                    width: parent.width - (parent.height / 59)
                    height: parent.height - (parent.height / 59)
                    anchors.centerIn: parent
                    color: "#2e2e2e"
                    radius: parent.radius

                    RButton {
                        id: claimButton
                        width: parent.width / 4
                        height: parent.height / 10
                        radii: width / 2
                        anchors.right: editInfo.left
                        anchors.rightMargin: editInfo.x / 20
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: height
                        bcolor: root.isClaimedByOther ? "#3a3a3a" : (root.isClaimed ? "#ac0000" : "dark orange")
                        hoverColor: root.isClaimedByOther ? "#3a3a3a" : (root.isClaimed ? "#660000" : "#ffb820")
                        pressedColor: root.isClaimedByOther ? "#3a3a3a" : (root.isClaimed ? "#4c0000" : "#ffc370")

                        canClick: !root.isProcessing && !root.isClaimedByOther
                        canHover: !root.isProcessing && !root.isClaimedByOther
                        opacity: (root.isProcessing || root.isClaimedByOther) ? 0.7 : 1.0

                        onTapped: {
                            root.isProcessing = true
                            if (root.isClaimed) {
                                SupabaseClient.unclaimSystem(root.currentSystemName, JournalManager.cmdrName);
                            } else {
                                SupabaseClient.claimSystem(root.currentSystemName, JournalManager.cmdrName);
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: {
                                if (root.isProcessing) return "Syncing..."
                                if (root.isClaimedByOther) return "Claimed by " + root.systemData.claimed_by
                                if (root.isClaimed) return "Unclaim"
                                return "Claim"
                            }
                            color: "white"
                            font.family: antonFont.name
                            font.pixelSize: parent.width / 7
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            fontSizeMode: Text.Fit
                            width: parent.width
                            height: parent.height
                        }
                    }

                    RButton {
                        id: editInfo
                        width: parent.width / 4
                        height: parent.height / 10
                        radii: width / 2
                        x: (parent.width - width) / 2
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: height
                        bcolor: root.isClaimed ? "#506060" : "#2a2a2a"
                        hoverColor: root.isClaimed ? "#607070" : "#2a2a2a"
                        pressedColor: root.isClaimed ? "#809090" : "#2a2a2a"
                        canHover: root.isClaimed
                        canClick: root.isClaimed

                        onTapped: {
                            root.isEditInfoOpen = true
                            root.requestEdit(root.systemData)
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "Edit Info"
                            color: root.isClaimed ? "white" : "#606060"
                            font.family: antonFont.name
                            font.pixelSize: parent.width / 7
                        }
                    }

                    RButton {
                        id: gecButton
                        width: parent.width / 4
                        height: parent.height / 10
                        radii: width / 2
                        anchors.left: editInfo.right
                        anchors.leftMargin: editInfo.x / 20
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: height
                        bcolor: "#965bde"
                        hoverColor: "#2b2336"
                        pressedColor: "#2b2336"
                        canHover: !root.isProcessing
                        canClick: !root.isProcessing

                        onTapped: {
                            if(root.inGec) {
                                let url = root.systemData.gec_url
                                Qt.openUrlExternally(url)
                            } else {
                                let url = "https://edastro.com/gec/new/" + root.systemData.system_name + "/POI Name Here"
                                Qt.openUrlExternally(url)
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: {
                                if(root.isProcessing) {
                                    return "..."
                                } else {
                                    if(root.inGec) {
                                        return "In GEC"
                                    } else {
                                        return "Not In GEC"
                                    }
                                }
                            }
                            color: root.isProcessing ? "#606060" : "white"
                            font.family: antonFont.name
                            font.pixelSize: parent.width / 7
                        }
                    }

                    Rectangle {
                        id: descriptionArea
                        width: parent.width
                        height: parent.height / 1.5
                        color: "#2e000000"
                        radius: parent.radius

                        Flickable {
                            id: flickablething
                            anchors.fill: parent
                            contentHeight: descriptionItself.contentHeight
                            clip: true

                            ScrollBar.vertical: ScrollBar {
                                policy: ScrollBar.AsNeeded
                            }

                            Image {
                                id: doubleQuotesTop
                                source: "images/double-quotes-l.svg"
                                fillMode: Image.PreserveAspectFit
                                width: parent.width / 8
                                height: width
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.margins: parent.width / 25
                                z: 1
                            }

                            Text {
                                id: descriptionItself
                                width: parent.width
                                topPadding: parent.width / 25
                                wrapMode: Text.WordWrap
                                text: root.systemData ? root.systemData.description : "No description available for this system..."
                                font.family: loraFont.name
                                font.pixelSize: descriptionArea.width / 30
                                color: "white"

                                onLineLaidOut: (line) => {
                                                   if (line.y < doubleQuotesTop.height + doubleQuotesTop.anchors.margins) {
                                                       line.width = descriptionArea.width - doubleQuotesTop.width - doubleQuotesTop.anchors.margins * 2
                                                       line.x = doubleQuotesTop.width + doubleQuotesTop.anchors.margins * 2
                                                   }
                                               }
                            }
                        }

                        Rectangle {
                            id: randomlinebru2
                            width: parent.width / 1.1
                            height: parent.height / 100
                            anchors.top: flickablething.bottom
                            anchors.topMargin: height * 5
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: "orange"
                        }
                    }
                }
            }
        }
        Rectangle {
            id: rightBorder
            width: parent.width / 2
            height: parent.height
            anchors.right: parent.right
            color: "transparent"

            property string activeImageUrl: ""

            Connections {
                target: root
                function onSystemDataChanged() {
                    if (root.systemData && root.systemData.main_image) {
                        rightBorder.activeImageUrl = root.systemData.main_image
                    } else {
                        rightBorder.activeImageUrl = "images/recordsBg.png"
                    }
                }
            }

            Rectangle {
                id: imageCarousel
                width: parent.width
                height: parent.height / 2.2
                anchors.horizontalCenter: parent.horizontalCenter
                color: "transparent"
                anchors.top: parent.top

                Rectangle {
                    id: imgHolder
                    width: holderImage.paintedWidth * 1.05
                    height: holderImage.paintedHeight * 1.05
                    anchors.centerIn: parent
                    color: "#333333"
                    radius: width / 50

                    Image {
                        id: holderImage
                        width: parent.parent.width * 0.8
                        source: rightBorder.activeImageUrl
                        asynchronous: true
                        fillMode: Image.PreserveAspectFit
                        anchors.centerIn: parent
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                        opacity: status === Image.Ready ? 1 : 0
                        onStatusChanged: {
                            if (status === Image.Error) {
                                console.log("Image Error for: " + source)
                            }
                        }

                        TapHandler {
                            enabled: !root.isEditInfoOpen
                            onTapped: {
                                if(holderImage.opacity === 1) {
                                    openImage(holderImage.source)
                                }
                            }
                        }
                    }
                    BusyIndicator {
                        anchors.centerIn: parent
                        running: holderImage.status === Image.Loading
                        visible: running
                        contentItem: BusyIndicatorImpl {
                            implicitWidth: 48
                            implicitHeight: 48
                            pen: "white"
                            fill: "orange"
                            running: parent.running
                        }
                    }
                }
            }

            ListView {
                id: testList
                width: parent.width
                height: parent.height / 10
                boundsMovement: Flickable.StopAtBounds
                orientation: ListView.Horizontal
                anchors.top: imageCarousel.bottom
                anchors.topMargin: -height / 20
                spacing: width / 50
                clip: true
                model: root.systemData ? root.systemData.images : []

                leftMargin: Math.max(0, (width - contentWidth) / 2)
                rightMargin: leftMargin

                Behavior on contentX {
                    NumberAnimation {
                        duration: 15
                    }
                }

                delegate: RButton {
                    width: testList.width / 7
                    height: testList.height
                    pressedColor: "#676767"
                    hoverColor: "#3e3e3e"
                    bcolor: "#2a2a2a"
                    radii: width / 10

                    onTapped: {
                        rightBorder.activeImageUrl = modelData
                    }

                    Image {
                        id: imageItself
                        source: modelData
                        fillMode: Image.PreserveAspectFit
                        width: parent.width * 0.9
                        height: width
                        anchors.centerIn: parent
                        opacity: rightBorder.activeImageUrl === modelData ? 1.0 : 0.5
                    }
                }

                ScrollBar.horizontal: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }

                WheelHandler {
                    target: testList
                    property: "contentX"
                    rotationScale: -1
                }
            }

            Flickable {
                id: bodyData
                width: parent.width
                height: parent.height - imageCarousel.height - testList.height - (parent.height / 20)
                anchors.top: testList.bottom
                anchors.topMargin: parent.height / 50
                contentHeight: bodyColumn.height
                clip: true

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }

                Column {
                    id: bodyColumn
                    width: parent.width * 0.95
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: parent.width / 40

                    Repeater {
                        model: root.systemData ? root.systemData.body_details : []

                        delegate: Rectangle {
                            width: bodyColumn.width
                            height: cardContent.implicitHeight + (bodyColumn.width / 20)
                            color: "#2e2e2e"
                            radius: width / 30
                            border.width: 2
                            border.color: "#3e3e3e"

                            Column {
                                id: cardContent
                                width: parent.width * 0.95
                                anchors.centerIn: parent
                                spacing: parent.width / 50

                                Text {
                                    width: parent.width
                                    text: modelData.tag
                                    font.family: antonFont.name
                                    font.pixelSize: parent.width / 15
                                    fontSizeMode: Text.Fit
                                    color: "orange"
                                }

                                Text {
                                    width: parent.width
                                    text:  modelData.body
                                    font.family: loraFont.name
                                    font.pixelSize: parent.width / 20
                                    color: "white"
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
