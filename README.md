# qtHue
A graphic interface for Philips Hue lights made in qt framework

![interface](https://github.com/mariusmotea/qtHue/blob/master/Screenshot.png?raw=true)

Currently this is in beta state, you can control only the On/Off state and the brightness. In the future i will add options for changing the colors of the lights and maybe to apply scenes.

No auto discovery is available in this moment, you will need to manually provide the ip and a valid username for communication with hue bridge.

    property string url: "127.0.0.1
    property string username: "a7161538be80d40b3de98dece6e91f904dc96170"


from diyHue is very easy to retrive an username from config.json file (config -> whitelist)
