//
//  MenuScene.swift
//  UMGameController
//
//  Created by fOrest on 7/17/16.
//  Copyright © 2016 fOrest. All rights reserved.
//

import UIKit
import SpriteKit
import CoreMotion

class MenuScene: SKScene, UMSKNodeDelegate {
    
    var backgroundNode: SKSpriteNode?

    var initialized: Bool = false
    
    var menuButtons: Array<UMSKNode> = Array<UMSKNode>()
    
    var touchCount: Int = 0
    
    func setBackground(_ node: SKSpriteNode) {
        
        if self.backgroundNode == nil {
            
            self.backgroundNode = node
            self.backgroundNode!.zPosition = -10
            self.backgroundNode?.size = self.size
            self.backgroundNode?.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            let alphaMask = SKSpriteNode(color: UIColor.black, size: self.size)
            alphaMask.alpha = 0.7
            alphaMask.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            alphaMask.zPosition = backgroundNode!.zPosition + 1
            self.addChild(self.backgroundNode!)
            self.addChild(alphaMask)
        }
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        if !initialized {
            
            initialized = true
            
            let menuButton: UMSKNode = UMSKNode(texture: nil, color: UIColor.red, size: CGSize(width: self.frame.width / 6, height: self.frame.width / 6))
            menuButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            menuButton.name = "menu"
            let label = SKLabelNode(fontNamed:"Chalkduster")
            label.text = menuButton.name
            label.fontSize = 35
            label.zPosition = menuButton.zPosition + 0.5
            menuButton.addChild(label)
            menuButton.delegate = self
            self.addChild(menuButton)
            
            menuButtons = Array<UMSKNode>(arrayLiteral:
                createButton("cali"),
                createButton("Siri"),
                createButton("view"),
                createButton("exit"),
                createButton("mode"),
                createButton("search")
            )

        }else {
            
            for node in menuButtons {
                
                if self.children.contains(node) {
                    node.removeFromParent()
                }
            }
        }
        
        runPresentAction(0.1)
        
        self.touchCount = 0
        self.alpha = 1.0
        view.isMultipleTouchEnabled = true
    }
    
    func createButton(_ name: String) ->UMSKNode {
        
        let umNode: UMSKNode = UMSKNode(texture: nil, color: UIColor.orange, size: CGSize(width: self.frame.width / 7, height: self.frame.width / 7))
        umNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        umNode.name = name
        let label = SKLabelNode(fontNamed:"Chalkduster")
        label.text = name
        label.fontSize = 32
        label.zPosition = umNode.zPosition + 0.5
        umNode.addChild(label)
        umNode.delegate = self
        return umNode
    }
    
    func runPresentAction(_ duration: TimeInterval) {
        
        var index  = 0
        let radius = CGFloat(100)
        let radianInc = (M_PI * 2) / (menuButtons.count >= 4 ? Double(menuButtons.count) : 7)
        
        for node in menuButtons {
            
            let radian = Double(index) * radianInc + M_PI_2 - (Double(menuButtons.count - 1) * radianInc / 2); index += 1
            //radian = radian >= 2 *  M_PI ? radian - 2 * M_PI : radian
            
            // reset node position to center of scene
            node.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            
            var circleCenter = CGPoint.zero
            circleCenter.x = CGFloat(cos(radian)) * radius + node.position.x
            circleCenter.y = CGFloat(sin(radian)) * radius + node.position.y
            
            let actionRotate = SKAction.customAction(withDuration: duration) { node, elapsed in
                
                let radian1 = (Double(elapsed) / duration) * M_PI // logical radian
                let radian2 = radian - M_PI                        // relation between logical and real coordinates
                node.position.x = CGFloat(cos(radian1 + radian2)) * radius + circleCenter.x
                node.position.y = CGFloat(sin(radian1 + radian2)) * radius + circleCenter.y
            }
            node.xScale = 0.2;node.yScale = 0.2;
            node.alpha = 0.5
            let actionScale = SKAction.scale(to: 1.0, duration: duration)
            let actionAlpha = SKAction.fadeAlpha(to: 1, duration: duration)
            actionRotate.timingMode = .easeOut
            actionScale.timingMode = .easeInEaseOut
            actionAlpha.timingMode = .easeOut
            node.run(actionRotate)
            node.run(actionAlpha)
            node.run(actionScale)
            self.addChild(node)
        }
    }
    
