//
//  UMGameControllerMessage.swift
//  UMGameController
//
//  Created by fOrest on 6/13/16.
//  Copyright © 2016 fOrest. All rights reserved.
//

import Foundation

@objc protocol UMMessageDelegate {
    
    @objc optional func umMessageDidFinishParsingHeader(_ message: UMMessage)
}

struct UMMessageHeader {

    /* default prefix and suffix
     */
    static let defPrefix: UInt8 = 0xCC
    
    static let defSuffix: UInt8 = 0xDD
    
    fileprivate var prefix:     UInt8 = UMMessageHeader.defPrefix
    
    var usage:              UInt8 = 0x00
    
    //var sequence:           UInt8 = 0x00
    
    //var timestamp: NSTimeInterval = NSDate().timeIntervalSince1970  // message initial time since 1970
    
    var length:             Int32 = 0x00000000         // data length
    
    var checkCode:          UInt8 = 0x00
    
    fileprivate var suffix:     UInt8 = UMMessageHeader.defSuffix
    
//    var data: NSData {
//        mutating get {
//            
//            let data = NSMutableData()
//            data.appendBytes(&prefix,       length: sizeofValue(prefix))
//            data.appendBytes(&usage,        length: sizeofValue(usage))
//            data.appendBytes(&sequence,     length: sizeofValue(sequence))
//            data.appendBytes(&timestamp,    length: sizeofValue(timestamp))
//            data.appendBytes(&length,       length: sizeofValue(length))
//            data.appendBytes(&checkCode,    length: sizeofValue(prefix))
//            data.appendBytes(&suffix,       length: sizeofValue(suffix))
//            
//            return data
//        }
//    }
}


open class UMMessage: NSObject {
    
    /* current message header
     */
    var header: UMMessageHeader?
    
    /* range of header in rawData
     */
    var rangeOfHeader: NSRange?
    
    /* use for message content(string) encoding
     */
    var encoding: String.Encoding?
    
    /* use for message object serialization
     */
    var coder: NSCoder?
    
    /* data for reading or writting
     */
    var rawData: Data?
    
    /* message content data
     */
    var contentData: Data?
    
    /* number of bytes of data that have been wtitten or read
     */
    var numberOfBytesTransferred: Int = 0
    
    /* number of bytes from the header
     */
    var totlalBytes: Int {
        
        get {
            if let header = self.header {
                
                return Int(MemoryLayout<UMMessageHeader>.size + header.length)
            }
            return 0
        }
    }
    
    /* to show if the message is completely written or read
     */
    var isTransferredComplete: Bool {
        
        get {
            return (totlalBytes != 0 && (numberOfBytesTransferred - rangeOfHeader!.location) == totlalBytes)
        }
    }
    
    /* initialize message for reading from inputSream
     */
    override init() {
        
        super.init()
        
        rawData = Data()
        
        rangeOfHeader = NSRange(location: 0, length: MemoryLayout<UMMessageHeader>.size)
    }
    
    /**
     * initialize message for writting to outputStream
     */
    init(data: Data, usageId usage: UInt8) {
        
        self.header = UMMessageHeader()
        self.contentData = data
        
        self.header?.usage = usage
        self.header?.length = Int32((contentData?.count)!)
        
        rawData = Data(bytes: &self.header, count: MemoryLayout<UMMessageHeader>.size)
        
        self.rawData!.append(self.contentData!)
        
        // TODO: generate check code
        
        rangeOfHeader = NSRange(location: 0, length: MemoryLayout<UMMessageHeader>.size)
    }
    
    func ParseHeader() ->Bool {
        
        /* too short for parsing header
         */
        if rawData!.count - rangeOfHeader!.location < rangeOfHeader!.length {
            
            return false
        }
        
        var header = UMMessageHeader()
        if rangeOfHeader!.length != rawData!.copyBytes(to: UnsafeMutableBufferPointer.init(start: &header, count: 1), from: rangeOfHeader!.toRange()) {
            
            return false
        }
        
        //verify header
        if header.prefix == UMMessageHeader.defPrefix && header.suffix == UMMessageHeader.defSuffix {
            
            self.header = header
            
            return true
        }
    
        // continue to read the next byte
        rangeOfHeader!.location = rangeOfHeader!.location + 1
        
        return false
    }
    
    /* verify recieved message by checking check code
     */
    func verifyMessage() ->Bool{
        
        return true
    }
    
    /**
     Writes the as many bytes to the output stream as it would accept
     @param stream The output stream to write to
     @returns The number of bytes written. -1 means that there was an error.
     */
    func writeToOutputStream(_ stream: OutputStream) ->Int {
        
        // how many bytes there are still untransmitted
        let maxLength: Int = rawData!.count - numberOfBytesTransferred;
        
        if maxLength <= 0 {
            return 0
        }
        
        // continue wiritting at current positon
        let actuallyWritten: Int = rawData!.withUnsafeBytes { (bytes) -> Int in
            
            return stream.write(bytes + numberOfBytesTransferred, maxLength: maxLength)
        }
        
        if (actuallyWritten > 0)
        {
            numberOfBytesTransferred += actuallyWritten;
        }
        
        return actuallyWritten;
    }
    
    /**
     Reads from the input stream and initializes the header and payload as the necessary data becomes available.
     @param stream The input stream to read from
     @returns The number of bytes read. -1 means that there was an error.
     */
    func readFromInputStream(_ stream: InputStream) ->Int{
        
        var maxLength      = 1024 * 1
        
        if totlalBytes > 0 {
            
            maxLength = min(maxLength, totlalBytes - MemoryLayout<UMMessageHeader>.size)
            
        } else {
            
            maxLength = 1
        }
        
        var buffer         = Array<UInt8>(repeating: 0, count: maxLength)
        
        let actuallyRead: Int = stream.read(&buffer, maxLength: maxLength)
        
        if (actuallyRead > 0) {
            
            rawData!.append(&buffer, count: actuallyRead)
            
            if totlalBytes == 0 {
                
                if ParseHeader() {
                    
                    debugPrint("successfully parsed header")
                }
            }
            else {
                
                if contentData != nil {
                    
                    contentData!.append(&buffer, count: actuallyRead)
                }
                else {
                    
                    contentData = Data(bytes: &buffer, count: actuallyRead)
                }
            }

            numberOfBytesTransferred += actuallyRead;
        }
        
        return actuallyRead;
    }
}
