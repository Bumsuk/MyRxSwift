//
//  ViewController.swift
//  MyRxSwiftSub
//
//  Created by brown on 2020/02/13.
//  Copyright © 2020 brown. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        Observable.from([1, 2, 3]).subscribe(onNext: {
            print("[(Sub)옵저버 결과] \($0)")
            }).dispose()

    }


}

