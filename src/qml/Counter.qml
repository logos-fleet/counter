import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    QtObject {
        id: d
        property var backend: null
        readonly property string mod: "counter"
        // THE BACKEND ARRIVES ON AN EDGE, not on first paint, and the early
        // call is what starts the acquire. On the desktop this is merely
        // correct; inside the Web container it is required — the replica there
        // is DYNAMIC (a page cannot dlopen the generated factory plugin), so it
        // has no metaobject until the source's has crossed the wire, and a
        // dynamic replica handed to QML before that is cached with the generic
        // one for the life of the page: every property reads `undefined` and
        // every slot is "not a function". ADR 0004 records it at length.
        //
        // `viewModuleReadyChanged` is emitted under that name by BOTH bridges,
        // which is what lets this document be the same file in both containers.
        function take() {
            d.backend = logos.module(d.mod)
        }
        Component.onCompleted: {
            if (typeof logos === "undefined" || !logos)
                return
            logos.viewModuleReadyChanged.connect(function (name, ready) {
                if (name === d.mod && ready) d.take()
            })
            d.take()
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 16

        Text {
            text: d.backend ? d.backend.count : "0"
            font.pixelSize: 48
            font.weight: Font.Bold
            color: "#333333"
            Layout.alignment: Qt.AlignHCenter
        }

        Button {
            text: "Increment me"
            Layout.alignment: Qt.AlignHCenter

            contentItem: Text {
                text: parent.text
                font.pixelSize: 15
                font.weight: Font.Medium
                color: "#ffffff"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                implicitWidth: 140
                implicitHeight: 44
                color: parent.pressed ? "#1a7f37" : "#238636"
                radius: 8
                border.color: "#2ea043"
                border.width: 1
            }

            onClicked: if (d.backend) d.backend.increment()
        }
    }
}
