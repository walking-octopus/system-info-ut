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

    property var systemInfo
    // Component.onCompleted: print(JSON.stringify(systemInfo, null, 2))

    title: header.title
    header: PageHeader {
        id: header
        title: i18n.tr('System')
    }

    // TODO: Add WayDroid/Anbox version

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

                // Linux and UT specific info
                SectionDivider {
                    text: i18n.tr("OS")
                }

                InfoItem {
                    title: systemInfo["system-image"]["update_channel"] && systemInfo["system-image"]["update_channel"].includes("stable") ?
                        i18n.tr("OTA version") :
                        i18n.tr("System version")

                    value: systemInfo["system-image"]["update_channel"] && systemInfo["system-image"]["update_channel"].includes("stable") ?
                        systemInfo["system-image"]["ota_version"] :
                        systemInfo["system-image"]["version_version"]
               }
                InfoItem {
                    title: i18n.tr("Update channel")
                    value: systemInfo["system-image"]["update_channel"]
                }
                InfoItem {
                    title: i18n.tr("Last update")
                    value: systemInfo["system-image"]["last_update"]
                }
                InfoItem {
                    title: i18n.tr("Ubuntu version")
                    value: systemInfo["uname"]["distro"]
                }
                InfoItem {
                    title: i18n.tr("Kernel version")
                    value: systemInfo["uname"]["kernel"]
                }
                InfoItem {
                    // This would fit better in Device or Hardware,
                    // but since it determines if a binary is compatible
                    // with your system, but might as well be here.

                    title: i18n.tr("Architecture")
                    value: systemInfo["uname"]["arch"]
                }
                InfoItem {
                    title: i18n.tr("Root file-system status")
                    value: systemInfo["fs_writable"] ? i18n.tr("Unlocked") : i18n.tr("Locked")
                }
                InfoItem {
                    title: i18n.tr("Hostname")
                    value: systemInfo["uname"]["hostname"]
                }
                InfoItem {
                    title: i18n.tr("Uptime")
                    value: systemInfo["uptime"]
                }
                InfoItem {
                    title: i18n.tr("AppArmor status")
                    value: systemInfo["aa_loaded"] ? i18n.tr("Enabled") : i18n.tr("Disabled")
                }
                ListItem {                
                    onClicked:
                        pStack.push(Qt.resolvedUrl("./LoadedModules.qml"));
                
                    ListItemLayout {
                        anchors.centerIn: parent
                        
                        title.text: i18n.tr("View loaded modules")
                        subtitle.text: i18n.tr("This may help troubleshoot device issues.")
                    }
                    
                    // FIXME: For some reason, it doesn't align verticly
                    ProgressionSlot {
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            rightMargin: units.gu(2)
                        }
                    }
                }

                SectionDivider {
                    text: i18n.tr("Preferences")
                }

                InfoItem {
                    title: i18n.tr("SSH (Remote control) status")
                    value: systemInfo["ssh_enabled"] ? i18n.tr("Enabled") : i18n.tr("Disabled")
                }
                InfoItem {
                    title: i18n.tr("ADB (Developer mode) status")
                    value: systemInfo["adb_enabled"] ? i18n.tr("Enabled") : i18n.tr("Disabled")
                }
                InfoItem {
                    title: i18n.tr("Language")
                    value: systemInfo["lang"]
                }
                
                SectionDivider {
                    text: i18n.tr("Halium")
                    subtext: i18n.tr("Halium allows us run Linux on the devices with pre-installed Android.")
                }
                // TODO: Show the device type (Halium | Legacy | Mainline)

                InfoItem {
                    title: i18n.tr("Android subsystem version")
                    value: systemInfo["build-info"]["android_version"]
                }
                InfoItem {
                    title: i18n.tr("Android API level")
                    value: systemInfo["build-info"]["android_api_level"]
                }
                InfoItem {
                    title: i18n.tr("Security patch")
                    value: systemInfo["build-info"]["security_patch"]
                }
                InfoItem {
                    title: i18n.tr("Build fingerprint")
                    value: systemInfo["build-info"]["build_fingerprint"]
                }
                InfoItem {
                    title: i18n.tr("Build date")
                    value: systemInfo["build-info"]["build_date"]
                }
                InfoItem {
                    title: i18n.tr("Build ID")
                    value: systemInfo["build-info"]["build_id"]
                }
                InfoItem {
                    title: i18n.tr("Build tags")
                    value: systemInfo["build-info"]["build_tags"]
                }
                InfoItem {
                    title: i18n.tr("Build type")
                    value: systemInfo["build-info"]["build_type"]
                }
            }
        }
    }
}
