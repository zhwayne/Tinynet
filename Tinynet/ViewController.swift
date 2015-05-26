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
        
        Tinynet.get(url: "http://zhwayne.com") { (data, response, error) -> Void in
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

