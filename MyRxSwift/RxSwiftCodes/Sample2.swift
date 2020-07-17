//
//  Sample1.swift
//  MyRxSwift
//
//  Created by brown on 2020/02/24.
//  Copyright © 2020 brown. All rights reserved.
//

import Foundation
import RxSwift

public class Sample2 {

    static let disposeBag = DisposeBag()
    
    // [Observable 커스텀 생성 및 사용]
    public static func test2() {
        
        enum MyError: Error {
            case ErrorNormal(reason: String)
        }
        
        // Observable.create(<#T##subscribe: (AnyObserver<_>) -> Disposable##(AnyObserver<_>) -> Disposable#>)
        Observable<String>.create { observer in
            observer.onNext("준비 크하흐")
            
            // observer.onCompleted() // 완료시켜버리므로, 하단 코드 동작x
            observer.onError(MyError.ErrorNormal(reason: "암튼 잘못됐다!")) // 에러 발생
            
            observer.on(.next("크하하하1"))
            Thread.sleep(forTimeInterval: 2)
            observer.on(.next("크하하하2"))
            
            return Disposables.create()
        }
        .debug()
        .subscribe({
            print("[custom Observable] \($0)")
            }) //.disposed(by: disposeBag)
    }

    
    // deferred를 사용한 옵저버블 팩토리 사용 > 거의 사용을 하지는 않았는데 사용할 때도 있겠지??
	// 구독할때마다 상황에 맞는 시퀀스를 반환하는데 사용한다.
    public static func test3() {
        var flip: Bool = false
    
        //Observable.deferred(<#T##observableFactory: () throws -> Observable<_>##() throws -> Observable<_>#>)
        let stream = Observable<String>.deferred {
        
            flip.toggle()

            if flip == true {
                return Observable.of("참", "참", "참")
            } else {
                return Observable.of("거짓", "거짓", "거짓")
            }
        }
        
        stream.subscribe({
            print("[defered] \($0)")
            }).disposed(by: disposeBag)
        
        stream.subscribe({
            print("[defered] \($0)")
            }).disposed(by: disposeBag)

    }
    
    // Single 사용 #1
    public static func test4() {
        enum FileReadError: Error {
            case fileNotFound, unReadable, encodingFailed
        }
        		
//        Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
//        //.flatMap(<#T##selector: (Int) throws -> ObservableConvertibleType##(Int) throws -> ObservableConvertibleType#>)
//        .flatMap({
//            Observable.range(start: $0, count: 5)
//        })
//        //.asSingle()
//        .debug()
//        //.subscribe(<#T##observer: (SingleEvent<_>) -> Void##(SingleEvent<_>) -> Void#>)
//        .subscribe({ single in
//            print("[Single 테스트] \(single)")
//        })
//

        //Single.create(subscribe: <#T##(@escaping (SingleEvent<_>) -> Void) -> Disposable#>)
        //func create(subscribe: @escaping (@escaping Self.SingleObserver) -> RxSwift.Disposable) -> RxSwift.Single<Self.Element>
        let someSingle = Single<String>.create(subscribe: { single in
            // single(.error(FileReadError.fileNotFound))
            single(.success("성공!"))
            print("check")
            return Disposables.create()
            })
        
        //someSingle.subscribe(onSuccess: <#T##((String) -> Void)?##((String) -> Void)?##(String) -> Void#>, onError: <#T##((Error) -> Void)?##((Error) -> Void)?##(Error) -> Void#>)
        someSingle.subscribe(onSuccess: {
            print("[onSuccess]", $0)
        }, onError: {
            print("[onError]", $0)
        })
    }
    
    // Single 사용 #2 - 스레드 지정 처리
    public static func test5() {
        enum FileReadError: Error {
            case fileNotFound, unReadable, encodingFailed
        }

        func loadText(_ name: String) {
            let disposable = Disposables.create()

            if Thread.isMainThread {
               print("현재 메인 스레드야!!")
            }
                        
            let single = Single<String>.create(subscribe: { observer in
                guard let path = Bundle.main.path(forResource: name, ofType: "txt") else {
                    observer(.error(FileReadError.fileNotFound))
                    return disposable
                }

                guard let data = FileManager.default.contents(atPath: path) else {
                    observer(.error(FileReadError.unReadable))
                    return disposable
                }

                guard let contents = String(data: data, encoding: .utf8) else {
                    observer(.error(FileReadError.encodingFailed))
                    return disposable
                }
                
                observer(.success(contents))
                
                return disposable
            })

            //let workSingle = single.observeOn(ConcurrentMainScheduler.instance)
            let workSingle = single.observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            
            workSingle
            .map({
                print("[check]")
                return $0
            })
            .subscribe(onSuccess: {
                print("[onSuccess]", $0)
            }, onError: {
                print("[onError]", $0)
            }).disposed(by: disposeBag)
        }
        
        Observable.from([1, 2, 3])
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .do(onNext: { _ in
                print("[check]") }
            )
            .subscribeOn(MainScheduler.instance)
            .subscribe {
                print("[check] \($0)")
            }.disposed(by: disposeBag)
        
        
        
        loadText("someText")
    }
    
    // [do, debug 연산자 사용예]
    public static func test6() {
        /*
        let stream = Observable<Any>.never()
          .subscribe(
            onNext: { element in
              print(element)
            },
            onCompleted: {
              print("Completed")
            },
            onDisposed: {
              print("Disposed")
            }
        )
        print("check - 🤡")
        disposeBag.insert(stream)
        */
        
        
        /*
        let observable = Observable<Any>.never()
        let disposeBag = DisposeBag()

        observable
        .map({
            return $0
        })
        .do(onSubscribe: {
            print("Subscribed - Main? : \(Thread.isMainThread)")
        })
        .subscribe(
            onNext: { element in
              print(element)
            },
            onCompleted: {
              print("Completed")
            },
            onDisposed: {
              print("Disposed")
            }
        )
        .disposed(by: disposeBag)

        print("check - 🤡")
        */
        
        Observable.from(["허허","하하","헤헤","히히","호호",])
        .debug("[확인중🤑]", trimOutput: true)
        .subscribe({
            print("[🤡] \($0)")
        })
        
    }
    
    // [bind 테스트 - 간단]
    public static func test7() {
        Observable<Int>.from([1, 2, 3])
        //.debug()
        .flatMap({ num in Observable<Int>.interval(.seconds(2), scheduler: MainScheduler.instance) })
            //.flatMap(<#T##selector: (Int) throws -> ObservableConvertibleType##(Int) throws -> ObservableConvertibleType#>)
        //Observable<Int>.interval(.seconds(2), scheduler: MainScheduler.instance)
        .bind(onNext: { _ in
            print("[bind!]")
        })
            
//        .bind(onNext: {
//            print("[bind 결과]", $0)
//        })
        .disposed(by: disposeBag)
    }
        
    
}
