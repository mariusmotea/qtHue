import QtQuick 2.6
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.8
import "styles"
import "functions.js" as Functions

Item {
    objectName: "Settings"

    Row{
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 5
        height: 40 + 40*parent.height*0.0008
        spacing: 5
        SettingsStyle{
            id: temp
            height: parent.height
            width: parent.width/4 - 4
            comboColor: colorCode
            model: ListModel{
                ListElement{text: "°C"}
                ListElement{text: "°F"}
            }
            Component.onCompleted: currentIndex = find(tempUnit)
            onActivated: {tempUnit = currentText; saveData()}
            ToolTip.visible: temp.hovered
            ToolTip.text: "~1.5 minutes to update"
            ToolTip.timeout: 2000
            ToolTip.delay: 500
        }
        SettingsStyle{
            id: time
            height: parent.height
            width: parent.width/4 - 4
            comboColor: colorCode
            model: ListModel{
                ListElement{text: "24h"; value: ""}
                ListElement{text: "12h"; value: "ap"}
            }
            Component.onCompleted: currentIndex = (timeUnit == "" ? 0 : 1)
            onActivated: {timeUnit = model.get(currentIndex).value; saveData()}
        }
        TextField{
            id: time_addition
            selectByMouse: true
            width: parent.width/4 - 4
            height: parent.height
            text: timeAddition
            color: colorCode
            placeholderText: "time addition for hourly weather forecast"
            font.pixelSize: 12*parent.height*0.03
            background: Rectangle{
                color: "#161619"
                width: parent.width
                height: parent.height
                radius: 12
            }
            onTextChanged: {timeAddition = time_addition.text; saveData()}
        }
        SettingsStyle{
            id: colorSelection
            height: parent.height
            width: parent.width/4 - 4
            comboColor: colorCode
            model: ListModel{
                ListElement{text: "Yellow"; value: "#e2D434"}
                ListElement{text: "Light Green"; value: "#35e035"}
                ListElement{text: "Green"; value: "#2c9122"}
                ListElement{text: "Cyan"; value: "#35ddcf"}
                ListElement{text: "Light Blue (default)"; value: "#33b5e5"}
                ListElement{text: "Blue"; value: "#3434db"}
                ListElement{text: "Violet"; value: "#8833ce"}
                ListElement{text: "Pink"; value: "#d662d6"}
                ListElement{text: "Red"; value: "#d12929"}
                ListElement{text: "Orange"; value: "#ce8833"}
                ListElement{text: "White"; value: "#ffffff"}
            }
            Component.onCompleted: {
                for(var i = 0; i < model.count; ++i) if(model.get(i).value == colorCode) currentIndex = i //@disable-check M126
            }
            onActivated: {colorCode = model.get(currentIndex).value; saveData()}
        }
    }

    Column{
        id: textEntrys
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.bottom: parent.bottom
        spacing: 10
        TextField {
            id: ipTextEntry
            width: parent.width*0.5
            height: parent.height/4 - 20
            anchors.horizontalCenter: parent.horizontalCenter
            selectByMouse: true
            text: bridgeIp
            color: "white"
            verticalAlignment: Text.AlignBottom
            font.pixelSize: 28*parent.height*0.0035
            placeholderText: "Bridge IP (e.g. 127.0.0.1)"
            background:
                BorderImage {
                    id: test
                    source: "images/textinput.png"
                    border.left: 8
                    border.right: 8
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 5
                    ColorOverlay{
                        width: parent.width
                        height: parent.height
                        source: parent
                        color: colorCode
                    }

            }
        }

        TextField {
            id: apikeyTextEntry
            width: parent.width*0.8
            height: parent.height/4 - 20
            anchors.horizontalCenter: parent.horizontalCenter
            selectByMouse: true
            text: apikey
            color: "white"
            font.pixelSize: 28*parent.height*0.0035
            placeholderText: "apikey"
            verticalAlignment: Text.AlignBottom
            background: BorderImage {
                source: "images/textinput.png"
                border.left: 8
                border.right: 8
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.right: parent.right
                ColorOverlay{
                    anchors.fill: parent
                    source: parent
                    color: colorCode
                }

            }
        }

        TextField {
            id: cityTextEntry
            width: parent.width*0.5
            height: parent.height/4 - 20
            anchors.horizontalCenter: parent.horizontalCenter
            selectByMouse: true
            text: city
            color: "white"
            font.pixelSize: 28*parent.height*0.0035
            placeholderText: "city name or id"
            verticalAlignment: Text.AlignBottom
            background: BorderImage {
                source: "images/textinput.png"
                border.left: 8
                border.right: 8
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.right: parent.right
                ColorOverlay{
                    anchors.fill: parent
                    source: parent
                    color: colorCode
                }
            }
        }

        Item{
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: parent.height/4
            Button {
                id: submit_button
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.leftMargin: -help_button.width + 5
                anchors.verticalCenter: parent.verticalCenter
                contentItem: Text {
                    text: "Save&Connect"
                    padding: 10
                    anchors.fill: parent
                    fontSizeMode: Text.Fit
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    color: "white"
                    font.pixelSize: 23*parent.parent.height*0.015
                    renderType: Text.NativeRendering
                }
                background: Rectangle {
                    anchors.fill: parent
                    antialiasing: true
                    radius: 20
                    color: "#FFFFFF"
                    opacity: 0.5
                    Rectangle{
                        id: highlight
                        anchors.margins: submit_button.pressed ? -3 : 0
                        anchors.fill: parent
                        radius: 20
                        color: submit_button.pressed ? colorCode : "transparent"
                        opacity: 0.8
                    }
                }
                onClicked: {
                    bridgeIp = ipTextEntry.text
                    apikey = apikeyTextEntry.text;
                    city = cityTextEntry.text;
                    timeAddition = time_addition.text;
                    saveData();
                    if(bridgeConnected != true) pyconn('POST', '', {devicetype: "qtHue#diyHue"}, bridgePair);
                    stackView.replace("Home.qml");
                }
            }
            Button{
                id: help_button
                anchors.left: submit_button.right
                anchors.leftMargin: 5
                anchors.verticalCenter: parent.verticalCenter
                width: submit_button.height
                height: this.width
                contentItem: Text{
                    anchors.fill: parent
                    padding: 2
                    fontSizeMode: Text.Fit
                    font.pixelSize: 200
                    font.family: "FontAwesome"
                    text:  "\uf059"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    color: "white"
                }
                background: Item{}
                onClicked: popup_help.open()
            }
        }
    }
    Popup{
        id: popup_help
        anchors.centerIn: parent
        width: parent.width*0.7
        height: parent.height*0.7
        contentItem: Text{
            anchors.fill: parent
            padding: 10
            color: "white"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            fontSizeMode: Text.Fit
            font.pixelSize: 200
            onLinkActivated: Qt.openUrlExternally(link)
            text: "<p><strong><span>Bridge IP</span></strong></p>
           <p><span>Type in your bridge ip e.g. 192.168.178.x</span></p>
           <p><span><strong>Apikey</strong></span></p>
           <p><span>Type in your apikey found&nbsp;</span><a href=\"https://home.openweathermap.org/api_keys\"><span>here</span></a></p><span>If you get an email about to many request, ignore it</span></p>
           <p><span><strong>City</strong></span></p>
           <p><span>Type in your city name or city id</span><br><span>Your city id can be found in the adressbar on your open weather city page</span></p>
           <p><span><strong>Unit</strong></span></p>
           <p><span>Change your time format from 24h to 12h or switch between Celsius and Fahrenheit</span></p>
           <p><span><strong>Time addition</strong></span></p>
           <p><span>It will be added behind the hour in the weather page (e.g. in german &quot;Uhr&quot; for better understanding)</span></p>"
        }
        background: Rectangle{
            anchors.fill: parent
            radius: 13
            color: "#212126"
            opacity: 0.97
            border.width: 2
            border.color: colorCode
        }
    }
}

