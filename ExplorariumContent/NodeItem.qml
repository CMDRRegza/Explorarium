import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    width: 400
    height: 400

    property string planetImgSource: "images/elw3.png"
    property string ringImgSource: "images/ring1.png"
    property real planetScale: 1.0
    property bool showRings: false
    property string labelText: "Earth"

    signal clicked()

    TapHandler {
        onTapped: root.clicked()
    }

    // The Visual Body
    Rectangle {
        id: body
        width: 200
        height: 200
        radius: 30
        color: "transparent"
        anchors.centerIn: parent
        scale: root.planetScale

        Image {
            visible: root.showRings
            source: root.ringImgSource
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: parent
            width: parent.width * 2.2
            height: width
            z: 1
        }

        Image {
            id: planetTexture
            source: root.planetImgSource
            fillMode: Image.PreserveAspectFit
            anchors.fill: parent
        }
    }
}
