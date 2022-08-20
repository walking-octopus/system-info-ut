import QtQuick 2.7
import Ubuntu.Components 1.3

ListItem {
    id: "rootItem"
    property string title: "Placeholder"
    property var value

    // TODO: Show a toast when copying data
    onClicked: Clipboard.push(`${layout.title.text}: ${layout.subtitle.text}`)

    ListItemLayout {
        id: layout
        anchors.centerIn: parent

        title.text: rootItem.title
        subtitle.text: rootItem.value != undefined ? rootItem.value : "N/A"
    }
}