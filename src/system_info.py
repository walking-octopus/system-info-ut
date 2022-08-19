'''
 Copyright (C) 2022  walking-octopus

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; version 3.

 system-info is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
'''

import platform
import subprocess

def cmd(command):
  result = subprocess.getstatusoutput(command)
  if result[0] != 0 or "not found" in result[1]:
    return "N/A"
  else:
    return result[1]

def getSystem():
  uname = platform.uname()
  kernel = uname.release
  hostname = uname.node
  arch = uname.processor

  disro = " ".join(platform.linux_distribution())
  ota = cmd("/usr/bin/system-image-cli -i | awk '/version tag:/ { print $3 }'")
  android_version = cmd('/usr/bin/getprop ro.build.version.release')
  device_codename = cmd('/usr/bin/getprop ro.product.board')

  return {
    "distro": disro,
    "ota": ota,
    "kernel": kernel,
    "hostname": hostname,
    "arch": arch,
    "android_version": android_version,
    "device_codename": device_codename
  }
