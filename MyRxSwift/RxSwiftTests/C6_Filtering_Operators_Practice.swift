//
//  C6_Filtering_Operators_Practice.swift
//  MyRxSwift
//
//  Created by brown on 2020/03/02.
//  Copyright © 2020 brown. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

// share 연산자를 테스트한다.
public class C6_Filtering_Operator {
    static let disposeBag = DisposeBag()
    
    open class func test_No_Share() {
        print(#function)
        let someStream = Observable<Int>.create({ observer in
            print("[create! 🦊]")
            
            let someNum = Int.random(in: 0...100)
            
            observer.onNext(someNum)
            observer.onCompleted()
            
            return Disposables.create()
        })

        // 구독1
        someStream.subscribe({ event in
            print("[구독1] \(event)")
        }).disposed(by: disposeBag)
        
        // 구독2
        someStream.subscribe({ event in
            print("[구독2] \(event)")
        }).disposed(by: disposeBag)
    }
    
    open class func test_Share() {
        print(#function)
        let randomNumStream = Observable<Int>.create({ observer in
            print("[🤡share create!]")
            let someNum = Int.random(in: 0...100)
            
            observer.onNext(someNum)
            //observer.onCompleted()
            
            return Disposables.create()
        })

        let shareStream = randomNumStream.map { "\($0)" }
            .share()
            .debug("check")
        //let shareStream = someStream.share(replay: 1, scope: .forever)
        
        // 구독1
        shareStream.subscribe({ event in
            print("[구독1(share)] \(event)")
        }).disposed(by: disposeBag)

        // 구독2
        shareStream.subscribe({ event in
            print("[구독2(share)] \(event)")
        }).disposed(by: disposeBag)
    }
    
    open class func test_Share_Normal() {
        print(#function)
        let stream = Observable.just("값1")
        //let stream = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .do(onNext: { print("[onNext-1] \($0)") })
            //.share(replay: 1, scope: .forever)
            //.take(2)
            .share()
            .do(onNext: { print("[onNext-2] \($0)") })
                
        stream.subscribe(onNext: {
            print("[구독1] \($0)")
        }).disposed(by: disposeBag)

        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            stream.subscribe(onNext: {
                print("[구독2] \($0)")
            }).disposed(by: disposeBag)
        })
    }
    
    
    open class func test_Share_Sample1() {
        print(#function)
        let observable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
            .take(2)
            .map { (element) -> Int in
                 print("map : \(element)")
                 return element
            }.share().debug("share")
         
         observable.subscribe(onNext: { (element) in
             print("observable subscribe1 : \(element)")
         }).disposed(by: disposeBag)
         
         observable.subscribe(onNext: { (element) in
             print("observable subscribe2 : \(element)")
         }).disposed(by: disposeBag)

    }
    /*
    map : 0
    observable subscribe1 : 0
    observable subscribe2 : 0
    map : 1
    observable subscribe1 : 1
    observable subscribe2 : 1
    */

    static let numberRelay = BehaviorRelay<Int>(value: 0)
    static let numberShare = numberRelay.asObservable().share()

    public static func test_Share_Subject() {
                
        numberShare.subscribe({ event in
            print("[구독1]", event)
        }).disposed(by: disposeBag)
        
        
        numberShare.subscribe({ event in
            print("[구독2]", event)
        }).disposed(by: disposeBag)

        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: { [weak numberRelay] in
            print("🦊 1초뒤", numberRelay)
            numberRelay?.accept(20)
        })
        
        
    }


}
