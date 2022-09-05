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
import psutil
import subprocess
import os
import re
import requests

# Parsers

def get_props():
  props = {}
  if os.path.exists("/system/build.prop"):
    output = cmd("getprop")
    if output == "N/A": return props

    columns = [[re.search(r"\[(.*)\]", i).group(1) for i in line.split(": ")] for line in output.splitlines()]
    for row in columns:
      if len(row) != 2: continue
      props[row[0]] = row[1]
  return props

# TODO: You could build a unified nm funtion for parsing nmcli outouts

def system_image():
  output = cmd("/usr/bin/system-image-cli -i").splitlines()
  fields = {}
  for row in output:
    row = row.split(": ")
    if len(row) != 2: continue
    fields[row[0].replace(" ", "_")] = row[1]
  return fields

def get_cpuinfo():
  cpu_arch = platform.processor()

  with open('/proc/cpuinfo', mode='r', newline='\n') as cpu_info_file:
    cpu_info = cpu_info_file.read()

    # psutil.cpu_count() Doesn't count all cores
    cpu_count = len(re.findall(r"processor", cpu_info))

    cpu_name = None
    for match in re.finditer(r"^(model name|Hardware|Processor|cpu model|chip type|cpu type)\s*: (.*)", cpu_info, re.MULTILINE):
      cpu_name = match.group(2)
      if match.group(1) == "Hardware": break

    cpu_min_freq = cat("/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq")
    cpu_max_freq = cat("/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq")

    return {
      "name": cpu_name,
      "count": cpu_count,
      "arch": cpu_arch,
      "max_freq": cpu_max_freq,
      "min_freq": cpu_min_freq,
    }

def nm_interfaces():
  parsed = {}

  interfaces = cmd("nmcli -t -f DEVICE,TYPE,STATE device status")
  if "N/A" in interfaces: return parsed

  for data in interfaces.splitlines():
    data = data.split(":")
    name = list_get(data, 0)
    type = list_get(data, 1)
    is_connected = "connected" in list_get(data, 2)
    is_virtual = ("tunnel" or "loopback" or "bridge" or "dummy" or "unknown") in type

    if is_virtual: continue
    parsed[name] = {
      "type": type,
      "is_connected": is_connected
    }

  return parsed

def nm_wifi():
  parsed = {}

  interfaces = cmd("nmcli -t -f BSSID,ACTIVE,SSID,SIGNAL,RATE,FREQ,SECURITY dev wifi")
  if interfaces == "N/A": return parsed

  for data in interfaces.splitlines():
    data = re.split(r'(?<!\\):', data)

    bssid = list_get(data, 0).replace("\\:", ":")
    is_active = "yes" in list_get(data, 1)
    ssid = list_get(data, 2)
    signal = list_get(data, 3)
    rate = list_get(data, 4)
    freq = list_get(data, 5)
    security = list_get(data, 6)

    if not is_active: continue
    parsed[bssid] = {
      "ssid": ssid,
      "signal": signal,
      "rate": rate,
      "freq": freq,
      "security": security,
    }

  return parsed

# `nmcli device show`
# def nm_device_show():
#   pass

# Utils

def cmd(command, useShell=False):
  try:
    result = subprocess.run(command.split(" "), shell=False, stdout=subprocess.PIPE)
  except FileNotFoundError:
    return "N/A"
  if result.returncode != 0:
    return "N/A"
  else:
    return result.stdout.decode("utf-8").strip()

def cmd_shell(command):
  result = subprocess.getstatusoutput(command)
  if result[0] != 0:
    return "N/A"
  else:
    return result[1]

def cat(path):
  try:
    with open(path) as file:
      return file.read().strip()
  except FileNotFoundError:
    return None

def list_get(list, index, fallback="N/A"):
  if len(list) > index:
    return list[index]
  else:
    return fallback

# Categories

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
  modulesNames.sort()

  response = []
  for name in modulesNames:
    version = cat("/sys/module/" + name + "/version")
 
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

  # TODO: (Fingerprint, etc)

  return {
    "basics": {
      "model": model,
      "brand": brand,
      "manufacturer": manufacturer,
      "code_name": code_name
    }
  }

def getHardware():
  # CPU
  cpu_info = get_cpuinfo()
  # The rest is dynamic info handled in `getUsage`
  return {
    "cpu": cpu_info
  }

def getUsage():
  # CPU
  cpu_percent = psutil.cpu_percent()
  cpu_governor = cat("/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor")
  cpu_freq = cat("/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq") # That's not the avarage...

  # There is a file descriptor for actual avarage frequency between cores,
  # but you don't have permission to read it as a normal user.

  # RAM
  memory = psutil.virtual_memory()

  # Disk
  disk_usage = psutil.disk_usage("/home/")

  return {
    "cpu": {
      "percent": cpu_percent,
      "freq": cpu_freq,
      "governor": cpu_governor
    },
    "ram": {
      "percent": memory.percent,
      "usage": memory.used,
      "total": memory.total
    },
    "disk": {
      "percent": disk_usage.percent,
      "usage": disk_usage.used,
      "total": disk_usage.total
    }
  }

def getNetwork():
  # FIXME: Some envirements, like the Clickable container, may not have `NetworkManager`

  current_interface = cmd_shell(r"ip route get 1.1.1.1 | grep -oP 'dev\s+\K[^ ]+'")
  current_ip = cmd_shell(
    r"ip addr show {interface} | grep -Po 'inet \K[\d.]+'"
    .format(interface = current_interface)
  )

  wifi_data = nm_wifi()
  if wifi_data == {}: current_wifi = {}
  else:
    current_wifi = wifi_data.get(next(iter(wifi_data)))

  # TODO: I don't entirely know how it works. Replace this hack with `nm_device_show()`
  nameservers = cmd_shell("( nmcli -f IP4.DNS,IP6.DNS dev list || nmcli -f IP4.DNS,IP6.DNS dev show ) 2>/dev/null | awk '/DNS/{print$NF}'").splitlines()

  try:
    global_ip = requests.get("https://ipaddress.sh/").text.strip()
  except:
    global_ip = "N/A"

  return {
    "current_interface": current_interface,
    "current_ip": current_ip,
    "interfaces": nm_interfaces(),
    "wifi": current_wifi,
    "nameservers": nameservers,
    "global_ip": global_ip
  }

def getBattery():
  output = cmd("upower -i /org/freedesktop/UPower/devices/battery_battery")
  infoDict = {}

  for line in output.splitlines():
    fields = line.split(": ")
    fields = [i.strip() for i in fields]
    if len(fields) != 2: continue
    fields[0] = fields[0].replace(" ", "-")
    fields[1] = fields[1].replace("'", '')
    if ("yes" or "no") in fields[1]: fields[1] = "yes" in fields[1]
    infoDict[fields[0]] = fields[1]

    # TODO: Read additional info from file descriptors and merge the info (prioritizing upower)
    # TODO: Consider attempting to estimate current battery capacity by looking through upower charge history

  return infoDict
