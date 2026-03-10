<div align="center">

<img src="ExplorariumContent/images/logo.png" alt="Explorarium Logo" width="400" />

<h1>The Explorarium App</h1>

### *Elite Dangerous tool to assist explorers in exploring the Explorarium's systems by reading journal files for the nearest systems and other uses.*

The Explorarium app is currently still being worked on adding more functionality and other things to use other than just navigating systems.

The download uses Inno Setup which is windows only. If you want to build the app in other operating systems try [building](#building)

[Download](https://github.com/CMDR-Regza/Explorarium/releases) &nbsp; | &nbsp; [Discord Server](https://discord.gg/JVNDFJVRKp)

</div>

- The Records


*"A plethora of extremely remarkable systems not documented properly. These systems are uncatalogued and only identified from datasets"*


- Galaxy Plotter


*"Advanced plotter provided by Spansh. It'll take care of fuel, neutron supercharges, and injection boosts"*

# Building
The Explorarium app was developed using Qt's C++ Framework and with CMake. 
### Prerequisites
- Qt Creator (https://www.qt.io/development/download)
- Qt 6 (included in Qt Creator https://www.qt.io/development/qt-framework/qt6)
- CMake (included in Qt Creator) 
- Qt Compiler Kits (Windows: MinGW / Linux: GCC / Mac: Clang) (included in Qt Creator)

### Running the app with Qt Creator

1. Clone the repo, then launch Qt Creator
2. Go to File > Open File or Project
3. Navigate to the cloned repo folder and select CMakeLists.txt
4. Qt might ask you to configure your kits based on the OS. e.g. Desktop Qt 6.X.X MinGW 64-bit for windows or GCC for linux. Ensure the "Build" and "Release" configs are selected.
5. Once the project indexing is finished (the popup on the right showing Qt is done indexing). Ctrl + B (or the hammer icon) to Build the executable, if there are no errors, Ctrl + R (or the play button) to run the app.
