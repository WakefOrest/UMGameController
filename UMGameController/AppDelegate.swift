//
//  AppDelegate.swift
//  UMGameController
//
//  Created by fOrest on 6/13/16.
//  Copyright © 2016 fOrest. All rights reserved.
//

import UIKit
import SpriteKit
import CoreMotion
import UMVHIDDevice_iOS

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UMbonjourConnectionDelegate, UMBonjourBrowserDelegate {

    var window: UIWindow?

    /* shared instance of GameViewController
     */
    var gameViewController: GameViewController?
    
    // MARK: networking variables
    private var _connMode: Int?
    
    var connMode: Int {
        
        get {
            if _connMode == nil {
                
                if UserData.getValue(UserDataKeys.connMode.rawValue) == nil {
                    
                    UserData.setValue(value: 0x00, forKey: UserDataKeys.connMode.rawValue)
                }
                _connMode = UserData.getValue(UserDataKeys.connMode.rawValue) as? Int
            }
            return _connMode!
        }
        set(mode) {
            
            _connMode = mode
            UserData.setValue(value: mode, forKey: UserDataKeys.connMode.rawValue)
        }
    }
    
    var cbPeripheral: UMCBPeripheral = UMCBPeripheral()
    
    var bonjourBrowser: UMBonjourBrowser = UMBonjourBrowser()
    
    var bonjourConnection: UMBonjourConnection?
    
    // MARK: device motion variables 
    var referenceAttitude: CMAttitude?
    
    var motionManager: CMMotionManager = CMMotionManager()
    
    var motionQueue: OperationQueue = OperationQueue()
        
    /* shared instance of AppDelegate
     */
    static var shared: AppDelegate?

    // MARK: UIApplicationDelegate
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        AppDelegate.shared = self
        
        self.gameViewController = self.window!.rootViewController as? GameViewController
        
        // Show our window
        //self.window!.rootViewController = self.gameViewController
        //self.window!.makeKeyAndVisible()
        
        bonjourBrowser.delegate = self
        bonjourConnection?.delegate = self
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        // stop searching services
        self.bonjourBrowser.stopSearching()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        // start searching services
        self.bonjourBrowser.startSearching()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    // MARK: UMBonjourBrowserDelegate
    
    func umBonjourBrowser(_ browser: UMBonjourBrowser, didCreateConnection connection: UMBonjourConnection) {
        
        debugPrint("umBonjourBrowser didCreateConnection")
        
        self.bonjourConnection?.close()
        self.bonjourConnection = connection
        self.bonjourConnection!.delegate = self
    }
    
    // MARK: UMbonjourConnectionDelegate
    
    func bonjourConnection(_ connection: UMBonjourConnection, didSendMessage message: UMMessage) {
        
        debugPrint("bonjourConnection didSendMessage")
    }
    
    func bonjourConnection(_ connection: UMBonjourConnection, didReceiveMessage message: UMMessage) {
        
        debugPrint("umBonjourServer didReceiveMessage")
        
        let usage = message.header!.usage
        //let data  = message.contentData
        
        if usage == 0x00 {
            // return heart beat message
            connection.sendMessage(UMMessage(data: Data(), usageId: 0x00))
        }
    }
    
    func bonjourConnectionDidOpen(_ connection: UMBonjourConnection) {
        
        if self.bonjourConnection != connection {
            
            // close current connection
            self.bonjourConnection?.close()
            
            // set new connection as current connection
            self.bonjourConnection = connection
            self.bonjourConnection!.delegate = self
        }
        
        self.bonjourBrowser.stopSearching()
        
        debugPrint("bonjourConnectionDidOpen")
    }
    
    func bonjourConnectionDidClose(_ connection: UMBonjourConnection) {
        
        if self.bonjourConnection == connection {
            
            self.bonjourConnection = nil
        }
        
        self.bonjourBrowser.startSearching()
        
        debugPrint("bonjourConnectionDidClose")
    }
    
    // MAKR: device motion functions
    
    func calibrateDevice() {
        
        if self.motionManager.isDeviceMotionActive {
            
            self.referenceAttitude = self.motionManager.deviceMotion?.attitude
        }
        else {
            
            self.motionManager.deviceMotionUpdateInterval = 0.2
            self.motionManager.startDeviceMotionUpdates(to: self.motionQueue, withHandler: self.deviceMotionHandler as! CMDeviceMotionHandler)
            
            // calibrate after certain seconds to ensure motion manager has beening initialized
            self.perform(#selector(AppDelegate.calibrateDevice), with: nil, afterDelay: 1.0)
        }
    }
    
    // device motiion handler
    func deviceMotionHandler(_ deviceMotion: CMDeviceMotion?, error: NSError?) {
        
        if self.referenceAttitude == nil {
            
            return
        }
        
        deviceMotion?.attitude.multiply(byInverseOf: self.referenceAttitude!)
        
        let skView = gameViewController?.view as? SKView
        if let scene  = skView?.scene as? GameScene {
            
            scene.deviceMotionHandler(deviceMotion, error: error)
        } else if let scene  = skView?.scene as? MenuScene {
            
            scene.deviceMotionHandler(deviceMotion, error: error)
        }
    }
    
    // MARK: network functions
    
    func sendUMMessage(_ message: UMMessage) {
        
        if self.bonjourConnection != nil && self.bonjourConnection!.isOpen {
            
            self.bonjourConnection!.sendMessage(message)
        }
    }
    
    func sendDebugInformation(infoString info: String ) {
        
        if self.bonjourConnection != nil && self.bonjourConnection!.isOpen {
            
            self.bonjourConnection!.sendMessage(UMMessage(data: info.data(using: String.Encoding.utf8)! , usageId: 0xff))
        }
    }
}

