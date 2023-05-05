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
import QtQuick.Window 2.0
import QtMultimedia 5.4
import "../../Components"
import "../../Components/Formatter.js" as Format

Page {
    anchors.fill: parent

    property var systemInfo

    title: header.title
    header: PageHeader {
        id: header
        title: i18n.tr('WayDroid')
    }

    ScrollView {
        id: scrollView
        height: parent.height
        width: parent.width

        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
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
                    text: i18n.tr("WayDroid Version")
                }

                InfoItem {
                    title: i18n.tr("Version")
                    value: systemInfo["basics"]["version"]
                }
                InfoItem {
                    title: i18n.tr("Status")
                    visible: systemInfo["basics"]["installed"] ? true : false
                    value: systemInfo["waydroid_status"]
                }
            }

            Column {
                id: lineage_layout
                width: parent.width
		        visible: systemInfo["basics"]["configured"] ? true : false
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: layout.bottom
                }

                SectionDivider {
                    text: i18n.tr("LineageOS Version")
                }

                InfoItem {
                    title: i18n.tr("Version")
                    value: systemInfo["container"]["version"]
                }

                InfoItem {
                    title: i18n.tr("Image Variant")
                    value: systemInfo["container"]["variant"]
                }

                InfoItem {
                        title: i18n.tr("Vendor Variant")
                        value: systemInfo["container"]["vendor_variant"]
                }

                InfoItem {
                    title: i18n.tr("System OTA link")
                    value: systemInfo["container"]["system_ota_config"]
                }

                InfoItem {
                    title: i18n.tr("Vendor OTA link")
                    value: systemInfo["container"]["vendor_ota_config"]
                }
            }
	    }
    }
}
