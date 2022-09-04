<img height="128" src="./assets/logo.png" align="left"/>

# Ubuntu Info

A beautiful system info app for Ubuntu Touch.
_____________________________________________

<img src="https://open-store.io/screenshots/system-info.walking-octopus-screenshot-4ff4fa94-9a16-4ad4-9e1a-ee12fd8618ce.png" alt="Screenshot" width="200" />

## Features:
 - Beautiful design: Endless lists of poorly labeled items are out of fashion! Quickly find what you're searching for in this modern app.
 - Forever free: No need to allow shady black boxes on your device just to view conveniently view some info. This app is free and open-source forever.
 - Community-built: Miss something? Just fill out an issue or submit a merge request and it will be added in no time!

## Building 

### Dependencies
- Docker
- Android tools (for adb)
- Python3 / pip3
- Clickable (get it from [here](https://clickable-ut.dev/en/latest/index.html))

Use Clickable to build and build it as Click package ready to be installed on Ubuntu Touch

### Build instructions
Make sure you clone the project with
`git clone https://github.com/walking-octopus/system-info-ut.git`.

To test the build on your workstation:
```
$  clickable desktop
```

To run on a device over SSH:
```
$  clickable --ssh [device IP address]
```

For more information on the several options see the Clickable [documentation](https://clickable-ut.dev/en/latest/index.html)

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

### Translations
Please help our translation efforts by following [these instructions](https://github.com/walking-octopus/system-info-ut/tree/main/po/README.md).

## License
 - The project is licensed under the [GPL-3.0](https://opensource.org/licenses/GPL-3.0).
 - The [CPU icon](https://thenounproject.com/icon/cpu-156717/) was made by Arthur Shlain from The Noun Project (CC).
 - The logo uses the `info` icon from Suru.
