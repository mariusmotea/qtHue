import QtQuick 2.8
import QtQuick.Controls 2.8

ComboBox{
    property var comboColor: "white"
    property var comboRadius: 12
    id: combobox
    width: parent.width
    height: parent.height
    font.pixelSize: 12*parent.height*0.03

    delegate: ItemDelegate {
        width: combobox.width
        contentItem: Text {
            text: model.text
            color: "white"
            font: combobox.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle{
            color: parent.hovered ? "#131316" : "#1A1A1E"
            width: parent.width
            height: parent.height
            radius: comboRadius
        }
        highlighted: combobox.highlightedIndex === index
    }
    indicator: Text{
        x: combobox.width - width - combobox.rightPadding
        y: combobox.topPadding + (combobox.availableHeight - height) / 3
        width: 12*parent.height*0.028
        height: 8*parent.height*0.04
        font.pixelSize: 20*parent.height*0.03
        font.family: "FontAwesome"
        text: "\uf103"
        color: combobox.pressed ? Qt.darker(comboColor, 2) : comboColor
    }
    contentItem: Text {
        leftPadding: 12
        rightPadding: combobox.indicator.width + combobox.spacing
        text: model.get(currentIndex).text
        font: combobox.font
        color: combobox.pressed ? Qt.darker(comboColor, 2) : comboColor
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
    popup: Popup {
        y: combobox.height - 1
        width: combobox.width
        implicitHeight: contentItem.implicitHeight
        padding: 1

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight + 2
            model: combobox.popup.visible ? combobox.delegateModel : null
            currentIndex: combobox.highlightedIndex
            ScrollIndicator.vertical: ScrollIndicator { }
        }
        background: Rectangle{
            anchors.fill: parent
            radius: comboRadius
            color: "#161619"
        }
    }
    background: Rectangle{
        color: "#161619"
        width: parent.width
        height: parent.height
        radius: comboRadius
    }
}

