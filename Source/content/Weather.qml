import QtQuick 2.6
import "styles"
import "font/weatherIcons.js" as Wi

Item {
    id: weather
    objectName: "Weather"
    property var response: weatherResponseOnecall
    Rectangle{
        anchors.fill: image_weather
        radius: 10
        opacity: 0.1
        color: Qt.hsva(colorCode.hsvHue - 0.001, colorCode.hsvSaturation - 0.25, colorCode.hsvValue, 1)
        visible: image_weather.text != ""
    }

    Text {
        id: image_weather
        width: this.height
        height: parent.height/2.1
        font.pixelSize: 400
        font.family: "Weather Icons"
        fontSizeMode: Text.Fit
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 10
        padding: 10
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        transformOrigin: Item.Center
        text: response != "" ? Wi.getWeatherIcon(response["current"]["weather"][0]["icon"].replace(/../,'') + response["current"]["weather"][0]["id"]) : ""
        color: "white"
    }

    Rectangle{
        color: "black"
        anchors.fill: text_description
        anchors.margins: 10
        radius: 10
        opacity: 0.2
        visible: text_description.text == "" ? false : true
    }

    Text{
        id: text_description
        anchors.top: image_weather.bottom
        anchors.bottom: weather_forecast.top
        anchors.left: parent.left
        width: parent.width
        color: "white"
        font.pixelSize: 400
        fontSizeMode: Text.Fit
        padding: 20
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        text: response != "" ? " " + response["current"]["weather"][0]["description"] : ""
    }


    /////1
    Row{
        height: image_weather.height/2
        anchors.top: parent.top
        anchors.left: image_weather.right
        anchors.right: parent.right
        anchors.margins: 10
        anchors.bottomMargin: 0
        spacing: 10
        Rectangle{          //tempature
            color: "#1A1A1E"
            width: parent.width/2
            height: parent.height
            radius: 10
            visible: text_temp.text == "" ? false : true
            Text{
                id: text_temp
                width: parent.width
                height: parent.height
                padding: 20
                color: "white"
                font.pixelSize: 400
                fontSizeMode: Text.Fit
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: response != "" ? parseFloat(response["current"]["temp"]).toFixed(1) + " " + tempUnit : ""
            }
        }
        Rectangle{         //sunrise and sunset
            color: "#1A1A1E"
            width: parent.width/2
            height: parent.height
            radius: 10
            visible: text_sun.text == "" ? false : true
            Text{
                id: text_sun
                width: parent.width
                height: parent.height
                padding: 20
                color: "white"
                font.family: "Weather Icons"
                font.pixelSize: 400
                fontSizeMode: Text.Fit
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: response != "" ? Wi.unixToReadable(response["current"]["sunrise"], "hour") + " \uf051  " + Wi.unixToReadable(response["current"]["sunset"], "hour") + " \uf052" : ""
            }
        }
    }


    /////2
    Row{
        height: image_weather.height/2 - 10
        anchors.bottom: text_description.top
        anchors.left: image_weather.right
        anchors.right: parent.right
        anchors.margins: 10
        anchors.bottomMargin: 0
        spacing: 10
        Rectangle{       //humidity
            color: "#1A1A1E"
            width: parent.width/2
            height: parent.height
            radius: 10
            visible: text_humidity.text == "" ? false : true
            Text{
                id: text_humidity
                width: parent.width
                height: parent.height
                padding: 20
                color: "white"
                font.pixelSize: 400
                fontSizeMode: Text.Fit
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: response != "" ? " " + response["current"]["humidity"] + " %" : ""
            }
        }
        Rectangle{       //wind 
            color: "#1A1A1E"
            width: parent.width/2
            height: parent.height
            radius: 10
            visible: text_wind.text == "" ? false : true
            Text{
                id: text_wind
                width: parent.width
                height: parent.height
                padding: 20
                color: "white"
                font.pixelSize: 400
                fontSizeMode: Text.Fit
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: response != "" ? Wi.getWindText() : ""
            }
        }
    }

    ////////hourly & daily weather data
    Row{
        id: weather_forecast
        height: parent.height/3.2
        width: parent.width - 20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10
        Flickable{
            height: parent.height
            width: (parent.width/9)*5
            contentWidth: (parent.width/9) * 12
            clip: true
            Row{
                height: parent.height
                width: parent.width
                spacing: 10
                WeatherStyle{
                    addition: timeAddition
                    time: "hourly"
                    timeId: 1
                }
                WeatherStyle{
                    addition: timeAddition
                    time: "hourly"
                    timeId: 2
                }
                WeatherStyle{
                    addition: timeAddition
                    time: "hourly"
                    timeId: 3
                }
                WeatherStyle{
                    addition: timeAddition
                    time: "hourly"
                    timeId: 4
                }
                WeatherStyle{
                    addition: timeAddition
                    time: "hourly"
                    timeId: 5
                }
                WeatherStyle{
                    addition: timeAddition
                    time: "hourly"
                    timeId: 6
                }
                WeatherStyle{
                    addition: timeAddition
                    time: "hourly"
                    timeId: 7
                }
                WeatherStyle{
                    addition: timeAddition
                    time: "hourly"
                    timeId: 8
                }
                WeatherStyle{
                    addition: timeAddition
                    time: "hourly"
                    timeId: 9
                }
                WeatherStyle{
                    addition: timeAddition
                    time: "hourly"
                    timeId: 10
                }
                WeatherStyle{
                    addition: timeAddition
                    time: "hourly"
                    timeId: 11
                }
                WeatherStyle{
                    addition: timeAddition
                    time: "hourly"
                    timeId: 12
                }
            }
        }
        Flickable{
            height: parent.height
            width: (parent.width/9)*4
            contentWidth: (parent.width/9) * 7
            clip: true
            Row{
                height: parent.height
                width: parent.width
                spacing: 10
                WeatherStyle{
                    textColor: Qt.lighter(colorCode, 1.5)
                    time: "daily"
                    timeId: 1
                }
                WeatherStyle{
                    textColor: Qt.lighter(colorCode, 1.5)
                    time: "daily"
                    timeId: 2
                }
                WeatherStyle{
                    textColor: Qt.lighter(colorCode, 1.5)
                    time: "daily"
                    timeId: 3
                }
                WeatherStyle{
                    textColor: Qt.lighter(colorCode, 1.5)
                    time: "daily"
                    timeId: 4
                }
                WeatherStyle{
                    textColor: Qt.lighter(colorCode, 1.5)
                    time: "daily"
                    timeId: 5
                }
                WeatherStyle{
                    textColor: Qt.lighter(colorCode, 1.5)
                    time: "daily"
                    timeId: 6
                }
                WeatherStyle{
                    textColor: Qt.lighter(colorCode, 1.5)
                    time: "daily"
                    timeId: 7
                }
            }
        }
    }
}
