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

import QtQuick 2.12
import Ubuntu.Components 1.3
import "../../Components"

Page {
    id: systemPage
    anchors.fill: parent

    property var myData
    // Component.onCompleted: print(JSON.stringify(myData, null, 2))

    header: PageHeader {
        id: header
        title: i18n.tr('System')
    }

    // OTA version and channel
    // Ubuntu base version
    // Kernel version
    // WayDroid/Anbox version
    // Halium and Android subsystem version
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
                    title: i18n.tr("OTA Version")
                    value: myData["ota_version"]
                }
                InfoItem {
                    title: i18n.tr("Ubuntu Version")
                    value: myData["distro"]
                }
                InfoItem {
                    title: i18n.tr("Kernel Version")
                    value: myData["kernel"]
                }
                InfoItem {
                    title: i18n.tr("Android subsystem version")
                    value: myData["android_version"]
                }
                
                // This would fit Device or Hardware more
                // InfoItem {
                //     title: i18n.tr("Device arch")
                //     value: myData["arch"]
                // }
                    
                InfoItem {
                    title: i18n.tr("Hostname")
                    value: myData["hostname"]
                }
                InfoItem {
                    title: i18n.tr("Uptime")
                    value: "TODO"
                }
            }
        }
    }
}
