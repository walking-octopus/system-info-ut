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

Page {
    anchors.fill: parent

    property var systemInfo
    // Component.onCompleted: print(JSON.stringify(systemInfo, null, 2))

    title: header.title
    header: PageHeader {
        id: header
        title: i18n.tr('Device')
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
                    title: i18n.tr("Model")
                    value: [systemInfo["basics"]["brand"], systemInfo["basics"]["model"]]
                            .filter(i => !!i)
                            .join(" ");

                    visible: !!systemInfo["basics"]["model"]
                }
                InfoItem {
                    title: i18n.tr("Manufacturer")
                    value: systemInfo["basics"]["manufacturer"]
                }
                InfoItem {
                    title: i18n.tr("Codename")
                    value: systemInfo["basics"]["code_name"]
                }

                SectionDivider {
                    text: i18n.tr("Display")
                }
                InfoItem {
                    title: i18n.tr("Name")
                    value: Screen.name
                    visible: !!Screen.name
                }
                InfoItem {
                    title: i18n.tr("Resolution")
                    value: [Screen.height, Screen.width].join("x")
                }
                // TODO: Physical size
                InfoItem {
                    title: i18n.tr("Aspect ratio")
                    value: {
                        // This may be inefficient
                        function getFraction(decimal) {
                            for (var denominator = 1; (decimal * denominator) % 1 !== 0; denominator++);
                            return {numerator: decimal * denominator, denominator: denominator};
                        }

                        let aspect = getFraction(Screen.width/Screen.height)
                        return [aspect.numerator, aspect.denominator].join(":")
                    }
                }
                InfoItem {
                    title: i18n.tr("Density")
                    value: Math.round(Screen.pixelDensity) + " ppm"
                    // Physical pixels per millimeter
                }
                InfoItem {
                    title: i18n.tr("Orientation")
                    value: {
                        let orientation = Screen.orientation
                        // Which is more useful?
                        // Screen.primaryOrientation or Screen.orientation

                        switch (orientation) {
                            case 1: return i18n.tr("Portrait")
                            case 2: return i18n.tr("Landscape")
                        }
                    }
                }
                InfoItem {
                    title: i18n.tr("Manufacturer")
                    value: [Screen.manufacturer, Screen.model].join(" ")
                    visible: !!Screen.manufacturer || !!Screen.model
                }

                SectionDivider {
                    text: i18n.tr("Camera")
                }
                InfoItem {
                    title: i18n.tr("Name")
                    value: QtMultimedia.availableCameras
                        .map((cam) => cam.displayName)
                        .join(" | ")
                }
                InfoItem {
                    title: i18n.tr("Position")
                    value: QtMultimedia.availableCameras
                        .map((cam) => {
                            switch (cam.position) {
                                case 1: return i18n.tr("Portrait")
                                case 2: return i18n.tr("Landscape")
                            }
                        })
                        .join(" | ")
                }
                InfoItem {
                    title: i18n.tr("Orientation")
                    value: QtMultimedia.availableCameras
                        .map((cam) => cam.orientation + "°")
                        .join(" | ")
                }
                // TODO: Get camera's highest resolution in megapixels
                // InfoItem {
                //     title: i18n.tr("Resolution")
                //     value: {
                //         camera.start()
                //         let resolutions = camera.supportedViewfinderResolutions(0, 100)
                //         print(JSON.stringify(resolutions))
                //         camera.stop()
                //         // return resolutions
                //         // ERROR: ** (qmlscene:1): CRITICAL **: gst_audio_format_from_string: assertion 'format != NULL' failed
                //     }
                // }

                // SectionDivider {
                //     text: i18n.tr("Features")
                //     subtext: "WIP"
                // }
                // TODO: Add Fingerprint sensor info
            }
        }
    }
}
