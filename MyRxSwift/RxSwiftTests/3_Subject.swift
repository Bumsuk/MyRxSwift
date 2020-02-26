//
//  3_Subject.swift
//  MyRxSwift
//
//  Created by brown on 2020/02/25.
//  Copyright © 2020 brown. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class C3_Subject {
    static let disposeBag = DisposeBag()

    // 기본 테스트
    public static func test0() {
        let subject = PublishSubject<String>()
        subject.onNext("Is anyone listening?")

        let subscriptionOne = subject
          .subscribe(onNext: { string in
            print("[subscriptionOne]", string)
          })

        subject.on(.next("1"))
        subject.onNext("2")

        let subscriptionTwo = subject
          .subscribe { event in
            print("[subscriptionTwo]", event.element ?? event)
        }

        subject.onNext("3")

        subscriptionOne.dispose()

        subject.onNext("4")

        // 1
        subject.onCompleted()

        // 2
        subject.onNext("5")

        // 3
        subscriptionTwo.dispose()

        let disposeBag = DisposeBag()

        // 4
        subject
          .subscribe {
            print("3)", $0.element ?? $0)
          }
          .disposed(by: disposeBag)

        subject.onNext("?")

    }
    
    public static func test0_1() {
        // let subject = BehaviorSubject<String>(value: "=default=")
        let subject = ReplaySubject<String>.create(bufferSize: 2)
        subject.onNext("hello?? - 1")
        
        subject
            .subscribe({
            print("[결과1] \($0)")
        })
                
        subject.onNext("hello?? - 2")
        subject.onNext("hello?? - 3")
        subject.onNext("hello?? - 4")
        
        subject
            .subscribe({
            print("[결과2] \($0)")
        })
        
        print("check - 🦹‍♂️")
    }
    
    // Subject 종류별 테스트
    public static func test1() {
        print("check! 🤡")
        
        // let subject = BehaviorSubject<String>(value: "=기본값=")
         let subject = PublishSubject<String>()
        // let subject = AsyncSubject<String>() // onCompleted 되어야만 방출!
        
        let ticket = subject
            //.debug("[check debug]")
            .subscribe({
                print("[수신1] \($0)")
            })

        subject.onNext("크헝~")
        subject.on(.completed)
        subject.on(.next("하~"))
        subject.on(.next("호~"))
        
        print("=== 😘 ===")
        
        subject
            //.debug("[check debug2]")
            .subscribe({
                print("[수신2] \($0)")
            }).disposed(by: disposeBag)

        
        subject.onCompleted()
        
        // 수동 dispose
        ticket.dispose()
    }
    
    // Subject 예
    public static func test2() {
        enum MyError: Error {
            case anError
        }
        
        func printCustom<T: CustomStringConvertible>(label: String, event: Event<T>) {
            print(label, (event.element ?? event.error) ?? event)
        }
        
        let subject = BehaviorSubject(value: "=default=")
        let disposeBag = DisposeBag()
        
        subject.on(.next("크"))
        subject.on(.next("흐"))
        subject.on(.next("호"))
        
        subject.subscribe {
            printCustom(label: "[1]", event: $0)
        }.disposed(by: disposeBag)
        
        //subject.onCompleted()
        
        subject.subscribe(onNext: { val in print("[2] \(val)") })
    }

    
    // Relay 종류별 테스트 - Subject에서 trait 화한 녀석으로, .completed / .error 를 방출하지 않는다. 값만(.next) 방출하는 전용
    public static func test3() {
        let relay = BehaviorRelay<String>(value: "=Default=")
        relay.accept("가")
        relay.accept("나")
        
        relay.dispose_()
        
        relay.subscribe({
            print("[relay 결과] \($0)")
        })
    }

}

extension BehaviorRelay where Element == String {
    func dispose_() {
        print("빨통보소!")
    }
}


