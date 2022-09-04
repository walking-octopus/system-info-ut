<img height="128" src="./assets/logo.png" align="left"/>

# Ubuntu Info

A system info beautiful app for Ubuntu Touch.
_____________________________________________

## Building 

### Dependencies
- Docker
- Android tools (for adb)
- Python3 / pip3
- Clickable (get it from [here](https://clickable-ut.dev/en/latest/index.html))

Use Clickable to build and package Translate as a Click package ready to be installed on Ubuntu Touch

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
The project is licensed under the [GPL-3.0](https://opensource.org/licenses/GPL-3.0).
The [CPU icon](https://thenounproject.com/icon/cpu-156717/) was made by Arthur Shlain from The Noun Project (CC).
