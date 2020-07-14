import QtQuick 2.4
import QtQuick.Controls 2.4
import QtGraphicalEffects 1.0
import "../content/functions.js" as Functions

Drawer {
    property string selected_id
    property int index: 0

    onSelected_idChanged: {
        lightsOptions.groupId = selected_id;
    }

    id: light_options
    y: mainWindow.header.height
    width: mainWindow.width*(330/1360) > 350 ? 350 : mainWindow.width*(330/1360) < 230 ? 230 : mainWindow.width*(330/1360)
    height: mainWindow.height - mainWindow.header.height
    edge: Qt.RightEdge
    opacity: 0.97
    dim: false; modal: false; dragMargin: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    clip: true

    background: Rectangle{
        anchors.fill: parent
        color: "#17171b"
    }
    contentChildren: [
        SwipeView{
            id: swipeView
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.top: header.bottom
            currentIndex: index
            contentData: [
                GridView {
                    GroupOptions {id: groupOptions}
                },
                GridView {
                    LightsOptions {id: lightsOptions}
                }]
        },

        Item {
            id: header
            implicitHeight: parent.height*0.07 < 40 ? 40 : parent.height*0.07 > 50 ? 50 : parent.height*0.07
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.left: parent.left

            Rectangle{
                id: middleAlignment
                width: 0
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Rectangle{
                height: 1
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                color: "#464141"
            }

            Rectangle {
                id: hightlight
                width: parent.width/2 - 10
                height: parent.height - 5
                anchors.verticalCenter: parent.verticalCenter
                radius: 4
                color: "#254757"
                states: [
                    State {
                        name: "SCENES"
                        when: swipeView.currentIndex === 0
                        PropertyChanges { target: hightlight; x: scenes.x}},
                    State {
                        name: "LIGHTS"
                        when: swipeView.currentIndex === 1
                        PropertyChanges { target: hightlight; x: lights.x}}
                ]
                transitions: Transition {
                    NumberAnimation {
                        properties: "x"
                        duration: 400
                        easing.type: Easing.OutQuint
                    }
                }
            }

            Text {
                id: scenes
                anchors{top: parent.top; bottom: parent.bottom; left: parent.left; right: middleAlignment.left; leftMargin: 8; rightMargin: 8; bottomMargin: 3;}
                fontSizeMode: Text.Fit
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 250
                color: 0 === swipeView.currentIndex ? "#ffffff" : "#cccccc"
                text: "Scenes"
                MouseArea{
                    id: scenes_mouseArea
                    anchors.fill: parent
                    onClicked: swipeView.setCurrentIndex(0)
                }
            }

            Text {
                id: lights
                anchors{bottomMargin: 3; top: parent.top; bottom: parent.bottom; left: middleAlignment.right; right: parent.right; leftMargin: 8; rightMargin: 8;}
                fontSizeMode: Text.Fit
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 250
                color: 1 === swipeView.currentIndex ? "#ffffff" : "#cccccc"
                text: "Lights"
                MouseArea{
                    anchors.fill: parent
                    onClicked: swipeView.setCurrentIndex(1)
                }
            }
        }
    ]
    Rectangle {
        anchors.top: parent.top
        anchors.topMargin: 1
        anchors.right: parent.left
        anchors.bottom: parent.bottom
        anchors.rightMargin: -3
        width: 4
        color: "#33B5E5"
        border.color: "#237B9C"
        border.width: 1
    }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:3}
}
##^##*/
