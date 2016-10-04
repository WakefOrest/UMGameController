//
//  UMBonjourConnection.swift
//  UMGameController
//
//  Created by fOrest on 6/17/16.
//  Copyright © 2016 fOrest. All rights reserved.
//

import Foundation

protocol UMbonjourConnectionDelegate: class {
    
    /**
     Called when the connection did send a complete UMMessage object
     @param connection The connection
     @param didSendMessage The message object that sent
     */
    func bonjourConnection(_ connection: UMBonjourConnection, didSendMessage message: UMMessage)
    /**
     Called when the connection did received a complete UMMessage object
     @param connection The connection
     @param didReceiveMessage The message object that received
     */
    func bonjourConnection(_ connection: UMBonjourConnection, didReceiveMessage message: UMMessage)
    /**
     Called when the connection was successfully opend.
     @param connection The connection
     */
    func bonjourConnectionDidOpen(_ connection: UMBonjourConnection)
    
    /**
     Called when the connection was closed
     @param connection The connection
     */
    func bonjourConnectionDidClose(_ connection: UMBonjourConnection)
}


func synchronized(_ lock: AnyObject, closure: () -> ()) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}

class UMBonjourConnection: NSObject, StreamDelegate {
    
    var name: String?
    
    var uuid: UUID?
    
    var lastActiveTime: TimeInterval      // last active time since 1970
    
    var inputStream: InputStream
    
    var outputStream: OutputStream
    
    var outputQueue: [UMMessage] = [UMMessage]()
    
    var receivingMessage: UMMessage?
    
    var delegate: UMbonjourConnectionDelegate?
    
    fileprivate var closed: Bool = true
    
    var isOpen: Bool {
        get {
            return (inputStream.streamStatus == Stream.Status.open && outputStream.streamStatus == Stream.Status.open)
        }
    }
    
    required init(inputStream input: InputStream, outputStream output: OutputStream) {

        self.inputStream  = input
        self.outputStream = output
        
        lastActiveTime = Date().timeIntervalSince1970
        
        super.init()
    }
    
    convenience init?(netService: NetService) {
        
        var input: InputStream?
        var output: OutputStream?
        
        if netService.getInputStream(&input, outputStream: &output) {
    
            self.init(inputStream: input!, outputStream: output!)
        }else {
            
            return nil
        }
    }
    
    deinit {
        
        close()
    }
    
    
    func openWithTimeout(_ timeout: TimeInterval) ->Bool {
        
        inputStream.delegate = self
        inputStream.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        inputStream.open()
        
        outputStream.delegate = self
        outputStream.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        outputStream.open()
        
        
        let delay: TimeInterval = timeout;
        let popTime: DispatchTime = DispatchTime.now() + Double((Int64)(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC);
        DispatchQueue.main.asyncAfter(deadline: popTime) { [weak self] () -> () in
            
            // No connection after timeout, closing.
            if let _self = self {
                if (!_self.isOpen) {
                    _self.close()
                }
            }
        }
        
        return true
    }
    
    @discardableResult func open() ->Bool {
        
        if openWithTimeout(1.0 as TimeInterval) {
            
            closed = false
            return true
        }
        return false
    }
    
    
    func close() {
        
        if closed {
            
            return
        }
        /* close streams
         */
        inputStream.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        inputStream.close()
        
        outputStream.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        outputStream.close()
        
        closed = true
        delegate?.bonjourConnectionDidClose(self)
    }

    @discardableResult func sendMessage(_ message: UMMessage) ->Bool {
        
        if !isOpen {
            
            NSLog("connection is not opened!")
            return false
        }
        
//        if outputQueue.count == 0 && outputStream.hasSpaceAvailable {
//            
//            if outputStream.write(bytes, maxLength: bytes.count) < bytes.count {
//                return false
//            }
//        }
        
        outputQueue.append(message)
        
        OperationQueue.current!.addOperation { [weak self] () -> () in
            
            self?.startSend()
        }
        
        return true
    }
    
    func startSend() {
        
        if outputQueue.count == 0 || !outputStream.hasSpaceAvailable {
            
            return
        }
        
        let message: UMMessage = outputQueue[0]
        
        let writtenBytes: Int = message.writeToOutputStream(self.outputStream)
	
        if writtenBytes > 0 {
            
            
            // If we didn't write all the bytes we'll continue writing them in response to the next
            // has-space-available event.
            if message.isTransferredComplete {
                
                outputQueue.remove(at: 0)
                
                delegate?.bonjourConnection(self, didSendMessage: message)
            }
        }
        else {
            // A non-positive result from -write:maxLength: indicates a failure of some form; in this
            // simple app we respond by simply closing down our connection.
            self.close()
        }
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    //  MARK: nsstream delegate
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        
        switch eventCode {
            
        case Stream.Event():
            // TODO:
            break
        case Stream.Event.openCompleted:
            
            if self.isOpen {
                // call delegate
                delegate?.bonjourConnectionDidOpen(self)
            }
            break
        case Stream.Event.errorOccurred:
            // close current connection
            if (aStream == inputStream || aStream == outputStream) {
                
                self.close()
            }
            break
        case Stream.Event.endEncountered:
            // close current connection
            if (aStream == inputStream || aStream == outputStream) {
                self.close()
            }
            break
        case Stream.Event.hasSpaceAvailable:
            // output data in output queue
            startSend()
            break
        case Stream.Event.hasBytesAvailable:
            
            guard aStream == self.inputStream else {
                
                return NSLog("input stream mismatch!")
            }
            
            // record current timestamp
            self.lastActiveTime = Date().timeIntervalSince1970
            
            if receivingMessage == nil {
                // start reading a new message
                receivingMessage = UMMessage()
            }
            
            // continue reading
            let actuallyRead: Int = receivingMessage!.readFromInputStream(self.inputStream)
            
            if actuallyRead < 0 {
                
                // error occurred
                self.close()
                break
            }
            
            if receivingMessage!.isTransferredComplete {
                
                if receivingMessage!.verifyMessage() {
                    
                    self.delegate?.bonjourConnection(self, didReceiveMessage: receivingMessage!)
                }
                // we're done with this message
                receivingMessage = nil
            }
            
            break
            
        default:
            break
        }
    }
}
