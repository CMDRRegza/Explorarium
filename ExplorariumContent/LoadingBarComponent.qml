import QtQuick
import QtQuick.Controls

Item {
    id: root
    width: 1920
    height: 1080

    Rectangle {
        id: progressBg
        width: parent.width / 1.5
        height: parent.height / 40
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: logo.bottom
        anchors.topMargin: parent.height / 6
        radius: width / 2

        Rectangle {
            id: progress
            property real value: 0.0
            width: parent.width * value
            height: parent.height
            radius: parent.radius
            color: "orange"
            Behavior on width { NumberAnimation { duration: 120 }}
        }

        Text {
            id: progressText
            anchors.top: progress.bottom
            anchors.topMargin: parent.height * 1.5
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            font.styleName: "ExtraBold"
            font.family: "Dosis"
            text: "yadda yadda blah blah"
            color: "white"
            font.pixelSize: parent.width / 15
        }
    }
}
