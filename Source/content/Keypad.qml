import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "../content/general.js" as General

Item {
    width: parent.width
    height: parent.height

    function keypad(tasta) {
        General.playback('sounds-1049-knob')
        virt_keypad = ""
        virt_keypad = tasta
    }

    Rectangle {
        id: background_keypad
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
        anchors.fill: background_keypad
        anchors.margins: 10
        columns: 3
        columnSpacing: 10
        rowSpacing: 10

        Button {
            style: touchStyle
            text: "1"
            onClicked: {
                keypad("1")
            }
        }
        Button {
            style: touchStyle
            text: "2"
            onClicked: {
                keypad("2")
            }
        }
        Button {
            style: touchStyle
            text: "3"
            onClicked: {
                keypad("3")
            }
        }
        Button {
            style: touchStyle
            text: "4"
            onClicked: {
                keypad("4")
            }
        }
        Button {
            style: touchStyle
            text: "5"
            onClicked: {
                keypad("5")
            }
        }
        Button {
            style: touchStyle
            text: "6"
            onClicked: {
                keypad("6")
            }
        }
        Button {
            style: touchStyle
            text: "7"
            onClicked: {
                keypad("7")
            }
        }
        Button {
            style: touchStyle
            text: "8"
            onClicked: {
                keypad("8")
            }
        }
        Button {
            style: touchStyle
            text: "9"
            onClicked: {
                keypad("9")
            }
        }
        Button {
            //style: touchStyle
            text: "."
            style: ButtonStyle {
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
                        Text {
                            text: "-"
                            anchors.top: parent.top
                            anchors.topMargin: 5
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            color: "#7d7d7d"
                            font.pixelSize: 23
                            renderType: Text.NativeRendering
                        }
                    }
                }
            }
            Timer {
                    id: longPressTimer

                    interval: 1000 //your press-and-hold interval here
                    repeat: false
                    running: false

                    onTriggered: {
                        keypad("-")
                    }
                }
            onPressedChanged: {
                    if ( pressed ) {
                        longPressTimer.running = true;
                    } else {
                        if (longPressTimer.running === true) {
                            longPressTimer.running = false;
                            keypad(".");
                        }
                    }
                }
        }
        Button {
            style: touchStyle
            text: "0"
            onClicked: {
                keypad("0")
            }
        }
        Button {
            style: touchStyle
            text: "\u232B"
            onClicked: {
                keypad("[delete]")
            }
        }
    }
}
