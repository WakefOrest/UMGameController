//
//  UMCBCentral.swift
//  UMGameController
//
//  Created by fOrest on 8/8/16.
//  Copyright © 2016 fOrest. All rights reserved.
//

import Foundation
import CoreGraphics
import CoreBluetooth

#if os(OSX)
    import UMVHIDDevice_Mac
#else
    import UMVHIDDevice_iOS
#endif

class UMCBCentral: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, UMVHIDDeviceDelegate {
    
    var centralManager: CBCentralManager
    
    var peripherals: [CBPeripheral] = [CBPeripheral]()
    
    /* temporarily store discovered peripherals
     */
    var discoveredPeripherals: [CBPeripheral] = [CBPeripheral]()
    
    var umVHIDDevice: UMVHIDDevice
    
    var buttonMap: UMGeneralButtonMap = UMGeneralButtonMap()
    
    var didUpdateValueHandler: ((Data)->Void)?
    
    var didConnectedPeripheral: ((CBPeripheral) ->Void)?
    
    var didDisConnectedPeripheral: ((CBPeripheral) ->Void)?
    
    var operationQueue: OperationQueue
    
    var enabled: Bool = false
    
    override init() {
        
        operationQueue = OperationQueue()
        operationQueue.qualityOfService = .userInitiated
        
        centralManager = CBCentralManager(delegate: nil, queue: operationQueue.underlyingQueue)
        
        umVHIDDevice = UMVHIDDevice(type: UMVHIDDeviceType.umVHIDDeviceTypeJoystick, pointerCount: 3, buttonCount: 16, isRelative: false)!
        
        super.init()
        
        umVHIDDevice.delegate = self
        centralManager.delegate = self
    }
    
    func enableBle() {
        
        enabled = true
        if centralManager.state == .poweredOn {
            
            centralManager.scanForPeripherals(withServices: [umServiceUUID], options: nil)
        }
    }
    
    func disableBle() {
        
        enabled = false
        stopScanningAndDisconnectPeripherals()
    }
    
    func stopScanningServices() {
        
        centralManager.stopScan()
    }
    
