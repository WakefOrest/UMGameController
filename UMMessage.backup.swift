//
//  UMMessage.backup.swift
//  UMGameController
//
//  Created by fOrest on 8/20/16.
//  Copyright © 2016 fOrest. All rights reserved.
//


import Foundation

// @objc private protocol UMMessageDelegate_backup {
//    
//    optional func umMessageDidFinishParsingHeader(message: UMMessage)
//}
//
//
//
//
//private class UMMessage_backup: NSObject {
//    
//    private struct UMMessageHeader {
//        
//        /* default prefix and suffix
//         */
//        static let defPrefix: UInt8 = 0xCC
//        
//        static let defSuffix: UInt8 = 0xDD
//        
//        static let minimumHeaderLength: Int32 = Int32(1 + sizeof(Int32) + 1 )
//        
//        private var prefix: UInt8 = 0xCC
//        
//        private var length: Int32 = 0x000000000000
//        
//        private var suffix: UInt8 = 0xDD
//        
//        private var dictionary: NSMutableDictionary?
//        
//        private var data: NSMutableData?
//        
//        /* initialize an empty header
//         */
//        init() {
//            
//            // set a minimum length with nil dictionary an data
//            self.length = Int32(sizeofValue(self.prefix) + sizeofValue(self.length) + sizeofValue(self.suffix) )
//            
//            data = NSMutableData()
//            data!.appendBytes(&self.prefix, length: sizeofValue(self.prefix))
//            data!.appendBytes(&self.length, length: sizeofValue(self.length))
//            data!.appendBytes(&self.suffix, length: sizeofValue(self.suffix))
//        }
//        
//        init?(length: Int, contentType type: String, contendCoder coder: String, sequenceNO sequence: Int = 0,usageId usage: Int = 0, time: NSTimeInterval = 0.0) {
//            
//            dictionary = NSMutableDictionary(dictionaryLiteral:
//                
//                ("usage",           usage),
//                                             ("sequence",        sequence),
//                                             ("timeSince1970",   time),
//                                             ("contentType",     type),
//                                             ("contentCoder",    coder),
//                                             ("contentLength",   length)
//                
//            )
//            
//            var dictData: NSData?
//            do {
//                try dictData = (NSJSONSerialization.dataWithJSONObject(dictionary!, options: NSJSONWritingOptions(rawValue: 0)))
//            } catch let error as NSError {
//                
//                NSLog(error.description)
//                return nil
//            }
//            
//            self.length = Int32(sizeofValue(self.prefix) + sizeofValue(self.length) + sizeofValue(self.suffix) )
//            
//            // didn't work for Int == Int16
//            if dictData!.length > Int(Int32.max - self.length )
//            {
//                return nil
//            }
//            self.length = self.length + Int(dictData!.length)
//            
//            data = NSMutableData()
//            data!.appendBytes(&self.prefix, length: sizeofValue(self.prefix))
//            data!.appendBytes(&self.length, length: sizeofValue(self.length))
//            data!.appendData(dictData!)
//            data!.appendBytes(&self.suffix, length: sizeofValue(self.suffix))
//            
//            
//        }
//        
//        init?(buffer: UnsafePointer<Void>, length: Int) {
//            
//            
//            self.length = Int32(sizeofValue(self.prefix) + sizeofValue(self.length) + sizeofValue(self.suffix) )
//            
//            // didn't work for Int == Int16
//            if length > Int(Int32.max - self.length)
//            {
//                return nil
//            }
//            self.length = self.length + Int(length)
//            
//            let data = NSData(bytes: buffer, length: length)
//            
//            do{
//                try dictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? NSMutableDictionary
//            }
//            catch let error as NSError {
//                
//                error.description
//                
//                return nil
//            }
//        }
//        
//        func getLength() ->Int32 {
//            
//            return self.length
//        }
//        
//        func getData() ->NSData? {
//            
//            return self.data
//        }
//        
//        func getDictionary() ->NSMutableDictionary? {
//            
//            return self.dictionary
//        }
//    }
//    
//    
//    
//    var header: UMMessageHeader?
//    
//    /* use for message content(string) encoding
//     */
//    var encoding: NSStringEncoding?
//    
//    /* use for message object serialization
//     */
//    var coder: NSCoder?
//    
//    /* current data for reading or writting
//     */
//    var _data: NSMutableData?
//    
//    /* current data for reading or writting
//     */
//    var rangeOfHeader: NSRange?
//    
//    /* number of bytes of data that have been wtitten or read
//     */
//    var numberOfBytesTransferred: Int = 0
//    
//    /* message content data
//     */
//    var messageData: NSMutableData?
//    
//    /* number of bytes from the header
//     */
//    var totlalBytes: Int {
//        
//        get {
//            if let header = self.header {
//                
//                //let contentLength: Any = header.dictionary?["contentLength"] ?? 0
//                
//                return Int(header.getLength()) + (header.dictionary?["contentLength"] as? Int ?? 0)
//            }
//            return 0
//        }
//    }
//    
//    /* to show if the message is completely written or read
//     */
//    var isTransferredComplete: Bool {
//        
//        get {
//            return (totlalBytes != 0 && (numberOfBytesTransferred - rangeOfHeader!.location) == totlalBytes)
//        }
//    }
//    
//    /* initialize message for reading from inputSream
//     */
//    override init() {
//        
//        super.init()
//        
//        _data = NSMutableData()
//        
//        rangeOfHeader = NSRange()
//        rangeOfHeader!.length = Int(UMMessageHeader.minimumHeaderLength)
//    }
//    
//    /**
//     * initialize message for writting to outputStream
//     */
//    init(data: NSMutableData, messageHeader header: UMMessageHeader) {
//        
//        self.header = header
//        self.messageData = data
//        self._data = NSMutableData()
//        self._data!.appendData(header.getData()!)
//        self._data!.appendData(data)
//        
//        rangeOfHeader = NSRange()
//        rangeOfHeader!.length = Int(header.getLength())
//    }
//    /**
//     * initialize message for writting to outputStream
//     */
//    init?(data: NSMutableData?, messageHeaderDictionary dictionary: NSDictionary?) {
//        
//        if data != nil {
//            
//            if let _dictionary = dictionary {
//                
//                let usage:         Int         = _dictionary["usage"]           as? Int     ?? 0
//                let time:          Double      = _dictionary["timeSince1970"]   as? Double  ?? 0
//                let sequence:      Int         = _dictionary["sequnce"]         as? Int     ?? 0
//                let contentType:   String      = _dictionary["contentType"]     as? String  ?? ""
//                let contentCoder:  String      = _dictionary["contentCoder"]    as? String  ?? ""
//                let contentLength: Int         = _dictionary["contentLength"]   as? Int     ?? 0
//                
//                header = UMMessageHeader(length: contentLength, contentType: contentType, contendCoder: contentCoder, sequenceNO: sequence, usageId: usage, time: time)
//            }
//            if header == nil {
//                return nil
//            }
//            
//            self.messageData = data
//            self._data = NSMutableData()
//            self._data!.appendData(header!.getData()!)
//            self._data!.appendData(data!)
//            
//            rangeOfHeader = NSRange()
//            rangeOfHeader!.length = Int(header!.getLength())
//            
//        } else {
//            
//            // creat an empty message only with headerd data
//            self._data = NSMutableData()
//            self.header = UMMessageHeader()
//            self._data!.appendData(header!.getData()!)
//        }
//    }
//    
//    func ParseHeader() ->Bool {
//        
//        var location = rangeOfHeader!.location
//        
//        /* too short for parsing header
//         */
//        if _data!.length - location < Int(UMMessageHeader.minimumHeaderLength) {
//            
//            return false
//        }
//        
//        var dataArray: [UInt8] = [UInt8](count: _data!.length, repeatedValue: 0)
//        _data?.getBytes(&dataArray, length: _data!.length)
//        
//        if dataArray[location] == UMMessageHeader.defPrefix {
//            
//            location = location + sizeof(UInt8)
//            
//            // get header length
//            var length: Int32 = 0
//            memcpy(&length, &dataArray + location, sizeof(Int32))
//            
//            // parsed length is larger than the minimum length
//            if (length > UMMessageHeader.minimumHeaderLength) {
//                
//                // set location to the suffix
//                location = location + sizeof(Int32) + Int(length - UMMessageHeader.minimumHeaderLength)
//                
//                if (location > dataArray.count - 1) {
//                    
//                    return false
//                }
//                
//                if dataArray[location] == UMMessageHeader.defSuffix {
//                    
//                    // set location to the dictionary
//                    location = location - Int(length - UMMessageHeader.minimumHeaderLength)
//                    if let header = UMMessageHeader(buffer: &dataArray + location, length: Int(length - UMMessageHeader.minimumHeaderLength)) {
//                        
//                        self.header = header
//                        return true
//                    }
//                }
//            }
//            else if (length == UMMessageHeader.minimumHeaderLength) {
//                // this means an empty header for an empty message
//                self.header = UMMessageHeader()
//                return true
//            }
//        }
//        // continue to read the next byte
//        rangeOfHeader!.location = rangeOfHeader!.location + 1
//        
//        return false
//    }
//    
//    /**
//     Writes the as many bytes to the output stream as it would accept
//     @param stream The output stream to write to
//     @returns The number of bytes written. -1 means that there was an error.
//     */
//    func writeToOutputStream(stream: NSOutputStream) ->Int {
//        
//        // how many bytes there are still untransmitted
//        let maxLength: Int = _data!.length - numberOfBytesTransferred;
//        
//        if maxLength <= 0 {
//            return 0
//        }
//        
//        // continue wiritting at current positon
//        let actuallyWritten: Int = stream.write(UnsafePointer<UInt8>(_data!.bytes) + numberOfBytesTransferred, maxLength: maxLength)
//        
//        if (actuallyWritten>0)
//        {
//            numberOfBytesTransferred += actuallyWritten;
//        }
//        
//        return actuallyWritten;
//    }
//    
//    /**
//     Reads from the input stream and initializes the header and payload as the necessary data becomes available.
//     @param stream The input stream to read from
//     @returns The number of bytes read. -1 means that there was an error.
//     */
//    func readFromInputStream(stream: NSInputStream) ->Int{
//        
//        var maxLength      = 1024 * 8
//        var buffer         = Array<UInt8>(count: maxLength, repeatedValue: 0)
//        
//        var isHeaderParsed: Bool = false
//        
//        if totlalBytes > 0 {
//            
//            maxLength = min(buffer.count, totlalBytes - Int(header!.getLength()))
//            isHeaderParsed = true
//        } else {
//            
//            maxLength = 1
//            isHeaderParsed = false
//        }
//        
//        let actuallyRead: Int = stream.read(&buffer, maxLength: maxLength)
//        
//        if (actuallyRead > 0) {
//            
//            _data!.appendBytes(&buffer, length: actuallyRead)
//            
//            if !isHeaderParsed {
//                if ParseHeader() {
//                    
//                    debugPrint("successfully parsed header")
//                }
//            } else {
//                if messageData == nil {
//                    messageData = NSMutableData()
//                }
//                messageData!.appendBytes(&buffer, length: actuallyRead)
//            }
//            
//            numberOfBytesTransferred += actuallyRead;
//        }
//        
//        return actuallyRead;
//    }
//}

