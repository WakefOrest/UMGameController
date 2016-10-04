//
//  UMSKNode.swift
//  UMGameController
//
//  Created by fOrest on 7/13/16.
//  Copyright © 2016 fOrest. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit
import AVFoundation
import AudioToolbox

protocol UMSKNodeDelegate: class {
     
    func umSKNode(_ node: UMSKNode, touchesBegan touches: Set<UITouch>, withEvent event: UIEvent?)
    
    func umSKNode(_ node: UMSKNode, touchesMoved touches: Set<UITouch>, withEvent event: UIEvent?)
    
    func umSKNode(_ node: UMSKNode, touchesEnded touches: Set<UITouch>, withEvent event: UIEvent?)
    
    func umSKNode(_ node: UMSKNode, touchesCancelled touches: Set<UITouch>?, withEvent event: UIEvent?)
}

class UMSKNode: SKSpriteNode {

    var delegate: UMSKNodeDelegate?
    
    var isValidTouchAreaInNode: ((_ node: SKNode?, _ touches: Set<UITouch>) ->Bool)?
    
    var renderTexture: (() ->Void)?
    
    var isValidBeganArea: Bool = false
    
    var beganPosition: CGPoint = CGPoint.zero
    
    var touchPointer: CGPoint = CGPoint.zero
    
    var isIneracting: Bool = false
    
    var soundId: SystemSoundID = 0
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        
        super.init(texture: texture, color: color, size: size)
        
        isUserInteractionEnabled = true

        let audioUrl = URL(fileURLWithPath: "/System/Library/Audio/UISounds/Tock.caf")
        AudioServicesCreateSystemSoundID(audioUrl as CFURL, &soundId)
        
        isValidTouchAreaInNode = { (node, touches) in
            
            if node == nil {
                return false
            }
            
            if let touch = touches.first {
                
                // the defult touch area is oval
                let radiusA = self.frame.width / 2
                let radiusB = self.frame.height / 2
                
                let distanceSquared = pow(touch.location(in: node!).x - self.position.x, 2) / pow(radiusA,  2) + pow(touch.location(in: node!).y - self.position.y, 2) / pow(radiusB, 2)
                
                // inside oval
                if (distanceSquared <= 1) {
                    return true
                }
            }
            return false
        }
        
        // default texture render
        renderTexture = { _ in
            
            let scale   = UIScreen.main.scale
            // MARK: Begin Render Context
            UIGraphicsBeginImageContextWithOptions(self.size, false, scale)
            
            self.color.set()
            let path = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: self.size))
            path.addClip()
            path.fill()
            
            // Get the Final image Rendered
            let image = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            // MARK: End Render Context

            self.texture = SKTexture(image: image!)
        }
        
        if self.texture == nil {
            
            self.renderTexture!()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //
        //debugPrint("UMSKNode touchesBegan touches: \(touches)")
        if isValidTouchAreaInNode != nil && !isValidTouchAreaInNode!(parent, touches) {
            
            parent?.touchesBegan(touches, with: event);return
        }
        if soundId > 0 {
            AudioServicesPlaySystemSound(soundId)
        }
        beganPosition = (touches.first?.location(in: parent!))!
        touchPointer = CGPoint.zero
        isIneracting = true
        isValidBeganArea = true
        delegate?.umSKNode(self, touchesBegan: touches, withEvent: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //
        if !isValidBeganArea {
            parent?.touchesMoved(touches, with: event);return
        }
        
        let position = (touches.first?.location(in: parent!))!
        touchPointer = CGPoint(x: position.x - beganPosition.x, y: position.y - beganPosition.y)
        delegate?.umSKNode(self, touchesMoved: touches, withEvent: event)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //
        if !isValidBeganArea {
            parent?.touchesEnded(touches, with: event);return
        }
        let position = (touches.first?.location(in: parent!))!
        touchPointer = CGPoint(x: position.x - beganPosition.x, y: position.y - beganPosition.y)
        isIneracting = false
        delegate?.umSKNode(self, touchesEnded: touches, withEvent: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        //
        if !isValidBeganArea {
            parent?.touchesCancelled(touches, with: event);return
        }
        isIneracting = false
        delegate?.umSKNode(self, touchesCancelled: touches, withEvent: event)
    }
}
