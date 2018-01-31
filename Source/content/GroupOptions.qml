import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0
import "functions.js" as Functions

Item {
    id: groupView
    anchors.top: modeListView.bottom
    anchors.bottom: parent.bottom
    width: 304
    x: parent.width - 304
    state: parent.state
    states: [
        State {
            name: "OPEN"
            PropertyChanges { target: groupView; x: parent.width - 304}
        },
        State {
            name: "CLOSE"
            PropertyChanges { target: groupView; x: parent.width}
        }
    ]
    transitions: Transition {
        NumberAnimation {
            properties: "x"
            duration: 160
            easing.type: Easing.OutQuint
        }
    }
    ScrollView {
        anchors.top: groupView.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: color_temp.top

        flickableItem.interactive: true

        ListView {
            id: scenesListView
            anchors.fill: parent
            model: scenesModel
            currentIndex: -1
            delegate: Text {
                id: scene_name
                color: "white"
                font.pixelSize: 32
                text: name
                anchors.left: parent.left
                anchors.leftMargin: 30

                MouseArea{
                    anchors.fill: parent
                    onClicked:{
                        pyconn('PUT', '/groups/0/action', {
                                   scene: scene
                               }, Functions.noCallback);
                        scenesListView.currentIndex = index;
                    }
                }
            }
            highlightMoveDuration: 500
            focus: true
            highlight: Rectangle {
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.right: parent.right
                anchors.rightMargin: 5
                radius: 4
                color: "#254757"
            }
        }
        style: ScrollViewStyle {
            transientScrollBars: true
            handle: Item {
                implicitWidth: 14
                implicitHeight: 26
                Rectangle {
                    color: "#424246"
                    anchors.fill: parent
                    anchors.topMargin: 2
                    anchors.leftMargin: 4
                    anchors.rightMargin: 4
                    anchors.bottomMargin: 8
                }
            }
            scrollBarBackground: Item {
                implicitWidth: 14
                implicitHeight: 26
            }
        }
    }
    Item {
        id: color_temp
        width: 300
        height: "ct" in config["groups"][selected_id]["action"] ? 50 : 0
        anchors.right: parent.right
        anchors.bottom: color_picker.top
        anchors.bottomMargin: 4
        LinearGradient {
            anchors.fill: parent
            start: Qt.point(0, 0)
            end: Qt.point(300, 0)
            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: "#ffecaa"
                }
                GradientStop {
                    position: 1
                    color: "#a5ceee"
                }
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                var ct = Math.floor(153 + ((300 - mouseX) * 1.15));
                pyconn('PUT', '/groups/' + selected_id + '/action', {"ct": ct}, Functions.noCallback);
                for (var light=0; light < config["groups"][selected_id]["lights"].length; light++) {
                    if ("ct" in config["lights"][config["groups"][selected_id]["lights"][light]]["state"]) {
                        config["lights"][config["groups"][selected_id]["lights"][light]]["state"]["ct"] = ct;
                    }
                }
                groupsModel.set(light_options.selected_id,{"ct":ct});
            }
        }
    }

    Rectangle {
        anchors.bottom: color_picker.top
        anchors.left: parent.left
        height: 4
        width: parent.width
        color: "#33bef2"
        border.color: "#3b7891"
        border.width: 1
    }

    Item {
        id: color_picker
        width: 300
        height: "xy" in config["groups"][selected_id]["action"] ? 300 : 0
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        ConicalGradient {
            anchors.fill: parent

            gradient: Gradient {
                GradientStop {
                    position: 0.000
                    color: Qt.rgba(1, 0, 0, 1)
                }
                GradientStop {
                    position: 0.167
                    color: Qt.rgba(1, 0, 1, 1)
                }
                GradientStop {
                    position: 0.333
                    color: Qt.rgba(0, 0, 1, 1)
                }
                GradientStop {
                    position: 0.500
                    color: Qt.rgba(0, 1, 1, 1)
                }
                GradientStop {
                    position: 0.667
                    color: Qt.rgba(0, 1, 0, 1)
                }
                GradientStop {
                    position: 0.833
                    color: Qt.rgba(1, 1, 0, 1)
                }
                GradientStop {
                    position: 1.000
                    color: Qt.rgba(1, 0, 0, 1)
                }
            }
            RadialGradient {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.1; color: Qt.rgba(1, 1, 1, 1) }
                    GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 0) }
                }
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {

                function mix(a, b, v)
                {
                    return (1-v)*a + v*b;
                }
                var centerX = width / 2;
                var centerY = height / 2

                var hue = Math.floor((Math.atan2(mouseY - centerY, mouseX - centerX)/ Math.PI * 180) + 180);
                var sat = Math.sqrt(Math.pow(mouseX - centerX, 2) + Math.pow(mouseY - centerY, 2));
                //convert angle to Hue
                if (hue < 90) hue += 270;
                else hue -= 90;
                hue = 360 - hue; //inverse rotation
                var V = groupsModel.get(light_options.selected_id).bri / 255;

                //console.warn("bri " + V);
                var H = hue;
                var S = sat / width;

                var V2 = V * (1 - S);
                var r  = ((H>=0 && H<=60) || (H>=300 && H<=360)) ? V : ((H>=120 && H<=240) ? V2 : ((H>=60 && H<=120) ? mix(V,V2,(H-60)/60) : ((H>=240 && H<=300) ? mix(V2,V,(H-240)/60) : 0)));
                var g  = (H>=60 && H<=180) ? V : ((H>=240 && H<=360) ? V2 : ((H>=0 && H<=60) ? mix(V2,V,H/60) : ((H>=180 && H<=240) ? mix(V,V2,(H-180)/60) : 0)));
                var b  = (H>=0 && H<=120) ? V2 : ((H>=180 && H<=300) ? V : ((H>=120 && H<=180) ? mix(V2,V,(H-120)/60) : ((H>=300 && H<=360) ? mix(V,V2,(H-300)/60) : 0)));


                if (r < 0) r = 0;
                if (b < 0) b = 0;
                if (g < 0) g = 0;

                var xy = Functions.rgb_to_cie(r,g,b);

                pyconn('PUT', '/groups/' + selected_id + '/action', {"xy": xy}, Functions.noCallback);

            }
        }
    }
}
