//
//  GameScene.swift
//  UMGameController
//
//  Created by fOrest on 7/9/16.
//  Copyright © 2016 fOrest. All rights reserved.
//

import Foundation
import SpriteKit
import CoreMotion
import UMVHIDDevice_iOS

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class GameScene: SKScene, AnalogJoystickDelegate, UMSKNodeDelegate, UMVHIDDeviceDelegate {
    
    /* a virtual hid device to represent data of an hid device
     */
    var umVHIDDevice = UMVHIDDevice(type: UMVHIDDeviceType.umVHIDDeviceTypeJoystick, pointerCount: 3, buttonCount: 16, isRelative: false)!
    
    var buttonMap: UMGeneralButtonMap = UMGeneralButtonMap()
    
    var updatingButtons: [UMGameControllerButton] = [UMGameControllerButton]()
    
    var resetingButtons: [UMGameControllerButton] = [UMGameControllerButton]()
    
    var stickAreaRadius: CGFloat = 0.0
    
    var leftStickPosition: CGPoint {
        
        return CGPoint(x: 0.0, y: 0.0)
    }
    
    var rightStickPosition: CGPoint {
        
        return CGPoint(x: 0.0, y: 0.0)
    }
    
    private var initialized: Bool = false
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        /* Setup your scene here */
        
        if initialized {
            
            return
        }
        
        self.backgroundColor = UIColor.lightGray
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.view?.isMultipleTouchEnabled = true
        
        // set filter
        self.filter = CIFilter(name: "CIGaussianBlur", withInputParameters: ["inputRadius": 1.0])
        self.filter?.setValue(50, forKey: "inputRadius")
        
        readLayout()
        
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Ultimate Master"
        myLabel.fontSize = 45
        myLabel.position = CGPoint(x:self.frame.midX, y: self.frame.midY + 220)
        
        //self.addChild(myLabel)
        let buttonCenterDn = UMSKNode(color: UIColor.darkGray, size: CGSize(width: 300, height: 200))
        buttonCenterDn.position = CGPoint(x: self.frame.midX, y: buttonCenterDn.size.height * 0.5)
        buttonCenterDn.name = "buttonCenterDn"
        buttonCenterDn.alpha = 1.0
        buttonCenterDn.delegate = self
        self.addChild(buttonCenterDn)
        
        let buttonRightDn = UMSKNode(color: UIColor.darkGray, size: CGSize(width: 300, height: 200))
        buttonRightDn.position = CGPoint(x: self.frame.maxX, y: buttonRightDn.size.height * 0.5)
        buttonRightDn.name = "buttonRightDn"
        buttonRightDn.alpha = 1.0
        buttonRightDn.delegate = self
        self.addChild(buttonRightDn)

        let buttonCenterUp = UMSKNode(color: UIColor.darkGray, size: CGSize(width: 300, height: 200))
        buttonCenterUp.position = CGPoint(x: 0, y: buttonCenterUp.size.height * 0.5)
        buttonCenterUp.name = "buttonCenterUp"
        buttonCenterUp.alpha = 1.0
        buttonCenterUp.delegate = self
        self.addChild(buttonCenterUp)
        
        let buttonRightUp = UMSKNode(color: UIColor.darkGray, size: CGSize(width: 300, height: 200))
        buttonRightUp.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - buttonRightUp.size.height * 0.5)
        buttonRightUp.name = "buttonRightUp"
        buttonRightUp.alpha = 1.0
        buttonRightUp.delegate = self
        self.addChild(buttonRightUp)
        
        let buttonLeftUp = UMSKNode(color: UIColor.darkGray, size: CGSize(width: 300, height: 200))
        buttonLeftUp.position = CGPoint(x: 0, y: self.frame.maxY - buttonLeftUp.size.height * 0.5)
        buttonLeftUp.name = "buttonLeftUp"
        buttonLeftUp.alpha = 1.0
        buttonLeftUp.delegate = self
        self.addChild(buttonLeftUp)
        
        let buttonLeftDn = UMSKNode(color: UIColor.darkGray, size: CGSize(width: 300, height: 200))
        buttonLeftDn.position = CGPoint(x: self.frame.maxX, y: self.frame.maxY - buttonLeftDn.size.height * 0.5)
        buttonLeftDn.name = "buttonLeftDn"
        buttonLeftDn.alpha = 1.0
        buttonLeftDn.delegate = self
        self.addChild(buttonLeftDn)
        
        
        let dPad = UMSKNode(color: UIColor.orange, size: CGSize(width: 180, height: 180))
        dPad.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        dPad.name = "dPad"
        dPad.alpha = 1.0
        dPad.delegate = self
        self.addChild(dPad)
        
        let dPadBackground = UMSKNode(color: self.backgroundColor, size: CGSize(width: 200, height: 200))
        dPadBackground.name = "dPadBackground"
        dPadBackground.alpha = 1.0
        dPadBackground.delegate = self
        dPadBackground.zPosition = dPad.zPosition - 1
        dPad.addChild(dPadBackground)
        
        let leftStickArea = UMSKNode(color: UIColor.black, size: CGSize(width: self.frame.midX - 40, height: self.frame.midX - 40))
        leftStickArea.position = CGPoint(x: leftStickArea.size.width / 2, y: self.frame.midY)
        leftStickArea.name = "leftStickArea"
        leftStickArea.zPosition = -3
        leftStickArea.delegate = self
        self.addChild(leftStickArea)
        
        let rightStickArea = UMSKNode(color: UIColor.black, size: CGSize(width: self.frame.midX - 40, height: self.frame.midX - 40))
        rightStickArea.position = CGPoint(x: self.frame.maxX - rightStickArea.size.width / 2, y: self.frame.midY)
        rightStickArea.name = "rightStickArea"
        rightStickArea.zPosition = -3
        rightStickArea.delegate = self
        self.addChild(rightStickArea)
        
        let leftStick = AnalogJoystick(textures: (SKTexture(imageNamed: "jSubstrate"), SKTexture(imageNamed: "jStick")), colors: (UIColor.darkGray, UIColor.gray), sizes: (CGSize(width: 200, height: 200), CGSize(width: 150, height: 150) ))
        leftStick.name = "leftStick"
        leftStick.zPosition = 2
        leftStick.isHidden = true
        self.addChild(leftStick)
        leftStick.delegate = self
        
        let rightStick = AnalogJoystick(textures: (SKTexture(imageNamed: "jSubstrate"), SKTexture(imageNamed: "jStick")), colors: (UIColor.darkGray, UIColor.gray), sizes: (CGSize(width: 200, height: 200), CGSize(width: 150, height: 150) ))
        rightStick.name = "rightStick"
        rightStick.zPosition = 2
        rightStick.isHidden = true
        self.addChild(rightStick)
        rightStick.delegate = self
        
        umVHIDDevice.delegate = self
        
        self.initialized = true
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        /* Called before each frame is rendered */
    }
    
    /* read controller layout settings from user defaults
     */
    func readLayout() {
        
        self.userData = UserData.getValue(UserDataKeys.gameDict.rawValue) as? NSMutableDictionary
        if self.userData == nil {
            
            self.userData = NSMutableDictionary(dictionaryLiteral:
                
                // 5 pixels to edge of screen, 10 pixels between edges of cicle areas
                ("stickAreaRadius", (self.frame.width - 5 - 5 - 10) / 2)
                // TODO:
            )
            UserData.setValue(value: self.userData, forKey: UserDataKeys.gameDict.rawValue)
        }
        self.stickAreaRadius = userData!["stickAreaRadius"] as! CGFloat
        // TODO: add other setting variables
    }
    
    /* write controller layout settings to user defaults
     */
    func wirteLayout() {
        // TODO:
    }
    
    func deviceMotionHandler(_ deviceMotion: CMDeviceMotion?, error: NSError?) {
        
        //sendDebugInformation("\(deviceMotion!.attitude)")
        //sendDebugInformation("\(deviceMotion!.rotationRate)")
        
        if abs((deviceMotion?.attitude.quaternion.x)!) > 0.3 && abs((deviceMotion?.rotationRate.x)!) > 2.0 {
            
            if abs((deviceMotion?.attitude.quaternion.x)!) > 2 * abs((deviceMotion?.attitude.quaternion.y)!) && abs((deviceMotion?.attitude.quaternion.x)!) > 2 * abs((deviceMotion?.attitude.quaternion.z)!) {
                
                if deviceMotion?.attitude.quaternion.x < -0.3 && !self.buttonMap.stick_left_click {
                    
                    self.buttonMap.stick_left_click = true
                    self.updatingButtons.append(.stick_left_click)
                    //self.resetingButtons.append(.stick_left_click)
                    self.sendGameControllerMessage()
                }
                else if deviceMotion?.attitude.quaternion.x > 0.3 && !self.buttonMap.stick_right_click {
                    
                    self.buttonMap.stick_right_click = true
                    self.updatingButtons.append(.stick_right_click)
                    //self.resetingButtons.append(.stick_right_click)
                    self.sendGameControllerMessage()
                }
            }
        } else if abs((deviceMotion?.attitude.quaternion.x)!) < 0.3 {
            
            if self.buttonMap.stick_left_click {
                
                self.buttonMap.stick_left_click = false
                self.updatingButtons.append(.stick_left_click)
                self.sendGameControllerMessage()
            }
            if self.buttonMap.stick_right_click {
                
                self.buttonMap.stick_right_click = false
                self.updatingButtons.append(.stick_right_click)
                self.sendGameControllerMessage()
            }
        }
        
    }
    
    func sendGameControllerMessage() {
        
        if AppDelegate.shared?.connMode == 0x00 {
            
            for button in updatingButtons {
                
                var value = getButtonValue(button)
                let data  = value as? Data ?? Data(bytes: &value, count: MemoryLayout.size(ofValue: value))
                
                AppDelegate.shared?.cbPeripheral.updateValue(data, forCharacteristic: button.UUID)
            }
        }
        else {
            
            self.umVHIDDevice.setState(buttonSequence: buttonMap.buttonState, pointerSequence: buttonMap.pointerState)
        }
        
        if resetingButtons.count != 0 {
            
            resetButtonsAfterTime()
        }
        updatingButtons.removeAll()

    }
    
    func resetButtonsAfterTime(_ time: TimeInterval = 0.1) {
        
        let delay: TimeInterval = time;
        let popTime: DispatchTime = DispatchTime.now() + Double((Int64)(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC);
        
        DispatchQueue.main.asyncAfter(deadline: popTime) { [weak self] () -> () in
            
            if let _self = self {
                
                if AppDelegate.shared?.connMode == 0x00 {
                    
                    for button in _self.resetingButtons {
                        
                        _self.resetButtonValue(button)
                        
                        var value = _self.getButtonValue(button)
                        let data  = value as? Data ?? Data(bytes: &value, count: MemoryLayout.size(ofValue: value))
                        
                        AppDelegate.shared?.cbPeripheral.updateValue(data, forCharacteristic: button.UUID)
                    }
                } else {
                    
                    for button in _self.resetingButtons {
                        
                        _self.resetButtonValue(button)
                    }
                    _self.umVHIDDevice.setState(buttonSequence: _self.buttonMap.buttonState, pointerSequence: _self.buttonMap.pointerState)
                }
                _self.resetingButtons.removeAll()
            }
        }
    }
    
    func getButtonValue(_ button: UMGameControllerButton)-> Any? {
        
        switch button {
            
        case .a                      : return buttonMap.a
        case .b                      : return buttonMap.b
        case .x                      : return buttonMap.x
        case .y                      : return buttonMap.y
        case .bumper_left            : return buttonMap.bumper_left
        case .bumper_right           : return buttonMap.bumper_right
            
        case .view                   : return buttonMap.view
        case .menu                   : return buttonMap.menu
        case .stick_left_click       : return buttonMap.stick_left_click
        case .stick_right_click      : return buttonMap.stick_right_click
        case .dpad_up                : return buttonMap.dpad_up
        case .dpad_down              : return buttonMap.dpad_down
        case .dpad_left              : return buttonMap.dpad_left
        case .dpad_right             : return buttonMap.dpad_right
        case .home                   : return buttonMap.home
            
        case .stick_left_x           : return buttonMap.stick_left_x
        case .stick_left_y           : return buttonMap.stick_left_y
        case .trigger_left           : return buttonMap.trigger_left
        case .stick_right_x          : return buttonMap.stick_right_x
        case .stick_right_y          : return buttonMap.stick_right_y
        case .trigger_right          : return buttonMap.trigger_right
            
        case .stick_left             :
            var data = Data(bytes: &buttonMap.stick_left_x, count: MemoryLayout.size(ofValue: buttonMap.stick_left_x))
            data.append(Data(bytes: &buttonMap.stick_left_y, count: MemoryLayout.size(ofValue: buttonMap.stick_left_y)))
            return data
        case .stick_right            :
            var data = Data(bytes: &buttonMap.stick_right_x, count: MemoryLayout.size(ofValue: buttonMap.stick_right_x))
            data.append(Data(bytes: &buttonMap.stick_right_y, count: MemoryLayout.size(ofValue: buttonMap.stick_right_y)))
            return data
            
        default: return 0x00
        }
    }
    
    func resetButtonValue(_ button: UMGameControllerButton) {
        switch button {
            
        case .a                      : buttonMap.a = false
        case .b                      : buttonMap.b = false
        case .x                      : buttonMap.x = false
        case .y                      : buttonMap.y = false
        case .bumper_left            : buttonMap.bumper_left = false
        case .bumper_right           : buttonMap.bumper_right = false
            
        case .view                   : buttonMap.view = false
        case .menu                   : buttonMap.menu = false
        case .stick_left_click       : buttonMap.stick_left_click = false
        case .stick_right_click      : buttonMap.stick_right_click = false
        case .dpad_up                : buttonMap.dpad_up = false
        case .dpad_down              : buttonMap.dpad_down = false
        case .dpad_left              : buttonMap.dpad_left = false
        case .dpad_right             : buttonMap.dpad_right = false
        case .home                   : buttonMap.home = false
            
        case .stick_left_x           : buttonMap.stick_left_x = 0
        case .stick_left_y           : buttonMap.stick_left_y = 0
        case .trigger_left           : buttonMap.trigger_left = 0
        case .stick_right_x          : buttonMap.stick_right_x = 0
        case .stick_right_y          : buttonMap.stick_right_y = 0
        case .trigger_right          : buttonMap.trigger_right = 0
            
        default: return
        }
    }
    
    func setButtonValue(_ button: UMGameControllerButton, value: Any) {
        switch button {
            
        case .a                      : buttonMap.a = value as! Bool
        case .b                      : buttonMap.b = value as! Bool
        case .x                      : buttonMap.x = value as! Bool
        case .y                      : buttonMap.y = value as! Bool
        case .bumper_left            : buttonMap.bumper_left = value as! Bool
        case .bumper_right           : buttonMap.bumper_right = value as! Bool
            
        case .view                   : buttonMap.view = value as! Bool
        case .menu                   : buttonMap.menu = value as! Bool
        case .stick_left_click       : buttonMap.stick_left_click = value as! Bool
        case .stick_right_click      : buttonMap.stick_right_click = value as! Bool
        case .dpad_up                : buttonMap.dpad_up = value as! Bool
        case .dpad_down              : buttonMap.dpad_down = value as! Bool
        case .dpad_left              : buttonMap.dpad_left = value as! Bool
        case .dpad_right             : buttonMap.dpad_right = value as! Bool
        case .home                   : buttonMap.home = value as! Bool
            
        case .stick_left_x           : buttonMap.stick_left_x = value as! Int16
        case .stick_left_y           : buttonMap.stick_left_y = value as! Int16
        case .trigger_left           : buttonMap.trigger_left = value as! Int16
        case .stick_right_x          : buttonMap.stick_right_x = value as! Int16
        case .stick_right_y          : buttonMap.stick_right_y = value as! Int16
        case .trigger_right          : buttonMap.trigger_right = value as! Int16
            
        default: return
        }
        sendGameControllerMessage()
    }
    
    func resetDpad() {
        
        let dPad = self.childNode(withName: "dPad") as! UMSKNode
        
        if dPad.position != CGPoint(x: self.frame.midX, y: self.frame.midY) {
            let actionMove = SKAction.move(to: CGPoint(x: self.frame.midX, y: self.frame.midY), duration: TimeInterval(0.2))
            actionMove.timingMode  = SKActionTimingMode.easeOut
            dPad.run(actionMove)
        }
        let leftStickArea = self.childNode(withName: "leftStickArea") as! UMSKNode
        let rightStickArea = self.childNode(withName: "rightStickArea") as! UMSKNode
        
        var scale: CGFloat = 1.0
        if  !dPad.isIneracting && (leftStickArea.isIneracting || rightStickArea.isIneracting) {
            scale = 0.6
        }
        if dPad.xScale != scale || dPad.yScale != scale {
            let actionScale = SKAction.scale(to: scale, duration: 0.2)
            actionScale.timingMode = SKActionTimingMode.easeOut
            dPad.run(actionScale)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch Ended */
    }
    
    // MARK:UMSKNodeDelegate
    func umSKNode(_ node: UMSKNode, touchesBegan touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        debugPrint("\(node.name) clicked!")
        
        if let touch = touches.first {
            
            switch node.name {
                
            case "buttonCenterDn"?: buttonMap.a = true;updatingButtons.append(.a);break
            case "buttonCenterUp"?: buttonMap.x = true;updatingButtons.append(.x);break
            case "buttonRightDn"?:  buttonMap.b = true;updatingButtons.append(.b);break
            case "buttonRightUp"?:  buttonMap.y = true;updatingButtons.append(.y);break
            case "buttonLeftUp"?:   buttonMap.bumper_left = true;updatingButtons.append(.bumper_left);break
            case "buttonLeftDn"?:   buttonMap.bumper_right = true;updatingButtons.append(.bumper_right);break
            case "dPad"?:
                resetDpad()
                break
            case "leftStickArea"?:
                
                if let leftStick = (self.childNode(withName: "leftStick") as? AnalogJoystick) {
                    
                    leftStick.position = touch.location(in: self)
                    leftStick.umSKNode(leftStick.stick, touchesBegan: touches, withEvent: event)
                    leftStick.isHidden = false
                    
                    if touch.tapCount > 1 {
                        
                        buttonMap.trigger_left = Int16.max;
                        
                        updatingButtons.append(.trigger_left)
                    }
                    resetDpad()
                }
                break
            case "rightStickArea"?:
                
                if let rightStick = self.childNode(withName: "rightStick") as? AnalogJoystick {
                    
                    rightStick.position = touch.location(in: self)
                    rightStick.umSKNode(rightStick.stick, touchesBegan: touches, withEvent: event)
                    rightStick.isHidden = false
                    
                    resetDpad()
                }
                break
            default:
                break
            }
            
            sendGameControllerMessage()
        }
    }
    
    func umSKNode(_ node: UMSKNode, touchesMoved touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            
            switch node.name {
            
            case "dPad"?:
                node.position = touch.location(in: self)
                break
            case "leftStickArea"?:
                if let leftStick = (self.childNode(withName: "leftStick") as? AnalogJoystick) {
                    
                    leftStick.umSKNode(leftStick.stick, touchesMoved: touches, withEvent: event)
                }
                break
            case "rightStickArea"?:
                if let rightStick = self.childNode(withName: "rightStick") as? AnalogJoystick {
                    
                    rightStick.umSKNode(rightStick.stick, touchesMoved: touches, withEvent: event)
                }
                break
            default:
                break
            }
        }
    }
    
    func umSKNode(_ node: UMSKNode, touchesEnded touches: Set<UITouch>, withEvent event: UIEvent?){
        
        switch node.name {
            
        case "buttonCenterDn"?: buttonMap.a = false;updatingButtons.append(.a);break
        case "buttonCenterUp"?: buttonMap.x = false;updatingButtons.append(.x);break
        case "buttonRightDn"?:  buttonMap.b = false;updatingButtons.append(.b);break
        case "buttonRightUp"?:  buttonMap.y = false;updatingButtons.append(.y);break
        case "buttonLeftUp"?:   buttonMap.bumper_left = false;updatingButtons.append(.bumper_left);break
        case "buttonLeftDn"?:   buttonMap.bumper_right = false;updatingButtons.append(.bumper_right);break
        case "dPad"?:
            
            let pointer = node.touchPointer
            if abs(pointer.x) < 5 && abs(pointer.y) < 5 {
                
                AppDelegate.shared?.gameViewController?.showMenuScene(SKTransition.fade(withDuration: 0.1))
                return
            }
            else {
                buttonMap.dpad_left  = abs(pointer.x) > abs(pointer.y) && pointer.x < 0
                buttonMap.dpad_right = abs(pointer.x) > abs(pointer.y) && pointer.x > 0
                buttonMap.dpad_up    = abs(pointer.x) < abs(pointer.y) && pointer.y > 0
                buttonMap.dpad_down  = abs(pointer.x) < abs(pointer.y) && pointer.y < 0
                
                resetDpad()
                
                if buttonMap.dpad_left {
                    updatingButtons.append(.dpad_left)
                    resetingButtons.append(.dpad_left)
                }
                else if buttonMap.dpad_right {
                    updatingButtons.append(.dpad_right)
                    resetingButtons.append(.dpad_right)
                }
                else if buttonMap.dpad_up {
                    updatingButtons.append(.dpad_up)
                    resetingButtons.append(.dpad_up)
                }
                else if buttonMap.dpad_down {
                    updatingButtons.append(.dpad_down)
                    resetingButtons.append(.dpad_down)
                }
            }

            break
        case "leftStickArea"?:
            resetDpad()
            if let leftStick = (self.childNode(withName: "leftStick") as? AnalogJoystick) {
                
                leftStick.isHidden = true
                
                if buttonMap.trigger_left > 0 {
                    
                    buttonMap.trigger_left = 0;
                    
                    updatingButtons.append(.trigger_left)
                }
                leftStick.umSKNode(leftStick.stick, touchesEnded: touches, withEvent: event)
            }
            break
        case "rightStickArea"?:
            resetDpad()
            
            if let rightStick = self.childNode(withName: "rightStick") as? AnalogJoystick {
                
                rightStick.isHidden = true
                
                let pointer = node.touchPointer
                if abs(pointer.x) < 5 && abs(pointer.y) < 5  {
                    
                    buttonMap.trigger_right = Int16.max;
                    
                    updatingButtons.append(.trigger_right)
                    resetingButtons.append(.trigger_right)
                }
                rightStick.umSKNode(rightStick.stick, touchesEnded: touches, withEvent: event)
            }
            break
        default:
            break
        }
        sendGameControllerMessage()
    }
    
    func umSKNode(_ node: UMSKNode, touchesCancelled touches: Set<UITouch>?, withEvent event: UIEvent?) {
        
        switch node.name {
            
        case "dPad"?: resetDpad(); break
        case "leftStickArea"?:
            resetDpad()
            if let leftStick = (self.childNode(withName: "leftStick") as? AnalogJoystick) {
                
                leftStick.isHidden = true
                
                if buttonMap.trigger_left > 0 {
                    
                    buttonMap.trigger_left = 0;
                    updatingButtons.append(.trigger_left)
                }
                leftStick.umSKNode(leftStick.stick, touchesCancelled: touches, withEvent: event)
            }
            break
        case "rightStickArea"?:
            resetDpad()
            if let rightStick = self.childNode(withName: "rightStick") as? AnalogJoystick {
                
                rightStick.isHidden = true
                
                rightStick.umSKNode(rightStick.stick, touchesCancelled: touches, withEvent: event)
            }
            break
        default:
            break
        }
    }
    
    // MARK: AnalogJoystickDelegate
    func analogJoystick(_ joystick: AnalogJoystick, touchesBegan touches: Set<UITouch>, withEvent event: UIEvent?) {
    }
    
    func analogJoystick(_ joystick: AnalogJoystick, touchesMoved touches: Set<UITouch>, withEvent event: UIEvent?) {
    }
    
    func analogJoystick(_ joystick: AnalogJoystick, touchesEnded touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if joystick == self.childNode(withName: "leftStick") {
        }
        else if joystick == self.childNode(withName: "rightStick") {
        }
    }
    
    func analogJoystick(_ joystick: AnalogJoystick, touchesCancelled touches: Set<UITouch>?, withEvent event: UIEvent?) {
    }
    
    func analogJoystick(_ joystick: AnalogJoystick, dataChanged data: AnalogJoystickData) {
        
        if joystick == self.childNode(withName: "leftStick") {
            
            buttonMap.stick_left_x = Int16(data.velocity.x)
            buttonMap.stick_left_y = Int16(-data.velocity.y)

            updatingButtons.append(.stick_left)
        }
        else if joystick == self.childNode(withName: "rightStick") {
            
            buttonMap.stick_right_x = Int16(data.velocity.x)
            buttonMap.stick_right_y = Int16(-data.velocity.y)
            
            updatingButtons.append(.stick_right)
        }
        
        sendGameControllerMessage()
    }
    
    // MARK: UMVHIDDeviceDelegate
    
    func umVHIDDevice(_ device: UMVHIDDevice, stateDidChange state: [Int8]) {
        
        AppDelegate.shared?.sendUMMessage(UMMessage(data: Data(bytes: state, count: state.count), usageId: 0xf0))
    }
    
}

extension UIColor {
    
    static func random() -> UIColor {
        
        return UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1)
    }
}
