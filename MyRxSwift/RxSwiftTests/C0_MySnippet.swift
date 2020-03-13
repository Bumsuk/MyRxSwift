//
//  C0_MySnippet.swift
//  MyRxSwift
//
//  Created by brown on 2020/03/10.
//  Copyright © 2020 brown. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

// 드럽게 많네. 그래도 공부하자.
class C0_MySnippet {
    
    // 구독 자체를 늦게 할수 있다. delay() 와 비슷하긴 한데...
    static func test_delaySubscription() {
        print(#function)
        
        _ = Observable.from([1, 10, 100, 1000, 1000])
            //.delay(<#T##dueTime: RxTimeInterval##RxTimeInterval#>, scheduler: <#T##SchedulerType#>)
            .delaySubscription(.seconds(3), scheduler: MainScheduler.instance)
            .subscribe { (num) in
                print("[delaySubscription 구독] \(num)")
            }
    }
    

}
