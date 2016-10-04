//
//  UMGameController.swift
//  UMGameController
//
//  Created by fOrest on 7/7/16.
//  Copyright © 2016 fOrest. All rights reserved.
//

import Cocoa
import CoreBluetooth
import UMVHIDDevice_Mac

class UMGameController: NSObject, UMBonjourServerDelegate, UMVHIDDeviceDelegate {
    
    var isServerPublished: Bool {
        get {
            return bonjourServer.isServerPublished
        }
    }
    
    var vhidData: UMVHIDDevice!
    
    var virtualDevice: UMVirtualDevice!
    
    var bonjourServer: UMBonjourServer = UMBonjourServer()
    
    var bleCentral: UMCBCentral = UMCBCentral()
    
    var keepAliveTimer: Timer!
    
    var deviceConnectedHandler: ((UMBonjourConnection?, CBPeripheral?) ->Void)?
    
    var deviceDisconnectedHandler: ((UMBonjourConnection?, CBPeripheral?) ->Void)?
    
    override init() {
        
        super.init()
        
        vhidData = UMVHIDDevice(type: UMVHIDDeviceType.umVHIDDeviceTypeJoystick, pointerCount: 3, buttonCount: 16, isRelative: false)!
        
        virtualDevice = UMVirtualDevice(productName: "Ultimate Master", serialNumber: "SN0000000001423", vendorId: 0x045e, productId: 0x028e, reportDescriptor: Data(bytes: vhidData.descriptor, count: vhidData.descriptor.count))
        
        keepAliveTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(keepAliveTimerProc), userInfo: nil, repeats: true)
        
        vhidData.delegate = self
        bonjourServer.delegate = self
        
        bleCentral.didUpdateValueHandler = { [unowned self] data ->Void in
            
            _ = self.virtualDevice.sendReport(data)
        }
        
        bleCentral.didConnectedPeripheral = { [unowned self] peripheral in
            
            self.deviceConnectedHandler?(nil, peripheral)
        }
        
        bleCentral.didDisConnectedPeripheral = { [unowned self] peripheral in
            
            self.deviceDisconnectedHandler?(nil, peripheral)
        }
        
        _ = virtualDevice.open()
        
    }
    
    func addServerObserver(_ observer: NSObject, forKeyPath keyPath: String, options: NSKeyValueObservingOptions, context: UnsafeMutableRawPointer?) {
        
        bonjourServer.addObserver(observer, forKeyPath: keyPath, options: options, context: context)
    }
    
    func removeServerObserver(_ observer: NSObject, forKeyPath keyPath: String) {
        
        bonjourServer.removeObserver(observer, forKeyPath: keyPath)
    }
    
    func releaseResources() {
        
        virtualDevice.close()
        
        bonjourServer.stopServer()
        
        bleCentral.stopScanningAndDisconnectPeripherals()
    }
    
    deinit {
        
        releaseResources()
    }
    
    func keepAliveTimerProc() {

        for item in self.bonjourServer.connections  {
            
            let connection = item as! UMBonjourConnection
            
            if connection.isOpen {
                
                let timeInterval = (Date().timeIntervalSince1970 - connection.lastActiveTime)
                
                if timeInterval > 2.0 && timeInterval <= 5.0 {
                    
                    // send heart beat message
                    connection.sendMessage(UMMessage(data: Data(), usageId: 0x00))
                }
                else if timeInterval > 5.0 {
                    
                    connection.close()
                }
            }
        }
    }
    
    
    // MARK: UMBonjourServer delegate
    func umBonjourServer(_ server: UMBonjourServer, didAcceptConnection connection: UMBonjourConnection) {
        // TODO:
    }
    
    func umBonjourServer(_ server: UMBonjourServer, didOpenConnection connection: UMBonjourConnection) {
        
        self.deviceConnectedHandler?(connection, nil)
    }
    
    func umBonjourServer(_ server: UMBonjourServer, didCloseConnection connection: UMBonjourConnection) {
        
        self.deviceDisconnectedHandler?(connection, nil)
    }
    
    func umBonjourServer(_ server: UMBonjourServer, didReceiveMessage message: UMMessage, viaConnection connection: UMBonjourConnection) {
        
        debugPrint("umBonjourServer didReceiveMessage")
        
        let usage = message.header!.usage
        let data  = message.contentData
        
        if usage == 0xf0 { // hid device report data
            
            // general controller
            
            _ = virtualDevice.sendReport(data!)
            
            //vhidData.setState(buttonSequence: buttonMap.buttonState, pointerSequence: buttonMap.pointerState)
        }
        else if usage == 0xff { // debug information
            
            let debugInformation = String(data: data! as Data, encoding: String.Encoding.utf8)
            
            debugPrint(debugInformation)
        }
    }
    
    // MARK: UMVHIDDeviceDelegate
    
    func umVHIDDevice(_ device: UMVHIDDevice, stateDidChange state: [Int8]) {
        
        _ = virtualDevice.sendReport(Data(bytes: state, count: state.count))
    }
}
