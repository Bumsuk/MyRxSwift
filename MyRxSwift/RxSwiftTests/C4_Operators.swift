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
    static let disposeBag = DisposeBag()

    enum MyError: Error {
        case anError
    }

    // [시작!]
    public static func test1() {
        
        // [ignoreElement 테스트]
        /*
        Observable.from([1, 2, 3])
        .ignoreElements()
        .subscribe(onCompleted: {
        }, onError: { error in
        })
        */
        
        // [elementAt 테스트 + catchError 테스트]
        /*
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
            })
        */
            
        // [elementAt - Subject 타입에서도 잘 동작한다.]
        /*
        let strikes = PublishSubject<String>()
        strikes
            .elementAt(1)
            .subscribe({ event in
                print("[구독] \(event)")
            }).disposed(by: disposeBag)
        
        
        strikes.onNext("X1")
        strikes.onNext("X2")
//        strikes.onNext("X3")
        */

        
        // [filter 사용의 예]
        /*
        Observable.of(1, 2, 3, 4, 5, 6)
        .filter({ num in
            num == Int.random(in: 1...6) ? false : true
        })
        .subscribe({ event in
            print("[구독]", event)
        })
        */
        
        // [skip 사용의 예]
        /*
        Observable.from(["a", "b", "c", "d", "e", "f"])
            .skip(3)
            .subscribe({
                print("[skip 구독] \($0)")
            })
        */
        
        // [skipWhile 사용의 예 - #1]
        /*
        Observable.of(1, 2, 3, 4, 5, 6)
        //.skipWhile(<#T##predicate: (Int) throws -> Bool##(Int) throws -> Bool#>)
        .skipWhile({ $0 < 4 })
        .subscribe({ event in print("[skipWhile 구독]", event) })
        */
        

        // [skipWhile 사용의 예 - #2]
        /*
        Observable<Int>
            .interval(.milliseconds(500), scheduler: MainScheduler.instance)
            .skipWhile({ $0 < 10 })
            .subscribe({ event in print("[구독]", event) })
        */
        
        // [skipUntil 사용의 예]
        let subject = PublishSubject<String>()
        let trigger = PublishSubject<String>() // 얘는 말그래도 트리거 역할만함.
        
        subject
            .skipUntil(trigger) // tirgger 가 emit 할때까지 subject의 onNext 발동이 안됨.
            .subscribe({ event in
                print("[skipUntil 구독] \(event)")
            }).disposed(by: disposeBag)

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
        
        trigger.onNext("trigger2!")
        subject.onNext("4")


        // [take 사용의 예]
        Observable.of(1, 2, 3, 4, 5, 6)
            .take(3)
            .subscribe(onNext: { print("[take 구독]", $0) })
            .disposed(by: disposeBag)
        
        
        // [takeWhile, takeLast 사용의 예]
        Observable.of(1, 2, 3, 4, 5, 6)
            // .takeLast(1)
            
            //.takeWhile(T##predicate: (Int) throws -> Bool##(Int) throws -> Bool)
        	.takeWhile({
                $0 < 3
            })
            .subscribe(onNext: {
                print("[takeWhile 구독] \($0)")
            })
        
        
        // [enumerated 사용의 예]
        Observable.of(1, 2, 3, 4, 5, 6)
            .enumerated()
            
        	//.takeWhile(<#T##predicate: ((index: Int, element: Int)) throws -> Bool##((index: Int, element: Int)) throws -> Bool#>)
            .takeWhile({ idx, item in
                (idx < 3) // 인덱스가 0, 1, 2 일때만 emit
            })
        
            .subscribe(onNext: {
                print("[enumerated 구독] \($0)")
            })
                
        // [takeUntil 사용의 예] > 방식은 skipUntil 과 똑같다.
        // 생략
        
        // [distinctUntilChanged 사용예 #1]
        Observable.from([1, 1, 2, 2, 3, 3])
        
            .distinctUntilChanged()
        	//.distinctUntilChanged(<#T##comparer: (Int, Int) throws -> Bool##(Int, Int) throws -> Bool#>)
        
            .subscribe({ num in
                print("[distinctUntilChanged 구독] \(num)")
            })
        
        
        // [distinctUntilChanged 사용예 #2]
        
        
        // end of file
        print("🤡check - end")
    }

}
