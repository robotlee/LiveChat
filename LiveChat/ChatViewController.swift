//
//  ChatViewController.swift
//  LiveChat
//
//  Created by robot on 15/4/15.
//  Copyright (c) 2015年 robot. All rights reserved.
//

import UIKit
let CHAT_SUBVIEW_TAG = 101
class ChatViewController: UIViewController {

    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var sendBoxViewBottomConstraint: NSLayoutConstraint!
    var chatWithUser = ""
    var currentUser = ""
    var messages = [LCMessage]()
    var keyboardShown = false
    override func viewDidLoad() {
        super.viewDidLoad()
        printLog(" starting ...messages: \(messages)  chatWithUser: \(chatWithUser)")
        currentUser = NSUserDefaults.standardUserDefaults().stringForKey("userID")!
        // Do any additional setup after loading the view.
        registerForKeyboardNotification()
    }
    deinit {
        let nc = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        nc.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func delegate() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    override func viewDidAppear(animated: Bool) {
        delegate().messageDelegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func registerForKeyboardNotification(){
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        nc.addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    @IBAction func isComposing(sender: AnyObject) {
        var xmlMessage = DDXMLElement.elementWithName("message") as! DDXMLElement
        
        xmlMessage.addAttributeWithName("to", stringValue: chatWithUser)
        xmlMessage.addAttributeWithName("from", stringValue: currentUser)
        
        var composing = DDXMLElement.elementWithName("composing") as! DDXMLElement
        composing.addAttributeWithName("xmlns", stringValue: "http://jabber.org/protocol/chatstates")
        
        xmlMessage.addChild(composing)
        
        delegate().xmppStream?.sendElement(xmlMessage)
    }
    
    @IBAction func sendMessage(sender: AnyObject) {
        var message = messageField.text
        messageField.text = ""
        messageField.resignFirstResponder()
        
        if message != "" {
            
            createMessage(message)
            tableView.reloadData()
        }
    }

    func createMessage(message:String){
        var xmlMessage = DDXMLElement.elementWithName("message") as! DDXMLElement
        
        xmlMessage.addAttributeWithName("type", stringValue: "chat")
        xmlMessage.addAttributeWithName("to", stringValue: chatWithUser)
        xmlMessage.addAttributeWithName("from", stringValue: currentUser)
        
        var body = DDXMLElement.elementWithName("body") as!DDXMLElement
        body.setStringValue(message)
        xmlMessage.addChild(body)
        
        delegate().xmppStream?.sendElement(xmlMessage)
        
        var msg = LCMessage()
        msg.isMe = true
        msg.body = message
        messages.append(msg)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func keyboardWillShow(notification:NSNotification){
        //printLog(notification)
        
        if keyboardShown {
            return
        }
        
        keyboardShown = true
        
        let baseView = self.view.viewWithTag(CHAT_SUBVIEW_TAG)
        
        let keyboardFrame = notification.userInfo![UIKeyboardFrameBeginUserInfoKey]!.CGRectValue()
        printLog(" keyboardFrame \(keyboardFrame.size.height)")
        let keyboardDuration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
        
        let visibleRows = tableView.indexPathsForVisibleRows() as! [NSIndexPath]
        var lastIndexPath: NSIndexPath? = nil
        if visibleRows.count > 0 {
            lastIndexPath = visibleRows[visibleRows.count - 1] as NSIndexPath
        }
        
        UIView.animateWithDuration(keyboardDuration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            baseView!.frame = CGRectMake(baseView!.frame.origin.x, baseView!.frame.origin.y, baseView!.frame.size.width, baseView!.frame.size.height - keyboardFrame.size.height)
            baseView!.layoutIfNeeded()
        }) { (finished) -> Void in
            if lastIndexPath != nil {
                self.tableView.scrollToRowAtIndexPath(lastIndexPath!, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
            }
        }
    }
    func keyboardWillHide(notification:NSNotification){
        //printLog(notification)
        if !keyboardShown {
            return
        }
        
        keyboardShown = false
        let baseView = self.view.viewWithTag(CHAT_SUBVIEW_TAG)
        let keyboardFrame = notification.userInfo![UIKeyboardFrameBeginUserInfoKey]!.CGRectValue()
        let keyboardDuration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
        
        UIView.animateWithDuration(keyboardDuration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            baseView!.frame = CGRectMake(baseView!.frame.origin.x, baseView!.frame.origin.y, baseView!.frame.size.width, baseView!.frame.size.height + keyboardFrame.size.height)
        }, completion: nil)
    }
}
extension ChatViewController:MessageDelegate {
    func newMessageReceive(message: LCMessage) {
        if message.isComposing {
            navigationItem.title = "Inputting..."
        }
        if message.body != "" {
            navigationItem.title = chatWithUser
            
            messages.append(message)
            tableView.reloadData()
        }
    }
}

extension ChatViewController:UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "MessageCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        let message = messages[indexPath.row]
        
        if message.isMe {
            cell.textLabel?.textAlignment = .Right
            cell.textLabel?.textColor = UIColor.grayColor()
        }else {
            cell.textLabel?.textColor = UIColor.orangeColor()
        }
        
        cell.textLabel?.text = message.body

        return cell
    }
}

extension ChatViewController:UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let shouldReturn = textField.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0
        if shouldReturn {
            let message = textField.text
            textField.text = ""
            
            if message != "" {
                
                createMessage(message)
                tableView.reloadData()
            }
            messageField.resignFirstResponder()
        }
        
        return shouldReturn
    }
}
