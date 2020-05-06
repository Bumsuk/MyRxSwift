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

// 본격적으로 서적의 소스를 실습하면서 추후 레퍼런싱 가능하도록 구성한다.
public class C3_Subject {
    static let disposeBag = DisposeBag()

    // 기본 테스트
    public static func test0() {
		print(#function)

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
		print(#function)

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
		print(#function)
        print("check! 🤡")
        
        let subject = BehaviorSubject<String>(value: "=기본값=")
		// let subject = PublishSubject<String>()
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
		print(#function)

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
    
    // 간단 Driver 테스트
    public static func test3_Driver() {
		print(#function)

        let relay = BehaviorRelay<String>(value: "")
        let driver = relay.asDriver(onErrorJustReturn: "=default=")
        
        relay.accept("12345")
        
        driver.asObservable().subscribe(onNext: { value in
            print("[drive 결과1] \(value)")
        })
              
        driver.drive(onNext: {
            print("[drive 결과2] \($0)")
        })
		
        driver.drive { value in
            print("[drive 결과3] \(value)")
        }
    }
    
    
    public static func test3_ReplaySubject() {
		print(#function)

        enum MyError: Error {
            case anError
        }
        
        let subject = ReplaySubject<String>.create(bufferSize: 2)
        let disposeBag = DisposeBag()
        
        subject.on(.next("1"))
        subject.on(.next("2"))
        subject.onNext("3")
                
        subject.subscribe {
            print("[1] \($0)")
        }.disposed(by: disposeBag)
        
        subject.subscribe {
            print("[2] \($0)")
        }.disposed(by: disposeBag)

        subject.onNext("4")
        subject.onError(MyError.anError)
        subject.dispose()
        
        subject.onNext("55555")
        
        subject.subscribe {
            print("[3] \($0)")
        }.disposed(by: disposeBag)

        
        subject.subscribe {
            print("[4] \($0)")
        }.disposed(by: disposeBag)

        
    }
}


// 테스트용 extension
extension BehaviorRelay where Element == String {
    func dispose_() {
        print("허미 허미!")
    }
}


