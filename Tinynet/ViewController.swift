//
//  ViewController.swift
//  Tinynet
//
//  Created by wayne on 15/5/26.
//  Copyright (c) 2015年 wayne. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var info:[String:AnyObject] = [:]
        info["userId"] = "0"
        info["key"] = "7506BAF5-1A21-4240-A9E2-3E1DD1B61D30"
        info["device"] = "2"
        info["content"] = "JustForTest"
        
        println(info)
        
        Tinynet.post(url: "http://1.wwszgroup.sinaapp.com/0/users/feedback/add.php", params: info) { (data, response, error) -> Void in
            if let er = error {
                println(er.description)
            }
            else {
                let str = NSString(data: data, encoding: NSUTF8StringEncoding)!
                println(str)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

