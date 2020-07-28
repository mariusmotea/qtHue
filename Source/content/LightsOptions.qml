import QtQuick 2.6
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import "styles"
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

    anchors.fill: parent

    ListModel {
        id: lightsModel
    }

    Flickable {
        anchors.fill: parent
        clip: true

        ListView {
            id: lightsListView
            anchors.fill: parent
            model: lightsModel
            delegate: LightsStyle {}
            highlightMoveDuration: 500
            focus: true
        }
    }

    transitions: Transition {
        NumberAnimation {
            properties: "x"
            duration: 160
            easing.type: Easing.OutQuint
        }
    }
}
