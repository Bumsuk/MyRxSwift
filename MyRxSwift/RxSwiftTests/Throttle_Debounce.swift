//
//  Throttle_Debounce.swift
//  MyRxSwift
//
//  Created by brown on 2020/03/20.
//  Copyright © 2020 brown. All rights reserved.
//

import Foundation

public class ThottleDebounce {

    static let bag = DisposeBag()
    
    // [throttle /  debounce 차이]
    // https://medium.com/@progjh/throttle-debounce-%EA%B0%9C%EB%85%90-%EC%9E%A1%EA%B8%B0-19cea2e85a9f
    
    // 이벤트를 일정한 주기마다 발생하도록 한다.
    // 예를 들어 Throttle 의 설정시간으로 1 ms 를 주게되면 해당 이벤트는 1ms 동안 최대 한번만 발생하게 된다.
    // 위의 Throttle 기법이 적용될 경우 다음과 같이 작동하게 된다.
    public static func test_throttle() {
        print(#function)
        Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .map { "throttle : \($0)" }
            .throttle(.seconds(5), scheduler: MainScheduler.instance)
            .subscribe(onNext: { print("🤡[throttle] \($0)") }, onCompleted: { print(#function) })
            .disposed(by: bag)

    }
    
    // 이벤트를 그룹화하여 특정시간이 지난 후 하나의 이벤트만 발생하도록 한다.
    public static func test_debounce() {
        print(#function)
        Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .map { "debounce : \($0)" }
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { print("🤡[debounce] \($0)") }, onCompleted: { print(#function) })
            .disposed(by: bag)
    }


}
