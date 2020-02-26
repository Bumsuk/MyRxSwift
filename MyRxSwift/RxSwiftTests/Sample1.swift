//
//  Sample1.swift
//  MyRxSwift
//
//  Created by brown on 2020/02/24.
//  Copyright © 2020 brown. All rights reserved.
//

import Foundation
import RxSwift

public class Sample1 {
    public static func test1() {
        
//        Observable.from([1, 2, 3, 4])
//            .subscribe(onNext: {
//                print("[테스트 결과 - from]", $0)
//            })
        
//        Observable.of(1, 2, 3, 4)
//            .subscribe({ event in
//                if let next = event.element {
//                    print("[next] \(next)")
//                }
//                print("[결과] \(event), type : \(type(of: event))")
//            })

        
//        Observable.of(1, 2, 3, 4)
//        .subscribe(onNext: { event in
//            print("[테스트 결과 - of]", event)
//        })

//        Observable.just([1, 2, 3])
//        .subscribe(onNext: {
//            print("[테스트 결과 - just]", $0)
//        })
        
        
        Observable<Int>.empty() // 여기서의 Int 제너릭 타입은 추론이 가능하지 않으므로, 명시적으로 지정해줘야 한다. 즉, 생략이 불가능하다.
        .subscribe({
            print("[empty] \($0)")
        })
        
//        Observable<Int>.empty()
//        .subscribe(onNext: { _ in
//            print("[onNext]")
//        }, onCompleted: {
//            print("[onCompleted!]")
//        }, onDisposed: {
//            print("[onDisposed!]")
//        })
    
        
        Observable<Any>.never()
        .debug()
        .subscribe(onNext: { _ in
            print("[onNext]")
        }, onCompleted: {
            print("[onCompleted!]")
        }, onDisposed: {
            print("[onDisposed!]")
        })

//        Observable<Int>.interval(.seconds(1), scheduler: SerialDispatchQueueScheduler(qos: .default))
//        .take(5)
//        .subscribe({
//            print("[interval] \($0)")
//        })
        
        
        let dispose = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
        .take(50)
        .map { _ in Int.random(in: 0...1000) }
        .subscribe({
            print("[interval] \($0)")
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            dispose.dispose()
        })

        
//        Observable.range(start: 10, count: 10)
//        .map { "흥\($0)" }
//        .subscribe(onNext: {
//            print("[range] \($0)")
//        }).dispose()

        
        
        
    }
    
}
