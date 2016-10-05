//: Playground - noun: a place where people can play

//import Cocoa
import UIKit
import Foundation

var str = "Hello, playground"

//struct UMMessageHeader {
//    
//    /* default prefix and suffix
//     */
//    static let defPrefix: UInt8 = 0xCC
//    
//    static let defSuffix: UInt8 = 0xDD
//    
//    private var prefix:     UInt8 = UMMessageHeader.defPrefix
//    
//    var usage:              UInt8 = 0x00
//    
//    var sequence:           UInt8 = 0x00
//    
//    var timestamp: TimeInterval = NSDate().timeIntervalSince1970  // message initial time since 1970
//    
//    var length:             Int32 = 0x00000000         // data length
//    
//    var checkCode:          UInt8 = 0x00
//    
//    private var suffix:     UInt8 = UMMessageHeader.defSuffix
//    
//}
//
//var header = UMMessageHeader()
//header.usage = 0x55
//header.sequence = 0x66
//var header1 = UMMessageHeader()
//MemoryLayout.size(ofValue: header)
//MemoryLayout<UMMessageHeader>.size
//
//var data1 = Data.init(bytes: &header, count: MemoryLayout<UMMessageHeader>.size)
//var data2 = Data.init(buffer: UnsafeBufferPointer<UMMessageHeader>.init(start: &header1, count: 1))
//
//var header2 = UMMessageHeader()
//data1.copyBytes(to: UnsafeMutableBufferPointer<UMMessageHeader>.init(start: &header2, count: 1), from: Range.init(uncheckedBounds: (lower: 0, upper: MemoryLayout.size(ofValue: header2))))
//
//data1.append(data2)
//
//data1.withUnsafeBytes { (bytes) -> Void in
//    
//    memcpy(&header2, bytes + 22, MemoryLayout<UMMessageHeader>.size)
//}



