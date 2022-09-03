import QtQuick 2.7
import Ubuntu.Components 1.3

ListItem {
    id: "rootItem"
    property string title: "Placeholder"
    property var value

    // visible: !!rootItem.value

    onClicked: {
        toast.show(i18n.tr("Copied!"))
        Clipboard.push(`${layout.title.text}: ${layout.subtitle.text}`)
    }

    ListItemLayout {
        id: layout
        anchors.centerIn: parent

        title.text: rootItem.title
        subtitle.text: !!rootItem.value ? rootItem.value : "N/A"
        subtitle.maximumLineCount: 2
        subtitle.wrapMode: Text.Wrap
    }
}