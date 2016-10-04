//
//  UMGameControllerButtonMap.swift
//  UMGameController
//
//  Created by fOrest on 7/9/16.
//  Copyright © 2016 fOrest. All rights reserved.
//

import Foundation
import CoreGraphics
import CoreBluetooth

enum UMGameControllerType {
    
    case umGameControllerTypeGeneral
    case umGameControllerTypeXbox
    
    var description: String {
        get {
            switch self {
            case .umGameControllerTypeGeneral:
                return "UMGameControllerTypeGeneral"
            case .umGameControllerTypeXbox:
                return "UMGameControllerTypeXbox"
            }
        }
    }
}

enum UMGameControllerButton: Int {
    
    case none               = 0x00000000
    case sync               = 0x00000001
    case dummy              = 0x00000002    // Always 0.
    case menu               = 0x00000004    // Not entirely sure what these are
    case view               = 0x00000008    // called on the new controller
    
    case a                  = 0x00000010
    case b                  = 0x00000020
    case x                  = 0x00000040
    case y                  = 0x00000080
    
    case dpad_up            = 0x00000100
    case dpad_down          = 0x00000200
    case dpad_left          = 0x00000400
    case dpad_right         = 0x00000800
    
    case bumper_left        = 0x00001000
    case bumper_right       = 0x00002000
    
    case stick_left_click   = 0x00004000
    case stick_right_click  = 0x00008000

    case stick_left_x       = 0x00010000
    case stick_left_y       = 0x00020000
    case stick_right_x      = 0x00040000
    case stick_right_y      = 0x00080000
    
    case trigger_left       = 0x00100000
    case trigger_right      = 0x02000000
    
    case stick_left         = 0x00400000
    case stick_right        = 0x00800000

    case home               = 0x40000000
    
//    var buttonIndex: Int {
//        
//        get {
//            switch self {
//            case a                      : return 0x00
//            case b                      : return 0x01
//            case x                      : return 0x02
//            case y                      : return 0x03
//            case bumper_left            : return 0x04
//            case bumper_right           : return 0x05
//            
//            case menu                   : return 0x08
//            case stick_left_click       : return 0x09
//            case stick_right_click      : return 0x0A
//            case dpad_up                : return 0x0B
//            case dpad_down              : return 0x0C
//            case dpad_left              : return 0x0D
//            case dpad_right             : return 0x0E
//            case view                   : return 0x0F
//            case home                   : return 0x10
//
//            default:
//                return 0xff
//            }
//        }
//    }
//    
//    var pointerIndex: Int {
//        get {
//            switch self {
//                
//            case stick_left_x           : return 0x00
//            case stick_left_y           : return 0x01
//            case trigger_left           : return 0x02
//            case stick_right_x          : return 0x03
//            case stick_right_y          : return 0x04
//            case trigger_right          : return 0x05
//            default:
//                return 0xff
//            }
//        }
//    }
    
    var UUID: CBUUID {
        get {
            
            return CBUUID(string: String(format: "384100A6-B372-40D0-B4F3-2B27%08x", self.rawValue))
        }
    }
    
    static var UUIDS: [CBUUID] {
        get {
            return [sync.UUID, dummy.UUID, menu.UUID, view.UUID, a.UUID, b.UUID, x.UUID, y.UUID, dpad_up.UUID, dpad_down.UUID, dpad_left.UUID, dpad_right.UUID, bumper_left.UUID, bumper_right.UUID, stick_left_click.UUID, stick_right_click.UUID, stick_left_x.UUID, stick_left_y.UUID, stick_right_x.UUID,stick_right_y.UUID, trigger_left.UUID, trigger_right.UUID, stick_left.UUID, stick_right.UUID]
        }
    }
}

struct UMGeneralButtonMap {
    
    var sync: Bool = false
    var dummy: Bool = false  // Always 0.
    var menu: Bool = false   // Not entirely sure what these are
    var view: Bool = false   // called on the new controller
    
    var a: Bool = false
    var b: Bool = false
    var x: Bool = false
    var y: Bool = false
    
    var dpad_up: Bool = false
    var dpad_down: Bool = false
    var dpad_left: Bool = false
    var dpad_right: Bool = false
    
    var bumper_left: Bool = false
    var bumper_right: Bool = false
    
    var stick_left_click: Bool = false
    var stick_right_click: Bool = false
    
    var home: Bool = false
    
    var stick_left_x: Int16 = 0
    var stick_left_y: Int16 = 0
    var stick_right_x: Int16 = 0
    var stick_right_y: Int16 = 0
    
    var trigger_left: Int16 = 0
    var trigger_right: Int16 = 0
    
    var buttonState: [Bool] {
        get {
            return Array<Bool>(arrayLiteral: a, b, x, y, bumper_left, bumper_right, stick_left_click, stick_right_click, menu, view, sync, dpad_up, dpad_down, dpad_left, dpad_right, dummy )
        }
    }
    
    var pointerState: [CGPoint] {
        get {

            return Array<CGPoint>(arrayLiteral: CGPoint(x: CGFloat(stick_left_x), y: CGFloat(stick_left_y)), CGPoint(x: CGFloat(trigger_left), y: CGFloat(stick_right_x)), CGPoint(x: CGFloat(stick_right_y), y: CGFloat(trigger_right)))
        }
    }
}

struct XboxButtonMap {
    
    var sync: Bool = false
    var dummy: Bool = false  // Always 0.
    var menu: Bool = false   // Not entirely sure what these are
    var view: Bool = false   // called on the new controller
    
    var a: Bool = false
    var b: Bool = false
    var x: Bool = false
    var y: Bool = false
    
    var dpad_up: Bool = false
    var dpad_down: Bool = false
    var dpad_left: Bool = false
    var dpad_right: Bool = false
    
    var bumper_left: Bool = false
    var bumper_right: Bool = false
    var stick_left_click: Bool = false
    var stick_right_click: Bool = false
    
    var trigger_left: UInt16 = 0
    var trigger_right: UInt16 = 0
    
    var stick_left_x: Int16 = 0
    var stick_left_y: Int16 = 0
    var stick_right_x: Int16 = 0
    var stick_right_y: Int16 = 0
    
    var home: Bool = false
}


