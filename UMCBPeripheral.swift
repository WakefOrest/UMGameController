//
//  UMBluetooth.swift
//  UMGameController
//
//  Created by fOrest on 7/23/16.
//  Copyright © 2016 fOrest. All rights reserved.
//

import Foundation
import CoreGraphics
import CoreBluetooth

#if os(OSX)
    import UMVHIDDevice_Mac
    private let deviceName = Host.current().localizedName!
#else
    import UMVHIDDevice_iOS
    import UIKit
    private let deviceName = UIDevice.current.name
#endif

let hidServiceUUID: CBUUID       = CBUUID(string: "0x1812") // 0X180D, 0x1124 0x1812

let umServiceUUID: CBUUID        = CBUUID(string: "DA63A4A2-A153-4C56-962E-E13C85110E91")

let umDeviceReportUUID: CBUUID   = CBUUID(string: "384100A6-B372-40D0-B4F3-2B27115269FF")

class UMCBPeripheral: NSObject, CBPeripheralManagerDelegate, UMVHIDDeviceDelegate {
    
    var peripheralManager: CBPeripheralManager
    
    var umService: CBMutableService
    
    var umCharacteristic: CBMutableCharacteristic
    
    var updateQueue: [CBCharacteristic] = [CBCharacteristic]()

    var umVHIDDevice: UMVHIDDevice
    
    var operationQueue: OperationQueue
    
    override init() {
        
        operationQueue = OperationQueue()
        operationQueue.qualityOfService = .userInitiated
        
        peripheralManager = CBPeripheralManager(delegate: nil, queue: operationQueue.underlyingQueue)
        
        umService  = CBMutableService(type: umServiceUUID,  primary: true)
        
        umCharacteristic = CBMutableCharacteristic(type: umDeviceReportUUID, properties: CBCharacteristicProperties(rawValue: CBCharacteristicProperties.read.rawValue | CBCharacteristicProperties.notify.rawValue | CBCharacteristicProperties.write.rawValue), value: nil, permissions: CBAttributePermissions(rawValue: CBAttributePermissions.readable.rawValue | CBAttributePermissions.writeable.rawValue))
        
        umVHIDDevice = UMVHIDDevice(type: UMVHIDDeviceType.umVHIDDeviceTypeJoystick, pointerCount: 3, buttonCount: 16, isRelative: false)!
        
        super.init()
        
        umService.characteristics = [umCharacteristic]
        for uuid in UMGameControllerButton.UUIDS {
            
            umService.characteristics!.append(createCharacteristicsForReading(uuid))
        }
        
        umVHIDDevice.delegate = self
        peripheralManager.delegate = self
        
    }
    
    func createCharacteristicsForReading(_ uuid: CBUUID)-> CBCharacteristic {
        
        let characteristic = CBMutableCharacteristic(type: uuid, properties: CBCharacteristicProperties(rawValue: CBCharacteristicProperties.read.rawValue | CBCharacteristicProperties.notify.rawValue ), value: nil, permissions: CBAttributePermissions(rawValue: CBAttributePermissions.readable.rawValue | CBAttributePermissions.writeable.rawValue))
        
        return characteristic
    }
    
    func updateValue(_ value: Data, forCharacteristic uuid: CBUUID) {
        
        for characteristic in umService.characteristics! {
            
            if characteristic.uuid.isEqual(uuid) {
                
                (characteristic as! CBMutableCharacteristic).value = value as Data
                
                if updateQueue.count > 0 {
                    
                    if !updateQueue.contains(characteristic) {
                        
                        updateQueue.append(characteristic)
                    }
                }
                else if !peripheralManager.updateValue(value as Data, for: characteristic as! CBMutableCharacteristic, onSubscribedCentrals: nil) {
                    
                    updateQueue.append(characteristic)
                }
            }
        }
    }

    // MARK: UMVHIDDeviceDelegate
    func umVHIDDevice(_ device: UMVHIDDevice, stateDidChange state: [Int8]) {
        
        umCharacteristic.value = Data(bytes: umVHIDDevice.state, count: umVHIDDevice.state.count)
        updateValue(umCharacteristic.value!, forCharacteristic: umDeviceReportUUID)
    }
    
    // MARK: CBPeripheralManagerDelegate
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        NSLog("UMGameController peripheralManagerDidUpdateState : \(peripheral.state.rawValue)")
        
        if peripheral.state == .poweredOn {
            
            if umService.peripheral != peripheralManager {
                
                peripheral.add(umService)
            }
        } else if peripheral.isAdvertising {
            
            peripheral.stopAdvertising()
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        
        if error != nil {
            return NSLog("UMGameController Error publishing service: \(error!.localizedDescription)")
        }
        
        peripheralManager.startAdvertising([CBAdvertisementDataLocalNameKey: deviceName , CBAdvertisementDataServiceUUIDsKey : [umServiceUUID]])
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        
        if error != nil {
            
            return NSLog("UMGameController Error advertising: \(error!.localizedDescription)")
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        
        if request.characteristic.uuid.isEqual(umCharacteristic.uuid) {
            
            umCharacteristic.value = umCharacteristic.value ?? Data(bytes: umVHIDDevice.state, count: umVHIDDevice.state.count) as Data
            
            if request.offset > umCharacteristic.value!.count {
                
                return peripheralManager.respond(to: request, withResult: CBATTError.Code.invalidOffset)
            }
            
            request.value = umCharacteristic.value?.subdata(in: NSMakeRange(request.offset,
                umCharacteristic.value!.count - request.offset).toRange()!)
            
            peripheralManager.respond(to: request, withResult: CBATTError.Code.success)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        
        for request in requests {
            
            if request.characteristic.uuid.isEqual(umCharacteristic.uuid) {
                umCharacteristic.value = request.value
                // TODO
                peripheralManager.respond(to: request, withResult: CBATTError.Code.success)
            }
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        
        NSLog("UMGameController Central: \(central) subscribed to characteristic: \(characteristic)")
        
        peripheral.setDesiredConnectionLatency(.low, for: central)
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        
        NSLog("UMGameController Central: \(central) unsubscribed to characteristic: \(characteristic)")
        
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        
        for characteristic in updateQueue {
            
            if peripheralManager.updateValue(characteristic.value!, for: characteristic as! CBMutableCharacteristic, onSubscribedCentrals: nil) {
                
                updateQueue.removeFirst()
            }
            else { break }
        }
    }
}


