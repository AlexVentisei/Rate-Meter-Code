// Simple BlueTooth I/O management class. Created from an original project by Nebojsa Petrovic on April 2016.
// The base project can be found at https://github.com/nebs/hello-bluetooth
//
// As part of my A-Level project to build an StrokeMeter for rowing coaching which uses bluetooth to connect to an IOS
// device I have made enhanced the code to do the following functions:
//
// The StrokeMeterDevice Class uses iOS Core BlueTooth to offer the following methods:
// 1.  Search for devices advertising with the correct UUID indicating that they are Stroke Meter Devices
// 2.  Create list of devices for selection (Need to build this currently just connecting to device found))
// 3.  Connect to the selected device (Need to build currently just connecting to the device found)
// 4.  Discover Services that the Stroke Meter is using
// 5.  Discover the Characteristics including ideintifying the writable characteristics
// 6.  Provide a method .writeValue to allow writing a value to the Stroke Meter Device
// 7.  Provide a delegate method for managing a value sent by the Stroke Meter device


import CoreBluetooth

protocol StrokeMeterIODelegate: class {
    func didReceiveValue(_ StrokeMeterIO: StrokeMeterIO, value_x: Int16, value_y: Int16, value_z: Int16)
}

class StrokeMeterIO: NSObject {
    
    //first identify all the services and characteristics we are interested in using with a Constant
    let accelerometerServiceUUID = CBUUID(string: "e95d0753-251d-470a-a062-fa1922dfa9a8")
    let ledServiceUUID = CBUUID(string: "E95DD91D-251D-470A-A062-FA1922DFA9A8")
    let pinIOServiceUUID = CBUUID(string: "E95D127B-251D-470A-A062-FA1922DFA9A8")
    
    let ACCELEROMETERDATA_CHARACTERISTIC_UUID = CBUUID(string: "E95DCA4B-251D-470A-A062-FA1922DFA9A8")
    let ACCELEROMETERPERIOD_CHARACTERISTIC_UUID = CBUUID(string: "E95DFB24-251D-470A-A062-FA1922DFA9A8")
    
    let PINDATA_CHARACTERISTIC_UUID = CBUUID(string: "E95D8D00-251D-470A-A062-FA1922DFA9A8")
    let PINADCONFIGURATION_CHARACTERISTIC_UUID = CBUUID(string: "E95D5899-251D-470A-A062-FA1922DFA9A8")
    let PINIOCONFIGURATION_CHARACTERISTIC_UUID = CBUUID(string: "E95DB9FE-251D-470A-A062-FA1922DFA9A8")
    
    let LEDMATRIXSTATE_CHARACTERISTIC_UUID = CBUUID(string: "E95D7B77-251D-470A-A062-FA1922DFA9A8")
    let LEDTEXT_CHARACTERISTIC_UUID = CBUUID(string: "E95D93EE-251D-470A-A062-FA1922DFA9A8")
    let SCROLLINGDELAY_CHARACTERISTIC_UUID = CBUUID(string: "E95D0D2D-251D-470A-A062-FA1922DFA9A8")

    weak var delegate: StrokeMeterIODelegate?

    var centralManager: CBCentralManager!
    var connectedPeripheral: CBPeripheral?
    var targetServices: [CBService] = []
    //var targetService: CBService?
    var accelerometerService: CBService?
    var pinIOService: CBService?
    var ledService: CBService?
    var AccelerometerPeriodCharacteristic: CBCharacteristic?
    var AccelerometerDataCharacteristic: CBCharacteristic?
    var pinDataCharacteristic: CBCharacteristic?
    var pinADCharacteristic: CBCharacteristic?
    var pinIOCharacteristic: CBCharacteristic?
    var ledTextCharacteristic: CBCharacteristic?
    var ledMatrixStateCharacteristic: CBCharacteristic?
    var scrollingDelayCharacteristic: CBCharacteristic?
    
