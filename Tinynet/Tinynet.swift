//
//  Tinynet.swift
//
//  Created by wayne on 15/5/21.
//  Copyright (c) 2015年 wayne. All rights reserved.
//

import Foundation

public enum Method : String{
    case GET    = "GET"
    case POST   = "POST"
}


public class Tinynet {
    public static var timeoutInterval: NSTimeInterval = 10;
    
    // MARK: request
    public static func request(#method: Method, url: String, params: Dictionary<String, AnyObject>, completionHandler: (data: NSData!, response:NSURLResponse!, error: NSError!) -> Void) {
        let manager = TinynetManager(url: url, method: method, params: params, completionHandler: completionHandler)
        manager.fire()
    }
    
    public static func request(#method: Method, url: String, completionHandler: (data: NSData!, response:NSURLResponse!, error: NSError!) -> Void) {
        let manager = TinynetManager(url: url, method: method, params: [String:AnyObject](), completionHandler: completionHandler)
        manager.fire()
    }
    
    // MARK: get
    public static func get(#url: String, params:Dictionary<String, AnyObject>, completionHandler: (data: NSData!, response:NSURLResponse!, error: NSError!) -> Void) {
        let manager = TinynetManager(url: url, method: Method.GET, params: params, completionHandler: completionHandler)
        manager.fire()
    }
    
    public static func get(#url: String, completionHandler: (data: NSData!, response:NSURLResponse!, error: NSError!) -> Void) {
        let manager = TinynetManager(url: url, method: Method.GET, params: [String:AnyObject](), completionHandler: completionHandler)
        manager.fire()
    }
    
    // MARK: post
    public static func post(#url: String, params:Dictionary<String, AnyObject>, completionHandler: (data: NSData!, response:NSURLResponse!, error: NSError!) -> Void) {
        let manager = TinynetManager(url: url, method: Method.POST, params: params, completionHandler: completionHandler)
        manager.fire()
    }
    
    public static func post(#url: String, completionHandler: (data: NSData!, response:NSURLResponse!, error: NSError!) -> Void) {
        let manager = TinynetManager(url: url, method: Method.POST, params: [String:AnyObject](), completionHandler: completionHandler)
        manager.fire()
    }
}


class TinynetManager {
    private let method: Method!
    private let params: Dictionary<String, AnyObject>
    private let completionHandler: (data: NSData!, response:NSURLResponse!, error: NSError!) -> Void
    private let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    private let url: String!
    private var request: NSMutableURLRequest!
    private var task: NSURLSessionTask!
    
    // MARK: init
    required init(url: String, method: Method, params: Dictionary<String, AnyObject>, completionHandler: (data: NSData!, response:NSURLResponse!, error: NSError!) -> Void) {
        self.url = url
        self.method = method
        self.params = params
        self.request = NSMutableURLRequest(URL: NSURL(string: url)!)
        self.completionHandler = completionHandler
    }

    // MARK: private
    private func buildRequest() {
        if self.method == Method.GET && self.params.count > 0 {
            println(self.buildParams(self.params))
            self.request = NSMutableURLRequest(URL: NSURL(string: url + "?" + self.buildParams(self.params))!)
        }

        self.request.HTTPMethod = self.method.rawValue
        self.request.timeoutInterval = Tinynet.timeoutInterval;

        if self.params.count > 0 {
            self.request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        }
    }

    private func bulidBody() {
        if self.method != Method.GET && self.params.count > 0 {
            self.request.HTTPBody = self.buildParams(self.params).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        }
    }
    
    private func commitTask() {
        self.task = session.dataTaskWithRequest(self.request, completionHandler: { (data, response, error) -> Void in
            self.completionHandler(data: data, response: response, error: error)
        })
        self.task.resume()
    }
    
    internal func fire() {
        self.buildRequest()
        self.bulidBody()
        self.commitTask()
    }

    // 构建参数
    private func buildParams(params: Dictionary<String, AnyObject>) -> String{
        var components = [(String, String)]();
        let arrkeys = sorted(Array(params.keys))
        for key in arrkeys {
            // 获取键值
            let value: AnyObject! = params[key];
            components += self.queryComponents(key, value)
        }
        return join("&", components.map({"\($0)=\($1)"}) as [String]);
    }

    private func queryComponents(key: String, _ value: AnyObject) -> [(String, String)] {
        var components = [(String, String)]();
        if let dictionary = value as? [String:AnyObject] {
            for (nestedKey, value) in dictionary {
                components += queryComponents("\(key)[\(nestedKey)]", value)
            }
        } else if let array = value as? [AnyObject] {
            for value in array {
                components += queryComponents("\(key)", value)
            }
        } else {
            components.extend([(self.escape(key), self.escape("\(value)"))])
        }

        return components
    }

    private func escape(string: String) -> String {
        let legalURLCharactersToBeEscaped: CFStringRef = ":&=;+!@#$()',*"
        return CFURLCreateStringByAddingPercentEscapes(nil, string, nil, legalURLCharactersToBeEscaped, CFStringBuiltInEncodings.UTF8.rawValue) as String
    }


}
