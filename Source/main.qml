import QtQuick 2.4
import QtQuick.Controls 2.4
import QtQuick.LocalStorage 2.0
import "./content"
import "content/functions.js" as Functions

ApplicationWindow {
    id: mainWindow
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
    property string local: "en_RO"
    property string city: "city"
    property string apikey: "apikey"  //free registration on openweathermap.org

    ///end user configuration
    property bool any_on: false
    property bool bridgeConnected: false
    property var config: { "groups": {}, "lights": {}, "scenes": {} }

    FontLoader {
        source: "content/fontawesome-webfont.ttf"
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
            } else if (xhr.readyState === 4 && xhr.status === 0 && stackView.currentItem.objectName !== "BridgeConnect") {
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

    function bridgePair(data) {
        if ("success" in data[0]) {
            username = data[0]["success"]["username"]
            pyconn('GET', '', {

                   }, Functions.updateLightsStatus)
            var db = LocalStorage.openDatabaseSync(
                        "qtHue", "", "Store bridge connection data", 10000)
            db.transaction(function (tx) {
                // Create the database if it doesn't already exist
                tx.executeSql('UPDATE hue_bridge SET username = "'
                              + data[0]["success"]["username"] + '", ip = "' + bridgeIp + '"')
            })
            bridgeConnected = true;
        } else {
            bridgeConnected = false;
            console.warn("pair failed")
            if ("error" in data[0]) {
                console.warn(data[0]["error"]["description"])
            }
            stackView.push(Qt.resolvedUrl("content/BridgeConnect.qml"))
        }
    }

    Item {
        Component.onCompleted: {
            Functions.getWeather();
            var db = LocalStorage.openDatabaseSync(
                        "qtHue", "", "Store bridge connection data", 10000)
            db.transaction(function (tx) {
                //tx.executeSql('DROP TABLE hue_bridge')  //just for tests
                // Create the database if it doesn't already exist
                tx.executeSql(
                            'CREATE TABLE IF NOT EXISTS hue_bridge(ip TEXT, username TEXT, city TEXT, apikey TEXT)')

                var rs = tx.executeSql('SELECT * FROM hue_bridge')
                if (rs.rows.length === 0) {
                    tx.executeSql('INSERT INTO hue_bridge VALUES(?, ?, ?, ?)',
                                  ['', '', '', ''])
                    stackView.push(Qt.resolvedUrl("content/BridgeConnect.qml"))
                    pyconn('POST', '', {
                                         devicetype: "qtHue#diyHue"
                                     }, bridgePair)
                } else {
                    bridgeIp = rs.rows.item(0).ip
                    username = rs.rows.item(0).username
                    city = rs.rows.item(0).city
                    apikey = rs.rows.item(0).apikey
                    pyconn('GET', '', {

                                     }, Functions.updateLightsStatus)
                }
            })
        }
    }





    header: BorderImage {

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
                        if (menu_context.visible === true) menu_context.close();
                        else menu_context.open();
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
                clock_txt.text = date.toLocaleTimeString(Qt.locale(local),
                                                         "hh:mm")
                date_txt.text = date.toLocaleDateString(Qt.locale(local),
                                                        "MMM yyyy")
                zi_txt.text = date.toLocaleDateString(Qt.locale(local), "dddd")
                nr_zi.text = date.toLocaleDateString(Qt.locale(local), "d")
                if (date.toLocaleTimeString(Qt.locale(local),
                                            "s").slice(-1) === "0") {
                    pyconn('GET', '', {

                           }, Functions.updateLightsStatus)
                    Functions.getWeather();
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
            name: "Bridge"
            page: "/content/BridgeConnect.qml"
        }
        ListElement {
            name: "Weather"
            page: "/content/Weather.qml"
        }
    }

    Menu {
        id: menu_context
    }

    Color {
        id: color
    }
}
