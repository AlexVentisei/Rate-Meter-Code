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
    
    func writePinValue(strokeRate: Double) {
        guard let peripheral = connectedPeripheral else {
            return
        }
        
        let strokeRateIntDec: UInt8 = UInt8(strokeRate/10)
        var strokeRateIntUnit: UInt8
        strokeRateIntUnit = UInt8(UInt8(strokeRate)-strokeRateIntDec*10)

        let pin11Mask: UInt8 = 0b00000001
        let pin5Mask: UInt8 = 0b00000010
        let pin9Mask: UInt8 = 0b00000100
        let pin12Mask: UInt8 = 0b00000001
        let pin15Mask: UInt8 = 0b00000010
        let pin14Mask: UInt8 = 0b00000100
        let pin2Mask: UInt8 = 0b00001000
        
        let pin11: UInt8 = (strokeRateIntDec & pin11Mask)
        let pin5: UInt8 = (strokeRateIntDec & pin5Mask) >> 1
        let pin9: UInt8 = (strokeRateIntDec & pin9Mask) >> 2
        
        let pin12: UInt8 = (strokeRateIntUnit & pin12Mask)
        let pin15: UInt8 = (strokeRateIntUnit & pin15Mask) >> 1
        let pin14: UInt8 = (strokeRateIntUnit & pin14Mask) >> 2
        let pin2: UInt8 = (strokeRateIntUnit & pin2Mask) >> 3

        
        let setAllOn: [[UInt8]] = [[0x0b,pin11],[0x09, pin9],[0x05, pin5],[0x0c,pin12],[0x0f,pin15],[0x0e,pin14],[0x02,pin2]]
        
        let data = Data.dataWithArray(value: setAllOn)
        peripheral.writeValue(data, for: pinDataCharacteristic!, type: .withResponse)
        
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
    
    func centralManger(_ peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: Error?) {
        //this function traps any errors in the writing to the characteristics
    }
    
    
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
