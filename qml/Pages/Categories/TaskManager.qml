/*
 * Copyright (C) 2022  JohnDoe
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * qml-rss-reader is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.12
import QtQuick.Layouts 1.3
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../../Components/Formatter.js" as Format
import "../../Components"

Page {
    property int sorted_by: 0 // 0: CPU; 1: RAM; 2: Name; 3: PID
    property int ordered_by: 0 // 0: Descending; 1: Ascending
    property string filter: ""
    property int updateInterval: 2000

    ListModel {
        id: processModel

        function reload() {
            python.call('system_info.getTaskManager', [sorted_by, ordered_by, filter], function(processes) {
                processModel.clear();
                processes.forEach((i) => append(i));
            });
        }

        Component.onCompleted: reload()
    }

    Timer {
        repeat: true; running: !view.movingVertically
        triggeredOnStart: true
        interval: updateInterval
    
        onTriggered: {
            processModel.reload()
            triggeredOnStart = false
            // A workaround to get some delay after the user stops scrolling
        }
    }

    title: header.title
    header: SearchHeader {
        id: header
        flickable: view
        title: i18n.tr("Task manager")

        onSearchText: function(pattern) {
            filter = pattern
        } // A binding would look neater

        trailingActionBar.actions: [
            Action {
                iconName: "sort-listitem"
                onTriggered: PopupUtils.open(sortPopup)
            }
        ]
    }

    // TODO: A dialog warning users about killing a process

    Component {
        id: sortPopup

        Dialog {
            id: sortDialog

            title: i18n.tr("Sorting options")

            OptionSelector {
                id: sortBySelector
                text: i18n.tr("Sort by")
                model: [i18n.tr('CPU usage'), i18n.tr('RAM usage'), i18n.tr('Process name'), i18n.tr('Launch order (PID)')]
                selectedIndex: sorted_by
            }
            OptionSelector {
                id: orderSelector
                text: i18n.tr("Order by")
                model: [i18n.tr('Descending'), i18n.tr('Ascending')]
                selectedIndex: ordered_by
            }

            Label { text: i18n.tr("Update interval (seconds)") }
            Slider {
                id: intervalSlider
                function formatValue(v) { return v.toFixed(1) }
                minimumValue: 0.5; maximumValue: 5
                value: updateInterval / 1000
            }

            Button {
                text: i18n.tr("Save")
                color: theme.palette.normal.positive
                onClicked: {
                    sorted_by = sortBySelector.selectedIndex
                    ordered_by = orderSelector.selectedIndex
                    updateInterval = intervalSlider.value * 1000
                    PopupUtils.close(sortDialog)
                }
            }
        }
   }

    ScrollView {
        id: scrollView
        anchors.fill: parent

          ListView {
              id: view
              anchors.fill: parent

              model: processModel
              delegate: ListItem {
                  ListItemLayout {
                      id: layout
                      anchors.centerIn: parent
                      
                      title.text: name
                      subtitle.text: `${i18n.tr("CPU")}: ${cpu_usage}% | ${i18n.tr("RAM")}: ${Format.formatBytes(memory_usage)}`
                    }

                    leadingActions: ListItemActions {
                      actions: Action {
                          iconName: "delete"
                          onTriggered: {
                            python.call('system_info.killProcess', [pid])
                            toast.show(i18n.tr("Killed process %1").arg(pid))
                          }
                      }
                  }
              }
          }
    }
}