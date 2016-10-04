//
//  AppDelegate.swift
//  UMGameController-Mac
//
//  Created by fOrest on 6/15/16.
//  Copyright © 2016 fOrest. All rights reserved.
//

import Cocoa
import CoreBluetooth

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var mainMenu: NSMenu!

    @IBOutlet weak var statusMenu: NSMenu!
    
    @IBOutlet weak var menuItemExit: NSMenuItem!
    
    @IBAction func exitMenuItemClicked(_ sender: AnyObject) {
        
        NSApplication.shared().terminate(self)
    }
    
    @IBAction func bleMenuItemClicked(_ sender: AnyObject) {
        
        // current mode is wifi mode
        if connectionMode == 1 {
            
            statusMenu.item(withTitle: "Connection Mode")?.submenu?.item(at: 0)?.state = 1
            statusMenu.item(withTitle: "Connection Mode")?.submenu?.item(at: 1)?.state = 0
            gameController.bonjourServer.stopServer()
            while self.statusMenu.indexOfItem(withTitle: "Connected Devices") + 1 < self.statusMenu.indexOfItem(withTitle: "Help") {
                
                self.statusMenu.removeItem(at: self.statusMenu.indexOfItem(withTitle: "Connected Devices") + 1)
            }
            gameController.bleCentral.enableBle()
        }
    }
    
    @IBAction func wifiMenuItemClicked(_ sender: AnyObject) {
        
        // current mode is ble mode
        if connectionMode == 0 {
            
            statusMenu.item(withTitle: "Connection Mode")?.submenu?.item(at: 0)?.state = 0
            statusMenu.item(withTitle: "Connection Mode")?.submenu?.item(at: 1)?.state = 1
            gameController.bleCentral.disableBle()
            while self.statusMenu.indexOfItem(withTitle: "Connected Devices") + 1 < self.statusMenu.indexOfItem(withTitle: "Help") {
                
                self.statusMenu.removeItem(at: self.statusMenu.indexOfItem(withTitle: "Connected Devices") + 1)
            }
            gameController.bonjourServer.startServer()
        }
    }
    
    /* @property current connection mode, 0: ble mode, 1: wifi mode
     */
    var connectionMode: Int {
        
        return statusMenu.item(withTitle: "Connection Mode")?.submenu?.item(at: 0)?.state == 1 ? 0 : 1
    }
    
    var statusItem: NSStatusItem!
    
    var gameController: UMGameController = UMGameController()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        self.statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        //self.statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(24)
        
        self.statusItem.menu = statusMenu
        self.statusItem.title = "My App"
        self.statusItem.highlightMode = true
        
        if let statusButton = statusItem.button {
            
            statusButton.image = NSImage(named: "Status")
            statusButton.alternateImage = NSImage(named: "StatusHighlighted")
        }
        
        gameController.deviceConnectedHandler = { [unowned self] pram0, param1 in
            
            // remove all device items
            while self.statusMenu.indexOfItem(withTitle: "Connected Devices") + 1 < self.statusMenu.indexOfItem(withTitle: "Help") {
                
                self.statusMenu.removeItem(at: self.statusMenu.indexOfItem(withTitle: "Connected Devices") + 1)
            }
            
            if self.connectionMode == 0 { // ble mode
                
                for periperial in self.gameController.bleCentral.peripherals {
                    
                    let menuItem: NSMenuItem = NSMenuItem()
                    menuItem.image = NSImage(named: "NSStatusAvailable")
                    menuItem.title = periperial.name ?? "unknown ble device"
                    
                    self.statusMenu.insertItem(menuItem, at: self.statusMenu.indexOfItem(withTitle: "Connected Devices") + 1)
                }
            }
            else {
                
                for connection in self.gameController.bonjourServer.connections {
                    
                    let menuItem: NSMenuItem = NSMenuItem()
                    menuItem.image = NSImage(named: "NSStatusAvailable")
                    menuItem.title = (connection as! UMBonjourConnection).name ?? "unknown device"
                    
                    self.statusMenu.insertItem(menuItem, at: self.statusMenu.indexOfItem(withTitle: "Connected Devices") + 1)
                }
            }
        }
        
        gameController.deviceDisconnectedHandler = { [unowned self] connection, periperial in
            
            // remove all device items
            while self.statusMenu.indexOfItem(withTitle: "Connected Devices") + 1 < self.statusMenu.indexOfItem(withTitle: "Help") {
                
                self.statusMenu.removeItem(at: self.statusMenu.indexOfItem(withTitle: "Connected Devices") + 1)
            }
            
            if self.connectionMode == 0 { // ble mode
                
                for periperial in self.gameController.bleCentral.peripherals {
                    
                    let menuItem: NSMenuItem = NSMenuItem()
                    menuItem.image = NSImage(named: "NSStatusAvailable")
                    menuItem.title = periperial.name ?? "unknown ble device"
                    
                    self.statusMenu.insertItem(menuItem, at: self.statusMenu.indexOfItem(withTitle: "Connected Devices") + 1)
                }
            }
            else {
                
                for connection in self.gameController.bonjourServer.connections {
                    
                    let menuItem: NSMenuItem = NSMenuItem()
                    menuItem.image = NSImage(named: "NSStatusAvailable")
                    menuItem.title = (connection as! UMBonjourConnection).name ?? "unknown device"
                    
                    self.statusMenu.insertItem(menuItem, at: self.statusMenu.indexOfItem(withTitle: "Connected Devices") + 1)
                }
            }
        }
        
        gameController.addServerObserver(self, forKeyPath: "isServerPublished", options: NSKeyValueObservingOptions.new, context: nil)
        
        if connectionMode == 0 {
            
            gameController.bleCentral.enableBle()
        } else {
            
            gameController.bonjourServer.startServer()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        
        return true
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        
        gameController.removeServerObserver(self, forKeyPath: "isServerPublished")
        gameController.releaseResources()
    }
        
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        switch keyPath! {
        case "isServerPublished":break
        default: break
        }
    }
    
}

