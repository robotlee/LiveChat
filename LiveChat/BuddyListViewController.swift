//
//  BuddyListViewController.swift
//  LiveChat
//
//  Created by robot on 15/4/9.
//  Copyright (c) 2015年 robot. All rights reserved.
//

import UIKit

class BuddyListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var unreadMessageList = [LCMessage]()

    var statusList = [LCBuddyStatus]()
    var logged = false
    
    var currentBuddyName = ""
    
    func delegate() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    func clearAllBuddy() {
        unreadMessageList.removeAll(keepCapacity: false)
        statusList.removeAll(keepCapacity: false)
    }
    
    func  login(){
        
        clearAllBuddy()
        delegate().connect()
        logged = true
        
        tableView.reloadData()
    }
    
    func logoff(){
        clearAllBuddy()
        
        delegate().disconnect()
        logged = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //tableView.delegate = self
        let jabberID = NSUserDefaults.standardUserDefaults().stringForKey("userID")
        if jabberID != nil {
            login()
            self.navigationItem.title = jabberID!
        }else{
            performSegueWithIdentifier("AuthenticationSegue", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        delegate().statusDelegate = self
        delegate().messageDelegate = self
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "toChatView" {
            let chatViewController = segue.destinationViewController as! ChatViewController
            chatViewController.chatWithUser = currentBuddyName
            
            for(index, message) in enumerate(unreadMessageList) {
                if message.from == currentBuddyName {
                    chatViewController.messages.append(message)
                }
            }
           
            var indexsAry = [Int]()
            for (index,aMsg) in enumerate(unreadMessageList) {
                if aMsg.from == currentBuddyName {
                    indexsAry.append(index)
                }
            }
            var correctAry = indexsAry.reverse()
            for index in correctAry {
                unreadMessageList.removeAtIndex(index)
            }
            
            tableView.reloadData()
        }
    }
    

    @IBAction func didTapSignOut(sender: AnyObject) {
        logoff()
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController: LoginViewController = storyBoard.instantiateViewControllerWithIdentifier("loginViewController") as! LoginViewController
        presentViewController(loginViewController, animated: true, completion: nil)
    }
}

extension BuddyListViewController:StatusDelegate {
    func newBuddyOnLine(buddyStatus: LCBuddyStatus) {
        printLog("isOn = \(buddyStatus)")
        
        for (index,oldStatus) in enumerate(statusList) {
            if buddyStatus.name == oldStatus.name {
                statusList.removeAtIndex(index)
                break
            }
        }
        
        statusList.append(buddyStatus)
        tableView.reloadData()
    }
    
    func buddyWentOffline(buddyStatus: LCBuddyStatus) {
        for(index, oldStatus) in enumerate(statusList) {
            if buddyStatus.name == oldStatus.name {
                statusList[index].isOnline = false
                break
            }
        }
        tableView.reloadData()
    }
    
    func didDisconnect() {
        logoff()
    }
}

extension BuddyListViewController:MessageDelegate{
    func newMessageReceive(message: LCMessage) {
        printLog(message)
        if message.body != "" {
            unreadMessageList.append(message)
            tableView.reloadData()
        }
    }
}

extension BuddyListViewController:UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statusList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "buddyListCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        let buddyStatus:LCBuddyStatus = statusList[indexPath.row]
        let isOnline = buddyStatus.isOnline
        let name = buddyStatus.name
        
        var messages = [LCMessage]()
        for msg in unreadMessageList {
            if msg.from == name {
                messages.append(msg)
            }
        }
        
        cell.textLabel?.text = name + "(\(messages.count))"
        if isOnline {
            cell.imageView?.image = UIImage(named: "on")
        }else {
            cell.imageView?.image = UIImage(named: "off")
        }
        
        return cell
    }
}

extension BuddyListViewController:UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        currentBuddyName = statusList[indexPath.row].name
        printLog(currentBuddyName)
        self.performSegueWithIdentifier("toChatView", sender: self)
    }
}
