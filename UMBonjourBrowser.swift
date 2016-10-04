//
//  UMGameControllerClient.swift
//  UMGameController
//
//  Created by fOrest on 6/13/16.
//  Copyright © 2016 fOrest. All rights reserved.
//

import Foundation

#if os(OSX)
    private let deviceName = Host.current().localizedName!
#else
    import UIKit
    private let deviceName = UIDevice.current.name
#endif


protocol UMBonjourBrowserDelegate {
    
    func umBonjourBrowser(_ browser: UMBonjourBrowser, didCreateConnection connection: UMBonjourConnection)
}

class UMBonjourBrowser: NSObject, NetServiceBrowserDelegate {
    
    let kUMServiceType = "_umservice._tcp"
    
    var browser: NetServiceBrowser?
    
    var delegate: UMBonjourBrowserDelegate?
    
    override init() {
        super.init()
        
        browser = NetServiceBrowser()
        
        if let browser = self.browser {
            browser.includesPeerToPeer = true
            browser.delegate = self
            
            //browser.searchForBrowsableDomains()
            //browser.searchForServicesOfType(kUMServiceType, inDomain: "local.")
        }
    }
    
    func startSearching() {
        
        self.browser!.searchForServices(ofType: kUMServiceType, inDomain: "local.")
    }
    
    func stopSearching() {
        
        self.browser!.stop()
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {
        
        debugPrint("netServiceBrowser didFindDomain: \(domainString)")
        
        guard browser == self.browser else {
            
            return NSLog("netServiceBrowser didFindService, browser does not match!")
        }
        
        /*
         search for service with avilable domain and kUMServiceType
         */
        //browser.searchForServicesOfType(kUMServiceType, inDomain: domainString)
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        
        debugPrint("netServiceBrowser didFindService: \(service.description)")
        
        guard browser == self.browser else {
            
            return NSLog("netServiceBrowser didFindService, browser does not match!")
        }
        
        var input:  InputStream?
        var output: OutputStream?
        
        if service.getInputStream(&input, outputStream: &output ) {
                        
            // creat new connection
            let connection = UMBonjourConnection(inputStream: input!, outputStream: output!)
            // open new created connection
            _ = connection.open()
            
            delegate?.umBonjourBrowser(self, didCreateConnection: connection)
            // stop search for domains and services
            //browser.stop()
        }
    }
    
    func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
        
        debugPrint("netServiceBrowserWillSearch")
    }
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        debugPrint("netServiceBrowserDidStopSearch")
    }
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        debugPrint("netServiceBrowser didNotSearch" + errorDict.description)
    }
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemoveDomain domainString: String, moreComing: Bool) {
        debugPrint("netServiceBrowser didRemoveDomain: \(domainString)")
    }
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        debugPrint("netServiceBrowser didRemoveService")
    }
}
