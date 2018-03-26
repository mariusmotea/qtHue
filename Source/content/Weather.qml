import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "functions.js" as Functions

Item {
    width: parent.width
    height: parent.height
    objectName: "Wheather"

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
        id: apikeyTextEntry
        anchors.centerIn: parent
        text: apikey
        width: 600
        style: touchStyle
    }

    TextField {
        id: cityTextEntry
        anchors.top: apikeyTextEntry.bottom
        anchors.left: apikeyTextEntry.left
        text: city
        style: touchStyle
    }
    Button {
        id: submit_button
        anchors.left: cityTextEntry.left
        anchors.top: cityTextEntry.bottom
        anchors.topMargin: 10
        text: "Save"
        style: pressStyle
        onClicked: {
            apikey = apikeyTextEntry.text;
            city = cityTextEntry.text;
            saveWheatherDetails();
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
