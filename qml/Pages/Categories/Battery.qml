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
    anchors.fill: parent

    property var systemInfo
    Component.onCompleted: print(JSON.stringify(systemInfo, null, 2))

    title: header.title
    header: PageHeader {
        id: header
        title: i18n.tr('Battery')
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

                // A lot is missing, but it's a start.

                // Current status and important info
                SectionDivider {
                    text: i18n.tr("Basics")
                    subtext: "WIP!"
                }
                InfoItem {
                    title: i18n.tr("Charge")
                    value: systemInfo["percentage"]

                    ProgressBar {
                        value: !!systemInfo["percentage"] ? systemInfo["percentage"].replace('%', '') : 0
                        minimumValue: 0; maximumValue: 100

                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                    }
                }
                InfoItem {
                    title: i18n.tr("State")
                    value: {
                        function capitalizeFirstLetter(string) {
                            if (!string) return ""
                            return string.charAt(0).toUpperCase() + string.slice(1);
                        }
                        capitalizeFirstLetter(systemInfo["state"])
                    }
                }
                // InfoItem {
                //     title: i18n.tr("Charging rate")
                //     value: systemInfo["energy-rate"]
                //     // TODO: Calculating the charging rate in percent per minute can be more understandable
                //     // I wasn't sure about the meaning of `energy-rate`, so I commented it out.
                // }
                InfoItem {
                    title: i18n.tr("Time to empty")
                    value: systemInfo["time-to-empty"]
                }

                // Battery health
                SectionDivider {
                    text: i18n.tr("Health")
                }
                InfoItem {
                    title: i18n.tr("Temperature")
                    value: !!systemInfo["temperature"] ? systemInfo["temperature"].replace("degrees C", "°C") : ""
                }
                InfoItem {
                    title: i18n.tr("Warning level")
                    value: systemInfo["warning-level"]
                }
                InfoItem {
                    title: i18n.tr("Voltage")
                    value: systemInfo["voltage"]
                }
                // TODO: Cycle count and estimated capacity will be read through file descriptors on supported phones

                // Some less important info. This also should mention what data is missing.
                SectionDivider {
                    text: i18n.tr("Other")
                }
                InfoItem {
                    title: i18n.tr("Technology")
                    value: systemInfo["technology"]
                }
            }
        }
    }
}
