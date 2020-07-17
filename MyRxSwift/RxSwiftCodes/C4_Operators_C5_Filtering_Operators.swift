//
//  C4_Operators_C5_Filtering_Operators.swift
//  MyRxSwift
//
//  Created by brown on 2020/02/28.
//  Copyright © 2020 brown. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class C4_Operators_C5_Filtering_Operators {
    static let bag = DisposeBag()

    enum MyError: Error {
        case anError(_ reason: String?)
    }
     
	// [ignoreElement 테스트]
	static func test_ignoreElements() {
		print(#function)

		#if true
		let strike = PublishSubject<String>()
		let ignore = strike.ignoreElements()
		ignore
			.subscribe(onCompleted: { print("[completed!]") }, onError: { print("[error] \($0)") })
			.disposed(by: bag)
				
		strike.onNext("x")
		strike.onNext("x")
		strike.onNext("x")
		strike.onCompleted() // complete 이벤트가 발생해야 ignore 구독 결과가 표시됨!
		
		print("🤡check!")
		#else
		Observable.from([1, 2, 3])
			.ignoreElements()
			.subscribe(onCompleted: {
				print("[onCompleted]")
			}, onError: {
				print("[onError]", $0)
			}).disposed(by: bag)
		#endif
	}
	
	// 이 예제가 더 알기 쉽다 > 방출되는 것들을 무시하고 완료될때 complete 방출!
	static func test_ignoreElements2() {
		print(#function)
		
		_ = Observable<Int>.timer(.seconds(0), period: .seconds(1), scheduler: MainScheduler.instance)
			.take(10)
			.debug()
			.ignoreElements()
			.subscribe(onCompleted: {
				print("[10번 take, ignoreElements 완료!] 10초동안 아무것도 방출되지 않았음!")
			}, onError: { err in
				print("[error] \(err)")
			})
	}

	
    // [catchError 테스트]
    static func test_catchError() {
        print(#function)
        		
        let someDatas = [1, 2, 3, 4, 5]
        let publishSubject = PublishSubject<Int>()
        publishSubject
            .catchErrorJustReturn(1004)
            /* 이 두가지는 다르다.
            .catchError({ (error) in
                Observable.just(1004) // 다른 시퀀스로 이어나가게 할수 있다.
            })
            */
            .subscribe(onNext: { num in
                print("[확인] \(num)")
            }).disposed(by: bag)
        
        // 5초뒤 1초 간격으로 5번 bind 통해 onNext 처리
        Observable<Int>
            .timer(.seconds(5), period: .seconds(1), scheduler: MainScheduler.instance)
            .take(5)
            .map { idx in
                if idx == 3 { throw MyError.anError("idx == 3 에러 발생!") }
                return someDatas[idx]
            }
            .bind(to: publishSubject)
            .disposed(by: bag)
    }
    
    // [Error 전파 테스트]
    static func test_ErorrInChain() {
        print(#function)
        
        let publishSubject = PublishSubject<Int>()

        _ = publishSubject.subscribe({ event in
            print("[구독1]", event)
        })
        _ = publishSubject.subscribe({ event in
            print("[구독2]", event)
        })
        
        // 5초뒤 1초 간격으로 5번 bind 통해 onNext 처리
        Observable<Int>
            .timer(.seconds(5), period: .seconds(1), scheduler: MainScheduler.instance) // period 생략되면 1회만 방출! (헷갈리지 마라!)
            .debug("🤡check!")
            .take(5)
            .map { idx in
                if idx == 3 { throw MyError.anError("idx == 3 에러 발생!") }
                return idx
            }
            .bind(to: publishSubject)
            .disposed(by: bag)
    }

    
    
    // [timeOut 테스트]
    // 지정시간동안 시퀀스가 방출되지 않으면 에러를 방출!
    static func test_timeout() {
        print(#function)
        
        let stream = Observable<Int>
            .interval(.seconds(5), scheduler: MainScheduler.instance)
            .take(1)
			// 이건 스케줄러를 지정해 구독하고, 해당 시간동안 시퀀스를 받는거지, 에러를 반환하진 않음. 그냥 완료됨!
            //.take(.seconds(2), scheduler: MainScheduler.instance)
			.timeout(.seconds(2), scheduler: MainScheduler.instance)
        
        stream.subscribe { (event) in
            print("[구독결과]", event)
        }.disposed(by: bag)
        
        /*
        test_timeout()
        [구독결과] error(Sequence timeout.)
        */
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
            .elementAt(1) // 두번째 값만 방출하고 '종료!' 시킴
            .subscribe({ event in
                print("[구독] \(event)")
            }).disposed(by: bag)
        
        strikes.onNext("X1")
        strikes.onNext("X2")
        strikes.onNext("X3")
    }
	/*
	test_elementAt()
	[구독] next(X2)
	[구독] completed
	*/
        
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
        let trigger = PublishSubject<String>() // 얘는 말그대로 트리거 역할만함.
        
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
			//.takeLast(1)
            //.takeWhile(T##predicate: (Int) throws -> Bool##(Int) throws -> Bool)
            .takeWhile { $0 < 3 }
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
    
    // [takeUntil 사용의 예] > 방식은 skipUntil과 반대.
    // 생략
        
    // [distinctUntilChanged 사용예 #1]
    static func test_distinctUntilChanged() {
        print(#function)

        Observable.from([1, 1, 2, 2, 3, 3])
            //.distinctUntilChanged()
			.distinctUntilChanged({ $0 == $1 })
            .subscribe({ num in
                print("[distinctUntilChanged 구독] \(num)")
            }).disposed(by: bag)
    }
	

}
