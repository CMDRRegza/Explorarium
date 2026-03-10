import QtQuick
import QtQuick.Controls
import QtQuick.Studio.DesignEffects
import QtQuick.Effects
import QtQuick.Controls.Basic.impl

Window {
    id: root
    width: 750
    height: 650
    color: "#00000000"
    flags: Qt.SplashScreen
    visible: true
    title: "Loading Screen"

    Connections {
        target: loadingScreenManager
        function onLoadApp() {
            Qt.callLater(function() {
                    root.close()
                })
        }
    }

    Rectangle {
        id: holder
        width: parent.width - (parent.width / 30)
        height: parent.height - (parent.height / 25)
        anchors.centerIn: parent
        color: "#303030"
        radius: parent.width / 5
        clip: true

        Image {
            id: planet
            width: parent.width / 2
            source: "images/planet.png"
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            anchors.top: parent.top
            anchors.topMargin: parent.height / 10
            anchors.horizontalCenter: parent.horizontalCenter
            z: 1

            FontLoader {
                id: antonFont
                source: "fonts/Anton-Regular.ttf"
            }
        }

        Image {
            id: logo
            source: "images/logo.png"
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            height: parent.height / 4
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            z: 3
        }

        Rectangle {
            id: coverer
            width: groundDesign.width
            height: groundDesign.height
            radius: holder.radius
            layer.enabled: true
            visible: false
        }

        Image {
            id: groundDesign
            width: parent.width - (parent.border.width * 2)
            height: width
            source: "images/groundDesign.png"
            asynchronous: true
            fillMode: Image.PreserveAspectCrop
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            layer.enabled: true
            layer.effect: MultiEffect {
                id: multiEffectInstance
                maskEnabled: true
                maskSource: coverer
            }
            z: 2
        }

        BusyIndicator {
            property bool pRunning: true
            contentItem: BusyIndicatorImpl {
                implicitWidth: 48
                implicitHeight: 48
                pen: "white"
                fill: "orange"
                running: parent.pRunning
            }
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            width: parent.width / 1
            height: parent.height / 1.25
        }
    }

    Rectangle {
        id: bgBorder
        property real value: 50
        width: holder.width + parent.height / value
        height: holder.height + parent.height / value
        radius: holder.radius
        anchors.centerIn: parent
        z: -1
        color: "orange"
    }
}
