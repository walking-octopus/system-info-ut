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
import "../Components"

Page {
    id: mainPage
    anchors.fill: parent

    // TODO: Add report export

    title: header.title
    header: PageHeader {
        id: header
        title: python.isLoading ? i18n.tr("Collecting data...") : i18n.tr('Ubuntu Info')

        // TODO: Add a dialog to choose what info to export
        // TODO: Use ContentHub to export the report

        trailingActionBar.actions: Action {
            // iconName: "import"
            iconSource: "../../assets/export.svg"
            onTriggered: python.generateReport()
        }
        
        ProgressBar {
            indeterminate: true
            visible: python.isLoading
            
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
        }
    }

    ScrollView {
        id: scrollView
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        Flickable {
            anchors.fill: parent
            contentWidth: parent.width
            contentHeight: flow.childrenRect.height + (flow.anchors.bottomMargin * 2)

            Flow {
                id: flow

                anchors.fill: parent
                anchors.margins: units.gu(1.6)
                spacing: units.gu(1.6)

                // ["#f0f0f0", "#ed3146", "#d4326b", "#e95420", "#f89b0f", "#f5d412", "#46c54f", "#14cfa8", "#19b6ee", "#4e46c5", "#9542c4", "#c343bf"]

                // The information about your OS and Halium
                CategoryButton {
                    title: i18n.tr("System")
                    iconName: "ubuntu-logo-symbolic"
                    colorIndex: 3

                    onClicked:
                        python.loadCategory("../Pages/Categories/System.qml", "system_info.getSystem")
                }

                // The specs of your device, like the product codename, screen DPI, fingerprint reader, etc.
                CategoryButton {
                    title: i18n.tr("Device")
                    iconName: "phone-smartphone-symbolic"
                    colorIndex: 5

                    onClicked:
                        python.loadCategory("../Pages/Categories/Device.qml", "system_info.getDevice")
                }

                // Your CPU, GPU, RAM, and storage.
                CategoryButton {
                    title: i18n.tr("Hardware")

                    // Thanks to Arthur Shlain for this icon!
                    // https://thenounproject.com/icon/cpu-156717/
                    // TODO: When making the about page, don't forget to attribute this icon

                    icon.source: "../../assets/noun-cpu.svg"
                    colorIndex: 9

                    onClicked:
                        python.loadCategory("../Pages/Categories/Hardware.qml", "system_info.getHardware")
                }

                // WiFI, cellular network, and Bluetooth
                CategoryButton {
                    title: i18n.tr("Network")
                    iconName: "network-wifi-symbolic"
                    colorIndex: 8

                    onClicked:
                        python.loadCategory("../Pages/Categories/Network.qml", "system_info.getNetwork")
                }

                // Battery information
                CategoryButton {
                    title: i18n.tr("Battery")

                    // This icon looked blurry when looked up by name, so I've downloaded the SVG

                    icon.source: "../../assets/battery.svg"
                    colorIndex: 6

                    onClicked:
                        python.loadCategory("../Pages/Categories/Battery.qml", "system_info.getBattery")
                }

		CategoryButton {
		    title: i18n.tr("WayDroid")

		    icon.source: "../../assets/waydroid.svg"
		    colorIndex: 11

		    onClicked:
			python.loadCategory("../Pages/Categories/WayDroid.qml", "system_info.getWaydroidInfo")
		}

                // TODO: How about a Sensors category?
            }
        }
    }
}
