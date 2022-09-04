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
import re
import requests

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
  except PermissionError:
    # FIXME: It's a bit hacky to show an error in this way, but it's better than nothing.
    return {
      "ro.build.version.release": "Error fetching `build.prop`. Contact your device maintainer."
    }
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

def nm_interfaces():
  interfaces = cmd("nmcli -t -f DEVICE,TYPE,STATE device status")
  if "N/A" in interfaces: return {}

  parsed = {}
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
  interfaces = cmd("nmcli -t -f BSSID,ACTIVE,SSID,SIGNAL,RATE,FREQ,SECURITY dev wifi")
  if interfaces == "N/A": return {}

  parsed = {}
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

def cmd(command, shell=False):
  try:
    result = subprocess.run(command.split(" "), shell=shell, stdout=subprocess.PIPE)
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

def list_get(list, index, fallback="N/A"):
  try:
    return list[index]
  except IndexError:
    return fallback

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

  # Display and Camera arselect start,end,processId,threadId from {} where correlationIde handled through their respective QML types

  # Other (Fingerprint, etc)

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
  cpu_count = psutil.cpu_count()
  cpu_arch = platform.processor()

  cpu_max_freq = cat("/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq")
  cpu_min_freq = cat("/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq")

  cpu_name = subprocess.getstatusoutput("""awk -F '\\s*: | @' \
    '/model name|Hardware|Processor|^cpu model|chip type|^cpu type/ {
    cpu=$2; if ($1 == "Hardware") exit } END { print cpu }' /proc/cpuinfo""")[1] # FIXME: This may crash.

  return {
    "cpu": {
      "name": cpu_name,
      "count": cpu_count,
      "arch": cpu_arch,
      "max_freq": cpu_max_freq,
      "min_freq": cpu_min_freq,
    }
  }

def getUsage():
  # CPU
  cpu_percent = psutil.cpu_percent()
  cpu_governor = cat("/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor")
  cpu_freq = cat("/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq")

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
  # ifconfig = psutil.net_if_addrs()
  # local_ips = cmd("hostname -I").split(" ")

  # You could build a unified nm funtion for parsing nmcli outouts
  # Also some devices may not have nmcli

  current_interface = subprocess.getstatusoutput("ip route get 1.1.1.1 | grep -oP 'dev\s+\K[^ ]+'")[1]
  current_ip = subprocess.getstatusoutput(
    "ip addr show {interface} | grep 'inet ' | cut -d '/' -f1 | cut -d ' ' -f6"
    .format(interface = current_interface)
  )[1]

  # FIXME: This may crash!

  wifi_data = nm_wifi()
  if wifi_data == {}: current_wifi = {}
  else:
    current_wifi = wifi_data.get(next(iter(wifi_data)))

  nameservers = subprocess.getstatusoutput("( nmcli -f IP4.DNS,IP6.DNS dev list || nmcli -f IP4.DNS,IP6.DNS dev show ) 2>/dev/null | awk '/DNS/{print$NF}'")[1].splitlines()
  # FIXME: This may crash!

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
        if len(fields) is not 2: continue
        fields[0] = fields[0].replace(" ", "-")
        fields[1] = fields[1].replace("'", '')
        if ("yes" or "no") in fields[1]: fields[1] = "yes" in fields[1]
        infoDict[fields[0]] = fields[1]

    # TODO: Read additional info from file descriptors and merge the info (prioritizing upower)
    # TODO: Consider attempting to estimate current battery capacity by looking through upower charge history

    return infoDict