//
//  MessageDelegate.swift
//  LiveChat
//
//  Created by robot on 15/4/10.
//  Copyright (c) 2015年 robot. All rights reserved.
//

import Foundation

protocol MessageDelegate {
    func newMessageReceive(message: LCMessage)
}