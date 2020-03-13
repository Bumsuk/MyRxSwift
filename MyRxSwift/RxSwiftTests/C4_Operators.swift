//
//  C4_Operators.swift
//  MyRxSwift
//
//  Created by brown on 2020/02/28.
//  Copyright © 2020 brown. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class C4_Operators {
    static let bag = DisposeBag()

    enum MyError: Error {
        case anError
    }
        
    // [timeOut 테스트]
    // 지정시간동안 시퀀스가 방출되지 않으면 에러를 방출!
    static func test_timeout() {
        print(#function)
        
        let stream = Observable<Int>
            .interval(.seconds(5), scheduler: MainScheduler.instance)
            .take(1)
            //.take(.seconds(2), scheduler: MainScheduler.instance) //이건 지정 구독해 시퀀스를 받는거지, 에러를 반환하진 않음.
            .timeout(.seconds(2), scheduler: MainScheduler.instance)
        
        stream.subscribe { (event) in
            print("[구독결과]", event)
        }.disposed(by: bag)
        
        /*
        test_timeout()
        [구독결과] error(Sequence timeout.)
        */
    }
    
    // [ignoreElement 테스트]
    static func test_ignoreElements() {
        print(#function)
        
        Observable.from([1, 2, 3])
            .ignoreElements()
            .subscribe(onCompleted: {
                print("[onCompleted]")
            }, onError: {
                print("[onError]", $0)
            }).disposed(by: bag)
    }
        
    // [elementAt 테스트 + catchError 테스트]
    static func test_elementAt_catchError() {
        print(#function)
        
        Observable.from([1, 2, 3])
            .elementAt(5)
            //.catchError(<#T##handler: (Error) throws -> Observable<Int>##(Error) throws -> Observable<Int>#>)
            // 내부에서 에러가 발생하면, 그 에러에 맞춰서 정상적인 스트림을 반환해 에러를 회피한다.
            // 둘다 똑같은 동작을 함.
            //.catchErrorJustReturn(1004)
            .catchError({ error in
                Observable.just(1004)
            })
            .subscribe(onNext: { val in
                print("[구독]", val)
            }).disposed(by: bag)
    }
            
    // [elementAt - Subject 타입에서도 잘 동작한다.]
    static func test_elementAt() {
        print(#function)

        let strikes = PublishSubject<String>()
        strikes
            .elementAt(1)
            .subscribe({ event in
                print("[구독] \(event)")
            }).disposed(by: bag)
        
        strikes.onNext("X1")
        strikes.onNext("X2")
        // strikes.onNext("X3")
    }
        
    // [filter 사용의 예]
    static func test_filter() {
        print(#function)
        
        Observable.of(1, 2, 3, 4, 5, 6)
            .filter({ num in
                num == Int.random(in: 1...6) ? false : true
            })
            .subscribe({ event in
                print("[구독]", event)
            }).disposed(by: bag)
    }

    // [skip 사용의 예]
    static func test_skip() {
        print(#function)
        
        Observable.from(["a", "b", "c", "d", "e", "f"])
            .skip(3)
            .subscribe({
                print("[skip 구독] \($0)")
            }).disposed(by: bag)
    }
        
    // [skipWhile 사용의 예 - #1]
    static func test_skipWhile1() {
        print(#function)
        
        Observable.of(1, 2, 3, 4, 5, 6)
            //.skipWhile(<#T##predicate: (Int) throws -> Bool##(Int) throws -> Bool#>)
            .skipWhile({ $0 < 4 })
            .subscribe({ event in print("[skipWhile 구독]", event) })
            .disposed(by: bag)
    }
        

    // [skipWhile 사용의 예 - #2]
    static func test_skipWhile2() {
        print(#function)
        
        Observable<Int>
            .interval(.milliseconds(500), scheduler: MainScheduler.instance)
            .skipWhile({ $0 < 10 })
            .subscribe({ event in print("[구독]", event) })
            .disposed(by: bag)
    }
        
    // [skipUntil 사용의 예]
    static func test_skipUntil() {
        print(#function)

        let subject = PublishSubject<String>()
        let trigger = PublishSubject<String>() // 얘는 말그래도 트리거 역할만함.
        
        subject
            .skipUntil(trigger) // tirgger 가 emit 할때까지 subject의 onNext 발동이 안됨.
            .subscribe({ event in
                print("[skipUntil 구독] \(event)")
            }).disposed(by: bag)

        // 얘도 구독을 한다면 emit한 값은 제대로 받아올수 있음.
        /*
        trigger.subscribe(onNext: {
            print("[trigger 구독] \($0)")
        }).disposed(by: disposeBag)
        */
        
        subject.onNext("1")
        subject.onNext("2")
        
        trigger.onNext("trigger1!")
        subject.onNext("3")
        
        //trigger.onNext("trigger2!")
        subject.onNext("4")
    }

    // [take 사용의 예]
    static func test_take() {
        print(#function)
        
        Observable.of(1, 2, 3, 4, 5, 6)
            .take(3)
            .subscribe(onNext: { print("[take 구독]", $0) })
            .disposed(by: bag)
    }
        
        
    // [takeWhile, takeLast 사용의 예]
    static func test_takeWhile_takeLast() {
        print(#function)
     
        Observable.of(1, 2, 3, 4, 5, 6)
            // .takeLast(1)
            //.takeWhile(T##predicate: (Int) throws -> Bool##(Int) throws -> Bool)
            .takeWhile({ $0 < 3 })
            .subscribe(onNext: {
                print("[takeWhile 구독] \($0)")
            }).disposed(by: bag)
    }
        
    // [enumerated 사용의 예]
    static func test_enumerated() {
        print(#function)
        
        Observable.of(1, 2, 3, 4, 5, 6)
            .enumerated()
            //.takeWhile(<#T##predicate: ((index: Int, element: Int)) throws -> Bool##((index: Int, element: Int)) throws -> Bool#>)
            .takeWhile({ idx, item in
                (idx < 3) // 인덱스가 0, 1, 2 일때만 emit
            })
            .subscribe(onNext: {
                print("[enumerated 구독] \($0)")
            }).disposed(by: bag)
    }
    
    // [takeUntil 사용의 예] > 방식은 skipUntil 과 똑같다.
    // 생략
        
    // [distinctUntilChanged 사용예 #1]
    static func test_distinctUntilChanged() {
        print(#function)

        Observable.from([1, 1, 2, 2, 3, 3])
            .distinctUntilChanged()
            //.distinctUntilChanged(<#T##comparer: (Int, Int) throws -> Bool##(Int, Int) throws -> Bool#>)
            .subscribe({ num in
                print("[distinctUntilChanged 구독] \(num)")
            }).disposed(by: bag)
    }
}
