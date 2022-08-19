/*
* Copyright (C) 2022 walking-octopus
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; version 3.
*
* system-info is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http: //www.gnu.org/licenses/>.
*/

import QtQuick 2.7
import Ubuntu.Components 1.3
import "../../Components"

Page {
    id: systemPage
    anchors.fill: parent

    header: PageHeader {
        id: header
        title: i18n.tr('System')
    }

// OTA version and channel
// Ubuntu base version
// Halium and Android subsystem version
// WayDroid/Anbox version
// Kernel version
// Uptime
// Developer mode/SSH enabled
// Localization settings

    ScrollView {
        id: scrollView
        height: parent.height
        width: parent.width

        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        Item {
            width: scrollView.width
            height: layout.height + units.gu(8)

            Column {
                id: layout
                width: parent.width
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                }
                
                SectionDivider {
                    text: i18n.tr("OS")
                }

                InfoItem {
                    title.text: i18n.tr("Ubuntu Version")
                    value.text: "Ubuntu 16.04 LTS"
                }
                InfoItem {
                    title.text: i18n.tr("OTA Version")
                    value.text: "OTA-23"
                }
                InfoItem {
                    title.text: i18n.tr("Uptime")
                    value.text: "2d 16h"
                }
            }
        }
    }


// Python {
//     id: python

//     Component.onCompleted: {
//         addImportPath(Qt.resolvedUrl('../src/'));

//         importModule('example', function() {
//             python.call('example.speak', ['Hello World!'], function(returnValue) {
//                 print(`example.speak returned ${returnValue}`);
//             })
//         });
//     }

//     onError: print(`Python error: ${traceback}`)
// }
}
