function unixToReadable(unixString, timeId){
    var date = new Date(unixString * 1000)
    if(timeId === "hourly") return Qt.formatDateTime(date, "hh" + timeUnit)
    else if(timeId === "daily") return date.toLocaleDateString(Qt.locale(local), "ddd")
    else if(timeId === "hour") return date.getHours() + "." + date.getMinutes()
}

function getWindText(){
    var windDeg = parseInt(weatherResponseOnecall["current"]["wind_deg"])
    var windSpeed = parseFloat(weatherResponseOnecall["current"]["wind_speed"])
    var windSpeedIcon

    if(windSpeed <= 0.3) windSpeedIcon = "\uf0b7";
    else if(windSpeed <= 1.5) windSpeedIcon = "\uf0b8";
    else if(windSpeed <= 3.3) windSpeedIcon = "\uf0b9";
    else if(windSpeed <= 5.4) windSpeedIcon = "\uf0ba";
    else if(windSpeed <= 7.9) windSpeedIcon = "\uf0bb";
    else if(windSpeed <= 10.7) windSpeedIcon = "\uf0bc";
    else if(windSpeed <= 13.8) windSpeedIcon = "\uf0bd";
    else if(windSpeed <= 17.1) windSpeedIcon = "\uf0be";
    else if(windSpeed <= 20.7) windSpeedIcon = "\uf0bf";
    else if(windSpeed <= 24.4) windSpeedIcon = "\uf0c0";
    else if(windSpeed <= 28.4) windSpeedIcon = "\uf0c1";
    else if(windSpeed <= 32.6) windSpeedIcon = "\uf0c2";
    else if(windSpeed >= 32.6) windSpeedIcon = "\uf0c3";

    if(windDeg <= 22.5) windDeg = "N"
    else if(windDeg >= 22.5 & windDeg < 67.5) windDeg = "NO"
    else if(windDeg >= 67.5 & windDeg < 112.5) windDeg = "O"
    else if(windDeg >= 112.5 & windDeg < 157.5) windDeg = "OS"
    else if(windDeg >= 157.5 & windDeg < 202.5) windDeg = "S"
    else if(windDeg >= 202.5 & windDeg < 247.5) windDeg = "SW"
    else if(windDeg >= 247.5 & windDeg < 292.5) windDeg = "W"
    else if(windDeg >= 292.5 & windDeg < 337.5) windDeg = "NW"
    else if(windDeg >= 337.5) windDeg = "N"

    return windSpeed + " m/s" + " " + windSpeedIcon + " " + windDeg
}

