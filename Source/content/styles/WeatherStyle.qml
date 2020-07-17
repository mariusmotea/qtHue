import QtQuick 2.8
import "../font/weatherIcons.js" as Wi

Item{
    property var time: ""
    property int timeId: 0
    property var textColor: "white"
    property var addition: ""
    property var response: weatherResponseOnecall
    width: weather_forecast.width/9 - 9
    height: weather_forecast.height

    Rectangle{
        color: "black"
        height: parent.height
        width: parent.width
        anchors.margins: 2
        radius: 10
        opacity: 0.2
        visible: image_weather.text == "" & text_time.text == "" & text_temp.text == "" ? false : true
    }

    Text{
        id: image_weather
        width: parent.width
        height: parent.height*0.48
        padding: 5
        color: textColor
        font.family: "Weather Icons"
        font.pixelSize: 500
        fontSizeMode: Text.Fit
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text: response != "" ? Wi.getWeatherIcon(response[time][timeId]["weather"][0]["icon"].replace(/[0-9]/g, '') + response[time][timeId]["weather"][0]["id"]) : ""
    }
    Text{
        id: text_time
        width: parent.width
        height: parent.height*0.26
        padding: 5
        anchors.top: image_weather.bottom
        color: textColor
        font.pixelSize: 400
        fontSizeMode: Text.Fit
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text: response != "" ? Wi.unixToReadable(response[time][timeId]["dt"], time) : ""
    }
    Text{
        id: text_temp
        width: parent.width
        height: parent.height*0.26
        padding: 5
        anchors.top: text_time.bottom
        color: textColor
        font.pixelSize: 400
        fontSizeMode: Text.Fit
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text: response == "" ? "" : time == "hourly" ? parseFloat(response["hourly"][timeId]["temp"]).toFixed(1) + tempUnit : time == "daily" ? parseFloat(response["daily"][timeId]["temp"]["min"]).toFixed(0) + "/" + parseFloat(response["daily"][timeId]["temp"]["max"]).toFixed(0) : ""
    }
}
