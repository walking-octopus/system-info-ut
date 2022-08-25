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
import QtQuick.Window 2.0
import QtMultimedia 5.4
import "../../Components"
import "../../Components/Formatter.js" as Format

Page {
    anchors.fill: parent

    property var systemInfo
    property var usageInfo: {
        "cpu": { "percent": 0 },
        "ram": { "percent": 0, "total": 0 },
        "disk": { "percent": 0, "total": 0 },
    }
    
    // Component.onCompleted: print(JSON.stringify(systemInfo, null, 2))
    Timer {
        repeat: true
        triggeredOnStart: true
        interval: 800
        running: true
    
        onTriggered: python.call(
            "system_info.getUsage", [],
            function(response) { usageInfo = response }
        )
    }

    title: header.title
    header: PageHeader {
        id: header
        title: i18n.tr('Hardware')
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
                    text: i18n.tr("Usage")
                }

                InfoItem {
                    title: i18n.tr("CPU usage")
                    value: [
                        usageInfo["cpu"]["percent"] + "%",
                        Math.round(usageInfo["cpu"]["freq"]  / 1000) + " MHz" // CPU #0
                    ].join(" | ")

                    ProgressBar {
                        value: usageInfo["cpu"]["percent"]
                        minimumValue: 0; maximumValue: 100

                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                    }
                }
                InfoItem {
                    title: i18n.tr("RAM usage")
                    value: {
                        let usage_percent = usageInfo["ram"]["percent"] + "%"
                        let usage_memory = [
                            Format.formatBytes(usageInfo["ram"]["usage"]),
                            Format.formatBytes(usageInfo["ram"]["total"])
                        ].join(" / ")

                        return [usage_percent, usage_memory].join(" | ")
                    }

                    ProgressBar {
                        value: usageInfo["ram"]["percent"]
                        minimumValue: 0; maximumValue: 100

                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                    }
                }
                InfoItem {
                    title: i18n.tr("Disk usage")
                    value: {
                        let usage_percent = usageInfo["disk"]["percent"] + "%"
                        let usage_size = [
                            Format.formatBytes(usageInfo["disk"]["usage"]),
                            Format.formatBytes(usageInfo["disk"]["total"])
                        ].join(" / ")

                        return [usage_percent, usage_size].join(" | ")
                    }

                    ProgressBar {
                        value: usageInfo["disk"]["percent"]
                        minimumValue: 0; maximumValue: 100

                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                    }
                }

                SectionDivider {
                    text: i18n.tr("CPU Information")
                }

                InfoItem {
                    title: i18n.tr("Processor")
                    value: systemInfo["cpu"]["name"]
                }
                InfoItem {
                    title: i18n.tr("Cores")
                    value: systemInfo["cpu"]["count"] + i18n.tr(" cores")
                }
                InfoItem {
                    title: i18n.tr("Max Frequency")
                    value: (systemInfo["cpu"]["max_freq"] / 1000) + " MHz"
                }
                InfoItem {
                    title: i18n.tr("Min Frequency")
                    value: (systemInfo["cpu"]["min_freq"] / 1000) + " MHz"
                }
                InfoItem {
                    title: i18n.tr("Architecture")
                    value: systemInfo["cpu"]["arch"]
                }
                InfoItem {
                    title: i18n.tr("Governor")
                    value: usageInfo["cpu"]["governor"]
                }
            }
        }
    }
}
