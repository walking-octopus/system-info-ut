/*
 * Copyright (C) 2022  walking-octopus
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * system-info is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.12
import Lomiri.Components 1.3
import QtQuick.Layouts 1.3

AbstractButton {
    id: rootItem

    height: units.gu(22)
    width: parent.width > units.gu(38) ?
        parent.width < units.gu(80) ?
            (flow.width * 0.5) - (flow.spacing * 0.5)
            : units.gu(22)
        : parent.width

    // Nested ternary operators look weird...

    // RGB channels from 'shape.color' are in [0; 1] range.
    property color foregroundColor: ((shape.color.r * 0.30 + shape.color.g * 0.6 + shape.color.b * 0.12) > 0.6) ? LomiriColors.darkGrey : "#F3F3E7"

    // TODO: Use a dictionary for more recognizable color names
    readonly property color color: ["#f0f0f0", "#ed3146", "#d4326b", "#e95420", "#f89b0f", "#f5d412", "#46c54f", "#14cfa8", "#19b6ee", "#4e46c5", "#9542c4", "#c343bf"][colorIndex]
    
    property int colorIndex: 0;
    property string iconName: "select-none"
    property string title: "Placeholder"

    property alias icon: icon

    LomiriShape {
        id: shape
        aspect: rootItem.pressed ? LomiriShape.Inset : LomiriShape.DropShadow
        color: rootItem.color
        radius: "medium"

        anchors.fill: parent
        clip: true

        Label {
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                bottomMargin: units.gu(1.55)
                leftMargin: units.gu(1.55)
            }

            text: rootItem.title
            fontSize: "large"
            font.weight: Font.Bold
            maximumLineCount: 1
            wrapMode: Text.WordWrap

            color: rootItem.foregroundColor
        }

        Icon {
            id: icon
            name: rootItem.iconName
            color: rootItem.foregroundColor

            width: units.gu(5); height: width
            anchors.centerIn: parent
        }
    }
}
