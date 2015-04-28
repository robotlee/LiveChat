//
//  LCMessage.swift
//  LiveChat
//
//  Created by robot on 15/4/28.
//  Copyright (c) 2015年 robot. All rights reserved.
//

import Foundation

//buddy message
struct LCMessage {
    var body = ""
    var from = ""
    var isComposing = false
    var isDealy = false
    var isMe = false
}

//buddy status
struct LCBuddyStatus {
    var name = ""
    var isOnline = false
}