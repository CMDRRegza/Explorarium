import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Studio.DesignEffects
import QtQuick.Controls.Basic.impl
import QtQuick.Dialogs
import Qt.labs.platform

Window {
    id: root
    width: 1920
    height: 1080
    visible: false
    color: "#00000000"
    title: "Explorarium"

    onClosing: (close) => { // qt is super whiny and this exists and works properly
                   Qt.quit()
               }

    property string appVersion: applicationVersion

    Binding {
        target: CategoryProxy
        property: "cmdrName"
        value: JournalManager.cmdrName
    }

    // Component.onCompleted: {
    //     editInfoPopup.open()
    // }

    Connections {
        target: loadingScreenManager
        function onLoadApp() {
            root.visible = true
            root.show()
            root.raise()
            root.requestActivate()
            effecter.start()
        }
    }

    Connections {
        target: systemViewPopup
        function onOpenImage(imgUrl) {
            theImage.source = imgUrl
            imagePopup.open()
        }
    }

    Connections {
        target: SupabaseClient
        function onErrorOccurred(error, title, operation) {
            errorPopup.error = error
            errorPopup.operation = operation
            errorPopup.title = title
            errorPopup.open()
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

    InfoPopup {
        id: infoPopup
        antonFontName: antonFont.name
        loraFontName: loraFont.name
    }

    Popup {
        id: imagePopup
        width: parent.width * 0.8
        height: parent.height * 0.9
        anchors.centerIn: parent
        modal: true
        focus: true
        dim: true
        z: 10

        enter: Transition {
            OpacityAnimator {
                target: imgHolder
                to: 1
                duration: 350
            }
        }

        exit: Transition {
            OpacityAnimator {
                target: imgHolder
                to: 0
                duration: 350
            }
        }

        background: Rectangle {
            id: imageBg
            opacity: 0

            TapHandler {
                acceptedButtons: Qt.LeftButton
                onTapped: imagePopup.close()
            }

            WheelHandler {
                onWheel: wheel.accepted = true
            }
        }

        Item {
            id: imgHolder
            anchors.fill: parent
            opacity: 0
            Image {
                id: theImage
                fillMode: Image.PreserveAspectFit
                width: parent.width
                anchors.centerIn: parent

                TapHandler {
                    acceptedButtons: Qt.LeftButton
                    onTapped: {}
                }
            }
        }
    }

    SettingRecordsPopup {
        id: settingsPopup
        width: parent.width * 0.5
        height: parent.height * 0.6
        anchors.centerIn: parent
    }

    GalaxyMapPopup {
        id: galaxyMapPopup
        width: parent.width
        height: parent.height
        anchors.centerIn: parent

        onRequestSystemView: (systemName) => {
                                 console.log("Main received request for: " + systemName)
                                 var dataObj = SupabaseClient.getSystem(systemName)
                                 systemViewPopup.systemData = dataObj
                                 systemViewPopup.open()
                             }
    }

    SystemViewPopup {
        id: systemViewPopup
        anchors.centerIn: parent

        onRequestEdit: (data) => {
                           field.text = data.title
                           thustheotherfieldlieshere.text = data.description
                           editInfoPopup.systemData = data
                           editInfoPopup.open()
                       }
        z: 1
    }

    Popup {
        id: errorPopup
        width: parent.width * 0.3
        height: parent.height * 0.4
        anchors.centerIn: parent
        modal: true
        focus: true
        dim: true
        z: 5

        enter: Transition {
            OpacityAnimator {
                target: errorInfoBg
                to: 1
                duration: 350
            }
            OpacityAnimator {
                target: errorholder
                to: 1
                duration: 350
            }
        }

        exit: Transition {
            OpacityAnimator {
                target: errorInfoBg
                to: 0
                duration: 350
            }
            OpacityAnimator {
                target: errorholder
                to: 0
                duration: 350
            }
        }

        background: Rectangle {
            id: errorInfoBg
            opacity: 0
            gradient: Gradient {
                GradientStop { position: 0; color: "#2a2a2a" }
                GradientStop { position: 1; color: "#2a0000" }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: (mouse) => mouse.accepted = true
                onWheel: (wheel) => wheel.accepted = true
                onPressed: (mouse) => mouse.accepted = true
            }
        }

        property string error: "This is a string"
        property string operation: "This is a string"
        property string title: "This is a string"

        Rectangle {
            id: errorholder
            color: "transparent"
            anchors.fill: parent
            opacity: 0

            Text {
                id: errorTitle
                text: errorPopup.title
                width: parent.width
                height: parent.height / 5
                font.pixelSize: parent.width / 10
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                fontSizeMode: Text.Fit
                color: "#fe4848"
                anchors.top: parent.top
                anchors.topMargin: height / 2.5
                font.family: antonFont.name
                z: 1
            }

            RButton {
                id: errorCloser
                width: parent.width / 15
                height: width
                pressedColor: "#7bd3d3d3"
                radii: width / 10
                bcolor: "transparent"
                canHover: false

                onTapped: {
                    errorPopup.close()
                }

                Image {
                    id: backimageplaceholder2
                    anchors.fill: parent
                    source: "images/close-large-line.svg"
                    fillMode: Image.PreserveAspectFit
                }
            }

            Rectangle {
                id: errorCard
                width: parent.width / 1.03
                height: errorholder.height / 1.5
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                radius: width / 30
                color: "#333333"
                Rectangle {
                    id: errorCardHolder
                    width: parent.width - (parent.height / 59)
                    height: parent.height - (parent.height / 59)
                    anchors.centerIn: parent
                    color: "#2e2e2e"
                    radius: parent.radius

                    Image {
                        id: errorLogo
                        source: "images/error-warning-line.svg"
                        fillMode: Image.PreserveAspectFit
                        width: parent.width / 2
                        height: width
                        anchors.centerIn: parent
                        opacity: 0.1
                    }

                    Text {
                        id: descriptionDefault
                        text: "Something went wrong while " + errorPopup.operation + ".\n\nError: " + errorPopup.error
                        width: parent.width
                        height: parent.height / 5
                        font.pixelSize: parent.width / 17
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.Wrap
                        color: "#ffffff"
                        anchors.centerIn: parent
                        font.family: loraFont.name
                    }
                }
            }
        }
    }

    Popup {
        id: editInfoPopup
        width: parent.width * 0.5
        height: parent.height * 0.6
        anchors.centerIn: parent
        modal: true
        focus: true
        dim: true
        z: 99

        onClosed: {
            systemViewPopup.isEditInfoOpen = false
        }

        property string fileErrorText: ""

        closePolicy: Popup.NoAutoClose

        property string mainImageUrl: "";

        property var systemData
        property var tempImages: []
        property var originalImages: []
        property var uploadedUrls: []
        property bool isSaving: false
        property bool isUploading: false

        onOpened: {
            editInfoPopup.isSaving = false
            editInfoPopup.tempImages = []
            editInfoPopup.originalImages = []
            editInfoPopup.uploadedUrls = []

            if (editInfoPopup.systemData && editInfoPopup.systemData.images) {
                var rawList = editInfoPopup.systemData.images
                var catImg = editInfoPopup.systemData.category_image
                editInfoPopup.mainImageUrl = editInfoPopup.systemData.main_image || ""
                var filteredList = []

                for(var i = 0; i < rawList.length; i++) {
                    var img = rawList[i]
                    if (img !== catImg && img !== "") {
                        filteredList.push(img)
                    }
                }
                editInfoPopup.tempImages = filteredList
                editInfoPopup.originalImages = Array.from(filteredList)
            }
        }

        Connections {
            target: SupabaseClient
            function onScreenshotReady(url) {
                if (editInfoPopup.visible) {
                    var urls = editInfoPopup.uploadedUrls
                    urls.push(url)
                    editInfoPopup.uploadedUrls = urls

                    var t = editInfoPopup.tempImages
                    t.unshift(url)
                    editInfoPopup.tempImages = t

                    if (editInfoPopup.mainImageUrl === "" ||
                            (editInfoPopup.systemData && editInfoPopup.mainImageUrl === editInfoPopup.systemData.category_image)) {
                        editInfoPopup.mainImageUrl = url
                    }

                    editInfoPopup.isUploading = false
                }
            }

            function onErrorOccurred(error, title, operation) {
                if (operation === "Uploading Screenshot") {
                    editInfoPopup.isUploading = false
                }
            }

            function onContributionUpdated(systemName) {
                if (editInfoPopup.visible && systemName === editInfoPopup.systemData.system_name) {
                    console.log("Database saved successfully! Closing...")
                    editInfoPopup.close()
                }
            }
        }

        enter: Transition {
            OpacityAnimator {
                target: editInfoBg
                to: 1
                duration: 350
            }
            OpacityAnimator {
                target: editholder
                to: 1
                duration: 350
            }
        }

        exit: Transition {
            OpacityAnimator {
                target: editInfoBg
                to: 0
                duration: 350
            }
            OpacityAnimator {
                target: editholder
                to: 0
                duration: 350
            }
        }

        background: Rectangle {
            id: editInfoBg
            opacity: 0
            gradient: Gradient {
                GradientStop { position: 0; color: "#2a2a2a" }
                GradientStop { position: 1; color: "#1a1a1a" }
            }
        }

        Rectangle {
            id: editholder
            color: "transparent"
            anchors.fill: parent
            opacity: 0

            Flickable {
                id: flickableringlmfaoooooo
                anchors.fill: parent
                contentHeight: editcardHolder.height
                clip: true

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }

                Column {
                    id: editcardHolder
                    width: flickableringlmfaoooooo.width
                    spacing: width / 35

                    RButton {
                        id: editcloser
                        width: parent.width / 15
                        height: width
                        pressedColor: "#7bd3d3d3"
                        radii: width / 10
                        bcolor: "transparent"
                        canHover: false

                        onTapped: {
                            editInfoPopup.close()
                        }

                        Image {
                            id: backimageplaceholder
                            anchors.fill: parent
                            source: "images/close-large-line.svg"
                            fillMode: Image.PreserveAspectFit
                        }
                    }

                    Rectangle {
                        id: titleCard
                        width: parent.width / 1.03
                        height: flickableringlmfaoooooo.height / 3
                        anchors.topMargin: height / 10
                        anchors.horizontalCenter: parent.horizontalCenter
                        radius: width / 30
                        color: "#333333"
                        Rectangle {
                            id: titleCardHolder
                            width: parent.width - (parent.height / 59)
                            height: parent.height - (parent.height / 59)
                            anchors.centerIn: parent
                            color: "#2e2e2e"
                            radius: parent.radius

                            Text {
                                id: titletitleforthetitlewhichisatitle
                                height: parent.height / 3
                                text: "SYSTEM TITLE"
                                color: "orange"
                                font.family: antonFont.name
                                font.pixelSize: parent.width / 40
                                padding: parent.width / 50

                                Rectangle {
                                    id: line20
                                    width: titleCardHolder.width - parent.width - (titleCardHolder.width / 50)
                                    height: parent.height / 20
                                    anchors.left: parent.right
                                    color: "orange"
                                    anchors.top: parent.top
                                    anchors.topMargin: parent.height * 0.5
                                }
                            }

                            ScrollView {
                                width: parent.width
                                height: parent.height - titletitleforthetitlewhichisatitle.height * 1.03
                                anchors.top: titletitleforthetitlewhichisatitle.bottom
                                wheelEnabled: field.activeFocus
                                TextArea {
                                    id: field
                                    wrapMode: Text.Wrap
                                    padding: width / 50
                                    selectedTextColor: "#ffffff"
                                    selectionColor: "#ff9a00"
                                    placeholderTextColor: "#88a5a5a5"
                                    placeholderText: "Type a title for the system here..."
                                    font.family: loraFont.name
                                    color: "white"
                                    background: Rectangle {
                                        anchors.fill: parent
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        radius: width / 30
                                        color: "#1f1f1f"

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

                    Rectangle {
                        id: descriptionCard
                        width: parent.width / 1.03
                        height: flickableringlmfaoooooo.height / 2
                        anchors.topMargin: height / 10
                        anchors.horizontalCenter: parent.horizontalCenter
                        radius: width / 30
                        color: "#333333"
                        Rectangle {
                            id: descriptionCardHolder
                            width: parent.width - (parent.height / 59)
                            height: parent.height - (parent.height / 59)
                            anchors.centerIn: parent
                            color: "#2e2e2e"
                            radius: parent.radius

                            Text {
                                id: titletitleforthetitlewhichisatitleandtheothertitleisthisone
                                height: parent.height / 5
                                text: "SYSTEM DESCRIPTION"
                                color: "orange"
                                font.family: antonFont.name
                                font.pixelSize: parent.width / 40
                                padding: parent.width / 50

                                Rectangle {
                                    id: line200
                                    width: descriptionCardHolder.width - parent.width - (descriptionCardHolder.width / 50)
                                    height: parent.height / 20
                                    anchors.left: parent.right
                                    color: "orange"
                                    anchors.top: parent.top
                                    anchors.topMargin: parent.height * 0.6
                                }
                            }

                            ScrollView {
                                width: parent.width
                                height: parent.height - titletitleforthetitlewhichisatitleandtheothertitleisthisone.height * 1.01
                                anchors.top: titletitleforthetitlewhichisatitleandtheothertitleisthisone.bottom
                                wheelEnabled: thustheotherfieldlieshere.activeFocus
                                TextArea {
                                    id: thustheotherfieldlieshere
                                    wrapMode: Text.Wrap
                                    padding: width / 50
                                    selectedTextColor: "#ffffff"
                                    selectionColor: "#ff9a00"
                                    placeholderTextColor: "#88a5a5a5"
                                    placeholderText: "Type a description for the system here..."
                                    font.family: loraFont.name
                                    color: "white"
                                    background: Rectangle {
                                        anchors.fill: parent
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        radius: width / 30
                                        color: "#1f1f1f"

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

                    TapHandler {
                        onTapped: flickableringlmfaoooooo.forceActiveFocus()
                    }

                    Rectangle {
                        id: imageEditorCard
                        width: parent.width / 1.03
                        height: flickableringlmfaoooooo.height / 2
                        anchors.topMargin: height / 10
                        anchors.horizontalCenter: parent.horizontalCenter
                        radius: width / 30
                        color: "#333333"
                        Rectangle {
                            id: imageEditorCardHolder
                            width: parent.width - (parent.height / 59)
                            height: parent.height - (parent.height / 59)
                            anchors.centerIn: parent
                            color: "#2e2e2e"
                            radius: parent.radius

                            Text {
                                id: okthisisgettingridiculous
                                height: parent.height / 10
                                text: "SYSTEM IMAGES"
                                color: "orange"
                                font.family: antonFont.name
                                font.pixelSize: parent.width / 40
                                padding: parent.width / 50

                                Rectangle {
                                    id: line2000
                                    width: descriptionCardHolder.width - parent.width - (descriptionCardHolder.width / 50)
                                    height: parent.height / 20
                                    anchors.left: parent.right
                                    color: "orange"
                                    anchors.top: parent.top
                                    anchors.topMargin: parent.height * 1.1
                                }
                            }

                            Row {
                                id: buttonRow
                                width: parent.width
                                height: parent.height / 8
                                anchors.top: okthisisgettingridiculous.bottom
                                anchors.topMargin: parent.height / 15
                                spacing: parent.width / 50
                                padding: parent.width / 50
                                z: 10

                                RButton {
                                    id: addImageButton
                                    width: parent.width / 12
                                    height: width
                                    bcolor: "grey"
                                    hoverColor: "dark grey"
                                    pressedColor: "light grey"
                                    radii: width / 10
                                    opacity: editInfoPopup.isUploading ? 0.5 : 1.0
                                    canClick: !editInfoPopup.isUploading
                                    canHover: !editInfoPopup.isUploading

                                    onTapped: {
                                        fileDialog.open()
                                    }

                                    Image {
                                        width: parent.width * 0.8
                                        height: parent.height * 0.8
                                        source: "images/close-large-line.svg"
                                        fillMode: Image.PreserveAspectFit
                                        anchors.centerIn: parent
                                        rotation: 45
                                        visible: !editInfoPopup.isUploading
                                    }

                                    BusyIndicator {
                                        anchors.centerIn: parent
                                        width: parent.width * 0.8
                                        height: width
                                        visible: editInfoPopup.isUploading
                                        running: editInfoPopup.isUploading

                                        contentItem: BusyIndicatorImpl {
                                            implicitWidth: 48
                                            implicitHeight: 48
                                            pen: "white"
                                            fill: "orange"
                                            running: parent.running
                                        }
                                    }
                                }

                                FileDialog {
                                    id: fileDialog
                                    title: "Select a screenshot"
                                    fileMode: FileDialog.OpenFiles
                                    folder: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]

                                    nameFilters: [ "Image files (*.jpg *.png *.bmp)" ]
                                    onAccepted: {
                                        editInfoPopup.fileErrorText = ""
                                        editInfoPopup.isUploading = true

                                        let maxFileSizeMB = 16.0
                                        let hasError = false

                                        for (var i = 0; i < files.length; i++) {
                                            var pathUrl = files[i].toString()
                                            var localFilePath = decodeURIComponent(pathUrl.replace(/^(file:\/{3})|(file:)/, ""))

                                            var fileName = localFilePath.substring(localFilePath.lastIndexOf("/") + 1)
                                            var sizeMB = SupabaseClient.getFileSizeMB(localFilePath)

                                            if (sizeMB > maxFileSizeMB) {
                                                editInfoPopup.fileErrorText = fileName + " is too large (" + sizeMB.toFixed(1) + " MB). Max is " + maxFileSizeMB + " MB."
                                                hasError = true
                                                console.log("Blocked upload: " + fileName)
                                                continue;
                                            }

                                            SupabaseClient.uploadScreenshot(
                                                        editInfoPopup.systemData.system_name,
                                                        JournalManager.cmdrName,
                                                        localFilePath
                                                        )
                                        }

                                        if (hasError && files.length === 1) {
                                            editInfoPopup.isUploading = false
                                        }
                                    }
                                }
                            }

                            Text {
                                id: simpleErrorText
                                text: editInfoPopup.fileErrorText || ""
                                height: parent.height
                                width: parent.width / 2

                                color: "#ff4444"
                                font.family: loraFont.name
                                font.pixelSize: parent.width / 30
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                fontSizeMode: Text.Fit
                                anchors.verticalCenter: buttonRow.verticalCenter
                                anchors.verticalCenterOffset: parent.height / 10
                                anchors.horizontalCenter: parent.horizontalCenter

                                visible: text !== ""

                                Behavior on opacity { NumberAnimation { duration: 250 } }
                                opacity: visible ? 1.0 : 0.0
                            }

                            ListView {
                                id: imageList
                                width: parent.width
                                height: parent.height / 1.5
                                boundsMovement: Flickable.StopAtBounds
                                orientation: ListView.Horizontal
                                anchors.bottom: parent.bottom
                                spacing: width / 50
                                clip: true
                                model: editInfoPopup.tempImages

                                property var parentPopup: editInfoPopup

                                leftMargin: Math.max(0, (width - contentWidth) / 2)
                                rightMargin: leftMargin

                                Behavior on contentX {
                                    NumberAnimation {
                                        duration: 15
                                    }
                                }

                                delegate: RButton {
                                    width: imageList.width / 7
                                    height: width
                                    anchors.bottom: parent.bottom
                                    pressedColor: "#676767"
                                    hoverColor: "#3e3e3e"
                                    bcolor: modelData === editInfoPopup.mainImageUrl ? "#ff9a00" : "#2a2a2a"
                                    radii: width / 10

                                    onTapped: {
                                        editInfoPopup.mainImageUrl = modelData
                                        console.log("Selected main image: " + modelData)
                                    }

                                    Text {
                                        text: "MAIN"
                                        visible: modelData === editInfoPopup.mainImageUrl
                                        font.family: antonFont.name
                                        font.pixelSize: parent.width / 5
                                        color: "white"
                                        anchors.top: parent.top
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.bottomMargin: parent.height / 20
                                    }

                                    RButton {
                                        id: deleteImageButton
                                        width: parent.width / 3
                                        height: width
                                        anchors.right: parent.right
                                        anchors.rightMargin: -width / 2.8
                                        anchors.topMargin: -width / 2.8
                                        anchors.top: parent.top
                                        radii: width
                                        bcolor: "#ac0000"
                                        pressedColor: "#660000"
                                        z: 1

                                        onTapped: {
                                            var popup = imageList.parentPopup
                                            var list = Array.from(popup.tempImages)
                                            var urlToDelete = list[index]
                                            list.splice(index, 1)
                                            popup.tempImages = list
                                            var queue = Array.from(popup.uploadedUrls)
                                            var queueIndex = queue.indexOf(urlToDelete)

                                            if(popup.mainImageUrl === urlToDelete) {
                                                if(list.length > 0) {
                                                    popup.mainImageUrl = list[0]
                                                } else if (popup.systemData && popup.systemData.category_image) {
                                                    popup.mainImageUrl = popup.systemData.category_image
                                                } else {
                                                    popup.mainImageUrl = ""
                                                }
                                            }

                                            if (queueIndex !== -1) {
                                                console.log("Removing deleted image from save queue: " + urlToDelete)
                                                queue.splice(queueIndex, 1)
                                                popup.uploadedUrls = queue
                                            }
                                        }
                                        Image {
                                            width: parent.width * 0.8
                                            height: parent.height * 0.8
                                            anchors.centerIn: parent
                                            source: "images/close-large-line.svg"
                                            fillMode: Image.PreserveAspectFit
                                        }
                                    }

                                    Image {
                                        id: delegateImage
                                        source: modelData
                                        fillMode: Image.PreserveAspectFit
                                        width: parent.width * 0.9
                                        height: width
                                        anchors.centerIn: parent
                                    }
                                }

                                ScrollBar.horizontal: ScrollBar {
                                    policy: ScrollBar.AsNeeded
                                }

                                WheelHandler {
                                    target: imageList
                                    property: "contentX"
                                    rotationScale: -1
                                    enabled: imageList.contentWidth > imageList.width
                                }
                            }
                        }
                    }

                    RButton {
                        id: saveButton
                        width: parent.width / 2
                        height: parent.height / 12
                        pressedColor: "#ffbb7d"
                        hoverColor: "#ff9534"
                        bcolor: editInfoPopup.isSaving ? "grey" : "dark orange"
                        anchors.horizontalCenter: parent.horizontalCenter
                        canClick: !editInfoPopup.isSaving
                        canHover: !editInfoPopup.isSaving

                        onTapped: {
                            var finalMainImg = editInfoPopup.mainImageUrl
                            if (finalMainImg === "" && editInfoPopup.tempImages.length > 0) {
                                finalMainImg = editInfoPopup.tempImages[0]
                            }

                            SupabaseClient.addContribution(
                                        editInfoPopup.systemData.system_name,
                                        JournalManager.cmdrName,
                                        field.text,
                                        thustheotherfieldlieshere.text,
                                        finalMainImg
                                        );

                            var currentQueue = editInfoPopup.uploadedUrls
                            for (var i = 0; i < currentQueue.length; i++) {
                                var urlToSave = currentQueue[i]

                                if (editInfoPopup.tempImages.indexOf(urlToSave) !== -1) {
                                    SupabaseClient.saveSystemImage(
                                                editInfoPopup.systemData.system_name,
                                                JournalManager.cmdrName,
                                                urlToSave
                                                );
                                }
                            }
                            editInfoPopup.uploadedUrls = []

                            var originals = editInfoPopup.originalImages
                            var currents = editInfoPopup.tempImages

                            for (var j = 0; j < originals.length; j++) {
                                var oldImg = originals[j]

                                if (currents.indexOf(oldImg) === -1) {
                                    console.log("Deleting removed image from DB: " + oldImg)
                                    SupabaseClient.removeScreenshot(
                                                editInfoPopup.systemData.system_name,
                                                JournalManager.cmdrName,
                                                oldImg
                                                );
                                }
                            }
                            editInfoPopup.isSaving = true
                        }
                        Text {
                            text: editInfoPopup.isSaving ? "Saving..." : "Save"
                            font.family: antonFont.name
                            font.pixelSize: parent.width / 10
                            color: "white"
                            anchors.centerIn: parent
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: effect
        color: "black"
        anchors.fill: parent
        opacity: 0
        z: 1

        property int rectangle: 0

        OpacityAnimator {
            id: effecter
            target: effect
            to: 0
            duration: 500
        }

        OpacityAnimator {
            id: uneffecter
            target: effect
            to: 1
            duration: 500

            onFinished: {
                console.log("Animation finished! Target: " + effect.rectangle)
                if (effect.rectangle === 0) {
                    effecter.start()
                    interfaceHolder.enabled = false
                    recordsInterface.enabled = true
                    recordsInterface.opacity = 1
                } else if(effect.rectangle === 1) {
                    effecter.start()
                    interfaceHolder.enabled = true
                    interfaceHolder.opacity = 1
                } else if(effect.rectangle === 2) {
                    effecter.start()
                    interfaceHolder.enabled = false
                    plotter.enabled = true
                    plotter.opacity = 1
                }
            }
        }
    }

    Rectangle {
        id: interfaceHolder
        color: "#2e2e2e"
        anchors.fill: parent

        Behavior on opacity {
            NumberAnimation {
                duration: 500
            }
        }

        Rectangle {
            id: topbar
            color: "orange"
            width: parent.width
            height: parent.height / 8

            gradient: Gradient {
                GradientStop { position: 0; color: "orange" }
                GradientStop { position: 1; color: "#c68000" }
            }

            Image {
                id: logo
                width: parent.width / 14
                height: width
                anchors.horizontalCenter: parent.horizontalCenter
                source: "images/logo.png"
                asynchronous: true
            }

            RButton {
                id: discordBtn
                pressedColor: "dark orange"
                hoverColor: "#00658c"
                width: height
                height: parent.height
                anchors.right: parent.right
                radii: 0
                canHover: false
                bcolor: "#00000000"

                onTapped: {
                    Qt.openUrlExternally("https://discord.gg/qNwtA6XVVT")
                }

                Image {
                    id: imgDiscord
                    anchors.right: parent.right
                    width: parent.height
                    height: width
                    source: "images/discord-fill.svg"
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    smooth: true
                }
            }

            RButton {
                id: infoBtn
                pressedColor: "dark orange"
                hoverColor: "#00658c"
                width: height
                height: parent.height
                anchors.left: parent.left
                radii: 0
                canHover: false
                bcolor: "#00000000"

                onTapped: {
                    infoPopup.open()
                }

                Image {
                    id: imgInfo
                    anchors.right: parent.right
                    source: "images/information-2-lines.svg"
                    width: parent.height
                    height: width
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    smooth: true
                }
            }
        }

        Rectangle {
            id: bottomBar
            color: "orange"
            width: parent.width
            height: parent.height / 8
            anchors.bottom: parent.bottom

            gradient: Gradient {
                GradientStop { position: 0; color: "orange" }
                GradientStop { position: 1; color: "#c68000" }
            }

            Text {
                id: cmdrname
                color: "white"
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                leftPadding: parent.width / 50
                font.wordSpacing: 0
                width: parent.width / 2
                height: parent.height
                text: "Welcome CMDR " + JournalManager.cmdrName
                font.pixelSize: parent.width / 40
                font.family: antonFont.name

                DesignEffect {
                    effects: [
                        DesignDropShadow {
                        }
                    ]
                }
            }

            Text {
                id: versionNum
                color: "white"
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                rightPadding: parent.width / 50
                font.wordSpacing: 0
                width: parent.width / 2
                height: parent.height
                text: root.appVersion
                font.pixelSize: parent.width / 40
                font.family: antonFont.name
                anchors.right: parent.right

                DesignEffect {
                    effects: [
                        DesignDropShadow {
                        }
                    ]
                }
            }
        }

        ScrollView {
            id: scroller
            width: parent.width
            height: parent.height - (parent.height / 8 * 2)
            anchors.verticalCenter: parent.verticalCenter
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOn

            Row {
                id: row
                width: scroller.width
                height: scroller.height

                RButton {
                    id: records
                    width: scroller.width / 3
                    height: scroller.height
                    pressedColor: "#ffffff"
                    radii: 0
                    bcolor: "transparent"
                    canHover: false

                    signal affecterDone()

                    onTapped: {
                        if(effect.opacity === 0) {
                            effect.rectangle = 0
                            interfaceHolder.opacity = 0
                            uneffecter.start()
                        }
                    }

                    Image {
                        width: parent.width
                        height: parent.height
                        source: "images/recordsBg.png"
                        fillMode: Image.PreserveAspectCrop
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            blur: 0.5
                            blurEnabled: true
                        }
                    }

                    Text {
                        id: recordstitle
                        color: "white"
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignTop
                        font.wordSpacing: 0
                        width: parent.width / 1.5
                        height: parent.height / 4
                        text: "The Records"
                        font.pixelSize: parent.width / 8
                        font.family: antonFont.name
                        x: width / 30

                        DesignEffect {
                            effects: [
                                DesignDropShadow {
                                }
                            ]
                        }
                    }

                    Text {
                        color: "white"
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignTop
                        wrapMode: Text.Wrap
                        font.family: loraFont.name
                        font.wordSpacing: 0
                        width: parent.width / 1.5
                        height: parent.height / 1
                        text: "A plethora of extremely remarkable systems. These systems are uncatalogued and only identified from datasets."
                        font.pixelSize: parent.width / 16
                        y: recordstitle.height - height / 8
                        x: width / 30

                        DesignEffect {
                            effects: [
                                DesignDropShadow {
                                }
                            ]
                        }
                    }
                }

                RButton {
                    id: galaxyPlotter
                    width: scroller.width / 3
                    height: scroller.height
                    pressedColor: "#ffffff"
                    radii: 0
                    bcolor: "transparent"
                    canHover: false

                    signal affecterDone()

                    onTapped: {
                        if(effect.opacity === 0) {
                            effect.rectangle = 2
                            interfaceHolder.opacity = 0
                            uneffecter.start()
                        }
                    }

                    Image {
                        width: parent.width
                        height: parent.height
                        source: "images/plotter2.png"
                        fillMode: Image.PreserveAspectCrop
                    }

                    Text {
                        id: plotterTitle
                        color: "white"
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignTop
                        font.wordSpacing: 0
                        width: parent.width / 1.2
                        height: parent.height / 4
                        text: "Galaxy Plotter"
                        font.pixelSize: parent.width / 8
                        font.family: antonFont.name
                        x: width / 30

                        DesignEffect {
                            effects: [
                                DesignDropShadow {
                                }
                            ]
                        }
                    }

                    Text {
                        color: "white"
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignTop
                        wrapMode: Text.Wrap
                        font.family: loraFont.name
                        font.wordSpacing: 0
                        width: parent.width / 1.1
                        height: parent.height / 3
                        text: "Advanced plotter provided by Spansh. It'll take care of fuel, neutron supercharges, and injection boosts."
                        font.pixelSize: parent.width / 16
                        y: recordstitle.height - height / 2.7
                        x: width / 30

                        DesignEffect {
                            effects: [
                                DesignDropShadow {
                                }
                            ]
                        }
                    }
                }

                // RButton {
                //     id: systemMap
                //     width: scroller.width / 3
                //     height: scroller.height
                //     pressedColor: "#ffffff"
                //     radii: 0
                //     bcolor: "transparent"
                //     canHover: false

                //     Image {
                //         width: parent.width
                //         height: parent.height
                //         source: "images/moreLaterBg.png"
                //         fillMode: Image.PreserveAspectCrop
                //         layer.enabled: true
                //         layer.effect: MultiEffect {
                //             blur: 0.5
                //             blurEnabled: true
                //         }
                //     }

                //     Text {
                //         id: systemMapTitle
                //         color: "white"
                //         horizontalAlignment: Text.AlignLeft
                //         verticalAlignment: Text.AlignTop
                //         font.wordSpacing: 0
                //         width: parent.width / 1.5
                //         height: parent.height / 4
                //         text: "System Map"
                //         font.pixelSize: parent.width / 8
                //         font.family: antonFont.name
                //         x: width / 30

                //         DesignEffect {
                //             effects: [
                //                 DesignDropShadow {
                //                 }
                //             ]
                //         }
                //     }

                //     Text {
                //         color: "white"
                //         horizontalAlignment: Text.AlignLeft
                //         verticalAlignment: Text.AlignTop
                //         wrapMode: Text.Wrap
                //         font.family: loraFont.name
                //         font.wordSpacing: 0
                //         width: parent.width / 1.5
                //         height: parent.height / 4
                //         text: "A system map viewer to see systems without visiting them."
                //         font.pixelSize: parent.width / 16
                //         y: morelaterTitle.height - height / 2
                //         x: width / 30

                //         DesignEffect {
                //             effects: [
                //                 DesignDropShadow {
                //                 }
                //             ]
                //         }
                //     }
                // }

                RButton {
                    id: morelater
                    width: scroller.width / 3
                    height: scroller.height
                    pressedColor: "#ffffff"
                    radii: 0
                    bcolor: "transparent"
                    canHover: false

                    Image {
                        width: parent.width
                        height: parent.height
                        source: "images/moreLaterBg.png"
                        fillMode: Image.PreserveAspectCrop
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            blur: 0.5
                            blurEnabled: true
                        }
                    }

                    Text {
                        id: morelaterTitle
                        color: "white"
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignTop
                        font.wordSpacing: 0
                        width: parent.width / 1.5
                        height: parent.height / 4
                        text: "More soon..."
                        font.pixelSize: parent.width / 8
                        font.family: antonFont.name
                        x: width / 30

                        DesignEffect {
                            effects: [
                                DesignDropShadow {
                                }
                            ]
                        }
                    }

                    Text {
                        color: "white"
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignTop
                        wrapMode: Text.Wrap
                        font.family: loraFont.name
                        font.wordSpacing: 0
                        width: parent.width / 1.5
                        height: parent.height / 4
                        text: "Explorarium will recieve new content later on in development."
                        font.pixelSize: parent.width / 16
                        y: morelaterTitle.height - height / 2
                        x: width / 30

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

    Rectangle {
        id: recordsInterface
        color: "#2e2e2e"
        anchors.fill: parent
        enabled: false
        opacity: 0

        Behavior on opacity { NumberAnimation { duration: 500}}

        property real sidebarwidth: 3.5

        Rectangle {
            id: leftSideBar
            color: "#1a1a1a"
            gradient: Gradient {
                GradientStop { position: 0; color: "#2a2a2a" }
                GradientStop { position: 1; color: "#1a1a1a" }
            }
            width: recordsInterface.width / recordsInterface.sidebarwidth
            height: recordsInterface.height

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
                    if(effect.opacity === 0) {
                        effect.rectangle = 1
                        recordsInterface.enabled = false
                        recordsInterface.opacity = 0
                        uneffecter.start()
                    }
                }
            }

            Column {
                width: parent.width
                height: parent.height - (parent.height / 12)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: parent.height / 12
                spacing: parent.height / 80

                Rectangle {
                    id: borderCardUser
                    width: parent.width / 1.03
                    height: parent.height / 4
                    radius: width / 30
                    color: "#333333"
                    Rectangle {
                        id: cardUser
                        width: parent.width - (parent.height / 59)
                        height: parent.height - (parent.height / 59)
                        anchors.centerIn: parent
                        color: "#2e2e2e"
                        radius: parent.radius

                        Item {
                            id: userHolder
                            anchors.fill: parent
                            z: 1

                            Text {
                                id: cmdrNameTitle
                                font.family: antonFont.name
                                width: parent.width
                                height: parent.height / 3
                                anchors.top: commanderTitle.bottom
                                text: "CMDR " + JournalManager.cmdrName
                                font.pixelSize: parent.width / 10
                                fontSizeMode: Text.Fit
                                leftPadding: parent.width / 50
                                color: "white"
                            }

                            Text {
                                id: systemLocTitle
                                font.family: antonFont.name
                                width: parent.width
                                height: parent.height / 2.5
                                anchors.top: systemTitle.bottom
                                text: JournalManager.location
                                font.pixelSize: parent.width / 12
                                verticalAlignment: Text.AlignVCenter
                                fontSizeMode: Text.Fit
                                padding: parent.width / 50
                                color: "white"
                            }

                            Text {
                                id: commanderTitle
                                font.family: antonFont.name
                                width: parent.width / 5
                                height: parent.height / 8
                                text: "COMMANDER"
                                font.pixelSize: parent.width / 30
                                verticalAlignment: Text.AlignTop
                                padding: parent.width / 50
                                color: "orange"

                                Rectangle {
                                    id: thisISALINEBROWHATAAAAAA
                                    width: cardUser.width - commanderTitle.width - (cardUser.width / 50)
                                    height: parent.height / 10
                                    anchors.left: parent.right
                                    color: "orange"
                                    anchors.top: parent.top
                                    anchors.topMargin: parent.height * 0.6
                                }
                            }

                            Text {
                                id: systemTitle
                                font.family: antonFont.name
                                width: parent.width / 4
                                height: parent.height / 8
                                text: "CURRENT SYSTEM"
                                font.pixelSize: parent.width / 30
                                verticalAlignment: Text.AlignTop
                                anchors.top: cmdrNameTitle.bottom
                                padding: parent.width / 50
                                color: "orange"

                                Rectangle {
                                    id: thisISANOTHERLINEBROWHATAAAAAA
                                    width: cardUser.width - systemTitle.width - (cardUser.width / 50)
                                    height: parent.height / 10
                                    anchors.left: parent.right
                                    color: "orange"
                                    anchors.top: parent.top
                                    anchors.topMargin: parent.height * 0.6
                                }
                            }
                        }
                        Image {
                            id: logoUser
                            source: "images/user-line.svg"
                            asynchronous: true
                            fillMode: Image.PreserveAspectFit
                            anchors.centerIn: parent
                            height: parent.height
                            width: parent.width
                            z: 0
                            opacity: 0.2
                        }
                    }
                }

                Rectangle {
                    id: statsCard
                    width: parent.width / 1.03
                    height: parent.height / 4
                    radius: width / 30
                    color: "#333333"
                    Rectangle {
                        id: cardstats
                        width: parent.width - (parent.height / 59)
                        height: parent.height - (parent.height / 59)
                        anchors.centerIn: parent
                        color: "#2e2e2e"
                        radius: parent.radius

                        Item {
                            id: statsHolder
                            anchors.fill: parent
                            z: 1
                            Text {
                                id: sysClaimed
                                font.family: antonFont.name
                                width: parent.width / 5
                                height: parent.height / 7
                                text: "YOUR CLAIMS"
                                font.pixelSize: parent.width / 30
                                verticalAlignment: Text.AlignTop
                                padding: parent.width / 50
                                color: "orange"

                                Rectangle {
                                    id: randomLine1
                                    width: cardUser.width - sysClaimed.width - (cardUser.width / 50)
                                    height: parent.height / 10
                                    anchors.left: parent.right
                                    color: "orange"
                                    anchors.top: parent.top
                                    anchors.topMargin: parent.height * 0.6
                                }
                            }

                            Text {
                                id: sessiontime
                                font.family: antonFont.name
                                width: parent.width / 4.5
                                height: parent.height / 8
                                text: "SESSION TIME"
                                font.pixelSize: parent.width / 30
                                verticalAlignment: Text.AlignTop
                                padding: parent.width / 50
                                anchors.top: claimedSystemText.bottom
                                color: "orange"

                                Rectangle {
                                    id: randomLine2
                                    width: cardUser.width - sessiontime.width - (cardUser.width / 50)
                                    height: parent.height / 10
                                    anchors.left: parent.right
                                    color: "orange"
                                    anchors.top: parent.top
                                    anchors.topMargin: parent.height * 0.6
                                }
                            }

                            Text {
                                id: claimedSystemText
                                font.family: antonFont.name
                                width: parent.width
                                height: parent.height / 3
                                anchors.top: sysClaimed.bottom
                                text: "Claimed Systems: " + SupabaseClient.YourClaimed
                                font.pixelSize: parent.width / 12
                                padding: parent.width / 50
                                color: "white"
                            }

                            Text {
                                id: sessionText
                                font.family: antonFont.name
                                width: parent.width
                                height: parent.height / 2.5
                                anchors.top: sessiontime.bottom
                                text: duration
                                font.pixelSize: parent.width / 10
                                padding: parent.width / 50
                                color: "white"

                                property int elapsedSeconds: 0
                                property string duration: "0h:00m:00s"

                                Timer {
                                    interval: 1000
                                    running: true
                                    repeat: true
                                    onTriggered: {
                                        parent.elapsedSeconds++
                                        var hours = Math.floor(parent.elapsedSeconds / 3600)
                                        var mins = Math.floor((parent.elapsedSeconds % 3600) / 60)
                                        var secs = parent.elapsedSeconds % 60
                                        parent.duration = hours + "h:" +
                                                (mins < 10 ? "0" + mins : mins) + "m:" +
                                                (secs < 10 ? "0" + secs : secs) + "s"
                                    }
                                }
                            }
                        }

                        Image {
                            id: logoStat
                            source: "images/line-chart-line.svg"
                            asynchronous: true
                            fillMode: Image.PreserveAspectFit
                            anchors.centerIn: parent
                            height: parent.height
                            width: parent.width
                            z: 0
                            opacity: 0.2
                        }
                    }
                }

                Rectangle {
                    id: dbInfoBorder
                    width: parent.width / 1.03
                    height: parent.height / 2.2
                    radius: width / 30
                    color: "#333333"
                    Rectangle {
                        id: dbInfo
                        width: parent.width - (parent.height / 59)
                        height: parent.height - (parent.height / 59)
                        anchors.centerIn: parent
                        color: "#2e2e2e"
                        radius: parent.radius

                        Item {
                            id: holderDb
                            anchors.fill: parent
                            z: 2
                            Text {
                                id: totalSys
                                font.family: antonFont.name
                                width: parent.width / 4
                                height: parent.height / 10
                                text: "TOTAL SYSTEMS"
                                font.pixelSize: parent.width / 30
                                verticalAlignment: Text.AlignTop
                                padding: parent.width / 50
                                color: "orange"
                                z: 1

                                Rectangle {
                                    id: randomLine3
                                    width: cardUser.width - totalSys.width - (cardUser.width / 50)
                                    height: parent.height / 16
                                    anchors.left: parent.right
                                    color: "orange"
                                    anchors.top: parent.top
                                    anchors.topMargin: parent.height * 0.45
                                }
                            }

                            Text {
                                id: lastUpdated
                                font.family: antonFont.name
                                width: parent.width / 4
                                height: parent.height / 10
                                text: "LAST UPDATED"
                                font.pixelSize: parent.width / 30
                                verticalAlignment: Text.AlignTop
                                padding: parent.width / 50
                                anchors.top: totalSysText.bottom
                                color: "orange"
                                z: 1

                                Rectangle {
                                    id: randomLine4
                                    width: cardUser.width - lastUpdated.width - (cardUser.width / 50)
                                    height: parent.height / 16
                                    anchors.left: parent.right
                                    color: "orange"
                                    anchors.top: parent.top
                                    anchors.topMargin: parent.height * 0.45
                                }
                            }

                            Text {
                                id: newthisweek
                                font.family: antonFont.name
                                width: parent.width / 2.8
                                height: parent.height / 10
                                text: "AMOUNT OF LATEST QUERY"
                                font.pixelSize: parent.width / 30
                                verticalAlignment: Text.AlignTop
                                padding: parent.width / 50
                                anchors.top: lastUpdatedText.bottom
                                color: "orange"
                                z: 1

                                Rectangle {
                                    id: randomLine5
                                    width: cardUser.width - newthisweek.width - (cardUser.width / 50)
                                    height: parent.height / 16
                                    anchors.left: parent.right
                                    color: "orange"
                                    anchors.top: parent.top
                                    anchors.topMargin: parent.height * 0.45
                                }
                            }

                            Text {
                                id: systemsClaimed
                                font.family: antonFont.name
                                width: parent.width / 3
                                height: parent.height / 10
                                text: "TOTAL CLAIMED SYSTEMS"
                                font.pixelSize: parent.width / 30
                                verticalAlignment: Text.AlignTop
                                padding: parent.width / 50
                                anchors.top: newthisweekText.bottom
                                color: "orange"
                                z: 1

                                Rectangle {
                                    id: randomLine6
                                    width: cardUser.width - systemsClaimed.width - (cardUser.width / 50)
                                    height: parent.height / 16
                                    anchors.left: parent.right
                                    color: "orange"
                                    anchors.top: parent.top
                                    anchors.topMargin: parent.height * 0.45
                                }
                            }

                            Text {
                                id: totalSysText
                                font.family: antonFont.name
                                width: parent.width
                                height: parent.height / 7
                                anchors.top: totalSys.bottom
                                text: "Systems: " + SupabaseClient.totalSystems
                                font.pixelSize: parent.width / 12
                                leftPadding: parent.width / 50
                                color: "white"
                                z: 1
                            }

                            Text {
                                id: lastUpdatedText
                                font.family: antonFont.name
                                width: parent.width
                                height: parent.height / 7
                                anchors.top: lastUpdated.bottom
                                text: SupabaseClient.lastUpdated
                                font.pixelSize: parent.width / 12
                                leftPadding: parent.width / 50
                                color: "white"
                                z: 1
                            }

                            Text {
                                id: newthisweekText
                                font.family: antonFont.name
                                width: parent.width
                                height: parent.height / 7
                                anchors.top: newthisweek.bottom
                                text: SupabaseClient.NewThisWeek
                                font.pixelSize: parent.width / 12
                                leftPadding: parent.width / 50
                                color: "white"
                                z: 1
                            }

                            Text {
                                id: systemsClaimedText
                                font.family: antonFont.name
                                width: parent.width
                                height: parent.height / 7
                                anchors.top: systemsClaimed.bottom
                                text: SupabaseClient.ClaimedSystems + " Systems Claimed"
                                font.pixelSize: parent.width / 12
                                leftPadding: parent.width / 50
                                color: "white"
                                z: 1
                            }
                        }

                        Image {
                            id: logoDb
                            source: "images/database-2-line.svg"
                            asynchronous: true
                            fillMode: Image.PreserveAspectFit
                            anchors.centerIn: parent
                            height: parent.height
                            width: parent.width
                            z: 1
                            opacity: 0.2
                        }
                    }
                }
            }
        }

        Rectangle {
            id: rightSideBar
            color: "orange"
            gradient: Gradient {
                GradientStop { position: 0; color: "#2a2a2a" }
                GradientStop { position: 1; color: "#1a1a1a" }
            }
            width: recordsInterface.width / recordsInterface.sidebarwidth
            height: recordsInterface.height
            anchors.right: recordsInterface.right

            Column {
                id: rightSideCardColumn
                height: parent.height
                width: parent.width / 1.03
                anchors.top: parent.top
                x: parent.x / 80
                spacing: parent.height / 80
                anchors.topMargin: parent.height / 50
                Rectangle {
                    id: filterCardBorder
                    width: parent.width / 1.03
                    height: parent.height / 4
                    radius: width / 30
                    color: "#333333"
                    Rectangle {
                        id: cardFilter
                        width: parent.width - (parent.height / 59)
                        height: parent.height - (parent.height / 59)
                        anchors.centerIn: parent
                        color: "#2e2e2e"
                        radius: parent.radius

                        Item {
                            id: filterHolder
                            anchors.fill: parent
                            z: 1

                            RButton {
                                id: comboBoxBg
                                width: parent.width / 1.1
                                height: parent.height / 4
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: frameOpenThingTitle.bottom
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
                                            openBorder.start()
                                        } else {
                                            comboEnabled = !comboEnabled
                                            comboBoxImg.rotation = 0
                                            closeBox.start()
                                            closeBorder.start()
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

                            RButton {
                                id: statusBoxBg
                                width: parent.width / 1.1
                                height: parent.height / 4
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: statusFilter.bottom
                                anchors.topMargin: (parent.height / 10) / 2
                                enabled: !comboBoxBg.comboEnabled
                                canHover: !comboBoxBg.comboEnabled
                                pressedColor: "#c4c4c4"
                                hoverColor: "#626262"
                                radii: width / 100
                                bcolor: "#4f4f4f"
                                z: 3

                                property bool comboEnabled: false

                                onTapped: {
                                    if(!openBox2.running && !closeBox2.running) {
                                        if(comboEnabled === false) {
                                            comboEnabled = !comboEnabled
                                            frameOpenThing2.opacity = 1
                                            statusBoxImg.rotation = 180
                                            openBox2.start()
                                            openBorder2.start()
                                        } else {
                                            comboEnabled = !comboEnabled
                                            statusBoxImg.rotation = 0
                                            closeBox2.start()
                                            closeBorder2.start()
                                        }
                                    }
                                }

                                Image {
                                    id: statusBoxImg
                                    height: parent.height
                                    source: "images/arrow-down-s-line.svg"
                                    fillMode: Image.PreserveAspectFit
                                    anchors.right: parent.right
                                    anchors.rightMargin: height / 10
                                }
                            }

                            Text {
                                id: frameOpenThingTitle
                                font.family: antonFont.name
                                width: parent.width / 4
                                height: parent.height / 8
                                text: "CATEGORY FILTER"
                                font.pixelSize: parent.width / 30
                                verticalAlignment: Text.AlignTop
                                padding: parent.width / 50
                                color: "orange"
                                z: 1

                                Rectangle {
                                    id: line1
                                    width: filterHolder.width - parent.width - (filterHolder.width / 50)
                                    height: parent.height / 10
                                    anchors.left: parent.right
                                    color: "orange"
                                    anchors.top: parent.top
                                    anchors.topMargin: parent.height * 0.6
                                }
                            }

                            Text {
                                id: statusFilter
                                font.family: antonFont.name
                                width: parent.width / 4
                                height: parent.height / 8
                                text: "STATUS FILTER"
                                font.pixelSize: parent.width / 30
                                verticalAlignment: Text.AlignTop
                                padding: parent.width / 50
                                color: "orange"
                                z: 1
                                anchors.top: comboBoxBg.bottom

                                Rectangle {
                                    id: line2
                                    width: filterHolder.width - parent.width - (filterHolder.width / 50)
                                    height: parent.height / 10
                                    anchors.left: parent.right
                                    color: "orange"
                                    anchors.top: parent.top
                                    anchors.topMargin: parent.height * 0.6
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
                                id: statusBorder
                                width: statusBoxBg.width + parent.width / 50
                                height: statusBoxBg.height + parent.height / 40
                                color: "#5f5f5f"
                                x: statusBoxBg.x - (parent.width / 50) / 2
                                y: statusBoxBg.y - (parent.height / 40) / 2
                                z: 2
                                radius: statusBoxBg.radii

                                PropertyAnimation {
                                    id: openBorder2
                                    target: statusBorder
                                    property: "height"
                                    to: statusBoxBg.height * 6 + filterHolder.height / 40
                                    duration: 350
                                }

                                PropertyAnimation {
                                    id: closeBorder2
                                    target: statusBorder
                                    property: "height"
                                    to: statusBoxBg.height + filterHolder.height / 40
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
                                    cacheBuffer: 0

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
                                                CategoryProxy.toggleCategory(model.category_name)
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
                                                    opacity: CategoryProxy.selectedCategories.indexOf(model.category_name) >= 0 ? 1 : 0
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
                                                asynchronous: true
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

                            Rectangle {
                                id: frameOpenThing2
                                width: statusBoxBg.width // this never changes
                                height: statusBoxBg.height
                                PropertyAnimation {
                                    id: openBox2
                                    target: frameOpenThing2
                                    property: "height"
                                    to: statusBoxBg.height * 6
                                    duration: 350
                                }

                                PropertyAnimation {
                                    id: closeBox2
                                    target: frameOpenThing2
                                    property: "height"
                                    to: statusBoxBg.height
                                    duration: 350

                                    onFinished: {
                                        frameOpenThing2.opacity = 0
                                    }
                                }

                                anchors.horizontalCenter: statusBoxBg.horizontalCenter
                                y: statusBoxBg.y
                                z: 2
                                radius: statusBoxBg.radii
                                opacity: 0
                                color: statusBoxBg.bcolor

                                property int selectedIndex: 0 // by default closest is selected


                                ListView {
                                    id: statusScroll
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
                                        id: filterComponent2

                                        RButton {
                                            id: clickComponent
                                            width: statusScroll.width
                                            height: statusScroll.height / 5
                                            radii: 0
                                            bcolor: "grey"
                                            hoverColor: "dark orange"
                                            pressedColor: "orange"
                                            enabled: frameOpenThing2.opacity === 1

                                            onTapped: {
                                                if(model.value === 2) {
                                                    CategoryProxy.showOnlyClaims = !CategoryProxy.showOnlyClaims
                                                } else {
                                                    frameOpenThing2.selectedIndex = index
                                                    SupabaseClient.sortMode = model.value
                                                }
                                            }

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
                                                    opacity: {
                                                        if (model.value === 2) {
                                                            return CategoryProxy.showOnlyClaims ? 1 : 0
                                                        } else {
                                                            return index === frameOpenThing2.selectedIndex ? 1 : 0
                                                        }
                                                    }
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
                                                text: model.name
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
                                                source: model.source
                                                fillMode: Image.PreserveAspectCrop
                                                width: parent.width
                                                height: parent.height
                                                opacity: 0.5
                                            }
                                        }
                                    }
                                    model: ListModel {
                                        id: statusListModel
                                        ListElement {name: "Closest First"; source: "images/closestFirstSource.jpg"; value: 0}
                                        ListElement {name: "Furthest First"; source: "images/furthestFirstSource.jpeg"; value: 1}
                                        ListElement {name: "Only My Claims"; source: "images/claimsSource.jpg"; value: 2}
                                    }

                                    delegate: filterComponent2
                                }
                            }
                        }

                        Image {
                            id: logoFilter
                            source: "images/filter-line.svg"
                            asynchronous: true
                            fillMode: Image.PreserveAspectFit
                            anchors.centerIn: parent
                            height: parent.height
                            width: parent.width
                            z: 0
                            opacity: 0.2
                        }
                    }
                }

                Rectangle {
                    id: actionsCard
                    width: parent.width / 1.03
                    height: parent.height / 4
                    radius: width / 30
                    color: "#333333"
                    z: -1
                    Rectangle {
                        id: cardactions
                        width: parent.width - (parent.height / 59)
                        height: parent.height - (parent.height / 59)
                        anchors.centerIn: parent
                        color: "#2e2e2e"
                        radius: parent.radius

                        Item {
                            id: actionsHolder
                            anchors.fill: parent
                            z: 1

                            Rectangle {
                                id: masking
                                width: parent.width
                                height: parent.height / 2.5
                                radius: width / 30
                                layer.enabled: true
                                visible: false
                            }

                            Image {
                                id: sourceImage
                                source: "images/E47CDFX.png"
                                fillMode: Image.PreserveAspectCrop
                                width: parent.width
                                anchors.top: parent.top
                                anchors.topMargin: height / 5
                                height: parent.height / 2.5
                                opacity: 1
                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    maskEnabled: true
                                    maskSource: masking
                                }

                                RButton {
                                    id: galaxyMapButton
                                    canHover: !statusBoxBg.comboEnabled && !comboBoxBg.comboEnabled
                                    width: parent.width
                                    height: parent.height
                                    enabled: !statusBoxBg.comboEnabled && !comboBoxBg.comboEnabled
                                    radii: width / 30
                                    bcolor: "transparent"
                                    opacity: 1
                                    hoverColor: "#7eb3b3b3"
                                    pressedColor: "#87ffdfb7"

                                    onTapped: {
                                        galaxyMapPopup.open()
                                    }

                                    Text {
                                        text: "Galaxy Map"
                                        font.family: antonFont.name
                                        anchors.centerIn: parent
                                        font.pixelSize: parent.width / 10
                                        color: "white"

                                        DesignEffect {
                                            effects: [
                                                DesignDropShadow {
                                                }
                                            ]
                                        }
                                    }
                                }
                            }

                            RButton {
                                id: settings
                                canHover: !statusBoxBg.comboEnabled && !comboBoxBg.comboEnabled
                                width: parent.width
                                height: parent.height / 2.5
                                radii: width / 30
                                anchors.top: sourceImage.bottom
                                anchors.topMargin: height / 10
                                enabled: !statusBoxBg.comboEnabled && !comboBoxBg.comboEnabled
                                bcolor: "#434343"
                                opacity: 1
                                hoverColor: "#777777"
                                pressedColor: "#bebebe"

                                onTapped: {
                                    settingsPopup.open()
                                }

                                Image {
                                    source: "images/settings-4-line.svg"
                                    fillMode: Image.PreserveAspectFit
                                    anchors.fill: parent
                                }
                            }
                        }
                    }
                }
            }
        }


        ListView {
            id: middleBar
            height: parent.height
            synchronousDrag: true
            width: parent.width - (parent.width / parent.sidebarwidth * 2)
            anchors.centerIn: parent
            spacing: recordsInterface.height / 60
            reuseItems: true
            cacheBuffer: 0

            enabled: !galaxyMapPopup.actualPopup.visible

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

            model: CategoryProxy
            delegate: SystemCard {
                width: middleBar.width
                height: middleBar.height / 6
                systemName: model.system_name || ""
                displayTitle: model.title || ""
                mainImage: (model.main_image && typeof model.main_image === "string")
                           ? model.main_image
                           : "images/recordsBg.png"
                category_text: model.category ? model.category.join(", ") : ""
                distance: model.distance || "Unknown"
                onTapped: {
                    if(!systemViewPopup.visible) {
                        var cleanData = model.systemData
                        systemViewPopup.systemData = cleanData
                        systemViewPopup.open()
                    }
                }
            }

            // footer: Item {
            //     id: wrapper
            //     width: ListView.view.width
            //     height: recordsInterface.height / 8
            //     RButton {
            //         id: moreButton
            //         width: parent.width / 1.5
            //         anchors.centerIn: parent
            //         height: recordsInterface.height / 10
            //         radii: width / 30
            //         bcolor: "#ff7700"
            //         hoverColor: "dark orange"
            //         pressedColor: "orange"
            //         Text {
            //             id: buttonText
            //             color: "white"
            //             horizontalAlignment: Text.AlignHCenter
            //             verticalAlignment: Text.AlignVCenter
            //             font.wordSpacing: 0
            //             width: parent.width
            //             height: parent.height
            //             text: "Show More"
            //             font.pixelSize: parent.width / 8
            //             anchors.centerIn: parent
            //             font.family: antonFont.name

            //             DesignEffect {
            //                 effects: [
            //                     DesignDropShadow {
            //                     }
            //                 ]
            //             }
            //         }
            //     }
            // }
        }
    }

    GalaxyPlotter {
        id: plotter
        anchors.fill: parent
        opacity: 0
        enabled: false
        onTurnthisoff: {
            if(effect.opacity === 0) {
                effect.rectangle = 1
                plotter.enabled = false
                plotter.opacity = 0
                uneffecter.start()
            }
        }
    }
}

