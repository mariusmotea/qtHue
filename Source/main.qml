import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQml.Models 2.2
import "./content"

ApplicationWindow {
    visible: true
    title: qsTr("piPOS")
    width: 1360
    height: 768

    property string url: "127.0.0.1"
    property string username: "a7161538be80d40b3de98dece6e91f904dc96170"
    property string locale: "en_RO"
    ///end user configuration

    property bool any_on: false

    FontLoader {
        source: "content/fontawesome-webfont.ttf"
    }

    function pyconn(reqType, path, data, callback) {
        var xhr = new XMLHttpRequest
        xhr.open(reqType,
                 'http://' + url + '/api/' + username + path,
                 true)
        xhr.setRequestHeader("Content-type", "application/json")
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4 && xhr.status === 200) {
                var response = JSON.parse(xhr.responseText)
                callback(response)
                //console.warn(xhr.responseText)
                return response.length
            }
        }
        xhr.send(JSON.stringify(data))
    }

    function updateLightsStatus(data) {
        any_on = false;
        if (data["groups"].length !== 0) {
            groupsModel.clear()
            for (var key in data["groups"]) {
                if (data["groups"][key]["name"].substring(0, 18) !== "Entertainment area") {
                    groupsModel.append({
                                           groupId: key,
                                           name: data["groups"][key]["name"],
                                           on: data["groups"][key]["state"]["any_on"],
                                           bri: data["groups"][key]["state"]["bri"]
                                       })
                    if (data["groups"][key]["state"]["any_on"])
                        any_on = true;
                }
            }
        }
    }

    function noCallback() {}

    toolBar: BorderImage {

        border.bottom: 8
        source: "content/images/toolbar.png"
        width: parent.width
        height: 60

        ////home image
        Item {
            id: home
            anchors.left: parent.left
            anchors.leftMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            width: 80
            height: 50

            Rectangle {
                id: home_background
                anchors.fill: parent
                anchors.leftMargin: 7
                antialiasing: true
                radius: 4
                color: homemouse.pressed ? "#222" : "transparent"
            }

            Text {
                id: home_img
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 18
                font.pointSize: 25
                font.family: "FontAwesome"
                color: any_on? "#cccccc" : "#3a3a3a"
                text: "\uf015"
            }

            MouseArea {
                id: homemouse
                anchors.fill: parent
                anchors.margins: -10
                onClicked: {
                    pyconn('PUT', '/groups/0/action', {
                               on: !any_on}, noCallback);
                    any_on =!any_on;
                }
            }
        }
        /////////////////////////
        Text {
            id: clock_txt
            font {
                family: "Droid Sans Regular"
                pixelSize: 45
            }
            color: "white"
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 3
        }
        Text {
            id: zi_txt
            font {
                family: "Droid Sans Regular"
                pixelSize: 22
            }
            color: "white"
            anchors.right: parent.right
            anchors.rightMargin: 7 + clock_txt.width
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
        }
        Text {
            id: date_txt
            font {
                family: "Droid Sans Regular"
                pixelSize: 16
            }
            color: "white"
            anchors.right: parent.right
            anchors.rightMargin: 7 + clock_txt.width
            anchors.top: parent.top
            anchors.topMargin: 8
        }
        Text {
            id: nr_zi
            font {
                family: "Droid Sans Regular"
                pixelSize: 22
            }
            color: "#17aff6"
            anchors.right: parent.right
            anchors.rightMargin: 8 + clock_txt.width + date_txt.width
            anchors.top: parent.top
            anchors.topMargin: 1
        }
        Timer {
            interval: 1000
            running: true
            repeat: true

            onTriggered: {
                var date = new Date()
                clock_txt.text = date.toLocaleTimeString(Qt.locale(locale),
                                                         "hh:mm")
                date_txt.text = date.toLocaleDateString(Qt.locale(locale),
                                                        "MMM yyyy")
                zi_txt.text = date.toLocaleDateString(Qt.locale(locale),
                                                      "dddd")
                nr_zi.text = date.toLocaleDateString(Qt.locale(locale), "d")
                if (date.toLocaleTimeString(Qt.locale(locale),"s").slice(-1) === "0") {
                    pyconn('GET', '', {}, updateLightsStatus);
                }
            }
        }
        Rectangle {
            id: linie_data
            x: nr_zi.x - 10
            anchors.verticalCenter: parent.verticalCenter
            width: 1
            height: 40
            color: "#424246"
        }
    }

    ListModel {
        id: groupsModel
        Component.onCompleted: {
            pyconn('GET', '', {

                   }, updateLightsStatus)
        }
    }

    Component {
        id: switchStyle
        SwitchStyle {

            groove: Rectangle {
                implicitHeight: 55
                implicitWidth: 120
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    width: parent.width / 2 - 2
                    height: 20
                    anchors.margins: 2
                    color: control.checked ? "#468bb7" : "#222"
                    Behavior on color {
                        ColorAnimation {
                        }
                    }
                    Text {
                        font.pixelSize: 18
                        color: "white"
                        anchors.centerIn: parent
                        text: "ON"
                    }
                }
                Item {
                    width: parent.width / 2
                    height: parent.height
                    anchors.right: parent.right
                    Text {
                        font.pixelSize: 18
                        color: "white"
                        anchors.centerIn: parent
                        text: "OFF"
                    }
                }
                color: "#222"
                border.color: "#444"
                border.width: 2
            }
            handle: Rectangle {
                width: parent.parent.width / 2
                height: control.height
                color: "#444"
                border.color: "#555"
                border.width: 2
            }
        }
    }

    Component {
        id: touchStyle
        SliderStyle {
            handle: Rectangle {
                width: 30
                height: 30
                radius: height
                antialiasing: true
                color: Qt.lighter("#468bb7", 1.2)
            }

            groove: Item {
                implicitHeight: 50
                implicitWidth: 240
                Rectangle {
                    height: 8
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#444"
                    opacity: 0.8
                    Rectangle {
                        antialiasing: true
                        radius: 1
                        color: "#468bb7"
                        height: parent.height
                        width: parent.width * control.value / control.maximumValue
                    }
                }
            }
        }
    }

    Component {
        id: groupsDelegate
        Item {
            id: produs
            width: parent.width
            height: parent.height
            Rectangle {
                width: 400
                height: 80
                color: "white"
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 5
                anchors.leftMargin: 5
                border.color: "#aaaaaa"
                border.width: 1
                radius: 5
                Text {
                    id: text_nume
                    text: name
                    width: 200
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.topMargin: 5
                    color: "#254757"
                    font.pixelSize: 24
                    font.family: "Tahoma"
                    renderType: Text.NativeRendering
                    wrapMode: Text.Wrap
                }

                Switch {
                    id: switch_state
                    style: switchStyle
                    anchors.top: parent.top
                    anchors.topMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 15
                    checked: on
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (switch_state.checked === true) {
                                switch_state.checked = false
                            } else {
                                switch_state.checked = true
                            }
                            pyconn('PUT', '/groups/' + groupId + '/action', {
                                       on: switch_state.checked
                                   }, noCallback)
                        }
                    }
                }
                Slider {
                    id: slider_bri
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.bottomMargin: -3
                    style: touchStyle
                    value: bri
                    maximumValue: 255
                    minimumValue: 1
                    updateValueWhileDragging: false
                    onValueChanged: {
                            pyconn('PUT', '/groups/' + groupId + '/action', {
                                       bri: parseInt(value, 10)
                                   }, noCallback);
                    }

                }
            }
        }
    }

    //////
    GridView {
        id: gridViewProduse
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width
        model: groupsModel
        delegate: groupsDelegate
        cellWidth: 410
        //cellHeight: 90
        flow: GridView.FlowTopToBottom
        interactive: false
        cacheBuffer: 1024
        focus: true
    }
}
