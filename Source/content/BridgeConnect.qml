import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "functions.js" as Functions

Item {
    width: parent.width
    height: parent.height
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
            style: touchStyle
        }
        Button {
            id: submit_button
            anchors.left: ipTextEntry.left
            anchors.top: ipTextEntry.bottom
            anchors.topMargin: 10
            text: "Connect"
            style: pressStyle
            onClicked: {
                bridgeIp = ipTextEntry.text
                pyconn('POST', '', {
                           devicetype: "qtHue#diyHue"
                       }, bridgePair);
                stackView.pop(1);
            }
        }


    Component {
        id: touchStyle

        TextFieldStyle {
            textColor: "white"
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
    }

    Component {
        id: pressStyle
        ButtonStyle {
            panel: Item {
                implicitHeight: 50
                implicitWidth: 320
                BorderImage {
                    anchors.fill: parent
                    antialiasing: true
                    border.bottom: 8
                    border.top: 8
                    border.left: 8
                    border.right: 8
                    anchors.margins: control.pressed ? -4 : 0
                    source: control.pressed ? "./images/button_pressed.png" : "./images/button_default.png"
                    Text {
                        text: control.text
                        anchors.centerIn: parent
                        color: "white"
                        font.pixelSize: 23
                        renderType: Text.NativeRendering
                    }
                }
            }
        }
    }

}
