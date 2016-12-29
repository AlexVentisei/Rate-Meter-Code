# Bluetooth Rate Meter using a BBC MicroBit

This is a simple swift app that enables bi-directional communication with an BBC: Microbit via bluetooth.  It requires the original firmware that comes with the Microbit.  If you have flashed your Microbic with code written on any of the code editors you will have replaced the firmware with an older version that does not implement all of the bluetooth capabilities used in this project.  You can get the original firmware and some additional information on the bluetooth capabilities of the Microbit at https://lancaster-university.github.io/microbit-docs/ble/profile/#bbc-microbit-bluetooth-profile
 

## Setup

Flash the Microbic with the original firmware (see above) and pair your phone with the Microbit.  Load the app on your IOS device and launch it.  It should automatically use the paired microbit advertised services to provide a stroke rate and x/y/z accelerometer data