     init(delegate: StrokeMeterIODelegate?) {
        self.delegate = delegate

        super.init()

        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func writeValue<T>(_ characteristic: CBCharacteristic, value: T) {
        guard let peripheral = connectedPeripheral else {
            return
        }

        let data = NSData.dataWithValue(value: value)
        peripheral.writeValue(data as Data, for: characteristic, type: .withResponse)
    }
    
    func writePinValue<T>(value: T) {
        guard let peripheral = connectedPeripheral else {
            return
        }
        
        let setAllOn: [[UInt8]] = [[0x00,0x01],  //temp to test if the write works  TODO interpret the value to the pin settings
            [0x01,0x01],
            [0x02,0x01],
            [0x03,0x01],
            [0x04,0x01],
            [0x05,0x01],
            [0x06,0x01],
            [0x07,0x01],
            [0x08,0x01],
            [0x09,0x01],
            [0x0a,0x01],
            [0x0b,0x01],
            [0x0c,0x01],
            [0x0d,0x01],
            [0x0e,0x01],
            [0x0f,0x01],
            [0x10,0x01],
            [0x11,0x01],]
        
        let data = NSData.dataWithValue(value: setAllOn)
        peripheral.writeValue(data as Data, for: pinDataCharacteristic!, type: .withResponse)
        
    }

}

extension StrokeMeterIO: CBCentralManagerDelegate {
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?){
        centralManager.scanForPeripherals(withServices: nil, options: nil)

    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if ((peripheral.name?.range(of: "BBC micro:bit")) != nil) {
            connectedPeripheral = peripheral

            if let connectedPeripheral = connectedPeripheral {
                connectedPeripheral.delegate = self
                centralManager.connect(connectedPeripheral, options: nil)
            }
            centralManager.stopScan()
        }

    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
}

extension StrokeMeterIO: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }

        for s in services {
            if s.uuid == self.accelerometerServiceUUID {
                accelerometerService = s
                targetServices.append(s)
            }
            if s.uuid == self.pinIOServiceUUID {
                pinIOService = s
                targetServices.append(s)
            }
            if s.uuid == self.ledServiceUUID {
                ledService = s
                targetServices.append(s)
            }

        }

        for s in targetServices {
            peripheral.discoverCharacteristics(nil, for: s)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        
        let setToDigital: UInt32 = 0x00
        let setToWrite: UInt32 = 0x00

        
        for characteristic in characteristics {
            switch characteristic.uuid{
                case ACCELEROMETERPERIOD_CHARACTERISTIC_UUID : AccelerometerPeriodCharacteristic = characteristic
                
                case ACCELEROMETERDATA_CHARACTERISTIC_UUID : AccelerometerDataCharacteristic = characteristic;
                    peripheral.setNotifyValue(true, for: characteristic)
                
                case PINDATA_CHARACTERISTIC_UUID : pinDataCharacteristic = characteristic;

                case PINADCONFIGURATION_CHARACTERISTIC_UUID : pinADCharacteristic = characteristic;
                    self.writeValue(pinADCharacteristic!, value: setToDigital);
                case PINIOCONFIGURATION_CHARACTERISTIC_UUID : pinIOCharacteristic = characteristic;
                    self.writeValue(pinIOCharacteristic!, value: setToWrite);
                case LEDMATRIXSTATE_CHARACTERISTIC_UUID : ledMatrixStateCharacteristic = characteristic
                case LEDTEXT_CHARACTERISTIC_UUID : ledTextCharacteristic = characteristic
                case SCROLLINGDELAY_CHARACTERISTIC_UUID : scrollingDelayCharacteristic = characteristic
                default : break
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data: NSData = characteristic.value as NSData?, let delegate = delegate else {
            return
        }

        delegate.didReceiveValue(self, value_x: data.convertValueX(), value_y: data.convertValueY(), value_z: data.convertValueZ())
    }
}
