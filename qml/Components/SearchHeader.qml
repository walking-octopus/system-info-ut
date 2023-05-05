import QtQuick 2.12
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3

PageHeader {
    id: rootItem
    signal searchText(string typedText)

    property bool isSearching: false
    property string title

    contents: Row {
        anchors.centerIn: parent
        width: isSearching ? parent.width - spacing : parent.width
        spacing: units.gu(1.5)

        Label {
            text: title
            visible: !isSearching
            textSize: Label.Large
        }

        TextField {
            id: searchField
            visible: isSearching
            width: parent.width

            // Disable predictive text
            inputMethodHints: Qt.ImhNoPredictiveText

            hasClearButton: false

            primaryItem: Icon {
                width: units.gu(2); height: width
                name: "find"
            }

            placeholderText: i18n.tr("Search with RegEx...")

            onTextChanged: searchText(text);
        }
    }

    leadingActionBar.actions: [
        Action {
            iconName: "toolkit_chevron-rtl_2gu"
            visible: !isSearching

            onTriggered: pStack.pop()
        },
        Action {
            iconName: "close"
            visible: isSearching

            onTriggered: closeHeader()
        }
    ]

    trailingActionBar {
        actions: [
            Action {
                iconName: "find"
                visible: !isSearching

                onTriggered: {
                    isSearching = true;
                    searchField.focus = true;
                }
            }
        ]
    }

    function closeHeader() {
        searchField.text = "";
        isSearching = false;
        searchField.focus = false;
    }
}