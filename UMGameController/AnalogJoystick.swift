//
//  AnalogStick.swift
//  Joystick
//
//  Created by Dmitriy Mitrophanskiy on 28.09.14.
//
//
import SpriteKit
import UIKit

// MARK: AnalogJoystickDelegate
protocol AnalogJoystickDelegate: class {
    
    func analogJoystick(_ joystick: AnalogJoystick, touchesBegan touches: Set<UITouch>, withEvent event: UIEvent?)
    
    func analogJoystick(_ joystick: AnalogJoystick, touchesMoved touches: Set<UITouch>, withEvent event: UIEvent?)
    
    func analogJoystick(_ joystick: AnalogJoystick, touchesEnded touches: Set<UITouch>, withEvent event: UIEvent?)
    
    func analogJoystick(_ joystick: AnalogJoystick, touchesCancelled touches: Set<UITouch>?, withEvent event: UIEvent?)
    
    func analogJoystick(_ joystick: AnalogJoystick, dataChanged data: AnalogJoystickData)
}

// MARK: AnalogJoystickData
struct AnalogJoystickData: CustomStringConvertible {
    
    var velocity    = CGPoint.zero
    var angular     = CGFloat(0)
    
    mutating func reset() {
        
        velocity    =   CGPoint.zero
        angular     =   CGFloat(0)
    }
    
    var isZero: Bool {
        
        return velocity == CGPoint.zero && angular == CGFloat(0)
    }
    
    var description: String {
        
        return "AnalogStickData(velocity: \(velocity), angular: \(angular))"
    }
}


//MARK: AnalogJoystick
class AnalogJoystick: SKNode, UMSKNodeDelegate {
    
    var substrate:          UMSKNode!
    var stick:              UMSKNode!
    
    var delegate: AnalogJoystickDelegate?
    
    fileprivate(set) var _data = AnalogJoystickData()
    
    var tracking: Bool {
        
        return !_data.isZero
    }
    
    var data: AnalogJoystickData{
        get {
            return _data
        }
    }
        
    var interacting: Bool {
        return stick.isIneracting
    }
    
    init(substrate: UMSKNode, stick: UMSKNode) {
        
        super.init()
        
        self.substrate  = substrate
        self.stick      = stick
        
        stick.zPosition     = substrate.zPosition + 1
        
        substrate.delegate = self
        stick.delegate = self
        
        addChild(substrate)
        addChild(stick)
    }
    
    convenience init(textures: (substrate: SKTexture?, stick: SKTexture?)? = nil, colors: (substrate: UIColor, stick: UIColor), sizes: (substrate: CGSize, stick: CGSize)) {
        
        let _textures   = textures ?? (substrate: nil, stick: nil)
        
        let substrate   = UMSKNode(texture: _textures.substrate, color: colors.substrate, size: sizes.substrate)
        let stick       = UMSKNode(texture: _textures.stick, color: colors.stick, size: sizes.stick)
        
        self.init(substrate: substrate, stick: stick)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    // CustomStringConvertible protocol
    override var description: String {
        
        return "AnalogJoystick(data: \(data), position: \(position))"
    }
    
    // private methods
    fileprivate func resetStick() {
        
        // Reset Stick Position
        let action = SKAction.move(to: CGPoint.zero, duration: TimeInterval(0.1))
        action.timingMode = SKActionTimingMode.easeOut
        stick.run(action)
   
        
        // Reset Joystick Data
        _data.reset()
        delegate?.analogJoystick(self, dataChanged: self.data)
    }
    
    // MARK: UMSKNodeDelegate
    func umSKNode(_ node: UMSKNode, touchesBegan touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if node == stick {
            stick.position = CGPoint.zero
            
            delegate?.analogJoystick(self, touchesBegan: touches, withEvent: event)
        }
    }
    
    func umSKNode(_ node: UMSKNode, touchesMoved touches: Set<UITouch>, withEvent event: UIEvent?){
        
        if node == stick {
            
            for touch: AnyObject in touches {
                
                let location = touch.location(in: self)
                
                let maxDistance = substrate.size.width / 2
                let realDistance = sqrt(pow(location.x, 2) + pow(location.y, 2))
                let needPosition = realDistance <= maxDistance ? CGPoint(x: location.x, y: location.y) : CGPoint(x: location.x / realDistance * maxDistance, y: location.y / realDistance * maxDistance)
                
                let needDistance = sqrt(pow(needPosition.x, 2) + pow(needPosition.y, 2))
                var velocity: CGPoint = CGPoint(x: needPosition.x / needDistance, y: needPosition.y / needDistance)
                
                // velocity ease out
//                velocity.x = velocity.x * CGFloat(Int16.max) * sqrt(sin((needDistance / maxDistance) * CGFloat(M_PI_2)))
//                velocity.y = velocity.y * CGFloat(Int16.max) * sqrt(sin((needDistance / maxDistance) * CGFloat(M_PI_2)))
                velocity.x = velocity.x * CGFloat(Int16.max) * (((needDistance / maxDistance)))
                velocity.y = velocity.y * CGFloat(Int16.max) * (((needDistance / maxDistance)))
                
                velocity.x = abs(velocity.x) > CGFloat(Int16.max) ? (velocity.x > 0 ? CGFloat(Int16.max) : CGFloat(Int16.min) ) : velocity.x
                
                velocity.y = abs(velocity.y) > CGFloat(Int16.max) ? (velocity.y > 0 ? CGFloat(Int16.max) : CGFloat(Int16.min) ) : velocity.y
                
                _data = AnalogJoystickData(velocity: velocity, angular: -atan2(velocity.x, velocity.y))
                delegate?.analogJoystick(self, dataChanged: data)
                
                stick.position = needPosition
            }
        }
        delegate?.analogJoystick(self, touchesMoved: touches, withEvent: event)
    }
    
    func umSKNode(_ node: UMSKNode, touchesEnded touches: Set<UITouch>, withEvent event: UIEvent?){
        
        if node == stick {
            resetStick()
            delegate?.analogJoystick(self, touchesEnded: touches, withEvent: event)
        }
    }
    
    func umSKNode(_ node: UMSKNode, touchesCancelled touches: Set<UITouch>?, withEvent event: UIEvent?) {
        
        if node == stick {
            resetStick()
            delegate?.analogJoystick(self, touchesCancelled: touches, withEvent: event)
        }
    }
    
}
