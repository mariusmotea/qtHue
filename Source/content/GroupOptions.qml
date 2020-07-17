import QtQuick 2.8
import QtQuick.Controls 2.8
import QtGraphicalEffects 1.0
import "functions.js" as Functions

Item {
    id: groupView
    anchors.fill: parent

    Flickable {
        anchors.top: groupView.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: color_temp.top
        clip: true

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
                anchors.leftMargin: 20

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
    }
    Slider {
        property bool activate: false
        id: color_temp
        height: "ct" in config["groups"][selected_id]["action"] ? color_picker.height : 0
        anchors.left: parent.left
        anchors.right: color_linie.left
        anchors.bottom: parent.bottom
        orientation: Qt.Vertical
        handle: Item{}
        background: LinearGradient {
            anchors.fill: parent
            start: Qt.point(0, 0)
            end: Qt.point(0, parent.height)
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
        from: 150
        to: 500
        live: false
        Component.onCompleted: {activate = true}
        onValueChanged: {
            if(activate){
                var ct = Math.floor(color_temp.value)
                console.log(ct)
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

    Item {
        id: color_picker
        width: parent.width*0.85
        height: "xy" in config["groups"][selected_id]["action"] ? parent.width*0.85 : 0
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

                var H = hue;
                var S = sat / (width / 2);

                if (S > 1) S = 1;

                var V2 = V * (1 - S);
                var r  = ((H>=0 && H<=60) || (H>=300 && H<=360)) ? V : ((H>=120 && H<=240) ? V2 : ((H>=60 && H<=120) ? mix(V,V2,(H-60)/60) : ((H>=240 && H<=300) ? mix(V2,V,(H-240)/60) : 0)));
                var g  = (H>=60 && H<=180) ? V : ((H>=240 && H<=360) ? V2 : ((H>=0 && H<=60) ? mix(V2,V,H/60) : ((H>=180 && H<=240) ? mix(V,V2,(H-180)/60) : 0)));
                var b  = (H>=0 && H<=120) ? V2 : ((H>=180 && H<=300) ? V : ((H>=120 && H<=180) ? mix(V2,V,(H-120)/60) : ((H>=300 && H<=360) ? mix(V,V2,(H-300)/60) : 0)));


                if (r < 0) r = 0;
                if (b < 0) b = 0;
                if (g < 0) g = 0;

                pyconn('PUT', '/groups/' + selected_id + '/action', {"xy": Functions.rgb_to_cie(r,g,b)}, Functions.noCallback);

            }
        }
    }
    Rectangle {
        id: color_linie_top
        anchors.bottom: color_picker.top
        anchors.right: parent.right
        anchors.left: parent.left
        color: colorCode
        height: "xy" in config["groups"][selected_id]["action"] && "ct" in config["groups"][selected_id]["action"] ? 3 : 0
        border.color: Qt.darker(colorCode,1.2)
        border.width: 1
    }

    Rectangle {
        id: color_linie
        anchors.bottom: parent.bottom
        anchors.right: color_picker.left
        anchors.rightMargin: -1
        width: 3
        height: color_picker.height
        color: colorCode
        border.color: Qt.darker(colorCode,1.2)
        border.width: 1
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
