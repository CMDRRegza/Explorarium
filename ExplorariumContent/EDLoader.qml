import QtQuick 2.15
import QtQuick.Shapes 1.15

Item {
    id: root

    width: 40
    height: 40
    opacity: 1.0

    property color color: "#ff7100"
    property real outerBaseOpacity: 0.3
    property real innerBaseOpacity: 0.4
    property real peakOpacity: 1.0
    property int durationMs: 1000
    property bool running: true

    property real t: 0.0
    property real vbW: 40
    property real vbH: 32

    property real s: Math.min(width / vbW, height / vbH)

    property real ox: (width - (vbW * s)) / 2
    property real oy: (height - (vbH * s)) / 2

    NumberAnimation on t {
        from: 0.0
        to: 1.0
        duration: root.durationMs
        loops: Animation.Infinite
        running: root.running
    }

    function triPoints(x1, y1, x2, y2, x3, y3) {
        return [ Qt.point(x1, y1), Qt.point(x2, y2), Qt.point(x3, y3) ]
    }

    function phaseFromBeginSeconds(sec) {
        var p = (-sec) % 1.0
        if (p < 0) p += 1.0
        return p
    }

    function opacityAt(base, phaseOffset) {
        var u = (root.t + phaseOffset) % 1.0

        if (u <= 0.2) {
            var a = u / 0.2
            return base + (root.peakOpacity - base) * a
        }

        var b = (u - 0.2) / 0.8
        return root.peakOpacity + (base - root.peakOpacity) * b
    }

    component Tri: Item {
        id: tri
        property var pts: []
        property real baseOpacity: 0.3
        property real phase: 0.0

        width: root.width
        height: root.height

        opacity: root.opacityAt(baseOpacity, phase)

        Shape {
            anchors.fill: parent
            layer.enabled: true
            layer.smooth: true

            ShapePath {
                strokeWidth: 0
                fillColor: root.color

                startX: pts.length > 0 ? (root.ox + pts[0].x * root.s) : 0
                startY: pts.length > 0 ? (root.oy + pts[0].y * root.s) : 0

                PathLine { x: pts.length > 1 ? (root.ox + pts[1].x * root.s) : 0; y: pts.length > 1 ? (root.oy + pts[1].y * root.s) : 0 }
                PathLine { x: pts.length > 2 ? (root.ox + pts[2].x * root.s) : 0; y: pts.length > 2 ? (root.oy + pts[2].y * root.s) : 0 }
                PathLine { x: pts.length > 0 ? (root.ox + pts[0].x * root.s) : 0; y: pts.length > 0 ? (root.oy + pts[0].y * root.s) : 0 }
            }
        }
    }

    Tri { pts: root.triPoints(5,8, 10,16, 15,8);   baseOpacity: root.outerBaseOpacity; phase: root.phaseFromBeginSeconds(-0.94736842) }
    Tri { pts: root.triPoints(5,8, 10,0,  15,8);   baseOpacity: root.outerBaseOpacity; phase: root.phaseFromBeginSeconds(-0.89473684) }
    Tri { pts: root.triPoints(10,0,15,8,20,0);     baseOpacity: root.outerBaseOpacity; phase: root.phaseFromBeginSeconds(-0.84210526) }
    Tri { pts: root.triPoints(15,8,20,0,25,8);     baseOpacity: root.outerBaseOpacity; phase: root.phaseFromBeginSeconds(-0.78947368) }
    Tri { pts: root.triPoints(20,0,25,8,30,0);     baseOpacity: root.outerBaseOpacity; phase: root.phaseFromBeginSeconds(-0.73684211) }
    Tri { pts: root.triPoints(25,8,30,0,35,8);     baseOpacity: root.outerBaseOpacity; phase: root.phaseFromBeginSeconds(-0.68421053) }
    Tri { pts: root.triPoints(25,8,30,16,35,8);    baseOpacity: root.outerBaseOpacity; phase: root.phaseFromBeginSeconds(-0.63157895) }
    Tri { pts: root.triPoints(30,16,35,8,40,16);   baseOpacity: root.outerBaseOpacity; phase: root.phaseFromBeginSeconds(-0.57894737) }
    Tri { pts: root.triPoints(30,16,35,24,40,16);  baseOpacity: root.outerBaseOpacity; phase: root.phaseFromBeginSeconds(-0.52631579) }
    Tri { pts: root.triPoints(25,24,30,16,35,24);  baseOpacity: root.outerBaseOpacity; phase: root.phaseFromBeginSeconds(-0.47368421) }
    Tri { pts: root.triPoints(25,24,30,32,35,24);  baseOpacity: root.outerBaseOpacity; phase: root.phaseFromBeginSeconds(-0.42105263) }
    Tri { pts: root.triPoints(20,32,25,24,30,32);  baseOpacity: root.outerBaseOpacity; phase: root.phaseFromBeginSeconds(-0.31578947) }
    Tri { pts: root.triPoints(15,24,20,32,25,24);  baseOpacity: root.outerBaseOpacity; phase: root.phaseFromBeginSeconds(-0.26315789) }
    Tri { pts: root.triPoints(10,32,15,24,20,32);  baseOpacity: root.outerBaseOpacity; phase: root.phaseFromBeginSeconds(-0.21052632) }
    Tri { pts: root.triPoints(5,24,10,32,15,24);   baseOpacity: root.outerBaseOpacity; phase: root.phaseFromBeginSeconds(-0.15789474) }
    Tri { pts: root.triPoints(5,24,10,16,15,24);   baseOpacity: root.outerBaseOpacity; phase: root.phaseFromBeginSeconds(-0.10526316) }
    Tri { pts: root.triPoints(0,16,5,24,10,16);    baseOpacity: root.outerBaseOpacity; phase: root.phaseFromBeginSeconds(-0.05263158) }
    Tri { pts: root.triPoints(0,16,5,8, 10,16);    baseOpacity: root.outerBaseOpacity; phase: root.phaseFromBeginSeconds(0.0) }

    Tri { pts: root.triPoints(10,16,15,8, 20,16);  baseOpacity: root.innerBaseOpacity; phase: root.phaseFromBeginSeconds(-0.83333333) }
    Tri { pts: root.triPoints(15,8, 20,16,25,8);   baseOpacity: root.innerBaseOpacity; phase: root.phaseFromBeginSeconds(-0.66666667) }
    Tri { pts: root.triPoints(20,16,25,8, 30,16);  baseOpacity: root.innerBaseOpacity; phase: root.phaseFromBeginSeconds(-0.5) }
    Tri { pts: root.triPoints(20,16,25,24,30,16);  baseOpacity: root.innerBaseOpacity; phase: root.phaseFromBeginSeconds(-0.33333333) }
    Tri { pts: root.triPoints(15,24,20,16,25,24);  baseOpacity: root.innerBaseOpacity; phase: root.phaseFromBeginSeconds(-0.16666667) }
    Tri { pts: root.triPoints(10,16,15,24,20,16);  baseOpacity: root.innerBaseOpacity; phase: root.phaseFromBeginSeconds(0.0) }
}
