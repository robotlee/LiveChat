//
//  StatusDelegate.swift
//  LiveChat
//
//  Created by robot on 15/4/10.
//  Copyright (c) 2015年 robot. All rights reserved.
//

import Foundation

protocol StatusDelegate{
    func newBuddyOnLine(buddyStatus:LCBuddyStatus)
    func buddyWentOffline(buddyStatus:LCBuddyStatus)
    func didDisconnect()
}