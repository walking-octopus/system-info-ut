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
    height: sectionSublabel.text ? units.gu(8) : units.gu(6) // FIXME: sectionSublabel is a bit hacky.
    clip: true

    Label {
        id: sectionLabel
        anchors {
            top: sectionSublabel.text ? parent.top : undefined
            topMargin: sectionSublabel.text ? units.gu(1.5) : units.gu(1)
            bottomMargin: sectionSublabel.text ? units.gu(2) : 0
            left: parent.left
            verticalCenter: sectionSublabel.text ? undefined : parent.verticalCenter
        }

        textSize: Label.Large
        color: theme.palette.normal.focus
    }

    Label {
        id: sectionSublabel
        visible: !!text
        width: parent.width - anchors.rightMargin

        anchors {
            top: sectionLabel.bottom
            topMargin: units.gu(0.5)
            rightMargin: units.gu(1.5)
        }

        // textSize: Label.Small
        fontSizeMode: Text.Fit

        wrapMode: Label.WordWrap
        color: theme.palette.normal.backgroundTertiaryText
    }
}

