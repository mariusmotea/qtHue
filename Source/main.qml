import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQml.Models 2.2
import QtQuick.LocalStorage 2.0
import QtGraphicalEffects 1.0
import "./content"

ApplicationWindow {
    visible: true
    title: qsTr("piPOS")
    width: 1360
    height: 768
    Rectangle {
        id: background
        color: "#212126"
        anchors.fill: parent
    }

    property string bridgeIp: "127.0.0.1"
    property string username: ""
    property string locale: "en_RO"
    property string city: "Bucharest"
    property string apikey: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"  //free registration on openweathermap.org

    ///end user configuration
    property bool any_on: false
    property bool keypad_focus: false

    FontLoader {
        source: "content/fontawesome-webfont.ttf"
    }

    Item {
        Component.onCompleted: {
            getWeather();
            var db = LocalStorage.openDatabaseSync(
                        "qtHue", "", "Store bridge connection data", 10000)
            db.transaction(function (tx) {
                //tx.executeSql('DROP TABLE hue_bridge')

                // Create the database if it doesn't already exist
                tx.executeSql(
                            'CREATE TABLE IF NOT EXISTS hue_bridge(ip TEXT, username TEXT)')

                var rs = tx.executeSql('SELECT * FROM hue_bridge')
                if (rs.rows.length === 0) {
                    tx.executeSql('INSERT INTO hue_bridge VALUES(?, ?)',
                                  ['192.168.10.200', ''])
                    stackView.push(Qt.resolvedUrl("content/BridgeConnect.qml"))
                    console.warn("este 0")
                    pyconn('POST', '', {
                               devicetype: "qtHue#diyHue"
                           }, bridgePair)
                } else {
                    bridgeIp = rs.rows.item(0).ip
                    username = rs.rows.item(0).username
                    pyconn('GET', '', {

                           }, updateLightsStatus)
                }
            })
        }
    }

    function bridgePair(data) {
        console.warn(data[0]["success"]["username"])
        if ("success" in data[0]) {
            username = data[0]["success"]["username"]
            pyconn('GET', '', {

                   }, updateLightsStatus)
            var db = LocalStorage.openDatabaseSync(
                        "qtHue", "", "Store bridge connection data", 10000)
            db.transaction(function (tx) {
                // Create the database if it doesn't already exist
                tx.executeSql('UPDATE hue_bridge SET username = "'
                              + data[0]["success"]["username"] + '"')
            })
        }
    }

    function getWeather() {
        var xhr = new XMLHttpRequest
        xhr.open('GET', 'http://api.openweathermap.org/data/2.5/forecast?q=' + city + '&units=metric&APPID=' + apikey, true);
        xhr.setRequestHeader("Content-type", "application/json")
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4 && xhr.status === 200) {
                var response = JSON.parse(xhr.responseText);
                temperature.text = city + ' ' + parseInt(response["list"][0]["main"]["temp"], 10) + '°C';
                wheather_icon.source = 'http://openweathermap.org/img/w/' + response["list"][1]["weather"][0]["icon"] + '.png';
            }
        }
        xhr.send()
    }

    function pyconn(reqType, path, data, callback) {
        var xhr = new XMLHttpRequest
        xhr.open(reqType,
                 'http://' + bridgeIp + '/api/' + username + path, true)
        xhr.setRequestHeader("Content-type", "application/json")
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4 && xhr.status === 200) {
                var response = JSON.parse(xhr.responseText)
                callback(response)
                //console.warn(xhr.responseText)
                return response.length
            } else if (xhr.readyState === 4 && xhr.status === 0
                       && stackView.currentItem.objectName !== "BridgeConnect") {
                stackView.push(Qt.resolvedUrl("content/BridgeConnect.qml"))
            }
        }
        xhr.send(JSON.stringify(data))
    }

    function updateLightsStatus(data) {
        any_on = false
        if (data["groups"].length !== 0) {
            groupsModel.clear()
            for (var key in data["groups"]) {
                if (data["groups"][key]["name"].substring(
                            0, 18) !== "Entertainment area") {
                    groupsModel.append({
                                           groupId: key,
                                           name: data["groups"][key]["name"],
                                           on: data["groups"][key]["state"]["any_on"],
                                           bri: data["groups"][key]["action"]["bri"],
                                           colormode: data["groups"][key]["action"]["colormode"],
                                           ct: data["groups"][key]["action"]["ct"],
                                           xy: data["groups"][key]["action"]["xy"]
                                       })
                    if (data["groups"][key]["state"]["any_on"])
                        any_on = true
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
                color: any_on ? "#cccccc" : "#3a3a3a"
                text: "\uf015"
            }

            MouseArea {
                id: homemouse
                anchors.fill: parent
                anchors.margins: -10
                onClicked: {
                    pyconn('PUT', '/groups/0/action', {
                               on: !any_on
                           }, noCallback)
                    any_on = !any_on
                    for (var i = 0; i < groupsModel.count; i++) {
                        groupsModel.set(i, {
                                            on: any_on
                                        })
                    }
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
                zi_txt.text = date.toLocaleDateString(Qt.locale(locale), "dddd")
                nr_zi.text = date.toLocaleDateString(Qt.locale(locale), "d")
                if (date.toLocaleTimeString(Qt.locale(locale),
                                            "s").slice(-1) === "0") {
                    pyconn('GET', '', {

                           }, updateLightsStatus)
                    getWeather();
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

        Image {
            id: wheather_icon
            anchors.right: linie_data.left
            anchors.rightMargin: 8
            anchors.top: parent.top
            anchors.topMargin: 5
        }

        Text {
            id: temperature
            font {
                family: "Droid Sans Regular"
                pixelSize: 36
            }
            color: "white"
            anchors.right: wheather_icon.left
            anchors.rightMargin: 8
            anchors.top: parent.top
            anchors.topMargin: 7
            //text: "Bucarest 5°C"
        }

    }

    ListModel {
        id: groupsModel
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

            LinearGradient {
                width: 400
                height: 80
                //color: "white"
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 5
                anchors.leftMargin: 5
                start: Qt.point(0, 0)
                end: Qt.point(80, 400)
                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: "white"
                    }
                    GradientStop {
                        position: 1.0
                        color: "black"
                    }
                }
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
                    style: SliderStyle {
                        handle: Rectangle {
                            width: 30
                            height: 30
                            radius: height
                            antialiasing: true
                            color: Qt.lighter(
                                       switch_state.checked ? "#468bb7" : "#444",
                                                              1.2)
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
                                    color: switch_state.checked ? "#468bb7" : "#444"
                                    height: parent.height
                                    width: parent.width * control.value / control.maximumValue
                                }
                            }
                        }
                    }
                    value: bri
                    maximumValue: 255
                    minimumValue: 1
                    enabled: switch_state.checked
                    updateValueWhileDragging: false
                    onValueChanged: {
                        if (value !== bri) {
                            pyconn('PUT', '/groups/' + groupId + '/action', {
                                       bri: parseInt(value, 10)
                                   }, noCallback)
                        }
                    }
                }
            }
        }
    }

    //////
    StackView {
        id: stackView
        anchors.fill: parent
        focus: true
        initialItem: GridView {
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

        Keypad {
            id: keypad
            x: 0
            y: 420
            height: 300
            width: parent.height
        }

        states: [
            State {
                name: "Keypad_open"
                when: keypad_focus
                PropertyChanges {
                    target: keypad
                    y: 0
                }
            }
        ]

        transitions: Transition {
            NumberAnimation {
                properties: "x,y,opacity"
                duration: 160
                easing.type: Easing.OutQuint
            }
        }
    }
}
