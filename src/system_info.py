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
import pyotherside

# Parsers

def get_props():
    props = {}
    if os.path.exists("/system/build.prop"):
        output = cmd("getprop")
        if output == "N/A": return props

        # columns = [[re.search(r"\[(.*)\]", i).group(1) for i in line.split(": ")] for line in output.splitlines()]
        columns = [i.split(": ") for i in output.replace("[", '').replace(']', '').splitlines()]
        for row in columns:
            if len(row) != 2: continue
            props[row[0]] = row[1]

    return props

def system_image():
    output = cmd("/usr/bin/system-image-cli -i").splitlines()
    fields = {}
    for row in output:
        row = row.split(": ")
        if len(row) != 2:
            continue
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
            if match.group(1) == "Hardware":
                break

        cpu_min_freq = cat(
            "/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq")
        cpu_max_freq = cat(
            "/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq")

        return {
            "name": cpu_name,
            "count": cpu_count,
            "arch": cpu_arch,
            "max_freq": cpu_max_freq,
            "min_freq": cpu_min_freq,
        }

# TODO: You could build a unified nm function for parsing nmcli outputs

def nm_interfaces():
    parsed = {}

    interfaces = cmd("nmcli -t -f DEVICE,TYPE,STATE device status")
    if "N/A" in interfaces:
        return parsed

    for data in interfaces.splitlines():
        data = data.split(":")
        name = list_get(data, 0)
        type = list_get(data, 1)
        is_connected = "connected" in list_get(data, 2)

        is_virtual = not type in {"gsm", "wifi", "ethernet"}
        if is_virtual:
            continue

        parsed[name] = {
            "type": type,
            "is_connected": is_connected
        }

    return parsed

def nm_wifi():
    parsed = {}

    interfaces = cmd(
        "nmcli -t -f BSSID,ACTIVE,SSID,SIGNAL,RATE,FREQ,SECURITY dev wifi")
    if interfaces == "N/A":
        return parsed

    for data in interfaces.splitlines():
        data = re.split(r'(?<!\\):', data)

        bssid = list_get(data, 0).replace("\\:", ":")
        is_active = "yes" in list_get(data, 1)
        ssid = list_get(data, 2)
        signal = list_get(data, 3)
        rate = list_get(data, 4)
        freq = list_get(data, 5)
        security = list_get(data, 6)

        if not is_active:
            continue
        parsed[bssid] = {
            "ssid": ssid,
            "signal": signal,
            "rate": rate,
            "freq": freq,
            "security": security,
        }
    return parsed

# Utils

def cmd(command):
    try:
        result = subprocess.run(command.split(
            " "), shell=False, stdout=subprocess.PIPE)
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
    if os.access(path, os.R_OK):
        with open(path) as file:
            return file.read().strip()
    else:
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
        model = build_props.get("ro.product.model")
        brand = build_props.get("ro.product.brand")
        manufacturer = build_props.get("ro.product.manufacturer")
        code_name = build_props.get("ro.cm.device")
    else:
        model = cat("/sys/devices/virtual/dmi/id/product_name")
        brand = cat("/sys/devices/virtual/dmi/id/product_family")
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
    # The rest is dynamic info handled in `getUsage`
    return { "cpu": get_cpuinfo() }

def getUsage():
    # CPU
    cpu_percent = psutil.cpu_percent()
    cpu_governor = cat("/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor")
    # That's not the average...
    cpu_freq = cat("/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq")

    cpu_temp = cat("/sys/class/thermal/thermal_zone0/temp")
    if cpu_temp is not None and float(cpu_temp) >= 1000:
        cpu_temp = float(cpu_temp) / 1000

    # There is a file descriptor for actual average frequency between cores,
    # but you don't have permission to read it as a normal user.

    # RAM
    memory = psutil.virtual_memory()

    # `memory.percent` gives some weird readings.
    # See https://github.com/giampaolo/psutil/issues/685#issuecomment-202914057

    # Disk
    disk_usage = psutil.disk_usage("/home/")

    return {
        "cpu": {
            "percent": cpu_percent,
            "freq": cpu_freq,
            "temp": cpu_temp,
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

def getTaskManager(sorted_by_i, ordered_by, filter):
    processes = []
    for process in psutil.process_iter():
        # if process.status() is 'idle': continue
        memory_usage = process.memory_info().rss
        cpu_usage = process.cpu_percent()
        name = process.name()
        pid = process.pid

        processes.append({
            "memory_usage": memory_usage,
            "cpu_usage": cpu_usage,
            "name": name,
            "pid": pid
        })

    # sorted_by: 0: CPU; 1: RAM; 2: Name; 3: PID
    # ordered_by: 0: Descending; 1: Ascending
    sorted_by_values = ["cpu_usage", "memory_usage", "name", "pid"]
    processes.sort(key=lambda x: x[sorted_by_values[sorted_by_i]], reverse=ordered_by == 0)

    if filter != "":
        pattern = re.compile(filter, re.IGNORECASE)
        processes = [x for x in processes if pattern.match(x["name"])]

    return processes

def killProcess(pid):
    try:
        psutil.Process(int(pid)).kill()
    except psutil.AccessDenied:
        pyotherside.send("AccessDenied")

def getNetwork():
    # FIXME: Some environments, like the Clickable container, may not have `NetworkManager`

    current_interface = cmd_shell(
        r"ip route get 1.1.1.1 | grep -oP 'dev\s+\K[^ ]+'")
    current_ip = cmd_shell(
        r"ip addr show {interface} | grep -Po 'inet \K[\d.]+'"
        .format(interface=current_interface)
    )

    wifi_data = nm_wifi()
    if not wifi_data:
        current_wifi = {}
    else:
        current_wifi = wifi_data.get(next(iter(wifi_data)))

    nameservers = re.findall(r"DNS\[[1-2]\]:\s+(.+)", cmd("nmcli dev show"))

    try:
        global_ip = requests.get("https://ipaddress.sh/").text.strip()
    except ConnectionError:  # I wonder if I can get more specific.
        global_ip = None

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
        if len(fields) != 2:
            continue
        fields[0] = fields[0].replace(" ", "-")
        fields[1] = fields[1].replace("'", '')
        if ("yes" or "no") in fields[1]:
            fields[1] = "yes" in fields[1]
        infoDict[fields[0]] = fields[1]

        # TODO: Read additional info from file descriptors and merge the info (prioritizing upower)
        # TODO: Consider attempting to estimate current battery capacity by looking through upower charge history

    return infoDict
