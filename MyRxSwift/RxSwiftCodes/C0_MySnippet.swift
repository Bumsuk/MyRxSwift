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
    static let bag = DisposeBag()
    
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
    
    // .debug 오퍼레이터 다양한 테스트
    static func test_debug() {
        print(#function)
        enum MyError: Error {
            case anError(String)
        }

        Observable<String>.create { (observer) -> Disposable in
            observer.onError(MyError.anError("에러발생시킴!"))
            //observer.onNext("1")
            return Disposables.create()
        }
        .debug("debug-1")
        
        .catchErrorJustReturn("에러복구값!")
        
        .subscribe { (event) in
            print("[결과] \(event)")
        }.disposed(by: bag)
        
    }
    

}
