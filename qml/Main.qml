/*
 * Copyright (C) 2022  walking-octopus
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * system-info is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.12
import Lomiri.Components 1.3
import "./Components"

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'system-info.walking-octopus'
    automaticOrientation: true

    width: units.gu(80)
    height: units.gu(70)

    Toast { id: toast }

    PageStack { id: pStack }
    
    Backend {
        id: python

        onReady: pStack.push(Qt.resolvedUrl("./Pages/MainPage.qml"))
    }
}
