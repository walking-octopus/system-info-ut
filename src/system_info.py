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
import psutil
import os

def get_props():
  props = {}
  try:
    with open('/system/build.prop', mode='r', newline='\n') as input_file:
      for row in input_file.read().splitlines():
        row = row.strip().split('=')
        if len(row) != 2: continue
        props[row[0]] = row[1]
  except FileNotFoundError:
    return {}
  return props

# TODO: Add a placeholder for non-existant values
def system_image():
  output = cmd("/usr/bin/system-image-cli -i").splitlines()
  fields = {}
  for row in output:
    row = row.split(": ")
    if len(row) != 2: continue
    fields[row[0].replace(" ", "_")] = row[1]
  return fields

def cmd(command):
  try:
    result = subprocess.run(command.split(" "), stdout=subprocess.PIPE)
  except FileNotFoundError:
    return "N/A"
  if result.returncode != 0:
    return "N/A"
  else:
    return result.stdout.decode("utf-8").strip()

def cat(path):
  try:
    with open(path) as file:
      return file.read().strip()
  except FileNotFoundError:
    return None

# def unwrap_or(value, fallback="N/A"):
#   if value is not None:
#     return value
#   else:
#     return fallback

def getSystem():
  uname = platform.uname()
  kernel = uname.release
  hostname = uname.node
  arch = uname.processor
  disro = " ".join(platform.linux_distribution())

  boot_time = psutil.boot_time()

  system_image_data = system_image()
  ota_version = system_image_data.get('version_tag')
  ota_channel = system_image_data.get('channel')
  last_ota_update = system_image_data.get('last_update')

  build_props = get_props()
  android_version = build_props.get('ro.build.version.release')
  android_api_level = build_props.get('ro.build.version.sdk')
  security_patch = build_props.get('ro.build.version.security_patch')
  build_id = build_props.get('ro.build.id')
  build_date = build_props.get('ro.build.date')
  build_fingerprint = build_props.get('ro.build.fingerprint')
  build_tags = build_props.get('ro.build.tags')
  build_type = build_props.get('ro.build.type')
  # device_codename = build_props.get('ro.product.board')

  lang = os.getenv('LANGUAGE')
  aa_loaded = "Yes" in cmd("aa-enabled")
  fs_writable = os.access('/', os.W_OK)

  ssh_enabled = "enabled" in cmd("android-gadget-service status ssh")
  adb_enabled = "enabled" in cmd("android-gadget-service status adb")

  # TODO: Fetching boot slot info might be useful

  return {
    "uname": {
      "kernel": kernel,
      "hostname": hostname,
      "arch": arch,
      "distro": disro,
    },
    "system-image": {
      "ota_version": ota_version,
      "update_channel": ota_channel,
      "last_update": last_ota_update,
    },
    "build-info": {
      "android_version": android_version,
      "android_api_level": android_api_level,
      "security_patch": security_patch,
      "build_fingerprint": build_fingerprint,
      "build_date": build_date,
      "build_id": build_id,
      "build_tags": build_tags,
      "build_type": build_type,
    },
    # "device_codename": device_codename,
    "boot_time": boot_time,
    "aa_loaded": aa_loaded,
    "fs_writable": fs_writable,
    "ssh_enabled": ssh_enabled,
    "adb_enabled": adb_enabled,
    "lang": lang,
  }

def getLoadedModules():
  modulesNames = os.listdir("/sys/module/")

  response = []
  for name in modulesNames:
    try:
      version = cat("/sys/module/" + name + "/version")
    except FileNotFoundError:
      version = None;

    response.append({
      "name": name,
      "version": version
    })

  return response

def getDevice():
  # Basic
  build_props = get_props()

  if build_props != {}:
    model, brand = build_props.get("ro.product.model"), build_props.get("ro.product.brand")
    manufacturer = build_props.get("ro.product.manufacturer")
    code_name = build_props.get("ro.cm.device")
  else:
    model, brand = cat("/sys/devices/virtual/dmi/id/product_name"), cat("/sys/devices/virtual/dmi/id/product_family")
    manufacturer = cat("/sys/devices/virtual/dmi/id/sys_vendor")
    code_name = None

  # Display and Camera are handled through their respective QML types

  # Other (Fingerprint, etc)

  return {
    "basics": {
      "model": model,
      "brand": brand,
      "manufacturer": manufacturer,
      "code_name": code_name
    }
  }