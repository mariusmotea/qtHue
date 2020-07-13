import QtQuick 2.0
import QtQuick.Controls 2.4
import QtGraphicalEffects 1.0
import "functions.js" as Functions

Item {
    id: lightView
    property string groupId

    onGroupIdChanged: {
        lightsModel.clear();
        for (var i=0; i < config["groups"][groupId]["lights"].length; i++) {
            lightsModel.append({
                                   "lightId": config["groups"][groupId]["lights"][i],
                                   "name": config["lights"][config["groups"][groupId]["lights"][i]]["name"],
                                   "on": config["lights"][config["groups"][groupId]["lights"][i]]["state"]["on"],
                                   "bri": config["lights"][config["groups"][groupId]["lights"][i]]["state"]["bri"],
                               });
        }
    }

    anchors.top: modeListView.bottom
    anchors.bottom: parent.bottom
    width: 304
    x: parent.width - 304
    state: parent.state
    states: [
        State {
            name: "CLOSE"
            PropertyChanges { target: lightView; x: parent.width - 304}
        },
        State {
            name: "OPEN"
            PropertyChanges { target: lightView; x: parent.width}
        }
    ]
    ListModel {
        id: lightsModel
    }

    ScrollView {
        anchors.fill: parent
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        clip: true

        ListView {
            id: lightsListView
            anchors.fill: parent
            model: lightsModel
            delegate: LightsStyle {}
            highlightMoveDuration: 500
            focus: true
        }
//        style: ScrollViewStyle {
//            transientScrollBars: true
//            handle: Item {
//                implicitWidth: 14
//                implicitHeight: 26
//                Rectangle {
//                    color: "#424246"
//                    anchors.fill: parent
//                    anchors.topMargin: 2
//                    anchors.leftMargin: 4
//                    anchors.rightMargin: 4
//                    anchors.bottomMargin: 8
//                }
//            }
//            scrollBarBackground: Item {
//                implicitWidth: 14
//                implicitHeight: 26
//            }
//        }
    }

    transitions: Transition {
        NumberAnimation {
            properties: "x"
            duration: 160
            easing.type: Easing.OutQuint
        }
    }
}
