import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0
import "functions.js" as Functions

Rectangle {
    property string selected_id

    onSelected_idChanged: {
        lightsOptions.groupId = selected_id;
    }

    id: light_options
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    visible: stackView.currentItem.objectName === "" ? true: false
    x: parent.width - 304
    width: 304
    state: "CLOSE"
    color: "#17171b"
    opacity: 0.97
    states: [
        State {
            name: "OPEN"
            PropertyChanges { target: light_options; x: parent.width - 304}
        },
        State {
            name: "CLOSE"
            PropertyChanges { target: light_options; x: parent.width}
        }
    ]
    Rectangle {
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.left: parent.left
        width: 4
        height: parent.height - 10
        color: "#33bef2"
        border.color: "#3b7891"
        border.width: 1
    }
    Text {
        id: close_options
        anchors.right: parent.right
        anchors.top: parent.top
        font.pointSize: 28
        font.family: "FontAwesome"
        color: "#3a3a3a"
        text: "\uf00d"
        MouseArea {
            anchors.fill: parent
            onClicked: {
                light_options.state = "CLOSE"
            }
        }
    }
    ListModel {
        id: modeModel
        ListElement {
            name: " Scenes "
            statex: "OPEN"
        }
        ListElement {
            name: " Lights "
            statex: "CLOSE"
        }
    }
    ListView {
        id: modeListView
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.right: close_options.left
        width: parent.width
        height: 42
        orientation: ListView.Horizontal
        model: modeModel
        delegate:     Text {
            id: modeSelection
            font.pointSize: 25
            color: "#cccccc"
            text: name
            MouseArea{
                anchors.fill: parent
                onClicked:{
                    modeListView.currentIndex = index;
                    groupOptions.state = statex;
                    lightsOptions.state = statex;
                }
            }
        }
        highlightMoveDuration: 500
        focus: true
        highlight: Rectangle {
            width: parent.width
            height: parent.height
            radius: 4
            color: "#254757"
        }
    }
    GroupOptions {
        id: groupOptions
    }

    LightsOptions {
        id: lightsOptions
    }

    transitions: Transition {
        NumberAnimation {
            properties: "x"
            duration: 160
            easing.type: Easing.OutQuint
        }
    }

}
