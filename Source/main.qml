import QtQuick 2.6
import QtQuick.Controls 2.0
import QtQuick.LocalStorage 2.0
import "./content"
import "content/functions.js" as Functions

ApplicationWindow {
    id: mainWindow
    visible: true
    title: qsTr("qtHue")
    width: 1360
    height: 768
    background: Rectangle {
        id: background
        color: "#212126"
        anchors.fill: parent
    }

    property var weatherResponseOnecall: ""
    property var weatherResponse: ""
    property string tempUnit: ""
    property string timeUnit: ""
    property string timeAddition: ""
    property color colorCode: "#33b5e5"
    property string bridgeIp: ""
    property string username: ""
    property string local: locale.name
    property string city: ""
    property string apikey: ""  //free registration on openweathermap.org

    ///end user configuration
    property bool any_on: false
    property bool bridgeConnected: false
    property var config: { "groups": {}, "lights": {}, "scenes": {} }

    FontLoader {
        source: "content/font/fontawesome-webfont.ttf"
    }
    FontLoader{
        source: "content/font/weathericons-regular-webfont.ttf"
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
                return response.length
            } else if (xhr.readyState === 4 && xhr.status === 0 && stackView.currentItem.objectName !== "Settings") {
                stackView.push(Qt.resolvedUrl("content/Settings.qml"))
            }
        }
        xhr.send(JSON.stringify(data))
    }

    function saveData() {
        var db = LocalStorage.openDatabaseSync("qtHue", "", "Store bridge connection data", 10000)
        db.transaction(function (tx) {
            tx.executeSql('UPDATE hue_bridge SET city = "' + city + '", apikey = "' + apikey + '"' )
            tx.executeSql('UPDATE settings SET timeUnit = "' + timeUnit + '", tempUnit = "' + tempUnit + '", colorCode = "' + colorCode + '", timeAddition = "' + timeAddition + '"' )
        })
    }

    function bridgePair(data) {
        if ("success" in data[0]) {
            username = data[0]["success"]["username"]
            pyconn('GET', '', {}, Functions.updateLightsStatus)
            var db = LocalStorage.openDatabaseSync("qtHue", "", "Store bridge connection data", 10000)
            db.transaction(function (tx) {
                // Create the database if it doesn't already exist
                tx.executeSql('UPDATE hue_bridge SET username = "' + data[0]["success"]["username"] + '", ip = "' + bridgeIp + '"')
            })
            bridgeConnected = true;
        } else {
            bridgeConnected = false;
            console.warn("pair failed")
            if ("error" in data[0]) {
                console.warn(data[0]["error"]["description"])
            }
            stackView.push(Qt.resolvedUrl("content/Settings.qml"))
        }
    }

    Item {
        Component.onCompleted: {
            var db = LocalStorage.openDatabaseSync("qtHue", "", "Store bridge connection data", 10000)

                db.transaction(function (tx) {
                    //tx.executeSql('DROP TABLE settings')  //just for tests
                    // Create the database if it doesn't already exist
                    tx.executeSql('CREATE TABLE IF NOT EXISTS hue_bridge(ip TEXT, username TEXT, city TEXT, apikey TEXT)')
                    tx.executeSql('CREATE TABLE IF NOT EXISTS settings(timeUnit TEXT, tempUnit TEXT, colorCode TEXT, timeAddition TEXT)')

                    var rs = tx.executeSql('SELECT * FROM hue_bridge')
                    var rs2 = tx.executeSql('SELECT * FROM settings')
                    if (rs.rows.length === 0) {
                        tx.executeSql('INSERT INTO hue_bridge VALUES(?, ?, ?, ?)',['', '', '', ''])
                        stackView.push(Qt.resolvedUrl("content/Settings.qml"))
                        pyconn('POST', '', {devicetype: "qtHue#diyHue"}, bridgePair)
                    } else {
                        bridgeIp = rs.rows.item(0).ip
                        username = rs.rows.item(0).username
                        city = rs.rows.item(0).city
                        apikey = rs.rows.item(0).apikey
                        bridgeConnected = true;
                        pyconn('GET', '', {}, Functions.updateLightsStatus)
                    }
                    if(rs2.rows.length === 0) tx.executeSql('INSERT INTO settings VALUES(?, ?, ?, ?)',["", "°C", "#33b5e5", ''])
                    else{
                        timeUnit = rs2.rows.item(0).timeUnit
                        tempUnit = rs2.rows.item(0).tempUnit
                        colorCode = rs2.rows.item(0).colorCode
                        timeAddition = rs2.rows.item(0).timeAddition
                    }

                })
            Functions.getWeather();
        }
    }
    header: ToolBar{
        id: toolbar
        width: parent.width
        height: 60
        anchors.bottom: parent.top
        background: Rectangle{
            anchors.fill: parent
            color: "black"
            Rectangle{
                anchors.bottom: parent.bottom
                height: 3
                width: parent.width
                color: colorCode
                border.color: Qt.darker(colorCode,1.1)
                border.width: 1
            }
        }
        contentChildren:[

            ////////////////Menubuttons
            Item{
                id: menu_buttons
                height: parent.height
                width: 120

                Rectangle {
                    id: linie_buttons
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    width: 1
                    height: 40
                    color: "#464141"
                }

                ToolButton {
                    id: menu
                    height: parent.height
                    anchors.right: linie_buttons.left
                    anchors.rightMargin: 10
                    antialiasing: true
                    onClicked: {
                        if (menu_context.visible === true) menu_context.close();
                        else menu_context.open();
                    }
                    background: Rectangle {
                        anchors.fill: menu_img
                        anchors.leftMargin: -10
                        anchors.rightMargin: -10
                        antialiasing: true
                        radius: 4
                        visible: menu.pressed ? true: false
                        color: "#222"
                    }
                    contentItem: Text {
                        id: menu_img
                        font.pointSize: 25
                        font.family: "FontAwesome"
                        color: "#cccccc"
                        text: "\uf0c9"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                ToolButton { //Home Button
                    id: home
                    height: parent.height
                    anchors.left: linie_buttons.right
                    anchors.leftMargin: 10
                    antialiasing: true
                    background: Rectangle {
                        anchors.fill: home_img
                        anchors.leftMargin: -10
                        anchors.rightMargin: -10
                        antialiasing: true
                        radius: 4
                        visible: home.pressed ? true : false
                        color: "#222"
                    }
                    contentItem: Text {
                        id: home_img
                        font.pointSize: 25
                        font.family: "FontAwesome"
                        color: any_on ? "#cccccc" : "#3a3a3a"
                        text: "\uf015"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                    onClicked: {
                        pyconn('PUT', '/groups/0/action', {on: !any_on}, Functions.noCallback)
                        any_on = !any_on
                        for (var i = 0; i < groupsModel.count; i++) {
                            groupsModel.set(i, {on: any_on})
                        }
                    }
                }
            },

            //////////////Temperature

            Flickable{
                id: temp_display
                height: parent.height
                anchors.left: menu_buttons.right
                anchors.right: clock_display.left
                flickableDirection: Flickable.HorizontalFlick
                contentWidth: stackView.currentItem.objectName === "Weather" ? this.width : weather_icon.width + temperature.width + 10
                clip: true
                rotation: 180

                Item {
                    rotation: 180
                    anchors.fill: parent
                    width: parent.width

                    Image {
                        id: weather_icon
                        fillMode: Image.PreserveAspectFit
                        anchors.rightMargin: 8
                        anchors.left: temperature.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        source: stackView.currentItem.objectName === "Weather" ? "" : weatherResponse != "" ? 'http://openweathermap.org/img/wn/' + weatherResponse["weather"][0]["icon"] + '@2x.png' : ""
                    }

                    Text {
                        id: temperature
                        font {
                            family: "Droid Sans Regular"
                            pixelSize: 36
                        }
                        color: "white"
                        width: temp_display.width - weather_icon.width
                        anchors.right: parent.right
                        anchors.rightMargin: 8 + weather_icon.width
                        anchors.top: parent.top
                        anchors.topMargin: 7
                        horizontalAlignment: stackView.currentItem.objectName === "Weather" ? Text.AlignHCenter : Text.AlignRight
                        text: stackView.currentItem.objectName === "Weather" ? weatherResponse["name"] : weatherResponseOnecall != "" ? weatherResponse["name"] + ' ' + parseInt(weatherResponseOnecall["current"]["temp"], 10) + '°C' : ""
                    }
                }
            },

            /////////////////Clock

            Item{
                id: clock_display
                height: parent.height
                width: clock_txt.width + linie_data.width + (nr_zi.width + date_txt.width > zi_txt.width ? nr_zi.width + date_txt.width : zi_txt.width) + 20
                anchors.right: parent.right

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
                    color: Qt.hsva(colorCode.hsvHue, colorCode.hsvSaturation, colorCode.hsvValue - 0.07, 1)
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
                        clock_txt.text = date.toLocaleTimeString(Qt.locale(local),"hh:mm" + timeUnit)
                        date_txt.text = date.toLocaleDateString(Qt.locale(local),"MMM yyyy")
                        zi_txt.text = date.toLocaleDateString(Qt.locale(local), "dddd")
                        nr_zi.text = date.toLocaleDateString(Qt.locale(local), "d")
                        if (date.toLocaleTimeString(Qt.locale(local),"s").slice(-1) === "0") {
                            pyconn('GET', '', {}, Functions.updateLightsStatus)
                        }
                    }
                }
                Timer{
                    interval: 90000
                    running: true
                    repeat: true
                    triggeredOnStart: true
                    onTriggered: Functions.getWeather()
                }

                Rectangle {
                    id: linie_data
                    x: nr_zi.x < zi_txt.x? nr_zi.x - 10 : zi_txt.x - 10
                    anchors.verticalCenter: parent.verticalCenter
                    width: 1
                    height: 40
                    color: "#424246"
                }
            }
        ]
    }

    ListModel {
        id: groupsModel
    }

    ListModel {
        id: scenesModel
    }

    //////
    StackView {
        id: stackView
        anchors.fill: parent
        focus: true
        initialItem: Home{}

        transitions: Transition {
            NumberAnimation {
                properties: "y,height"
                duration: 160
                easing.type: Easing.OutQuint
            }
        }
    }

    ListModel {
        id: menuModel
        ListElement {
            name: "Home"
            page: "/content/Home.qml"
        }
        ListElement {
            name: "Weather"
            page: "/content/Weather.qml"
        }
        ListElement {
            name: "Settings"
            page: "/content/Settings.qml"
        }
    }

    Menu {
        id: menu_context
    }

    Color {
        id: color
    }
}
