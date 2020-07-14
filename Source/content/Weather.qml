import QtQuick 2.4
import QtQuick.Controls 2.4
import "functions.js" as Functions

Item {
    objectName: "Weather"

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

    TextField {
        id: cityTextEntry
        anchors.top: apikeyTextEntry.bottom
        anchors.left: apikeyTextEntry.left
        text: city
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
        anchors.left: cityTextEntry.left
        anchors.top: cityTextEntry.bottom
        anchors.topMargin: 10
        contentItem: Text {
            text: "Save"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: "white"
            font.pixelSize: 23
            renderType: Text.NativeRendering
        }
        background: Item {
            implicitHeight: 50
            implicitWidth: 320
            BorderImage {
                anchors.fill: parent
                antialiasing: true
                border.bottom: 8
                border.top: 8
                border.left: 8
                border.right: 8
                anchors.margins: submit_button.pressed ? -4 : 0
                source: submit_button.pressed ? "./images/button_pressed.png" : "./images/button_default.png"
            }
        }
        onClicked: {
            apikey = apikeyTextEntry.text;
            city = cityTextEntry.text;
            saveWheatherDetails();
            stackView.pop(1);
        }
    }
}
