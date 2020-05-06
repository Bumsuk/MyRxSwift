//
//  C0_BInd_Binder_Etc.swift
//  MyRxSwift
//
//  Created by brown on 2020/03/11.
//  Copyright © 2020 brown. All rights reserved.
//

import Foundation
//import RxSwift
//import RxCocoa

// Bind는 UI와 관련 > 에러 발생 x, 메인스레드와 관련 >> 더 추가(확실한 정보로)
class C0_Bind_Binder_Etc {
    static let bag = DisposeBag()
    
    // 참고 : https://mcflynn.tistory.com/12
    // bind 테스트 #1 - subscribe 와 비슷하지만 에러처리 못함(fatal 에러 우려!, qucik help 봐라!)
    static func test_bind1() {
        print(#function)
        enum MyError: Error {
            case anError(String)
        }
        
        let stream1 = Observable.from(["가", "나", "다"])
        let stream2 = Observable.from(["A", "B", "C"])
        let stream3 = Observable<String>.create { (observer) -> Disposable in
            observer.on(.error(MyError.anError("그냥 에러!")))
            return Disposables.create()
        }
        
        stream3.bind(onNext: { str in
            print("[bind - stream3] \(str)")
        })
		
		let button = UIButton.init(type: .contactAdd)
		stream1.asObservable().asDriver(onErrorJustReturn: "").drive(button.rx.title(for: .normal))
		
        print("🤡check - end!")
    }
    
    // bind(to: _)로 relay에 시퀀스를 전달하는 예제 > 자주 쓰인다!!!!!
    static func test_bind_to_relay() {
        print(#function)
        enum MyError: Error {
            case anError(String)
        }
        
        let relay = BehaviorRelay<String>(value: "")
        relay
            .skipWhile({ $0 == "" })
            .subscribe { (event) in
                print("[realy]", event)
            }.disposed(by: bag)
        
        // relay.accept("1111")
        
        let strStream = Observable.from(["가", "나", "다", "라", "마"])
        
        // 이렇게 bind를 relay에 하면(구독), strStream의 시퀀스가 relay에서 방출된다.
        // 자세히 설명하면, strStream에서 onNext 된 값이 바로 relay에서 onNext 된다.
        strStream
            //.debug("bind")
            .bind(to: relay)
            .disposed(by: bag)

        print("🤡check - end!")
    }

    
    // bind(to: _)로 relay에 시퀀스를 전달하는 예제 > 자주 쓰인다!!!!!
    // bind로 여러 릴레이에게 시퀀스를 전달하는 것을 테스트 > 중요!
    static func test_bind_to_relays() {
        print(#function)
        enum MyError: Error {
            case anError(String)
        }

        // source 시퀀스들
        let stream1 = Observable.of(["1", "2", "3"])
        let stream2 = Observable.of(["일", "이", "삼"])
        let stream3 = Observable.of(["one", "two", "three"])
        
        // relay 들
        let relay1 = BehaviorRelay<[String]>.init(value: [])
        let relay2 = BehaviorRelay<[String]>.init(value: [])
        let relay3 = BehaviorRelay<[String]>.init(value: [])
                
        // relay1 을 relay2, 3와 bind!! > 이 부분 순서도 중요하다..
        relay1.bind(to: relay2, relay3).disposed(by: bag)
        
        // relay(subject)니까 구독설정을 해준다. 초기값이 오는건 염두에 두자(뭐 skip하도록 해되 되지만)
        relay1.subscribe(onNext: { nums in
            Log.i("[relay1] \(nums)")
        }).disposed(by: bag)
        relay2.subscribe(onNext: { nums in
            Log.i("[relay2] \(nums)")
        }).disposed(by: bag)
        relay3.subscribe(onNext: { nums in
            Log.i("[relay3] \(nums)")
        }).disposed(by: bag)
        
        // relay1에 bind(구독!!)하면 relay1, 2, 3에 전부 전달된다.
        stream3.bind(to: relay1).disposed(by: bag)
        
        print("🤡check - end!")
    }
}
