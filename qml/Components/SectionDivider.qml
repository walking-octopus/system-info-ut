import QtQuick 2.7
import Ubuntu.Components 1.3

Item {
    id: rootItem

    property alias text: sectionLabel.text
    property alias subtext: sectionSublabel.text

    anchors {
        left: parent.left
        right: parent.right
        leftMargin: units.gu(2)
    }
    height: units.gu(6)

    Label {
        id: sectionLabel
        anchors {
            top: sectionSublabel.text ? parent.top : undefined
            topMargin: sectionSublabel.text ? units.gu(2) : units.gu(1)
            left: parent.left
            verticalCenter: sectionSublabel.text ? undefined : parent.verticalCenter
        }

        textSize: Label.Large
        color: theme.palette.normal.focus
    }

    Label {
        id: sectionSublabel
        visible: !!text
        width: parent.width

        anchors {
            top: sectionLabel.bottom
            topMargin: units.gu(1)
        }

        textSize: Label.XSmall
        wrapMode: Label.WordWrap
        color: theme.palette.normal.backgroundTertiaryText
    }
}