    func runDisappearAction(_ duration: TimeInterval) {
        
        var index  = 0
        let radius = CGFloat(100)
        let radianInc = (M_PI * 2) / (menuButtons.count >= 4 ? Double(menuButtons.count) : 7)
        
        for node in menuButtons {
            
            let radian = Double(index) * radianInc + M_PI_2 - (Double(menuButtons.count - 1) * radianInc / 2); index += 1
            //radian = radian >= 2 *  M_PI ? radian - 2 * M_PI : radian
            
            var circleCenter = CGPoint.zero
            circleCenter.x = CGFloat(cos(radian)) * radius + self.frame.midX
            circleCenter.y = CGFloat(sin(radian)) * radius + self.frame.midY
            
            let actionRotate = SKAction.customAction(withDuration: duration) { node, elapsed in
                
                let radian1 = M_PI - (Double(elapsed) / duration) * M_PI // logical radian
                let radian2 = radian - M_PI                        // relation between logical and real coordinates
                node.position.x = CGFloat(cos(radian1 + radian2)) * radius + circleCenter.x
                node.position.y = CGFloat(sin(radian1 + radian2)) * radius + circleCenter.y
            }

            let actionScale = SKAction.scale(to: 0.5, duration: duration)
            let actionAlpha = SKAction.fadeAlpha(to: 0.2, duration: duration)
            actionRotate.timingMode = .easeOut
            actionScale.timingMode = .easeInEaseOut
            actionAlpha.timingMode = .easeOut
            node.run(actionRotate)
            node.run(actionAlpha)
            node.run(actionScale)
        }
    }
    
    func showGameScene() {
        
        runDisappearAction(0.2)
        self.run(SKAction.fadeAlpha(to: 0.2, duration: 0.2), completion: {
            
            AppDelegate.shared?.gameViewController?.showGameScene(nil)
        })
    }
    
    func deviceMotionHandler(_ deviceMotion: CMDeviceMotion?, error: NSError?) {
        //
    }
    
    func umSKNode(_ node: UMSKNode, touchesBegan touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        switch node.name {
            
        case "menu"?:
            AppDelegate.shared?.gameViewController?.gameScene?.updatingButtons.append(.menu)
            AppDelegate.shared?.gameViewController?.gameScene?.setButtonValue(UMGameControllerButton.menu, value: true)
            break
        case "view"?:
            AppDelegate.shared?.gameViewController?.gameScene?.updatingButtons.append(.view)
            AppDelegate.shared?.gameViewController?.gameScene?.setButtonValue(UMGameControllerButton.view, value: true)
            break
        default:break
        }
    }
    
    func umSKNode(_ node: UMSKNode, touchesEnded touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        switch node.name {
            
        case "menu"?:
            AppDelegate.shared?.gameViewController?.gameScene?.updatingButtons.append(.menu)
            AppDelegate.shared?.gameViewController?.gameScene?.setButtonValue(UMGameControllerButton.menu, value: false)
            showGameScene()
            break
        case "view"?:
            AppDelegate.shared?.gameViewController?.gameScene?.updatingButtons.append(.view)
            AppDelegate.shared?.gameViewController?.gameScene?.setButtonValue(UMGameControllerButton.view, value: false)
            showGameScene()
            break
        case "mode"?:
            AppDelegate.shared?.connMode = AppDelegate.shared?.connMode == 0x00 ? 0x01 : 0x00
            showGameScene()
            break
        case "exit"?:
            showGameScene()
            break
        default:break
        }
    }
    
    func umSKNode(_ node: UMSKNode, touchesMoved touches: Set<UITouch>, withEvent event: UIEvent?) {
        //
    }
    
    func umSKNode(_ node: UMSKNode, touchesCancelled touches: Set<UITouch>?, withEvent event: UIEvent?) {
        //
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.touchCount += 1
        if self.touchCount == 2 {
            
            // calibrate motion sensors
            AppDelegate.shared?.calibrateDevice()
            showGameScene()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch Ended */
        
        self.touchCount -= 1
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchCount -= 1
    }
    
}