    func stopScanningAndDisconnectPeripherals() {
        
        centralManager.stopScan()
        
        self.discoveredPeripherals.removeAll()
        for peripheral in self.peripherals {
            
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    // MARK: UMVHIDDeviceDelegate
    func umVHIDDevice(_ device: UMVHIDDevice, stateDidChange state: [Int8]) {
        
        didUpdateValueHandler?(Data(bytes: state, count: state.count))
    }
    
    // MARK: CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        NSLog("UMGameController centralManager DidUpdateState : \(central.state.rawValue)")
        
        if enabled && central.state == .poweredOn {
            
            centralManager.scanForPeripherals(withServices: [umServiceUUID], options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        
        NSLog("UMGameController centralManager willRestoreState : \(dict)")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        if peripherals.contains(peripheral) {
            
            peripherals.remove(at: peripherals.index(of: peripheral)!)
            
            didDisConnectedPeripheral?(peripheral)
        }
        if enabled && central.state == .poweredOn {
            
            centralManager.scanForPeripherals(withServices: [umServiceUUID], options: nil)
        }

        if error != nil {
            
            return NSLog("UMGameController centralManager didDisconnectPeripheral error: \(error?.localizedDescription)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        NSLog("UMGameController centralManager didDiscoverPeripheral: \(peripheral.name)")
        
        //centralManager.stopScan()
        
        if !discoveredPeripherals.contains(peripheral) {
            
            discoveredPeripherals.append(peripheral)
        }
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
        NSLog("UMGameController centralManager didDiscoverPeripheral: \(peripheral.name) error: \(error?.localizedDescription)")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        NSLog("UMGameController centralManager didConnectPeripheral: \(peripheral.name)")
        
        peripheral.delegate = self
        peripheral.discoverServices([hidServiceUUID, umServiceUUID])
        
        if !peripherals.contains(peripheral) {
            
            peripherals.append(peripheral)
        }
        
        didConnectedPeripheral?(peripheral)
    }
    
    // MARK: CBPeripheralDelegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if error != nil {
            
            return NSLog("UMGameController peripheral didConnectPeripheral error: \(error?.localizedDescription)")
        }
        
        for service in peripheral.services! {
            
            NSLog("UMGameController centralManager didConnectPeripheral: \(service)")
            
            peripheral.discoverCharacteristics(UMGameControllerButton.UUIDS, for: service)
            peripheral.discoverCharacteristics([umDeviceReportUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if error != nil {
            
            return NSLog("UMGameController peripheral didDiscoverCharacteristicsForService error: \(error?.localizedDescription)")
        }
        
        for characteristic in service.characteristics! {
            
            NSLog("UMGameController peripheral didDiscoverCharacteristicsForService: \(characteristic)")
            
            if characteristic.uuid.isEqual(umDeviceReportUUID) {
                
                peripheral.readValue(for: characteristic)
            }
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if error != nil {
            
            return NSLog("UMGameController peripheral didUpdateValueForCharacteristic error: \(error?.localizedDescription)")
        }
        
        let value = characteristic.value
        
        if characteristic.uuid.isEqual(UMGameControllerButton.trigger_left.UUID) {
            
            _ = (value as Data?)?.copyBytes(to: UnsafeMutableBufferPointer(start: &buttonMap.trigger_left, count: 1), from: NSMakeRange(0, 2).toRange())
        }
        else if characteristic.uuid.isEqual(UMGameControllerButton.trigger_right.UUID) {
            
            _ = (value as Data?)?.copyBytes(to: UnsafeMutableBufferPointer(start: &buttonMap.trigger_right, count: 1), from: NSMakeRange(0, 2).toRange())
        }
        else if characteristic.uuid.isEqual(UMGameControllerButton.stick_left.UUID) {
            
            _ = (value as Data?)?.copyBytes(to: UnsafeMutableBufferPointer(start: &buttonMap.stick_left_x, count: 1), from: NSMakeRange(0, 2).toRange())
            _ = (value as Data?)?.copyBytes(to: UnsafeMutableBufferPointer(start: &buttonMap.stick_left_y, count: 1), from: NSMakeRange(2, 2).toRange())
        }
        else if characteristic.uuid.isEqual(UMGameControllerButton.stick_right.UUID) {
            
            _ = (value as Data?)?.copyBytes(to: UnsafeMutableBufferPointer(start: &buttonMap.stick_right_x, count: 1), from: NSMakeRange(0, 2).toRange())
            _ = (value as Data?)?.copyBytes(to: UnsafeMutableBufferPointer(start: &buttonMap.stick_right_y, count: 1), from: NSMakeRange(2, 2).toRange())
        }
        else if characteristic.uuid.isEqual(UMGameControllerButton.stick_left_x.UUID) {
            
            _ = (value as Data?)?.copyBytes(to: UnsafeMutableBufferPointer(start: &buttonMap.stick_left_x, count: 1), from: NSMakeRange(0, 2).toRange())
        }
        else if characteristic.uuid.isEqual(UMGameControllerButton.stick_left_y.UUID) {
            
            _ = (value as Data?)?.copyBytes(to: UnsafeMutableBufferPointer(start: &buttonMap.stick_left_y, count: 1), from: NSMakeRange(0, 2).toRange())
        }
        else if characteristic.uuid.isEqual(UMGameControllerButton.stick_right_x.UUID) {
            
            _ = (value as Data?)?.copyBytes(to: UnsafeMutableBufferPointer(start: &buttonMap.stick_right_x, count: 1), from: NSMakeRange(0, 2).toRange())
        }
        else if characteristic.uuid.isEqual(UMGameControllerButton.stick_right_y.UUID) {
            
            _ = (value as Data?)?.copyBytes(to: UnsafeMutableBufferPointer(start: &buttonMap.stick_right_y, count: 1), from: NSMakeRange(0, 2).toRange())
        }
        else if characteristic.uuid.isEqual(UMGameControllerButton.a.UUID) {
            
            _ = (value as Data?)?.copyBytes(to: UnsafeMutableBufferPointer(start: &buttonMap.dpad_up, count: 1), from: NSMakeRange(0, 1).toRange())
        }
        else if characteristic.uuid.isEqual(UMGameControllerButton.b.UUID) {
            
            _ = (value as Data?)?.copyBytes(to: UnsafeMutableBufferPointer(start: &buttonMap.b, count: 1), from: NSMakeRange(0, 1).toRange())
        }
        else if characteristic.uuid.isEqual(UMGameControllerButton.x.UUID) {
            
            _ = (value as Data?)?.copyBytes(to: UnsafeMutableBufferPointer(start: &buttonMap.x, count: 1), from: NSMakeRange(0, 1).toRange())
        }
        else if characteristic.uuid.isEqual(UMGameControllerButton.y.UUID) {
            
            _ = (value as Data?)?.copyBytes(to: UnsafeMutableBufferPointer(start: &buttonMap.y, count: 1), from: NSMakeRange(0, 1).toRange())
        }
        else if characteristic.uuid.isEqual(UMGameControllerButton.bumper_left.UUID) {
            
            _ = (value as Data?)?.copyBytes(to: UnsafeMutableBufferPointer(start: &buttonMap.bumper_left, count: 1), from: NSMakeRange(0, 1).toRange())
        }
        else if characteristic.uuid.isEqual(UMGameControllerButton.bumper_right.UUID) {
            
            _ = (value as Data?)?.copyBytes(to: UnsafeMutableBufferPointer(start: &buttonMap.bumper_right, count: 1), from: NSMakeRange(0, 1).toRange())
        }
        else if characteristic.uuid.isEqual(UMGameControllerButton.dpad_up.UUID) {
            
            _ = (value as Data?)?.copyBytes(to: UnsafeMutableBufferPointer(start: &buttonMap.dpad_up, count: 1), from: NSMakeRange(0, 1).toRange())
        }
        else if characteristic.uuid.isEqual(UMGameControllerButton.dpad_down.UUID) {
            
            _ = (value as Data?)?.copyBytes(to: UnsafeMutableBufferPointer(start: &buttonMap.dpad_down, count: 1), from: NSMakeRange(0, 1).toRange())
        }
        else if characteristic.uuid.isEqual(UMGameControllerButton.dpad_left.UUID) {
            
            _ = (value as Data?)?.copyBytes(to: UnsafeMutableBufferPointer(start: &buttonMap.dpad_left, count: 1), from: NSMakeRange(0, 1).toRange())
        }
        else if characteristic.uuid.isEqual(UMGameControllerButton.dpad_right.UUID) {
            
            _ = (value as Data?)?.copyBytes(to: UnsafeMutableBufferPointer(start: &buttonMap.dpad_right, count: 1), from: NSMakeRange(0, 1).toRange())
        }
        else if characteristic.uuid.isEqual(UMGameControllerButton.view.UUID) {
            
            _ = (value as Data?)?.copyBytes(to: UnsafeMutableBufferPointer(start: &buttonMap.view, count: 1), from: NSMakeRange(0, 1).toRange())
        }
        else if characteristic.uuid.isEqual(UMGameControllerButton.menu.UUID) {
            
            _ = (value as Data?)?.copyBytes(to: UnsafeMutableBufferPointer(start: &buttonMap.menu, count: 1), from: NSMakeRange(0, 1).toRange())
        }
        else if characteristic.uuid.isEqual(UMGameControllerButton.stick_left_click.UUID) {
            
            _ = (value as Data?)?.copyBytes(to: UnsafeMutableBufferPointer(start: &buttonMap.stick_left_click, count: 1), from: NSMakeRange(0, 1).toRange())
        }
        else if characteristic.uuid.isEqual(UMGameControllerButton.stick_right_click.UUID) {
            
            _ = (value as Data?)?.copyBytes(to: UnsafeMutableBufferPointer(start: &buttonMap.stick_right_click, count: 1), from: NSMakeRange(0, 1).toRange())
        }
        else if characteristic.uuid.isEqual(UMGameControllerButton.home.UUID) {
            
            _ = (value as Data?)?.copyBytes(to: UnsafeMutableBufferPointer(start: &buttonMap.home, count: 1), from: NSMakeRange(0, 1).toRange())
        }
        else if characteristic.uuid.isEqual(umDeviceReportUUID) {
            
            didUpdateValueHandler?(value!)
            return
        }
        umVHIDDevice.setState(buttonSequence: buttonMap.buttonState, pointerSequence: buttonMap.pointerState)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
        if error != nil {
            
            return NSLog("UMGameController peripheral didUpdateNotificationStateForCharacteristic error: \(error?.localizedDescription)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if error != nil {
            return NSLog("UMGameController peripheral didWriteValueForCharacteristic error: \(error?.localizedDescription)")
        }
    }
}
