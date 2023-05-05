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
import Lomiri.Components 1.3

Page {
    ListModel {
        id: moduleModel

        function reload() {
            python.call('system_info.getLoadedModules', [], function(modules) {
                moduleModel.clear();

                modules.forEach((item) => {
                    moduleModel.append(item);
                });
            });
        }

        Component.onCompleted: reload()
    }

    title: header.title
    header: PageHeader {
        id: header
        flickable: view
        title: i18n.tr("Loaded modules (%1)").arg(moduleModel.count)
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent

        ListView {
            id: view
            anchors.fill: parent

            model: moduleModel
            delegate: ListItem {
                ListItemLayout {
                    anchors.centerIn: parent

                    title.text: name
                    subtitle.text: !!version ? version : "";
                }
            }
        }
    }
}
