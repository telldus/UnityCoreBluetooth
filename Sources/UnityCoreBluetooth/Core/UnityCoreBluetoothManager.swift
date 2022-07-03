//
//  UnityCoreBluetooth.swift
//  ExampleMacOS
//
//  Created by fuziki on 2019/09/09.
//  Copyright © 2019 fuziki.factory. All rights reserved.
//

import CoreBluetooth
import Foundation

internal class UnityCoreBluetoothManager: NSObject {
    public static let shared: UnityCoreBluetoothManager = UnityCoreBluetoothManager()

    public var onErrorMessageHandler: ((_ message: String) -> Void)?
    public var onUpdateStateHandler: ((_ state: String) -> Void)?
    public var onDiscoverPeripheralHandler: ((_ peripheral: CBPeripheral, _ advertisementData: String, _ RSSI: NSNumber) -> Void)?
    public var onConnectPeripheralHandler: ((_ peripheral: CBPeripheral) -> Void)?
    public var onDiscoverServicelHandler: ((_ service: CBService) -> Void)?
    public var onDiscoverCharacteristiclHandler: ((_ characteristic: CBCharacteristic) -> Void)?
    public var onUpdateValueHandler: ((_ characteristic: CBCharacteristic, _ value: Data) -> Void)?

    private var manager: CBCentralManager?
    private var peripherals: [String: CBPeripheral] = [:]

    override public init() {
        super.init()
    }

    public func startCoreBluetooth() {
        manager = CBCentralManager(delegate: self, queue: nil)
    }

    public func stopCoreBluetooth() {
        peripherals.removeAll()
        manager = nil
    }

    public func startScan() {
        if let manager = self.manager, manager.isScanning == false {
            manager.scanForPeripherals(withServices: nil, options: nil)
        }
    }

    public func stopScan() {
        manager?.stopScan()
    }

    public func connect(peripheral: CBPeripheral) {
        if let p = peripherals[peripheral.identifier.uuidString] {
            manager?.connect(p, options: nil)
        }
    }

    public func clearPeripherals() {
        peripherals.removeAll()
    }
}

extension UnityCoreBluetoothManager: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if let state = UCBManagerState(state: central.state) {
            self.onUpdateStateHandler?(state.rawValue)
        }
    }

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        peripherals[peripheral.identifier.uuidString] = peripheral
        
        var jsonString = "";
        
        if advertisementData.keys.contains("kCBAdvDataLocalName") && advertisementData.keys.contains("kCBAdvDataManufacturerData") {
            let kCBAdvDataLocalNameValue: String = advertisementData["kCBAdvDataLocalName"] as! String
            let ManfcData = advertisementData["kCBAdvDataManufacturerData"] as! Data;
            let kCBAdvDataManufacturerDataValue: String = ManfcData.hexEncodedString()
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: [
                    "kCBAdvDataLocalName": kCBAdvDataLocalNameValue,
                    "kCBAdvDataManufacturerData": kCBAdvDataManufacturerDataValue,
                ], options: [])
                jsonString = String(data: jsonData, encoding: String.Encoding.ascii)!
            } catch let error {
                print("UnityCoreBluetoothManager didDiscover JSONSerialization exception : "+error.localizedDescription)
            }
        }
        
        self.onDiscoverPeripheralHandler?(peripheral, jsonString, RSSI)
    }

    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        self.onConnectPeripheralHandler?(peripheral)
    }

    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        self.onErrorMessageHandler?("connection failed")
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for s in peripheral.services ?? [] {
            self.onDiscoverServicelHandler?(s)
        }
    }
}

extension UnityCoreBluetoothManager: CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for c in service.characteristics ?? [] {
            self.onDiscoverCharacteristiclHandler?(c)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        self.onUpdateValueHandler?(characteristic, characteristic.value ?? Data())
    }
}

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return self.map { String(format: format, $0) }.joined()
    }
}
