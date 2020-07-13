import QtQuick 2.4
import QtQuick.Controls 2.4
import "functions.js" as Functions

Item {
    objectName: "BridgeConnect"

    property real progress: 0
    SequentialAnimation on progress {
        loops: Animation.Infinite
        running: true
        NumberAnimation {
            from: 0
            to: 1
            duration: 3000
        }
        NumberAnimation {
            from: 1
            to: 0
            duration: 3000
        }
    }

    TextField {
        id: ipTextEntry
        anchors.centerIn: parent
        text: bridgeIp
        color: "white"
        font.pixelSize: 28
        background: Item {
            implicitHeight: 50
            implicitWidth: 320
            BorderImage {
                source: "./images/textinput.png"
                border.left: 8
                border.right: 8
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
            }
        }
    }
    Button {
        id: submit_button
        implicitHeight: 50
        implicitWidth: 320
        anchors.left: ipTextEntry.left
        anchors.top: ipTextEntry.bottom
        anchors.topMargin: 10
        contentItem: Text {
            text: "Connect"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: "white"
            font.pixelSize: 23
            renderType: Text.NativeRendering
        }
        background: BorderImage {
            anchors.fill: parent
            antialiasing: true
            border.bottom: 8
            border.top: 8
            border.left: 8
            border.right: 8
            anchors.margins: submit_button.pressed ? -4 : 0
            source: submit_button.pressed ? "./images/button_pressed.png" : "./images/button_default.png"
        }
        onClicked: {
            bridgeIp = ipTextEntry.text
            pyconn('POST', '', {
                       devicetype: "qtHue#diyHue"
                   }, bridgePair);
            stackView.pop(1);
        }
    }

}
