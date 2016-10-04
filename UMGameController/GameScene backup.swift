//
//  GameScene.swift
//  UMGameController
//
//  Created by fOrest on 6/13/16.
//  Copyright (c) 2016 fOrest. All rights reserved.
//

import SpriteKit

class GameSceneBackup: SKScene {
    
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!"
        myLabel.fontSize = 45
        myLabel.position = CGPoint(x:self.frame.midX, y:self.frame.midY)
        
        self.addChild(myLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.location(in: self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotate(byAngle: CGFloat(M_PI), duration:1)
            
            sprite.run(SKAction.repeatForever(action))
            
            self.addChild(sprite)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            // TODO:
            debugPrint(touch.description)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            // TODO:
            debugPrint(touch.description)
        }
    }
   
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
}

//
//  GameScene.swift
//  UMGameController
//
//  Created by fOrest on 7/9/16.
//  Copyright © 2016 fOrest. All rights reserved.
//
//
//import Foundation
//import SpriteKit
//import CoreMotion
//
//class GameScene: SKScene, AnalogJoystickDelegate, UMSKNodeDelegate, UMBonjourBrowserDelegate, UMbonjourConnectionDelegate {
//    
//    var spaceShip: SKSpriteNode?
//    
//    let moveStick = AnalogJoystick(textures: (SKTexture(imageNamed: "jSubstrate"), SKTexture(imageNamed: "jStick")), colors: (UIColor.darkGrayColor(), UIColor.grayColor()), sizes: (CGSize(width: UIScreen.mainScreen().bounds.height, height: UIScreen.mainScreen().bounds.height), CGSize(width: UIScreen.mainScreen().bounds.height - 150, height: UIScreen.mainScreen().bounds.height - 150) ))
//    
//    let rotateStick = AnalogJoystick(textures: (SKTexture(imageNamed: "jSubstrate"), SKTexture(imageNamed: "jStick")), colors: (UIColor.darkGrayColor(), UIColor.grayColor()), sizes: (CGSize(width: UIScreen.mainScreen().bounds.height, height: UIScreen.mainScreen().bounds.height), CGSize(width: UIScreen.mainScreen().bounds.height - 150, height: UIScreen.mainScreen().bounds.height - 150) ))
//    
//    let menuScene: MenuScene = MenuScene()
//    
//    var connection: UMBonjourConnection?
//    
//    var buttonMap: UMGeneralButtonMap = UMGeneralButtonMap()
//    
//    var blebutton: UMGameControllerButton = UMGameControllerButton.none
//    
//    var bleData: NSData?
//    
//    var browser: UMBonjourBrowser = UMBonjourBrowser()
//    
//    var peripheral: UMCBPeripheral = UMCBPeripheral()
//    
//    //var central: UMCBCentral = UMCBCentral()
//    
//    var initialized: Bool = false
//    
//    override func didMoveToView(view: SKView) {
//        super.didMoveToView(view)
//        /* Setup your scene here */
//        
//        if initialized {
//            
//            return
//        }
//        
//        self.backgroundColor = UIColor.lightGrayColor()
//        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
//        
//        //self.becomeFirstResponder()
//        
//        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
//        myLabel.text = "Ultimate Master"
//        myLabel.fontSize = 45
//        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame) + 220)
//        
//        //self.addChild(myLabel)
//        let buttonA = UMSKNode(color: UIColor.darkGrayColor(), size: CGSize(width: 300, height: 200))
//        buttonA.position = CGPointMake(self.frame.midX, buttonA.size.height * 0.5)
//        buttonA.name = "buttonA"
//        buttonA.alpha = 1.0
//        buttonA.delegate = self
//        self.addChild(buttonA)
//        
//        let buttonB = UMSKNode(color: UIColor.darkGrayColor(), size: CGSize(width: 300, height: 200))
//        buttonB.position = CGPointMake(self.frame.maxX, buttonB.size.height * 0.5)
//        buttonB.name = "buttonB"
//        buttonB.alpha = 1.0
//        buttonB.delegate = self
//        self.addChild(buttonB)
//        
//        let buttonX = UMSKNode(color: UIColor.darkGrayColor(), size: CGSize(width: 300, height: 200))
//        buttonX.position = CGPointMake(0, buttonX.size.height * 0.5)
//        buttonX.name = "buttonX"
//        buttonX.alpha = 1.0
//        buttonX.delegate = self
//        self.addChild(buttonX)
//        
//        let buttonY = UMSKNode(color: UIColor.darkGrayColor(), size: CGSize(width: 300, height: 200))
//        buttonY.position = CGPointMake(self.frame.midX, self.frame.maxY - buttonY.size.height * 0.5)
//        buttonY.name = "buttonY"
//        buttonY.alpha = 1.0
//        buttonY.delegate = self
//        self.addChild(buttonY)
//        
//        let bumperLeft = UMSKNode(color: UIColor.darkGrayColor(), size: CGSize(width: 300, height: 200))
//        bumperLeft.position = CGPointMake(0, self.frame.maxY - bumperLeft.size.height * 0.5)
//        bumperLeft.name = "bumperLeft"
//        bumperLeft.alpha = 1.0
//        bumperLeft.delegate = self
//        self.addChild(bumperLeft)
//        
//        let bumperRight = UMSKNode(color: UIColor.darkGrayColor(), size: CGSize(width: 300, height: 200))
//        bumperRight.position = CGPointMake(self.frame.maxX, self.frame.maxY - bumperRight.size.height * 0.5)
//        bumperRight.name = "bumperRight"
//        bumperRight.alpha = 1.0
//        bumperRight.delegate = self
//        self.addChild(bumperRight)
//        
//        
//        let dPad = UMSKNode(color: UIColor.orangeColor(), size: CGSize(width: 180, height: 180))
//        dPad.position = CGPointMake(self.frame.midX, self.frame.midY)
//        dPad.name = "dPad"
//        dPad.alpha = 1.0
//        dPad.delegate = self
//        self.addChild(dPad)
//        
//        let dPadBackground = UMSKNode(color: self.backgroundColor, size: CGSize(width: 200, height: 200))
//        //dPadForeground.position = CGPointMake(self.frame.midX, self.frame.midY)
//        dPadBackground.name = "dPadBackground"
//        dPadBackground.alpha = 1.0
//        dPadBackground.delegate = self
//        dPadBackground.zPosition = dPad.zPosition - 1
//        dPad.addChild(dPadBackground)
//        
//        
//        let moveCircle = UMSKNode(color: UIColor.blackColor(), size: CGSize(width: self.frame.midX - 40, height: self.frame.midX - 40))
//        moveCircle.position = CGPointMake(moveCircle.size.width / 2, self.frame.midY)
//        moveCircle.name = "moveCircle"
//        moveCircle.zPosition = -3
//        moveCircle.delegate = self
//        self.addChild(moveCircle)
//        
//        let rotateCircle = UMSKNode(color: UIColor.blackColor(), size: CGSize(width: self.frame.midX - 40, height: self.frame.midX - 40))
//        rotateCircle.position = CGPointMake(self.frame.maxX - rotateCircle.size.width / 2, self.frame.midY)
//        rotateCircle.name = "rotateCircle"
//        rotateCircle.zPosition = -3
//        rotateCircle.delegate = self
//        self.addChild(rotateCircle)
//        
//        moveStick.zPosition = 2
//        //self.addChild(moveStick)
//        moveStick.delegate = self
//        
//        rotateStick.zPosition = 2
//        //self.addChild(rotateStick)
//        rotateStick.delegate = self
//        
//        let ultimateLabel = SKLabelNode(fontNamed:"Chalkduster")
//        ultimateLabel.text = "Ultimate"
//        ultimateLabel.fontSize = 45
//        ultimateLabel.zPosition = 1
//        ultimateLabel.userInteractionEnabled = false
//        moveCircle.addChild(ultimateLabel)
//        
//        let masterLabel = SKLabelNode(fontNamed:"Chalkduster")
//        masterLabel.text = "Master"
//        masterLabel.fontSize = 45
//        masterLabel.zPosition = 1
//        masterLabel.userInteractionEnabled = false
//        rotateCircle.addChild(masterLabel)
//        
//        browser.delegate = self
//        
//        self.filter = CIFilter(name: "CIGaussianBlur", withInputParameters: ["inputRadius": 1.0])
//        self.filter?.setValue(50, forKey: "inputRadius")
//        
//        if menuScene.gameScene == nil {
//            
//            menuScene.gameScene = self
//            menuScene.scaleMode = self.scaleMode
//            menuScene.size = self.size
//            
//            self.shouldEnableEffects = true
//            self.shouldRasterize = true
//            
//            menuScene.setBackground(SKSpriteNode(texture: self.view?.textureFromNode(self)))
//            
//            self.shouldRasterize = false
//            self.shouldEnableEffects = false
//        }
//        self.initialized = true
//        view.multipleTouchEnabled = true
//    }
//    
//    func ShowMenuScene() {
//        
//        self.view?.presentScene(menuScene, transition: SKTransition.fadeWithDuration(0.1))
//    }
//    
//    override func update(currentTime: CFTimeInterval) {
//        /* Called before each frame is rendered */
//    }
//    
//    func deviceMotionHandler(deviceMotion: CMDeviceMotion?, error: NSError?) {
//        
//        sendDebugInformation("\(deviceMotion!.attitude)")
//    }
//    
//    func sendDebugInformation(information: String) {
//        
//        if connection == nil {
//            return
//        }
//        if !connection!.isOpen {
//            return
//        }
//        
//        let header: UMMessageHeader? = UMMessageHeader(length: information.lengthOfBytesUsingEncoding(NSUTF8StringEncoding), contentType: "debug information", contendCoder: "none", sequenceNO: 0, usageId: 0xff, time: NSDate().timeIntervalSince1970)
//        if header == nil {
//            return
//        }
//        
//        connection!.sendMessage(UMMessage(data: NSMutableData(data: information.dataUsingEncoding(NSUTF8StringEncoding)!) , messageHeader: header!))
//    }
//    
//    func sendGameControllerMessage() {
//        
//        return peripheral.umVHIDDevice.setState(buttonSequence: buttonMap.buttonState, pointerSequence: buttonMap.pointerState)
//        
//        if blebutton == .none {
//            
//            //peripheral.umVHIDDevice.setState(buttonSequence: buttonMap.buttonState, pointerSequence: buttonMap.pointerState)
//            peripheral.updateValue(NSData(bytes: &self.buttonMap, length: sizeofValue(self.buttonMap)), forCharacteristic: umDeviceReportUUID)
//        }
//        else {
//            
//            peripheral.updateValue(bleData!, forCharacteristic: blebutton.UUID)
//        }
//        return (self.blebutton = .none)
//        
//        if connection == nil {
//            return
//        }
//        if !connection!.isOpen {
//            return
//        }
//        
//        let header: UMMessageHeader? = UMMessageHeader(length: sizeofValue(buttonMap), contentType: UMGameControllerType.UMGameControllerTypeGeneral.description, contendCoder: "none", sequenceNO: 0, usageId: 0x00, time: NSDate().timeIntervalSince1970)
//        if header == nil {
//            return
//        }
//        
//        connection!.sendMessage(UMMessage(data: NSMutableData(bytes: &self.buttonMap, length: sizeofValue(self.buttonMap)), messageHeader: header!))
//        // reset bletutton
//        self.blebutton = .none
//    }
//    
//    func resetButtonsAfterTime(inout map: UMGeneralButtonMap, time: NSTimeInterval = 0.2) {
//        
//        let delay: NSTimeInterval = time;
//        let popTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, (Int64)(delay * Double(NSEC_PER_SEC)) );
//        dispatch_after(popTime, dispatch_get_main_queue() ) { [weak self] () -> () in
//            
//            if let _self = self {
//                
//                var memberBuffer = [UInt8](count: sizeofValue(_self.buttonMap), repeatedValue: 0)
//                memcpy(&memberBuffer, &_self.buttonMap, sizeofValue(_self.buttonMap))
//                
//                
//                var maskBuffer = [UInt8](count: sizeofValue(_self.buttonMap), repeatedValue: 0)
//                memcpy(&maskBuffer, &map, sizeofValue(map))
//                
//                for index in 0...memberBuffer.count - 1 {
//                    memberBuffer[index] = memberBuffer[index] & maskBuffer[index]
//                }
//                memcpy(&_self.buttonMap, &memberBuffer, sizeofValue(_self.buttonMap))
//                
//                _self.blebutton = .none
//                
//                _self.sendGameControllerMessage()
//            }
//        }
//    }
//    
//    func resetDpad() {
//        
//        let dPad = self.childNodeWithName("dPad") as! UMSKNode
//        
//        if dPad.position != CGPointMake(self.frame.midX, self.frame.midY) {
//            let actionMove = SKAction.moveTo(CGPointMake(self.frame.midX, self.frame.midY), duration: NSTimeInterval(0.2))
//            actionMove.timingMode  = SKActionTimingMode.EaseOut
//            dPad.runAction(actionMove)
//        }
//        let moveCircle = self.childNodeWithName("moveCircle") as! UMSKNode
//        let rotateCircle = self.childNodeWithName("rotateCircle") as! UMSKNode
//        
//        var scale: CGFloat = 1.0
//        if  !dPad.isIneracting && (moveCircle.isIneracting || rotateCircle.isIneracting) {
//            scale = 0.6
//        }
//        if dPad.xScale != scale || dPad.yScale != scale {
//            let actionScale = SKAction.scaleTo(scale, duration: 0.2)
//            actionScale.timingMode = SKActionTimingMode.EaseOut
//            dPad.runAction(actionScale)
//        }
//    }
//    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        //
//    }
//    
//    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        /* Called when a touch Ended */
//    }
//    
//    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
//        //buttonMap.a = true
//        //sendGameControllerMessage()
//    }
//    
//    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
//        //buttonMap.a = false
//        //sendGameControllerMessage()
//    }
//    
//    override func motionCancelled(motion: UIEventSubtype, withEvent event: UIEvent?) {
//        //
//    }
//    
//    // MARK:UMSKNodeDelegate
//    func umSKNode(node: UMSKNode, touchesBegan touches: Set<UITouch>, withEvent event: UIEvent?) {
//        
//        debugPrint("\(node.name) clicked!")
//        
//        if let touch = touches.first {
//            
//            switch node.name {
//                
//            case "buttonA"?:        buttonMap.a = true;blebutton = .a;bleData = NSData(bytes: &buttonMap.a, length: 1);break
//            case "buttonB"?:        buttonMap.b = true;blebutton = .b;bleData = NSData(bytes: &buttonMap.b, length: 1);break
//            case "buttonX"?:        buttonMap.x = true;blebutton = .x;bleData = NSData(bytes: &buttonMap.x, length: 1);break
//            case "buttonY"?:        buttonMap.y = true;blebutton = .y;bleData = NSData(bytes: &buttonMap.y, length: 1);break
//            case "bumperLeft"?:     buttonMap.bumper_left = true;blebutton = .bumper_left;bleData = NSData(bytes: &buttonMap.bumper_left, length: 2);break
//            case "bumperRight"?:    buttonMap.bumper_right = true;blebutton = .bumper_right;bleData = NSData(bytes: &buttonMap.bumper_right, length: 2);break
//            case "dPad"?:
//                resetDpad()
//                break
//            case "moveCircle"?:
//                
//                moveStick.position = touch.locationInNode(self)
//                moveStick.umSKNode(moveStick.stick, touchesBegan: touches, withEvent: event)
//                
//                if !self.children.contains(moveStick) {
//                    self.addChild(moveStick)
//                }
//                
//                if node.touches!.first?.tapCount > 1 {
//                    buttonMap.trigger_left = Int16.max; blebutton = .trigger_left;bleData = NSData(bytes: &buttonMap.trigger_left, length: 2)
//                }
//                resetDpad()
//                break
//            case "rotateCircle"?:
//                rotateStick.position = touch.locationInNode(self)
//                rotateStick.umSKNode(rotateStick.stick, touchesBegan: touches, withEvent: event)
//                if !self.children.contains(rotateStick) {
//                    self.addChild(rotateStick)
//                }
//                resetDpad()
//                break
//            default:
//                break
//            }
//            
//            sendGameControllerMessage()
//        }
//    }
//    
//    func umSKNode(node: UMSKNode, touchesMoved touches: Set<UITouch>, withEvent event: UIEvent?) {
//        
//        for touch in touches {
//            
//            switch node.name {
//                
//            case "dPad"?:
//                node.position = touch.locationInNode(self)
//                break
//            case "moveCircle"?:
//                if self.children.contains(moveStick) {
//                    moveStick.umSKNode(moveStick.stick, touchesMoved: touches, withEvent: event)
//                }
//                break
//            case "rotateCircle"?:
//                if self.children.contains(rotateStick) {
//                    rotateStick.umSKNode(rotateStick.stick, touchesMoved: touches, withEvent: event)
//                }
//                break
//            default:
//                break
//            }
//        }
//    }
//    
//    func umSKNode(node: UMSKNode, touchesEnded touches: Set<UITouch>, withEvent event: UIEvent?){
//        
//        switch node.name {
//            
//        case "buttonA"?:        buttonMap.a = false;blebutton = .a;bleData = NSData(bytes: &buttonMap.a, length: 1);break
//        case "buttonB"?:        buttonMap.b = false;blebutton = .b;bleData = NSData(bytes: &buttonMap.b, length: 1);break
//        case "buttonX"?:        buttonMap.x = false;blebutton = .x;bleData = NSData(bytes: &buttonMap.x, length: 1);break
//        case "buttonY"?:        buttonMap.y = false;blebutton = .y;bleData = NSData(bytes: &buttonMap.y, length: 1);break
//        case "bumperLeft"?:     buttonMap.bumper_left = false;blebutton = .bumper_left;bleData = NSData(bytes: &buttonMap.bumper_left, length: 1);break
//        case "bumperRight"?:    buttonMap.bumper_right = false;blebutton = .bumper_right;bleData = NSData(bytes: &buttonMap.bumper_right, length: 1);break
//        case "dPad"?:
//            
//            let pointer = node.touchPointer
//            if abs(pointer.x) < 2 && abs(pointer.y) < 2 {
//                
//                return ShowMenuScene()
//                
//                buttonMap.menu = true
//                
//                resetDpad()
//                
//                var map = UMGeneralButtonMap()
//                memset(&map, 0xff, sizeofValue(map))
//                map.menu = false
//                resetButtonsAfterTime(&map)
//            }
//            else {
//                buttonMap.dpad_left  = abs(pointer.x) > abs(pointer.y) && pointer.x < 0
//                buttonMap.dpad_right = abs(pointer.x) > abs(pointer.y) && pointer.x > 0
//                buttonMap.dpad_up    = abs(pointer.x) < abs(pointer.y) && pointer.y > 0
//                buttonMap.dpad_down  = abs(pointer.x) < abs(pointer.y) && pointer.y < 0
//                
//                resetDpad()
//                
//                if buttonMap.dpad_left
//                { blebutton = .dpad_left;   bleData = NSData(bytes: &buttonMap.dpad_left, length: 1) }
//                else if buttonMap.dpad_right
//                { blebutton = .dpad_right;  bleData = NSData(bytes: &buttonMap.dpad_right, length: 1) }
//                else if buttonMap.dpad_up
//                { blebutton = .dpad_up;     bleData = NSData(bytes: &buttonMap.dpad_up, length: 1) }
//                else if buttonMap.dpad_down
//                { blebutton = .dpad_down;   bleData = NSData(bytes: &buttonMap.dpad_down, length: 1) }
//                
//                if buttonMap.dpad_left || buttonMap.dpad_right || buttonMap.dpad_up || buttonMap.dpad_down {
//                    
//                    var map = UMGeneralButtonMap()
//                    memset(&map, 0xff, sizeofValue(map))
//                    map.dpad_left = false;map.dpad_right = false;map.dpad_up = false;map.dpad_down = false
//                    resetButtonsAfterTime(&map)
//                }
//            }
//            
//            break
//        case "moveCircle"?:
//            resetDpad()
//            if self.children.contains(moveStick) {
//                moveStick.removeFromParent()
//            }
//            if buttonMap.trigger_left > 0 {
//                buttonMap.trigger_left = 0; blebutton = .trigger_left;bleData = NSData(bytes: &buttonMap.trigger_left, length: 2)
//            }
//            moveStick.umSKNode(moveStick.stick, touchesEnded: touches, withEvent: event)
//            break
//        case "rotateCircle"?:
//            resetDpad()
//            
//            if self.children.contains(rotateStick) {
//                rotateStick.removeFromParent()
//            }
//            
//            let pointer = node.touchPointer
//            if abs(pointer.x) < 2 && abs(pointer.y) < 2  {
//                
//                buttonMap.trigger_right = Int16.max;blebutton = .trigger_right;bleData = NSData(bytes: &buttonMap.trigger_right, length: 2)
//                
//                var map = UMGeneralButtonMap()
//                memset(&map, 0xff, sizeofValue(map))
//                map.trigger_right = 0
//                resetButtonsAfterTime(&map)
//            }
//            rotateStick.umSKNode(rotateStick.stick, touchesEnded: touches, withEvent: event)
//            break
//        default:
//            break
//        }
//        
//        sendGameControllerMessage()
//    }
//    
//    func umSKNode(node: UMSKNode, touchesCancelled touches: Set<UITouch>?, withEvent event: UIEvent?) {
//        
//        switch node.name {
//            
//        case "dPad"?: resetDpad(); break
//        case "moveCircle"?:
//            resetDpad()
//            if self.children.contains(moveStick) {
//                moveStick.removeFromParent()
//            }
//            if buttonMap.trigger_left > 0 {
//                buttonMap.trigger_left = 0; blebutton = .trigger_left;bleData = NSData(bytes: &buttonMap.trigger_left, length: 2)
//            }
//            moveStick.umSKNode(moveStick.stick, touchesCancelled: touches, withEvent: event)
//            break
//        case "rotateCircle"?:
//            resetDpad()
//            if self.children.contains(rotateStick) {
//                rotateStick.removeFromParent()
//            }
//            rotateStick.umSKNode(rotateStick.stick, touchesCancelled: touches, withEvent: event)
//            break
//        default:
//            break
//        }
//    }
//    
//    // MARK: AnalogJoystickDelegate
//    func analogJoystick(joystick: AnalogJoystick, touchesBegan touches: Set<UITouch>, withEvent event: UIEvent?) {
//        //
//    }
//    
//    func analogJoystick(joystick: AnalogJoystick, touchesMoved touches: Set<UITouch>, withEvent event: UIEvent?) {
//        //
//    }
//    
//    func analogJoystick(joystick: AnalogJoystick, touchesEnded touches: Set<UITouch>, withEvent event: UIEvent?) {
//        
//        if joystick == moveStick {
//            
//        } else if joystick == rotateStick {
//            
//        }
//    }
//    
//    func analogJoystick(joystick: AnalogJoystick, touchesCancelled touches: Set<UITouch>?, withEvent event: UIEvent?) {
//        //
//    }
//    
//    func analogJoystick(joystick: AnalogJoystick, dataChanged data: AnalogJoystickData) {
//        
//        if joystick == self.moveStick {
//            
//            buttonMap.stick_left_x = Int16(data.velocity.x)
//            buttonMap.stick_left_y = Int16(-data.velocity.y)
//            
//            blebutton = .stick_left
//            let data = NSMutableData(bytes: &buttonMap.stick_left_x, length: 2)
//            data.appendBytes(&buttonMap.stick_left_y, length: 2)
//            bleData = NSData(data: data)
//        }
//        else if joystick == self.rotateStick {
//            
//            buttonMap.stick_right_x = Int16(data.velocity.x)
//            buttonMap.stick_right_y = Int16(-data.velocity.y)
//            
//            blebutton = .stick_right
//            let data = NSMutableData(bytes: &buttonMap.stick_right_x, length: 2)
//            data.appendBytes(&buttonMap.stick_right_y, length: 2)
//            bleData = NSData(data: data)
//        }
//        
//        sendGameControllerMessage()
//    }
//    
//    // MARK: UMBonjourBrowserDelegate
//    func umBonjourBrowser(browser: UMBonjourBrowser, didCreateConnection connection: UMBonjourConnection) {
//        
//        debugPrint("umBonjourBrowser didCreateConnection")
//        
//        self.connection?.close()
//        self.connection = connection
//        self.connection?.delegate = self
//    }
//    
//    // MARK: UMbonjourConnectionDelegate
//    
//    func bonjourConnection(connection: UMBonjourConnection, didSendMessage message: UMMessage) {
//        
//        debugPrint("bonjourConnection didSendMessage")
//    }
//    
//    func bonjourConnection(connection: UMBonjourConnection, didReceiveMessage message: UMMessage) {
//        // TODO:
//    }
//    
//    func bonjourConnectionDidOpen(connection: UMBonjourConnection) {
//        
//        if self.connection! != connection {
//            self.connection?.close()
//            self.connection = connection
//            self.connection!.delegate = self
//        }
//        debugPrint("bonjourConnectionDidOpen")
//    }
//    
//    func bonjourConnectionDidClose(connection: UMBonjourConnection) {
//        
//        if self.connection! == connection {
//            self.connection = nil
//        }
//        
//        debugPrint("bonjourConnectionDidClose")
//    }
//    
//    func bonjourConnection(connection: UMBonjourConnection, didReceiveBytes bytes: UnsafeMutablePointer<Void>, withLength length: Int) {
//        // TODO:
//    }
//    
//}
//
//extension UIColor {
//    
//    static func random() -> UIColor {
//        
//        return UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1)
//    }
//}

