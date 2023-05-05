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
import Lomiri.Components 1.3
import "../../Components"

Page {
    anchors.fill: parent

    property var systemInfo
    Component.onCompleted: {
        let copiedSystemInfo = JSON.parse(JSON.stringify(systemInfo));
        copiedSystemInfo.global_ip = "REDACTED";

        print(JSON.stringify(copiedSystemInfo, null, 2))
    }

    title: header.title
    header: PageHeader {
        id: header
        title: i18n.tr('Network')
    }

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
            height: layout.height + units.gu(5)

            Column {
                id: layout
                width: parent.width
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                }

                SectionDivider {
                    text: i18n.tr("Basics")
                }

                InfoItem {
                    title: i18n.tr("Local IP")
                    value: systemInfo["current_ip"]
                }
                InfoItem {
                    title: i18n.tr("Current interface")
                    value: systemInfo["current_interface"]
                    // value: {
                        // if (Object.keys(systemInfo["interfaces"]).length == 0)
                        //     return systemInfo["current_interface"]

                        // return [
                        //     systemInfo["current_interface"],
                        //     systemInfo["interfaces"][systemInfo["current_interface"]]["type"]
                        // ].join(" | ")
                    // }
                }
                InfoItem {
                    title: i18n.tr("Global IP")
                    value: !!systemInfo["global_ip"] ? systemInfo["global_ip"] : i18n.tr("Offline")
                }
                InfoItem {
                    title: i18n.tr("DNS")
                    value: systemInfo["nameservers"].join(", ")
                }

                SectionDivider {
                    text: i18n.tr("WiFi")
                }
                InfoItem {
                    title: i18n.tr("SSID")
                    value: systemInfo["wifi"]["ssid"]
                }
                InfoItem {
                    title: i18n.tr("Signal strength")
                    // TODO: Add units
                    value: systemInfo["wifi"]["signal"]
                }
                InfoItem {
                    title: i18n.tr("Freqency")
                    // TODO: Convert to GHz
                    value: systemInfo["wifi"]["freq"]
                }
                InfoItem {
                    title: i18n.tr("Link speed")
                    value: systemInfo["wifi"]["rate"]
                }
                InfoItem {
                    title: i18n.tr("Security")
                    value: systemInfo["wifi"]["security"]
                }

                // TODO: Figure out a better way to display simular data
                SectionDivider {
                    text: i18n.tr("Interfaces")
                }
                InfoItem {
                    title: i18n.tr("Names")
                    value: Object.keys(systemInfo["interfaces"]).join(" | ")
                }
                InfoItem {
                    title: i18n.tr("Types")
                    value: Object.values(systemInfo["interfaces"])
                        .map((i) => i.type)
                        .join(" | ")
                }
                InfoItem {
                    title: i18n.tr("Status")
                    value: Object.values(systemInfo["interfaces"])
                        .map((i) => i.is_connected ? i18n.tr("Connected") : i18n.tr("Inactive"))
                        .join(" | ")
                }

                // TODO: DHCP lease time
                // TODO: Gateway, subnet mask
            }
        }
    }
}
