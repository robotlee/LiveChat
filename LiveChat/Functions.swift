//
//  Functions.swift
//  LiveChat
//
//  Created by robot on 15/4/9.
//  Copyright (c) 2015年 robot. All rights reserved.
//

import Foundation

func printLog<T>(message: T,
    file: String = __FILE__,
    method: String = __FUNCTION__,
    line: Int = __LINE__)
{
    //#if DEBUG
        println("\(file.lastPathComponent)[\(line)], \(method): \(message)")
    //#endif
}

struct RegexHelper {
    let regex: NSRegularExpression?
    
    init(_ pattern: String) {
        var error: NSError?
        regex = NSRegularExpression(pattern: pattern,
                                    options: .CaseInsensitive,
                                      error: &error)
    }
    
    func match(input: String) -> Bool {
        if let matches = regex?.matchesInString(input,options: nil,range: NSMakeRange(0, count(input))) {
            return matches.count > 0
        } else {
            return false
        }
    }
}