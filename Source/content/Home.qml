import QtQuick 2.8
import "styles"
import "functions.js" as Functions

Item {
    id: home
    objectName: "Home"
    property int columnCount: gridViewProduse.cellHeight*gridViewProduse.count < gridViewProduse.height ? 1 : gridViewProduse.cellHeight*gridViewProduse.count < gridViewProduse.height*2 ? 2 : 3
        GridView {
            id: gridViewProduse
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: mainWindow.width
            model: groupsModel
            delegate: GroupStyle {}

            cellWidth: 365*columnCount > mainWindow.width ? 365 : mainWindow.width/columnCount > 500 ? 500 : mainWindow.width/columnCount
            cellHeight: mainWindow.height*(109/768) > 95 ? 95 : mainWindow.height*(109/768) < 82 ? 82 : mainWindow.height*(109/768)
            flow: GridView.FlowTopToBottom
            cacheBuffer: 1024
            focus: true
        }
}
