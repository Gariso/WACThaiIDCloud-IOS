//
//  ViewController.swift
//  WACThaiIDCloud
//
//  Created by Thananchai Pinyo on 25/7/2565 BE.
//

import UIKit
import ACSSmartCardIO
import SmartCardIO

class ViewController: UIViewController, MPayBleLibDelegate {
    
    func onMPayBleResponse_Error(_ iErrorCode: Int32, message sMessage: String!) {
        
    }
    
    func onMPayBleResponse_UpdateState(_ iStateCode: Int32, message sMessage: String!) {
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

