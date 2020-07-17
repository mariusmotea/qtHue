import QtQuick 2.8
import "styles"
import "functions.js" as Functions

Item {
    id: home
    objectName: "Home"

    GridView {
        id: gridViewProduse
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width
        model: groupsModel
        clip: true

        delegate: GroupStyle {}

//        cellWidth:  parent.width < 500*2 ? parent.width/2 : parent.width*(710/1360) > 500 ? 500 : parent.width*(710/1360)
//        cellHeight: parent.height*(109/768) > 89 ? 89 : parent.height*(109/768) < 69 ? 69 : parent.height*(109/768)
        cellWidth: 460
        flow: GridView.FlowTopToBottom
        interactive: false
        cacheBuffer: 1024
        focus: true
    }
}
