//
//  C11_window.swift
//  MyRxSwift
//
//  Created by brown on 2020/03/13.
//  Copyright © 2020 brown. All rights reserved.
//

import Foundation

// [참고]
// http://reactivex.io/documentation/operators/window.html
// https://brunch.co.kr/@tilltue/9
// buffer와 비슷하지만, buffer와 달리 배열을 방출하는 것이 아닌, 옵저버블의 배열을 방출한다.
public class C11_window {
    static let bag = DisposeBag()
    
    static func test_window1() {
        print(#function)
        
        Observable
            .range(start: 1, count: 10, scheduler: MainScheduler.instance)
            .window(timeSpan: .seconds(10), count: 3, scheduler: MainScheduler.instance)
            
            //.flatMap { $0 }

            .subscribe(onNext: { observable in
                //print("check", observable)
                observable.subscribe { (event) in
                    print("[결과]", event)
                }
            })
            
        print("🤡check - end")
    }
    
}

