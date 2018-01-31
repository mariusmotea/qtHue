import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0
import "functions.js" as Functions



Item {
    id: lightStyle
    width: 300
    height: background.height + 10

    Rectangle {
        id: background
        width: parent.width
        height: 90 + xy_selection.height + color_temp.height
        //color: "white"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 5
        anchors.leftMargin: 5
        state: "CLOSED"
        states: [
            State {
                name: "OPEN"
                PropertyChanges { target: background; height: 100 + xy_selection.height + color_temp.height0}
            },
            State {
                name: "CLOSE"
                PropertyChanges { target: background; height: 100}
            }
        ]
        transitions: Transition {
            NumberAnimation {
                properties: "height"
                duration: 160
                easing.type: Easing.OutQuint
            }
        }
        radius: 5
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#fcfcfc"
            }
            GradientStop {
                position: 1.0
                color: "#c6c6c6"
            }
        }
        Image {
            id: bulb
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.topMargin: 7
            source: "/content/images/bulb.png"

            Image {
                id: bulb_mask
                anchors.top: parent.top
                anchors.left: parent.left
                source: "/content/images/bulb_head.png"
                visible: false

            }
            Rectangle {
                id: bulb_color
                anchors.fill: bulb_mask
                color: { if (on) {
                        if (config["lights"][lightId]["state"]["colormode"] === "xy")
                            Functions.cieToRGB(config["lights"][lightId]["state"]["xy"][0],config["lights"][lightId]["state"]["xy"][1], bri);
                        else if (config["lights"][lightId]["state"]["colormode"] === "ct")
                            Functions.colorTemperatureToRGB(config["lights"][lightId]["state"]["ct"]);
                        else
                            "#000000";
                    } else
                        "#333333";
                }
                visible: false

            }
            OpacityMask {
                anchors.fill: bulb_mask
                source: bulb_color
                maskSource: bulb_mask
            }
        }

        Text {
            id: text_nume
            text: name
            width: 200
            anchors.top: parent.top
            anchors.left: bulb.right
            anchors.leftMargin: 10
            anchors.topMargin: 5
            color: "#254757"
            font.pixelSize: 24
            font.family: "Tahoma"
            renderType: Text.NativeRendering
            wrapMode: Text.Wrap
        }

        Text {
            id: power_switch
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.top: parent.top
            anchors.topMargin: 10
            font.pointSize: 32
            font.family: "FontAwesome"
            color: state === "ON" ? "#468bb7" : "#cccccc"
            text: "\uf011"
            state: on ? "ON":"OFF"

            MouseArea {
                id: menumouse
                anchors.fill: parent
                anchors.margins: -10
                onClicked: {
                    if ( power_switch.state === "ON") {
                        power_switch.state = "OFF";
                    } else {
                        power_switch.state = "ON";
                    }
                    pyconn('PUT', '/lights/' + lightId + '/state', {
                               "on": !on
                           }, Functions.noCallback);
                    on = !on;
                }
            }
        }
        Slider {
            id: slider_bri
            anchors.top: parent.top
            anchors.left: bulb.right
            anchors.leftMargin: 10
            anchors.topMargin: 45
            style: SliderStyle {
                handle: Rectangle {
                    width: 30
                    height: 30
                    radius: height
                    antialiasing: true
                    color: Qt.lighter(
                               power_switch.state === "ON" ? "#468bb7" : "#444",
                                                      1.2)
                }

                groove: Item {
                    implicitHeight: 50
                    implicitWidth: 200
                    Rectangle {
                        height: 8
                        width: parent.width
                        anchors.verticalCenter: parent.verticalCenter
                        color: "#444"
                        opacity: 0.8
                        Rectangle {
                            antialiasing: true
                            radius: 1
                            color: power_switch.state === "ON" ? "#468bb7" : "#444"
                            height: parent.height
                            width: parent.width * control.value / control.maximumValue
                        }
                    }
                }
            }
            value: bri
            maximumValue: 255
            minimumValue: 1
            enabled: power_switch.state === "ON"? true : false
            updateValueWhileDragging: false
            onValueChanged: {
                if (value !== bri) {
                    pyconn('PUT', '/lights/' + lightId + '/state', {
                                         "bri": parseInt(value, 10)
                                     }, Functions.noCallback)
                }
            }
        }
        LinearGradient {
            id: xy_selection
            width: parent.width - 10
            anchors.left: parent.left
            anchors.leftMargin: 5
            height: background.state === "OPEN" ? 100 : 0
            anchors.top: parent.top
            anchors.topMargin: 100
            start: Qt.point(0, 0)
            end: Qt.point(parent.width, 0)
            gradient: Gradient {
                GradientStop {
                    position: 0.000
                    color: Qt.rgba(1, 0, 0, 1)
                 }
                 GradientStop {
                    position: 0.167
                    color: Qt.rgba(1, 1, 0, 1)
                 }
                 GradientStop {
                    position: 0.333
                    color: Qt.rgba(0, 1, 0, 1)
                 }
                 GradientStop {
                    position: 0.500
                    color: Qt.rgba(0, 1, 1, 1)
                 }
                 GradientStop {
                    position: 0.667
                    color: Qt.rgba(0, 0, 1, 1)
                 }
                 GradientStop {
                    position: 0.833
                    color: Qt.rgba(1, 0, 1, 1)
                 }
                 GradientStop {
                    position: 1.000
                    color: Qt.rgba(1, 0, 0, 1)
                 }
            }
            LinearGradient {
                anchors.fill: parent
                start: Qt.point(0, parent.height)
                end: Qt.point(0, 0)
                gradient: Gradient {
                    GradientStop { position: 0; color: Qt.rgba(1, 1, 1, 1) }
                    GradientStop { position: 1; color: Qt.rgba(1, 1, 1, 0) }
                }
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    function mix(a, b, v)
                    {
                        return (1-v)*a + v*b;
                    }

                    var H = mouseX * 360 / width;
                    var S = (height - mouseY) / height;
                    var V = bri / 255;
                    var V2 = V * (1 - S);
                    var r  = ((H>=0 && H<=60) || (H>=300 && H<=360)) ? V : ((H>=120 && H<=240) ? V2 : ((H>=60 && H<=120) ? mix(V,V2,(H-60)/60) : ((H>=240 && H<=300) ? mix(V2,V,(H-240)/60) : 0)));
                    var g  = (H>=60 && H<=180) ? V : ((H>=240 && H<=360) ? V2 : ((H>=0 && H<=60) ? mix(V2,V,H/60) : ((H>=180 && H<=240) ? mix(V,V2,(H-180)/60) : 0)));
                    var b  = (H>=0 && H<=120) ? V2 : ((H>=180 && H<=300) ? V : ((H>=120 && H<=180) ? mix(V2,V,(H-120)/60) : ((H>=300 && H<=360) ? mix(V,V2,(H-300)/60) : 0)));


                    if (r < 0) r = 0;
                    if (b < 0) b = 0;
                    if (g < 0) g = 0;

                    var decColor =0x1000000+ Math.round(b * 255) + 0x100 * Math.round(g * 255) + 0x10000 * Math.round(r * 255) ;

                    bulb_color.color = '#'+decColor.toString(16).substr(1);


                    var xy = Functions.rgb_to_cie(r,g,b);

                    pyconn('PUT', '/lights/' + lightId + '/state', {"xy": xy}, Functions.noCallback);
                }
            }
        }
        LinearGradient {
            id: color_temp
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5
            width: parent.width - 10
            anchors.left: parent.left
            anchors.leftMargin: 5
            height: background.state === "OPEN" ? 50 : 0
            start: Qt.point(0, 0)
            end: Qt.point(parent.width, 0)
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
            LinearGradient {
                id: mask_colortemp
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0; color: Qt.rgba(1, 1, 1, 0.8) }
                    GradientStop { position: 0.3; color: Qt.rgba(1, 1, 1, 0) }
                }
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    var ct = 153 + ((width - mouseX) * 347 / width);
                    pyconn('PUT', '/lights/' + lightId + '/state', {"ct": ct}, Functions.noCallback);
                    bulb_color.color = Functions.colorTemperatureToRGB(ct);

                }
            }
        }
        MouseArea {
            anchors.top: parent.top
            anchors.left: parent.left
            width: parent.width - 60
            height: 50
            onClicked: {
                if (background.state === "OPEN") {
                    background.state = "CLOSED";
                } else {
                    background.state = "OPEN"
                }
            }
        }
    }
}

