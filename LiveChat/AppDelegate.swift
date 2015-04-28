//
//  AppDelegate.swift
//  LiveChat
//
//  Created by robot on 15/4/9.
//  Copyright (c) 2015年 robot. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var xmppStream:XMPPStream?
    var isOpen = false
    var statusDelegate: StatusDelegate?
    var messageDelegate:MessageDelegate?
    var loginServer:String = ""
    var password:String?
    
    func initStream(){
        xmppStream = XMPPStream()
        xmppStream?.addDelegate(self, delegateQueue: dispatch_get_main_queue())
    }
    
    func online(){
        var p = XMPPPresence()
        xmppStream?.sendElement(p)
    }
    
    func offline(){
        var p = XMPPPresence(type: "unavailable")
        xmppStream?.sendElement(p)
    }
    
    func connect()-> Bool {
        printLog("Connecting...")
        initStream()
        if xmppStream!.isConnected() {
            return true
        }
        
        let jabberID = NSUserDefaults.standardUserDefaults().stringForKey("userID")
        let myPassword = NSUserDefaults.standardUserDefaults().stringForKey("userPassword")
        let server = NSUserDefaults.standardUserDefaults().stringForKey("loginServer")
        if server != nil {
            loginServer = server!
        }
        
        if let stream = xmppStream {
            if jabberID == nil || myPassword == nil {
                printLog("no jabberID set: \(jabberID)")
                printLog("no password set: \(myPassword)")
                return false
            }
        
            stream.myJID = XMPPJID.jidWithString(jabberID)
            stream.hostName = server
            password = myPassword!
            
            var error:NSError?
            if !stream.connectWithTimeout(XMPPStreamTimeoutNone, error: &error) {
                var alertView:UIAlertView? = UIAlertView(title: "Error", message: "Cannot connect to \(error!.localizedDescription)", delegate: nil, cancelButtonTitle: "Ok")
                alertView!.show()
                return false
            }
        }
        
        return false
    }
    
    func disconnect() {
        if let stream = xmppStream {
            if stream.isConnected() {
                offline()
                xmppStream?.disconnect()
            }
        }

    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate: XMPPStreamDelegate {
    func xmppStreamDidConnect(sender: XMPPStream!) {
        printLog(sender)
        isOpen = true
        xmppStream!.authenticateWithPassword(password, error: nil)
    }
    func xmppStreamDidAuthenticate(sender: XMPPStream!) {
        printLog(sender)
        //
        online()
    }
    
    func xmppStream(sender: XMPPStream!, didReceiveMessage message: XMPPMessage!) {
        printLog(message)
        //
        if message.isChatMessage() {
            var msg = LCMessage()
            if message.elementForName("composing") != nil {
                msg.isComposing = true
            }
            
            if message.elementForName("delay") != nil {
                msg.isDealy = true
            }
        
            if let body = message.elementForName("body") {
                msg.body = body.stringValue()
            }
            msg.from = message.from().user + "@" + message.from().domain
            messageDelegate?.newMessageReceive(msg)
        }
    }
    
    func xmppStream(sender: XMPPStream!, didReceivePresence presence: XMPPPresence!) {
        printLog(presence)
        //
        let myUser = sender.myJID.user
        let buddyUser = presence.from().user
        
        let domain = presence.from().domain
        
        let presenceType = presence.type()
        if (buddyUser != myUser){
            var buddyStatus = LCBuddyStatus()
            buddyStatus.name = buddyUser + "@" + domain
            if presenceType == "available" {
                buddyStatus.isOnline = true
                statusDelegate?.newBuddyOnLine(buddyStatus)
            }else if presenceType == "unavailable" {
                statusDelegate?.buddyWentOffline(buddyStatus)
            }
        }
    }
}
