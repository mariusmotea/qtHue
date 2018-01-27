import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.LocalStorage 2.0
import QtGraphicalEffects 1.0
import "./content"

ApplicationWindow {
    visible: true
    title: qsTr("qtHue")
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
    property string city: "city"
    property string apikey: "apikey"  //free registration on openweathermap.org

    ///end user configuration
    property bool any_on: false
    property var config: { "groups": {}, "lights": {}, "scenes": {} }

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
                            'CREATE TABLE IF NOT EXISTS hue_bridge(ip TEXT, username TEXT, city TEXT, apikey TEXT)')

                var rs = tx.executeSql('SELECT * FROM hue_bridge')
                if (rs.rows.length === 0) {
                    tx.executeSql('INSERT INTO hue_bridge VALUES(?, ?, ?, ?)',
                                  ['', '', '', ''])
                    stackView.push(Qt.resolvedUrl("content/BridgeConnect.qml"))
                    console.warn("este 0")
                    pyconn('POST', '', {
                               devicetype: "qtHue#diyHue"
                           }, bridgePair)
                } else {
                    bridgeIp = rs.rows.item(0).ip
                    username = rs.rows.item(0).username
                    city = rs.rows.item(0).city
                    apikey = rs.rows.item(0).apikey
                    pyconn('GET', '', {

                           }, updateLightsStatus)
                }
            })
        }
    }

    function bridgePair(data) {
        if ("success" in data[0]) {
            username = data[0]["success"]["username"]
            pyconn('GET', '', {

                   }, updateLightsStatus)
            var db = LocalStorage.openDatabaseSync(
                        "qtHue", "", "Store bridge connection data", 10000)
            db.transaction(function (tx) {
                // Create the database if it doesn't already exist
                tx.executeSql('UPDATE hue_bridge SET username = "'
                              + data[0]["success"]["username"] + '", ip = "' + bridgeIp + '"')
            })
        } else {
            stackView.push(Qt.resolvedUrl("content/BridgeConnect.qml"))
        }
    }

    function getWeather() {
        if (apikey.length > 10) {
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

    function saveWheatherDetails() {
        var db = LocalStorage.openDatabaseSync(
                    "qtHue", "", "Store bridge connection data", 10000)
        db.transaction(function (tx) {
            tx.executeSql('UPDATE hue_bridge SET city = "' + city + '", apikey = "' + apikey + '"' )
        })
    }

    function updateLightsStatus(data) {
        any_on = false
        config["groups"] = data["groups"];
        config["lights"] = data["lights"];
        if (data["groups"].length !== 0) {
            groupsModel.clear()
            for (var group in data["groups"]) {
                if (data["groups"][group]["name"].substring(
                            0, 18) !== "Entertainment area") {
                    groupsModel.append({
                                           groupId: group,
                                           name: data["groups"][group]["name"],
                                           on: data["groups"][group]["state"]["any_on"],
                                           bri: data["groups"][group]["action"]["bri"],
                                           colormode: data["groups"][group]["action"]["colormode"],
                                           ct: data["groups"][group]["action"]["ct"],
                                           xy: data["groups"][group]["action"]["xy"]
                                       })
                    if (data["groups"][group]["state"]["any_on"])
                        any_on = true
                }
            }
        }
        if (data["scenes"].length !== 0) {
            for (var scene in data["scenes"]) {
                for (var i in data["groups"]) {
                    if (data["groups"][i]["lights"].indexOf(data["scenes"][scene]["lights"][0]) > -1) {
                        if (config["scenes"][i] == null) {
                            config["scenes"][i] = {}
                        }
                        config["scenes"][i][scene] = data["scenes"][scene]["name"];
                    }
                }
            }
        }
    }

    function noCallback() {}

    function cieToRGB(x, y, brightness)
    {
        //Set to maximum brightness if no custom value was given (Not the slick ECMAScript 6 way for compatibility reasons)
        if (brightness === undefined) {
            brightness = 254;
        }

        var z = 1.0 - x - y;
        var Y = (brightness / 254).toFixed(2);
        var X = (Y / y) * x;
        var Z = (Y / y) * z;

        //Convert to RGB using Wide RGB D65 conversion
        var red 	=  X * 1.656492 - Y * 0.354851 - Z * 0.255038;
        var green 	= -X * 0.707196 + Y * 1.655397 + Z * 0.036152;
        var blue 	=  X * 0.051713 - Y * 0.121364 + Z * 1.011530;

        //If red, green or blue is larger than 1.0 set it back to the maximum of 1.0
        if (red > blue && red > green && red > 1.0) {

            green = green / red;
            blue = blue / red;
            red = 1.0;
        }
        else if (green > blue && green > red && green > 1.0) {

            red = red / green;
            blue = blue / green;
            green = 1.0;
        }
        else if (blue > red && blue > green && blue > 1.0) {

            red = red / blue;
            green = green / blue;
            blue = 1.0;
        }

        //Reverse gamma correction
        red 	= red <= 0.0031308 ? 12.92 * red : (1.0 + 0.055) * Math.pow(red, (1.0 / 2.4)) - 0.055;
        green 	= green <= 0.0031308 ? 12.92 * green : (1.0 + 0.055) * Math.pow(green, (1.0 / 2.4)) - 0.055;
        blue 	= blue <= 0.0031308 ? 12.92 * blue : (1.0 + 0.055) * Math.pow(blue, (1.0 / 2.4)) - 0.055;


        //Convert normalized decimal to decimal
        red 	= Math.round(red * 255);
        green 	= Math.round(green * 255);
        blue 	= Math.round(blue * 255);

        if (isNaN(red))
            red = 0;

        if (isNaN(green))
            green = 0;

        if (isNaN(blue))
            blue = 0;

        var decColor =0x1000000+ blue + 0x100 * green + 0x10000 *red ;
        return '#'+decColor.toString(16).substr(1);
    }



    function colorTemperatureToRGB(mireds){

        var hectemp = 20000.0 / mireds;

        var red, green, blue;

        if( hectemp <= 66 ){

            red = 255;
            green = 99.4708025861 * Math.log(hectemp) - 161.1195681661;
            blue = hectemp <= 19 ? 0 : (138.5177312231 * Math.log(hectemp - 10) - 305.0447927307);


        } else {

          red = 329.698727446 * Math.pow(hectemp - 60, -0.1332047592);
          green = 288.1221695283 * Math.pow(hectemp - 60, -0.0755148492);
          blue = 255;

        }

          red = red > 255 ? 255 : red;
          green = green > 255 ? 255 : green;
          blue = blue > 255 ? 255 : blue;


        var decColor =0x1000000+ parseInt(blue, 10) + 0x100 * parseInt(green, 10) + 0x10000 * parseInt(red, 10) ;
        return '#'+decColor.toString(16).substr(1);


    }



    toolBar: BorderImage {

        border.bottom: 8
        source: "content/images/toolbar.png"
        width: parent.width
        height: 60

        Rectangle {
            id: menu
            x: 5
            anchors.verticalCenter: parent.verticalCenter
            width: 65
            antialiasing: true
            height: 50
            radius: 4
            color: menumouse.pressed ? "#222" : "transparent"
            Behavior on x {
                NumberAnimation {
                    easing.type: Easing.OutCubic
                }
            }

            Text {
                id: menu_img
                anchors.centerIn: parent
                font.pointSize: 25
                font.family: "FontAwesome"
                color: "#cccccc"
                text: "\uf0c9"

                MouseArea {
                    id: menumouse
                    anchors.fill: parent
                    anchors.margins: -10
                    onClicked: {
                        if (menu_context.state === "OPEN") {
                            menu_context.state = "CLOSE";
                        } else {
                            menu_context.state = "OPEN";
                        }
                    }
                }
            }

            Rectangle {
                id: linie_menu
                anchors.left: parent.right
                anchors.leftMargin: 5
                anchors.verticalCenter: parent.verticalCenter
                width: 1
                height: 45
                color: "#424246"
            }
        }

        ////home image
        Item {
            id: home
            anchors.left: menu.right
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
            x: nr_zi.x < zi_txt.x? nr_zi.x - 10 : zi_txt.x - 10
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

    ListModel {
        id: scenesModel
    }


    Component {
        id: switchStyle
        SwitchStyle {

            groove: Rectangle {
                implicitHeight: 55
                implicitWidth: 120
                radius: 5
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    radius: 3
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
                radius: 5
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
                width: 450
                height: 80
                //color: "white"
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 5
                anchors.leftMargin: 5
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
                    Canvas {
                        id: bulb_light
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        height: 21
                        opacity: 0.7
                        visible: false
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();
                            ctx.rect(0, 0, width, height);
                            var gradient = ctx.createLinearGradient(0, 21, 40, 0);
                            var step_level = 0, current_level= 0;
                            if (config["groups"][groupId]["lights"].length > 1) {
                                step_level = 1.0 / (config["groups"][groupId]["lights"].length - 1);
                            } else {
                                step_level = 1
                            }
                            for (var i = 0; i < config["groups"][groupId]["lights"].length; i++) {
                                if (config["lights"][config["groups"][groupId]["lights"][i]]["state"]["on"]) {
                                    if ("colormode" in config["lights"][config["groups"][groupId]["lights"][i]]["state"]) {
                                        if (config["lights"][config["groups"][groupId]["lights"][i]]["state"]["colormode"] === "xy") {

                                            gradient.addColorStop(current_level, cieToRGB(config["lights"][config["groups"][groupId]["lights"][i]]["state"]["xy"][0], config["lights"][config["groups"][groupId]["lights"][i]]["state"]["xy"][1], 250))
                                        } else if (config["lights"][config["groups"][groupId]["lights"][i]]["state"]["colormode"] === "ct") {
                                            gradient.addColorStop(current_level, colorTemperatureToRGB(config["lights"][config["groups"][groupId]["lights"][i]]["state"]["ct"]))
                                        }
                                    } else {
                                        gradient.addColorStop(current_level, "#fff9aa")
                                    }
                                } else {
                                    gradient.addColorStop(current_level, "#333333")
                                }

                                current_level += step_level
                            }
                            ctx.fillStyle = gradient;
                            ctx.fill();
                            ctx.restore();

                            //GradientStop { position: 1.0; color: config["groups"][groupId]["action"]["colormode"] === "xy"? cieToRGB(config["groups"][groupId]["action"]["xy"][0], config["groups"][groupId]["action"]["xy"][1], config["groups"][groupId]["action"]["bri"]) : colorTemperatureToRGB(config["groups"][groupId]["action"]["ct"]) }

                        }
                    }

                    Image {
                        id: bulb_mask
                        anchors.top: parent.top
                        anchors.left: parent.left
                        source: "/content/images/bulb_head.png"
                        visible: false

                    }
                    OpacityMask {
                        anchors.fill: bulb_light
                        source: bulb_light
                        maskSource: bulb_mask
                    }
                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            light_options.state = "OPEN"
                            scenesModel.clear();
                            for (var key in config["scenes"][groupId]) {
                                scenesModel.append({
                                                       scene: key,
                                                       name: config["scenes"][groupId][key]})
                            }
                        }
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
                            on = switch_state.checked
                            if (switch_state.checked === true) {
                                on = false
                            } else {
                                on = true
                            }
                            for (var i = 0; i < config["groups"][groupId]["lights"].length; i++) {
                                config["lights"][config["groups"][groupId]["lights"][i]]["state"]["on"] = on
                                bulb_light.requestPaint();
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
                    anchors.left: bulb.right
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
            cellWidth: 460
            //cellHeight: 90
            flow: GridView.FlowTopToBottom
            interactive: false
            cacheBuffer: 1024
            focus: true
            Rectangle {
                id: light_options
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                visible: stackView.currentItem.objectName === "" ? true: false
                x: parent.width - 300
                width: 300
                state: "CLOSE"
                color: "#17171b"
                opacity: 0.97
                states: [
                    State {
                        name: "OPEN"
                        PropertyChanges { target: light_options; x: parent.width - 300}
                    },
                    State {
                        name: "CLOSE"
                        PropertyChanges { target: light_options; x: parent.width}
                    }
                ]
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
                Text {
                    id: scenes_options
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    font.pointSize: 25
                    color: "#cccccc"
                    text: "Scenes"
                }
                ScrollView {
                    anchors.top: scenes_options.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    flickableItem.interactive: true

                    ListView {
                        id: scenesListView
                        model: scenesModel
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
                                           }, noCallback);
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
                transitions: Transition {
                    NumberAnimation {
                        properties: "x"
                        duration: 160
                        easing.type: Easing.OutQuint
                    }
                }
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
            }
        }



        transitions: Transition {
            NumberAnimation {
                properties: "y"
                duration: 160
                easing.type: Easing.OutQuint
            }
        }
    }

    ListModel {
        id: menuModel
        ListElement {
            name: "Home"
            page: "main.qml"
        }
        ListElement {
            name: "Bridge"
            page: "/content/BridgeConnect.qml"
        }
        ListElement {
            name: "Wheater"
            page: "/content/Wheather.qml"
        }
    }

    Rectangle {
        id: menu_context
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        x: 0
        width: 300
        state: "CLOSE"
        color: "#17171b"
        opacity: 0.97
        states: [
            State {
                name: "OPEN"
                PropertyChanges { target: menu_context; x: 0}
            },
            State {
                name: "CLOSE"
                PropertyChanges { target: menu_context; x: -300}
            }
        ]

        ScrollView {
            anchors.fill: parent

            flickableItem.interactive: true

            ListView {
                id: menuListView
                model: menuModel
                delegate: Item {
                    id: root
                    width: parent.width
                    height: 70
                    Text {
                        id: menu_name
                        anchors.verticalCenter: parent.verticalCenter
                        color: "white"
                        height: 55
                        font.pixelSize: 40
                        text: name
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                    }
                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 15
                        height: 1
                        color: "#424246"
                    }

                    Image {
                        anchors.right: parent.right
                        anchors.rightMargin: 20
                        anchors.verticalCenter: parent.verticalCenter
                        source: "/content/images/navigation_next_item.png"
                    }

                    MouseArea{
                        anchors.fill: parent
                        onClicked:{
                            if (name === "Home") {
                                stackView.pop(1)
                            } else {
                                stackView.push(Qt.resolvedUrl(page));
                            }
                            menuListView.currentIndex = index;
                            menu_context.state = 'CLOSE'
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
        transitions: Transition {
            NumberAnimation {
                properties: "x"
                duration: 160
                easing.type: Easing.OutQuint
            }
        }
        Rectangle {
            anchors.top: parent.top
            anchors.topMargin: 5
            anchors.right: parent.right
            width: 4
            height: parent.height - 10
            color: "#33bef2"
            border.color: "#3b7891"
            border.width: 1
        }
    }
}
