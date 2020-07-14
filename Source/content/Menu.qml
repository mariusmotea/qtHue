import QtQuick 2.4
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.0
import "functions.js" as Functions

Drawer {
    id: menu_context
    y: mainWindow.header.height
    height: mainWindow.height - mainWindow.header.height
    width: mainWindow.width*(350/1360) > 400 ? 400 : mainWindow.width*(350/1360) < 200 ? 200 : mainWindow.width*(350/1360)
    opacity: 0.97
    dragMargin: 10

    background: Rectangle {
        color: "#17171b"
        anchors.fill: parent
        Rectangle {
            anchors.top: parent.top
            anchors.topMargin: 1
            anchors.right: parent.right
            width: 3
            height: menu_context.height
            color: "#33B5E5"
            border.color: "#237B9C"
            border.width: 1

        }
    }
    contentChildren: [
        ScrollView {
            id: menu_scrollview
            anchors.fill: parent
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            clip: true

            ListView {
                id: menuListView
                anchors.fill: parent
                model: menuModel

                delegate: ColumnLayout{
                    id: menu_grid
                    width: parent.width
                    height: root.height
                    Item{
                        id: root
                        Layout.fillWidth: true
                        Layout.preferredHeight: 55
                        Text {
                            id: menu_name
                            height: text.height
                            color: "white"
                            font.pixelSize: 400
                            fontSizeMode: Text.Fit
                            text: name
                            verticalAlignment: Text.AlignVCenter
                            anchors{left: parent.left; right: menu_arrow.left; top: parent.top; bottom: parent.bottom; margins: 10; leftMargin: 20; rightMargin: 5;}
                        }

                        Rectangle {
                            id: menu_line
                            height: 1
                            anchors.top: menu_name.text.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: 15
                            color: "#424246"
                        }

                        Image {
                            id: menu_arrow
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.rightMargin: 15
                            source: "./images/navigation_next_item.png"
                            fillMode: Image.PreserveAspectFit
                        }

                        MouseArea{
                            anchors.fill: parent
                            onClicked:{
                                stackView.replace(Qt.resolvedUrl(page))
                                menuListView.currentIndex = index;
                                menu_context.close();
                            }
                        }
                    }
                }
                highlightMoveDuration: 300
                focus: true
                highlight: Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 5
                    radius: 20
                    color: "#254757"
                }
            }
        },
        Item{
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            height: 40
            Rectangle{
                id: background
                height: 40
                width: parent.width - 3
                color: "#17171b"
            }

            Text{
                id: quit_txt
                anchors{right: linie_middle.left; left: parent.left; bottom: parent.bottom; top: linie_abrove.bottom; margins: 2;}
                color: "white"
                font.pixelSize: 25
                fontSizeMode: Text.Fit
                text: "Quit"
                horizontalAlignment: Text.AlignHCenter
                MouseArea{anchors.fill: parent; onClicked: Qt.quit();}
            }

            Text{
                id: screen_txt
                height: 40
                anchors{left: linie_middle.right; right: parent.right; bottom: parent.bottom; top: linie_abrove.bottom; rightMargin: 4; margins: 2;}
                color: "white"
                font.pixelSize: 25
                fontSizeMode: Text.Fit
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: "Fullscreen"
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        if(screen_txt.text == "Fullscreen"){screen_txt.text = "Windowed"; mainWindow.showFullScreen();}
                        else{screen_txt.text = "Fullscreen"; mainWindow.showNormal();
                        }}}
            }

            Rectangle {
                id: linie_middle
                width: 1
                anchors{top: linie_abrove.top; bottom: parent.bottom; margins: 5; horizontalCenter: parent.horizontalCenter;}
                color: "#424246"
            }
            Rectangle {
                id: linie_abrove
                height: 1
                anchors{top: parent.top; topMargin: 5; left: parent.left; right: parent.right; margins: 10;}
                color: "#424246"
            }
        }
    ]
}