function getWeatherIcon(weatherId){
//    var weatherId = weatherResponse["list"][0]["sys"]["pod"] + weatherResponseOnecall["current"]["weather"][0]["id"];
//    weatherResponse["current"]["weather"][0]["icon"].replace(/[0-9]/g, '')

    if(weatherId === "d200") return "\uf010";
    else if(weatherId === "d201") return "\uf010";
    else if(weatherId === "d202") return "\uf010";
    else if(weatherId === "d210") return "\uf005";
    else if(weatherId === "d211") return "\uf005";
    else if(weatherId === "d212") return "\uf005";
    else if(weatherId === "d221") return "\uf005";
    else if(weatherId === "d230") return "\uf010";
    else if(weatherId === "d231") return "\uf010";
    else if(weatherId === "d232") return "\uf010";
    else if(weatherId === "d300") return "\uf00b";
    else if(weatherId === "d301") return "\uf00b";
    else if(weatherId === "d302") return "\uf008";
    else if(weatherId === "d310") return "\uf008";
    else if(weatherId === "d311") return "\uf008";
    else if(weatherId === "d312") return "\uf008";
    else if(weatherId === "d313") return "\uf008";
    else if(weatherId === "d314") return "\uf008";
    else if(weatherId === "d321") return "\uf00b";
    else if(weatherId === "d500") return "\uf00b";
    else if(weatherId === "d501") return "\uf008";
    else if(weatherId === "d502") return "\uf008";
    else if(weatherId === "d503") return "\uf008";
    else if(weatherId === "d504") return "\uf008";
    else if(weatherId === "d511") return "\uf006";
    else if(weatherId === "d520") return "\uf009";
    else if(weatherId === "d521") return "\uf009";
    else if(weatherId === "d522") return "\uf009";
    else if(weatherId === "d531") return "\uf00e";
    else if(weatherId === "d600") return "\uf00a";
    else if(weatherId === "d601") return "\uf0b2";
    else if(weatherId === "d602") return "\uf00a";
    else if(weatherId === "d611") return "\uf006";
    else if(weatherId === "d612") return "\uf006";
    else if(weatherId === "d615") return "\uf006";
    else if(weatherId === "d616") return "\uf006";
    else if(weatherId === "d620") return "\uf006";
    else if(weatherId === "d621") return "\uf00a";
    else if(weatherId === "d622") return "\uf00a";
    else if(weatherId === "d701") return "\uf003";
    else if(weatherId === "d711") return "\uf062";
    else if(weatherId === "d721") return "\uf0b6";
    else if(weatherId === "d731") return "\uf063";
    else if(weatherId === "d741") return "\uf003";
    else if(weatherId === "d761") return "\uf063";
    else if(weatherId === "d762") return "\uf063";
    else if(weatherId === "d781") return "\uf056";
    else if(weatherId === "d800") return "\uf00d";
    else if(weatherId === "d801") return "\uf000";
    else if(weatherId === "d802") return "\uf000";
    else if(weatherId === "d803") return "\uf000";
    else if(weatherId === "d804") return "\uf00c";
    else if(weatherId === "d900") return "\uf056";
    else if(weatherId === "d902") return "\uf073";
    else if(weatherId === "d903") return "\uf076";
    else if(weatherId === "d904") return "\uf072";
    else if(weatherId === "d906") return "\uf004";
    else if(weatherId === "d957") return "\uf050";
    else if(weatherId === "n200") return "\uf02d";
    else if(weatherId === "n201") return "\uf02d";
    else if(weatherId === "n202") return "\uf02d";
    else if(weatherId === "n210") return "\uf025";
    else if(weatherId === "n211") return "\uf025";
    else if(weatherId === "n212") return "\uf025";
    else if(weatherId === "n221") return "\uf025";
    else if(weatherId === "n230") return "\uf02d";
    else if(weatherId === "n231") return "\uf02d";
    else if(weatherId === "n232") return "\uf02d";
    else if(weatherId === "n300") return "\uf02b";
    else if(weatherId === "n301") return "\uf02b";
    else if(weatherId === "n302") return "\uf028";
    else if(weatherId === "n310") return "\uf028";
    else if(weatherId === "n311") return "\uf028";
    else if(weatherId === "n312") return "\uf028";
    else if(weatherId === "n313") return "\uf028";
    else if(weatherId === "n314") return "\uf028";
    else if(weatherId === "n321") return "\uf02b";
    else if(weatherId === "n500") return "\uf02b";
    else if(weatherId === "n501") return "\uf028";
    else if(weatherId === "n502") return "\uf028";
    else if(weatherId === "n503") return "\uf028";
    else if(weatherId === "n504") return "\uf028";
    else if(weatherId === "n511") return "\uf026";
    else if(weatherId === "n520") return "\uf029";
    else if(weatherId === "n521") return "\uf029";
    else if(weatherId === "n522") return "\uf029";
    else if(weatherId === "n531") return "\uf02c";
    else if(weatherId === "n600") return "\uf02a";
    else if(weatherId === "n601") return "\uf0b4";
    else if(weatherId === "n602") return "\uf02a";
    else if(weatherId === "n611") return "\uf026";
    else if(weatherId === "n612") return "\uf026";
    else if(weatherId === "n615") return "\uf026";
    else if(weatherId === "n616") return "\uf026";
    else if(weatherId === "n620") return "\uf026";
    else if(weatherId === "n621") return "\uf02a";
    else if(weatherId === "n622") return "\uf02a";
    else if(weatherId === "n701") return "\uf04a";
    else if(weatherId === "n711") return "\uf062";
    else if(weatherId === "n721") return "\uf0b6";
    else if(weatherId === "n731") return "\uf063";
    else if(weatherId === "n741") return "\uf04a";
    else if(weatherId === "n761") return "\uf063";
    else if(weatherId === "n762") return "\uf063";
    else if(weatherId === "n781") return "\uf056";
    else if(weatherId === "n800") return "\uf02e";
    else if(weatherId === "n801") return "\uf022";
    else if(weatherId === "n802") return "\uf022";
    else if(weatherId === "n803") return "\uf022";
    else if(weatherId === "n804") return "\uf086";
    else if(weatherId === "n900") return "\uf056";
    else if(weatherId === "n902") return "\uf073";
    else if(weatherId === "n903") return "\uf076";
    else if(weatherId === "n904") return "\uf072";
    else if(weatherId === "n906") return "\uf024";
    else if(weatherId === "n957") return "\uf050"
}
