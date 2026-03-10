import QtQuick
import QtQuick.Controls

Popup {
    id: root
    width: parent.width * 0.8
    height: parent.height * 0.9
    anchors.centerIn: parent
    modal: true
    focus: true
    dim: true
    z: 15

    property string antonFontName: "Anton"
    property string loraFontName: "Lora"

    enter: Transition {
        OpacityAnimator {
            target: infoHolder
            to: 1
            duration: 350
        }

        OpacityAnimator {
            target: infoBg
            to: 1
            duration: 350
        }
    }

    exit: Transition {
        OpacityAnimator {
            target: infoHolder
            to: 0
            duration: 350
        }

        OpacityAnimator {
            target: infoBg
            to: 0
            duration: 350
        }
    }

    background: Rectangle {
        id: infoBg
        opacity: 0
        gradient: Gradient {
            GradientStop { position: 0; color: "#363636" }
            GradientStop { position: 1; color: "#232323" }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: (mouse) => mouse.accepted = true
            onWheel: (wheel) => wheel.accepted = true
            onPressed: (mouse) => mouse.accepted = true
        }
    }

    Item {
        id: infoHolder
        anchors.fill: parent
        opacity: 0

        Item {
            id: header
            width: parent.width
            height: parent.height * 0.1
            anchors.top: parent.top

            Text {
                text: "About The Explorarium"
                color: "white"
                font.family: root.antonFontName
                font.pixelSize: parent.height * 0.5
                anchors.centerIn: parent
            }

            RButton {
                id: infoCloser
                width: parent.width / 20
                height: width
                pressedColor: "#7bd3d3d3"
                radii: width / 10
                bcolor: "transparent"
                canHover: false

                onTapped: {
                    infoPopup.close()
                }

                Image {
                    id: backimageplaceholder4
                    anchors.fill: parent
                    source: "images/close-large-line.svg"
                    fillMode: Image.PreserveAspectFit
                }
            }

            Rectangle {
                width: parent.width * 0.9
                height: 1
                color: "#444"
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Flickable {
            id: infoScroll
            width: parent.width
            anchors.top: header.bottom
            anchors.bottom: parent.bottom
            anchors.topMargin: 20
            anchors.bottomMargin: 20
            contentWidth: width
            contentHeight: contentColumn.height
            interactive: true
            ScrollBar.vertical: ScrollBar { }
            clip: true

            Column {
                id: contentColumn
                width: parent.width - 40
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 25

                Text {
                    text: "Written by Richard Fluiraniz M and Regza." // footnote
                    font.pixelSize: parent.width / 75
                    font.family: root.loraFontName
                    color: "#ffe39f"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "The Explorarium App" // title
                    font.pixelSize: parent.width / 20
                    font.family: root.antonFontName
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    width: parent.width
                    text: '“This app is meant to assist with explorers participating within The Explorarium in finding amazing things and making exploring these systems easier. Our main objective is to make these destinations known and accessible to others. The current version of the app comes with a galaxy router and a galaxy map.”' // footnote
                    font.pixelSize: parent.width / 55
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                    font.family: root.loraFontName
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Rectangle {
                    width: parent.width / 2
                    height: infoHolder.height / 10
                    color: "#72ffc435"
                    radius: width / 15
                    border.color: "#ffd541"
                    border.width: width / 200
                    anchors.horizontalCenter: parent.horizontalCenter

                    Image {
                        id: funnyImage
                        source: "images/whiteError.svg"
                        fillMode: Image.PreserveAspectFit
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.horizontalCenterOffset: -parent.width / 3
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width / 10
                    }

                    Text {
                        text: "App is currently in beta, some bugs might occur!"
                        fontSizeMode: Text.Fit
                        color: "white"
                        font.family: root.loraFontName
                        font.pixelSize: parent.width / 25
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        anchors.left: funnyImage.right
                        anchors.leftMargin: parent.width / 55
                        anchors.right: parent.right
                        anchors.rightMargin: parent.width / 20
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Text {
                    text: "The Records" // title
                    font.pixelSize: parent.width / 30
                    font.family: root.antonFontName
                    color: "#4598ff"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Image {
                    width: parent.width
                    height: infoHolder.height / 2
                    source: "images/Pic1.png"
                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    width: parent.width
                    text: "“A plethora of extremely remarkable systems not documented properly. These systems are uncatalogued and only identified from datasets.” " // footnote
                    font.pixelSize: parent.width / 55
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                    textFormat: Text.RichText
                    font.family: root.loraFontName
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    width: parent.width
                    text: "Currently the main section of the Explorarium." // footnote
                    font.pixelSize: parent.width / 55
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                    textFormat: Text.RichText
                    font.family: root.loraFontName
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    width: parent.width
                    text: "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n<html><head><meta name=\"qrichtext\" content=\"1\" /><meta charset=\"utf-8\" /><style type=\"text/css\">\np, li { white-space: pre-wrap; }\nhr { height: 1px; border-width: 0; }\nli.unchecked::marker { content: \"\\2610\"; }\nli.checked::marker { content: \"\\2612\"; }\n</style></head><body style=\" font-family:'Segoe UI'; font-size:12pt; font-weight:400; font-style:normal;\">\n<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\"><span style=\" font-family:'Lora'; font-size:20pt;\">A misconception of the “Records” section is that it is only for space tourism.</span><span style=\" font-family:'Lora'; font-size:20pt; font-weight:700;\"> The Records is a list of systems to investigate for their interesting features.</span><span style=\" font-family:'Lora'; font-size:20pt;\"> The systems in the records are as of writing undocumented and almost completely uncatalogued; The mission of the Records is to discover and document these systems and let the general public understand that these amazing systems exist.</span></p></body></html>" // footnote
                    font.pixelSize: parent.width / 45
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                    textFormat: Text.RichText
                    font.family: root.loraFontName
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    width: parent.width
                    text: "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n<html><head><meta name=\"qrichtext\" content=\"1\" /><meta charset=\"utf-8\" /><style type=\"text/css\">\np, li { white-space: pre-wrap; }\nhr { height: 1px; border-width: 0; }\nli.unchecked::marker { content: \"\\2610\"; }\nli.checked::marker { content: \"\\2612\"; }\n</style></head><body style=\" font-family:'Segoe UI'; font-size:12pt; font-weight:400; font-style:normal;\">\n<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\"><span style=\" font-family:'Lora'; font-size:20pt;\">An example of such phenomena that exist within the records is currently the most popular of which &quot;Colliding Rings&quot;. Originally discovered by CMDR TwoFingers july last year. It is a phenomena I wouldn't have been able to discover in the explorarium if it wasn't for him.</span></p></body></html>" // footnote
                    font.pixelSize: parent.width / 45
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                    textFormat: Text.RichText
                    font.family: root.loraFontName
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Image {
                    width: parent.width
                    height: infoHolder.height / 2
                    source: "images/Pic2.png"
                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    width: parent.width
                    text: "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n<html><head><meta name=\"qrichtext\" content=\"1\" /><meta charset=\"utf-8\" /><style type=\"text/css\">\np, li { white-space: pre-wrap; }\nhr { height: 1px; border-width: 0; }\nli.unchecked::marker { content: \"\\2610\"; }\nli.checked::marker { content: \"\\2612\"; }\n</style></head><body style=\" font-family:'Segoe UI'; font-size:12pt; font-weight:400; font-style:normal;\">\n<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\"><span style=\" font-family:'Lora'; font-size:20pt;\">Another example of such phenomena is Matroyshka. It is very crowded system with three bodies smashing into each other regularly. And one of the only examples of a </span><span style=\" font-family:'Lora'; font-size:20pt; font-weight:700;\">trinary collision</span><span style=\" font-family:'Lora'; font-size:20pt;\">. It'll be in Oct-Nov 2026. (as of writing)</span></p></body></html>" // footnote
                    font.pixelSize: parent.width / 45
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                    textFormat: Text.RichText
                    font.family: root.loraFontName
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Image {
                    width: parent.width
                    height: infoHolder.height / 2
                    source: "images/Pic3.jpg"
                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    width: parent.width
                    text: "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n<html><head><meta name=\"qrichtext\" content=\"1\" /><meta charset=\"utf-8\" /><style type=\"text/css\">\np, li { white-space: pre-wrap; }\nhr { height: 1px; border-width: 0; }\nli.unchecked::marker { content: \"\\2610\"; }\nli.checked::marker { content: \"\\2612\"; }\n</style></head><body style=\" font-family:'Segoe UI'; font-size:12pt; font-weight:400; font-style:normal;\">\n<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\"><span style=\" font-family:'Lora'; font-size:20pt;\">And this is just the beginning; the research we conduct and your support will help us discover places and points of interest in our galactic backyard.</span></p></body></html>" // footnote
                    font.pixelSize: parent.width / 45
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                    textFormat: Text.RichText
                    font.family: root.loraFontName
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "Queries" // title
                    font.pixelSize: parent.width / 30
                    font.family: root.antonFontName
                    color: "#4598ff"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    width: parent.width
                    text: "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n<html><head><meta name=\"qrichtext\" content=\"1\" /><meta charset=\"utf-8\" /><style type=\"text/css\">\np, li { white-space: pre-wrap; }\nhr { height: 1px; border-width: 0; }\nli.unchecked::marker { content: \"\\2610\"; }\nli.checked::marker { content: \"\\2612\"; }\n</style></head><body style=\" font-family:'Segoe UI'; font-size:12pt; font-weight:400; font-style:normal;\">\n<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\"><span style=\" font-family:'Lora'; font-size:20pt;\">A term coined by the leaders of the project, it is the defining factor of the records. Have you ever seen an amazing system in the GEC or a popular and amazing system you have personally discovered? The great news is that there is most likely a multitude of systems like that! Our role is to find a list of systems from a specific description of a system defined in just a sentence. An example of which is </span><span style=\" font-family:'Lora'; font-size:20pt; font-weight:700;\">&quot;Binary atmospherics close to Gas giant.&quot;</span><span style=\" font-family:'Lora'; font-size:20pt;\"> a simple sentence can produce amazing sights. Although you do sort of need very creative for these (which frankly I'm not very creative with this sort of thing.) </span></p></body></html>" // footnote
                    font.pixelSize: parent.width / 45
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                    textFormat: Text.RichText
                    font.family: root.loraFontName
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "User Interface" // title
                    font.pixelSize: parent.width / 30
                    font.family: root.antonFontName
                    color: "#4598ff"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    width: parent.width
                    text: "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n<html><head><meta name=\"qrichtext\" content=\"1\" /><meta charset=\"utf-8\" /><style type=\"text/css\">\np, li { white-space: pre-wrap; }\nhr { height: 1px; border-width: 0; }\nli.unchecked::marker { content: \"\\2610\"; }\nli.checked::marker { content: \"\\2612\"; }\n</style></head><body style=\" font-family:'Segoe UI'; font-size:12pt; font-weight:400; font-style:normal;\">\n<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\"><span style=\" font-family:'Lora'; font-size:20pt;\">In the left section of the interface of the records. Is the general statistics of the records. It provides your location, your claimed systems, session time, and even general database information.</span></p></body></html>" // footnote
                    font.pixelSize: parent.width / 45
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                    textFormat: Text.RichText
                    font.family: root.loraFontName
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Image {
                    width: parent.width
                    height: infoHolder.height / 2
                    source: "images/Pic4.png"
                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    width: parent.width
                    text: "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n<html><head><meta name=\"qrichtext\" content=\"1\" /><meta charset=\"utf-8\" /><style type=\"text/css\">\np, li { white-space: pre-wrap; }\nhr { height: 1px; border-width: 0; }\nli.unchecked::marker { content: \"\\2610\"; }\nli.checked::marker { content: \"\\2612\"; }\n</style></head><body style=\" font-family:'Segoe UI'; font-size:12pt; font-weight:400; font-style:normal;\">\n<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\"><span style=\" font-family:'Lora'; font-size:20pt;\">In the right section you can see the galaxy map button, settings, category filter (to filter through queries) and status filter (to filter through individual systems e.g. sort by furthest, sort by closest, show only your claims.)</span></p></body></html>" // footnote
                    font.pixelSize: parent.width / 45
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                    textFormat: Text.RichText
                    font.family: root.loraFontName
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Image {
                    width: parent.width
                    height: infoHolder.height / 2
                    source: "images/Pic5.png"
                    fillMode: Image.PreserveAspectFit
                }

                Image {
                    width: parent.width
                    height: infoHolder.height / 2
                    source: "images/Pic6.png"
                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    text: "Claim System & General Usage" // title
                    font.pixelSize: parent.width / 30
                    font.family: root.antonFontName
                    color: "#4598ff"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    width: parent.width
                    text: "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n<html><head><meta name=\"qrichtext\" content=\"1\" /><meta charset=\"utf-8\" /><style type=\"text/css\">\np, li { white-space: pre-wrap; }\nhr { height: 1px; border-width: 0; }\nli.unchecked::marker { content: \"\\2610\"; }\nli.checked::marker { content: \"\\2612\"; }\n</style></head><body style=\" font-family:'Segoe UI'; font-size:12pt; font-weight:400; font-style:normal;\">\n<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\"><span style=\" font-family:'Lora'; font-size:20pt;\">While the explorarium does provide enough systems to keep a massive group of people busy, eventually though we will cross paths with systems some people have already discovered through the explorarium. A system we have implemented is the Claim system. This is to make it easier for people to know that a system is done already and allows others to gain quick information from a system. And to not cause a disruption across the explorarium.</span></p></body></html>" // footnote
                    font.pixelSize: parent.width / 45
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                    textFormat: Text.RichText
                    font.family: root.loraFontName
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    width: parent.width
                    text: "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n<html><head><meta name=\"qrichtext\" content=\"1\" /><meta charset=\"utf-8\" /><style type=\"text/css\">\np, li { white-space: pre-wrap; }\nhr { height: 1px; border-width: 0; }\nli.unchecked::marker { content: \"\\2610\"; }\nli.checked::marker { content: \"\\2612\"; }\n</style></head><body style=\" font-family:'Segoe UI'; font-size:12pt; font-weight:400; font-style:normal;\">\n<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\"><span style=\" font-family:'Lora'; font-size:20pt;\">To claim a system, choose a system from the middle bar, a scrolling list of every single system from the explorarium. By default it is sorted by distance so you can easily see systems close to you (If you want more information on where the systems are use the Galaxy Map). If you have chosen a system press the view button to open up the system view.</span></p></body></html>" // footnote
                    font.pixelSize: parent.width / 45
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                    textFormat: Text.RichText
                    font.family: root.loraFontName
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Image {
                    width: parent.width
                    height: infoHolder.height / 2
                    source: "images/Pic7.png"
                    fillMode: Image.PreserveAspectFit
                }

                Image {
                    width: parent.width
                    height: infoHolder.height / 2
                    source: "images/Pic8.png"
                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    width: parent.width
                    text: "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n<html><head><meta name=\"qrichtext\" content=\"1\" /><meta charset=\"utf-8\" /><style type=\"text/css\">\np, li { white-space: pre-wrap; }\nhr { height: 1px; border-width: 0; }\nli.unchecked::marker { content: \"\\2610\"; }\nli.checked::marker { content: \"\\2612\"; }\n</style></head><body style=\" font-family:'Segoe UI'; font-size:12pt; font-weight:400; font-style:normal;\">\n<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\"><span style=\" font-family:'Lora'; font-size:20pt;\">You are greeted with a bunch of information about the system you have chosen. The top left is the main image of the system. In this case it is the </span><span style=\" font-family:'Lora'; font-size:20pt; font-weight:700;\">Default Query Image.</span><span style=\" font-family:'Lora'; font-size:20pt;\"> (this is by default shown when there are no images of the system) and it shows a greyed out text of the system and a big white text of the system name. The white one is the &quot;title&quot; (editable) and the tiny grey one is uneditable. Hovering and clicking the title will throw it into your clipboard. It will always copy the system name and not whatever title you have put in.</span></p></body></html>" // footnote
                    font.pixelSize: parent.width / 45
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                    textFormat: Text.RichText
                    font.family: root.loraFontName
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    width: parent.width
                    text: "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n<html><head><meta name=\"qrichtext\" content=\"1\" /><meta charset=\"utf-8\" /><style type=\"text/css\">\np, li { white-space: pre-wrap; }\nhr { height: 1px; border-width: 0; }\nli.unchecked::marker { content: \"\\2610\"; }\nli.checked::marker { content: \"\\2612\"; }\n</style></head><body style=\" font-family:'Segoe UI'; font-size:12pt; font-weight:400; font-style:normal;\">\n<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\"><span style=\" font-family:'Lora'; font-size:20pt;\">The tiny orange rectangle below that is the category. Which is the specific query this system exists in. Sometimes a system can be apart of </span><span style=\" font-family:'Lora'; font-size:20pt; font-weight:700;\">Multiple</span><span style=\" font-family:'Lora'; font-size:20pt;\"> queries (which can have some VERY INTERESTING SYSTEMS) below that is the description which is self-explanatory. It is editable of course and by default shows &quot;No description available for this system...&quot; And below that you get three options. &quot;Claim, edit info, GEC button&quot;. Claim is self-explanatory. It'll be greyed out when it is claimed by someone else and red to unclaim if the system is already yours. Edit info is only enabled if the system is yours. And the gec button has two forms. If it is Not In GEC it sends you to a page to easily upload the system to the GEC. and if it does exist in the GEC it opens the page for it on your web browser. </span></p></body></html>" // footnote
                    font.pixelSize: parent.width / 45
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                    textFormat: Text.RichText
                    font.family: root.loraFontName
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    width: parent.width
                    text: "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n<html><head><meta name=\"qrichtext\" content=\"1\" /><meta charset=\"utf-8\" /><style type=\"text/css\">\np, li { white-space: pre-wrap; }\nhr { height: 1px; border-width: 0; }\nli.unchecked::marker { content: \"\\2610\"; }\nli.checked::marker { content: \"\\2612\"; }\n</style></head><body style=\" font-family:'Segoe UI'; font-size:12pt; font-weight:400; font-style:normal;\">\n<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\"><span style=\" font-family:'Lora'; font-size:20pt;\">The right section shows a carousel of images. You can click on an active image to open it in big view. And the bottom section is a scrollable info dump of what even is in the system and general statistics of the query from my database.</span></p></body></html>" // footnote
                    font.pixelSize: parent.width / 45
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                    textFormat: Text.RichText
                    font.family: root.loraFontName
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    width: parent.width
                    text: "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n<html><head><meta name=\"qrichtext\" content=\"1\" /><meta charset=\"utf-8\" /><style type=\"text/css\">\np, li { white-space: pre-wrap; }\nhr { height: 1px; border-width: 0; }\nli.unchecked::marker { content: \"\\2610\"; }\nli.checked::marker { content: \"\\2612\"; }\n</style></head><body style=\" font-family:'Segoe UI'; font-size:12pt; font-weight:400; font-style:normal;\">\n<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\"><span style=\" font-family:'Lora'; font-size:20pt;\">Our rules for descriptions and titles are sort of relaxed. Although common sense is non-negotiable here. We also don't accept AI descriptions or anything of that sort. It is meant to use a short description and to keep in mind that it is plain-text only. You cannot jam links or images or bold your text inside of the description. The GEC has those features and it is not needed here as it only serves as a general info dump of what the system is or contains. Although you are free to upload the system to the GEC but make sure to follow their guidelines as they are much stricter than ours.</span></p></body></html>" // footnote
                    font.pixelSize: parent.width / 45
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                    textFormat: Text.RichText
                    font.family: root.loraFontName
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "Galaxy Map" // title
                    font.pixelSize: parent.width / 30
                    font.family: root.antonFontName
                    color: "#4598ff"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Image {
                    width: parent.width
                    height: infoHolder.height / 2
                    source: "images/Pic9.png"
                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    width: parent.width
                    text: "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n<html><head><meta name=\"qrichtext\" content=\"1\" /><meta charset=\"utf-8\" /><style type=\"text/css\">\np, li { white-space: pre-wrap; }\nhr { height: 1px; border-width: 0; }\nli.unchecked::marker { content: \"\\2610\"; }\nli.checked::marker { content: \"\\2612\"; }\n</style></head><body style=\" font-family:'Segoe UI'; font-size:12pt; font-weight:400; font-style:normal;\">\n<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\"><span style=\" font-family:'Lora'; font-size:20pt;\">The Record's Galaxy Map a simple 2d map that shows modern regions with accuracy and with our queries from a top-down view. You can increase/decrease the star size (if the galaxy map is a little bit noisy) zoom in, general stuff a map should have. It is a bit unfinished and doesn't have many features although it does well on its own and is definitely a great tool for your needs.</span></p></body></html>" // footnote
                    font.pixelSize: parent.width / 45
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                    textFormat: Text.RichText
                    font.family: root.loraFontName
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "Galaxy Plotter" // title
                    font.pixelSize: parent.width / 30
                    font.family: root.antonFontName
                    color: "#4598ff"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Image {
                    width: parent.width
                    height: infoHolder.height / 2
                    source: "images/Pic10.png"
                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    width: parent.width
                    text: "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n<html><head><meta name=\"qrichtext\" content=\"1\" /><meta charset=\"utf-8\" /><style type=\"text/css\">\np, li { white-space: pre-wrap; }\nhr { height: 1px; border-width: 0; }\nli.unchecked::marker { content: \"\\2610\"; }\nli.checked::marker { content: \"\\2612\"; }\n</style></head><body style=\" font-family:'Segoe UI'; font-size:12pt; font-weight:400; font-style:normal;\">\n<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\"><span style=\" font-family:'Lora'; font-size:20pt;\">The galaxy plotter is a plotter provided from Spansh's own Galaxy Plotter, just with the ship build step completely automated. And it can automatically know what your current system is. You can let the plotter determine how much cargo you have onboard. Reserve fuel (in tons) which is the limit of fuel the plotter has access to use during jumping (e.g. leave 2 tons of fuel left always when jumping). You can determine if you are already neutron supercharged (not white dwarf) Use neutron supercharges. Or FSD Injections. or to exclude secondary stars (for refuel/neutron charging) or to refuel every scoopable star. And determine the logic of the router (Optimistic is the default and regarded as the best). Press generate route and it'll automatically copy the next system enroute.</span></p></body></html>" // footnote
                    font.pixelSize: parent.width / 45
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                    textFormat: Text.RichText
                    font.family: root.loraFontName
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    width: parent.width
                    text: "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n<html><head><meta name=\"qrichtext\" content=\"1\" /><meta charset=\"utf-8\" /><style type=\"text/css\">\np, li { white-space: pre-wrap; }\nhr { height: 1px; border-width: 0; }\nli.unchecked::marker { content: \"\\2610\"; }\nli.checked::marker { content: \"\\2612\"; }\n</style></head><body style=\" font-family:'Segoe UI'; font-size:12pt; font-weight:400; font-style:normal;\">\n<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\"><span style=\" font-family:'Lora'; font-size:20pt;\">If you have any questions to ask you can ask around in the discord server for any support or questions.</span></p></body></html>" // footnote
                    font.pixelSize: parent.width / 45
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                    textFormat: Text.RichText
                    font.family: root.loraFontName
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Item { width: 1; height: 50 }
            }
        }
    }
}
