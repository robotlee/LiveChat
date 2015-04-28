//
//  ILRLiveChatService.swift
//  LiveChat
//
//  Created by robot on 15/4/10.
//  Copyright (c) 2015年 robot. All rights reserved.
//

import UIKit

class ILRLiveChatService: NSObject {
    private static let singleton = ILRLiveChatService()
    class var sharedInstance: ILRLiveChatService {
        get {
            return singleton
        }
    }
    
    override init() {
        //
    }
}
