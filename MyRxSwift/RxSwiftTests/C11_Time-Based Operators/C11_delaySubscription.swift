//
//  C11_delaySubscription.swift
//  MyRxSwift
//
//  Created by brown on 2020/03/14.
//  Copyright © 2020 brown. All rights reserved.
//

import Foundation

// [참고]
// http://reactivex.io/documentation/operators/delay.html
public class C11_delaySubscription {
    static let bag = DisposeBag()
    
    // '구독' 자체를 늦게 실시한다! 별건 없다.
    static func test_delaySubscription() {
        print(#function)
        
        _ = Observable.from([1, 10, 100, 1000, 1000])
            //.delay(.seconds(3), scheduler: MainScheduler.instance)
            .delaySubscription(.seconds(3), scheduler: MainScheduler.instance)
            .debug()
            .subscribe { (num) in
                print("[delaySubscription 구독] \(num)")
            }
        
    }
    
    // 위의 delaySubscription와 차이는 구독은 곧바로 하되, 시퀀스의 방출을 늦춘다.
    // 둘이 차이점은 구독을 늦추는 delaySubscription의 경우 핫 옵저버블의 경우 방출값들을 놓칠수 있지만,
    // delay는 방출값들을 받되, 그 값들을 지연시키는 것이다.
    static func test_delay() {
        print(#function)
        
        _ = Observable.from([1, 10, 100, 1000, 1000])
            .delay(.seconds(3), scheduler: MainScheduler.instance)
            .debug()
            .subscribe { (num) in
                print("[delaySubscription 구독] \(num)")
            }
        
    }

}
