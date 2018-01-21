import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Item {
    width: parent.width
    height: parent.height

    Rectangle {
        id: background_//keypad
        color: "#17171b"
        x: 1019
        y: 340
        width: 340
        height: 370
        opacity: 0.97
        radius: 5
        MouseArea {
            anchors.fill: parent
        }
        border.color: "#535757"
        border.width: 1
    }

    Component {
        id: touchStyle
        ButtonStyle {
            panel: Item {
                implicitHeight: 80
                implicitWidth: 100
                BorderImage {
                    anchors.fill: parent
                    antialiasing: true
                    border.bottom: 8
                    border.top: 8
                    border.left: 8
                    border.right: 8
                    anchors.margins: control.pressed ? -4 : 0
                    source: control.pressed ? "/content/images/button_pressed.png" : "/content/images/button_default.png"
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

    Grid {
        anchors.fill: background_//keypad
        anchors.margins: 10
        columns: 3
        columnSpacing: 10
        rowSpacing: 10

        Button {
            style: touchStyle
            text: "1"
            onClicked: {
                bridgeIp += "1"
            }
        }
        Button {
            style: touchStyle
            text: "2"
            onClicked: {
                 bridgeIp += "2"
            }
        }
        Button {
            style: touchStyle
            text: "3"
            onClicked: {
                 bridgeIp += "3"
            }
        }
        Button {
            style: touchStyle
            text: "4"
            onClicked: {
                 bridgeIp += "4"
            }
        }
        Button {
            style: touchStyle
            text: "5"
            onClicked: {
                 bridgeIp += "5"
            }
        }
        Button {
            style: touchStyle
            text: "6"
            onClicked: {
                 bridgeIp += "6"
            }
        }
        Button {
            style: touchStyle
            text: "7"
            onClicked: {
                 bridgeIp += "7"
            }
        }
        Button {
            style: touchStyle
            text: "8"
            onClicked: {
                 bridgeIp += "8"
            }
        }
        Button {
            style: touchStyle
            text: "9"
            onClicked: {
                 bridgeIp += "9"
            }
        }
        Button {
            style: touchStyle
            text: "."
            onClicked: {
                 bridgeIp += "."
            }
        }
        Button {
            style: touchStyle
            text: "0"
            onClicked: {
                 bridgeIp += "0"
            }
        }
        Button {
            style: touchStyle
            text: "\u232B"
            onClicked: {
                 bridgeIp = bridgeIp.slice(0, -1)
            }
        }
    }
}
