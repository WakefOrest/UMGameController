//
//  UMGameControllerServer.swift
//  UMGameController
//
//  Created by fOrest on 6/14/16.
//  Copyright © 2016 fOrest. All rights reserved.
//

import Foundation

#if os(OSX)
    private let deviceName = Host.current().localizedName!
#else
    import UIKit
    private let deviceName = UIDevice.current.name
#endif

protocol UMBonjourServerDelegate {
    
    func umBonjourServer(_ server: UMBonjourServer, didAcceptConnection connection: UMBonjourConnection)
    
    func umBonjourServer(_ server: UMBonjourServer, didOpenConnection connection: UMBonjourConnection)
    
    func umBonjourServer(_ server: UMBonjourServer, didCloseConnection connection: UMBonjourConnection)
    
    func umBonjourServer(_ server: UMBonjourServer, didReceiveMessage message: UMMessage, viaConnection connection: UMBonjourConnection)
}

class UMBonjourServer: NSObject, NetServiceDelegate, UMbonjourConnectionDelegate {

    let kUMServiceType = "_umservice._tcp"
    
    var delegate: UMBonjourServerDelegate?
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    //  MARK: service
    ///////////////////////////////////////////////////////////////////////////////////////////////////

    var name : String?
    
    var service : NetService?
    
    dynamic var isServerPublished = false
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    //  MARK: streams
    ///////////////////////////////////////////////////////////////////////////////////////////////////

    let connections = NSMutableSet()

    ///////////////////////////////////////////////////////////////////////////////////////////////////
    //  MARK: init
    ///////////////////////////////////////////////////////////////////////////////////////////////////

    override init() {
        
        super.init()
        
        self.service = NetService(domain: "local.", type: kUMServiceType, name: deviceName, port: 0)
        
        if let service = self.service {
            
            service.includesPeerToPeer = true
            service.delegate = self
        }
    }
    
    func publishService() {
        
        self.service?.publish(options: NetService.Options.listenForConnections)
    }
    
    func stopPublish() {
        
        if let service = self.service {
            
            service.stop()
        }
    }
    
    func startServer() {
        
        publishService()
    }
    
    func stopServer() {
        
        if isServerPublished {
            
            stopPublish()
        }
        for item in connections {
            
            (item as! UMBonjourConnection).close()
        }
    }
    
    deinit {
        
        stopServer()
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    //  MARK: NSNetServiceDelegate
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    func netServiceDidPublish(_ sender: NetService) {
        
        self.name = sender.name
        self.isServerPublished = true
        debugPrint("netServiceDidPublish: service: \(sender.description)")
    }
    
    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        
        for dictionary in errorDict{
            
            debugPrint(dictionary.0 + ": \(dictionary.1)")
        }
    }
    
    func netService(_ sender: NetService, didUpdateTXTRecord data: Data) {
        
        debugPrint("\(data.description)")
    }
    
    func netServiceDidStop(_ sender: NetService) {
        
        self.isServerPublished = false
        debugPrint("netServiceDidStop: service: \(sender.description)")
    }
    
    func netService(_ sender: NetService, didAcceptConnectionWith inputStream: InputStream, outputStream: OutputStream) {
        
        OperationQueue.main.addOperation { [weak self] in
            
            if let _self = self {
                
                let connection = UMBonjourConnection(inputStream: inputStream, outputStream: outputStream)
                
                if connection.open() {
                    
                    _self.connections.add(connection)
                    connection.delegate = _self
                    
                    debugPrint("netService didAcceptConnectionWithInputStream inputSream: \(inputStream.description), outputStream: \(outputStream.description)")
                } else {
                    
                    // reject connection
                    connection.close()
                }
            }
        }
        
    }
    
    
    func bonjourConnection(_ connection: UMBonjourConnection, didSendMessage message: UMMessage) {
        
        // TODO:
    }
    
    func bonjourConnection(_ connection: UMBonjourConnection, didReceiveMessage message: UMMessage) {
        
        if self.connections.contains(connection) {
            
            delegate?.umBonjourServer(self, didReceiveMessage: message, viaConnection: connection)
        } else {
            
            connection.close()
        }
    }
    
    func bonjourConnectionDidOpen(_ connection: UMBonjourConnection) {
        
        delegate?.umBonjourServer(self, didOpenConnection: connection)
        
        return debugPrint("bonjourConnectionDidOpen connection: \(connection.description)")
    }
    
    func bonjourConnectionDidClose(_ connection: UMBonjourConnection) {
        
        if self.connections.contains(connection) {
            
            self.connections.remove(connection)
        }
        
        delegate?.umBonjourServer(self, didCloseConnection: connection)
        
        return debugPrint("bonjourConnectionDidClose connection: \(connection.description)")
        
    }
}
