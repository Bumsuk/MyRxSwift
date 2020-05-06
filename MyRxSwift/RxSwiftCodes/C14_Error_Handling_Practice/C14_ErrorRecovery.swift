//
//  ErrorRecovery.swift
//  MyRxSwift
//
//  Created by brown on 2020/03/23.
//  Copyright © 2020 brown. All rights reserved.
//

import Foundation
import AudioToolbox

enum MyError: Error {
    case anError(String)
}

class ErrorRecovery {
    static let bag = DisposeBag()
    
    // [throw Error 기본 개념]
    // 아주 중요하다!
    static func test_throw_error1() {
        print(#function)
        		
        // period 생략되면 1회만 방출! (헷갈리지 마라!)
        _ = Observable<Int>.timer(.seconds(1), period: .seconds(1), scheduler: MainScheduler.instance)
            
            // #1 - Error 객체 만들어 throw로 발생시키는 방법
            /*
            .map { num -> Int in
                guard num != 2 else { throw NSError.init(domain: "수동 에러!", code: 0, userInfo: nil) }
                return num
            }
            */
            
            // #2 - Observable.error()로 발생시키는 방법
            .flatMap { num -> Observable<Int> in
                num == 5 ? .error(NSError.init(domain: "에러!", code: 0, userInfo: nil)) : .just(num)
            }
            
            .subscribe(onNext: { num in
                print("[결과]", num)
                //NSLog("[결과] %s", num)
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            })
    }
    
    
    // [retry 테스트 - 간단]
    // retry를 하게 되면 에러발생시 source Observable를 dispose 하고 다시 subscribe가 된다. 유의할것!
    // 이건 마치 merge 사용시 각각의 observable들이 subscribe되는 것과 같다.
    // 내부 소스를 보면 당연히 이렇게 구현해야... chainning 이 될테니....
    public static func test_retry1() {
        print(#function)
        
        var retryCount = 0
        let someStream = Observable<Int>.create({ observer in
            defer { retryCount += 1 }
            if retryCount < 3 {
                observer.on(.error(MyError.anError("수동 에러 발생시킴!")))
            } else {
                observer.onNext(7272727272)
            }
            return Disposables.create()
        })
        
        someStream
            .debug("[someStream]")
            .retry(5)
            .subscribe({ event in
                print("[결과]", event)
            }).disposed(by: bag)
    }
    
    // [retry 테스트 - 간단]
    // .retry(1) ... 는 의미가 없다!!! retry(2)를 해야 제대로된 재시도를 한다!
    public static func test_retry2() {
        print(#function)
        
        // retry를 시도하면 다시 처음부터 시작한다는 예를 보여줌.
        let someStream = Observable<Int>.create({ observer in
            print("🤓 시퀀스 생성!")
            observer.onNext(111)
            observer.onNext(222)
            
            observer.onError(MyError.anError("에러!"))
            // 간단하게 테스트를 위해 NSError 객체를 만들어서 사용해도 되지만, 프로덕션 환경에서는 제대로된 Error 프로토콜 conform된 객체를 사용해야겠지?
            // observer.onError(NSError.init(domain: "크허허헝 에러 도메인!", code: 7272, userInfo: nil))
            
            observer.onNext(333)
            observer.onCompleted()
            
            return Disposables.create()
        })
        
        someStream
            .debug("[someStream]")
            
            // retry시에 딜레이를 주고 싶을때 이렇게 사용할수도 있지만,
            // RxSwiftExt 리포에서 제공하는 확장된 RepeatBehavior 를 사용해도 될것 같다.
            // https://yoxisem544.github.io/exponential-retry/
            .do(afterError: { (_) in
                print("[aferError] 2초 기다리고 재시작!")
                Thread.sleep(forTimeInterval: TimeInterval(2))
            })
            
            //.retry(1) ... 는 의미가 없다. retry(2)를 해야 제대로된 재시도를 한다!
            .retry(2)
            
            .subscribe({ event in
                print("🤡[결과]", event)
            }).disposed(by: bag)
    }
    
    
    
    // [test_retryWhen 테스트]
    // https://brunch.co.kr/@tilltue/8
    /* 명확하게 잘 이해되지 않는다. 나중에 써먹을때 다시 한번 체크해보자.
     - 재시도 하는 시점을 지정할 수 있고, 한번만 수행한다.
     - retry 와 다르게 마지막 Error를 이벤트로 전달하지 않는다.
     */
    
    /*
    알아야 할 중요한 사항은 notificationHandler 유형이 TriggerObservable 유형이라는 것.
    observable 트리거는 일반 Observable 또는 Subject 일 수 있으며 임의 시간에 재 시도를 트리거하는 데 사용한다.
    */
    // [!!!] 결국 retryWhen을 사용하는 기본적인 이유(복잡한 상황도 있을수 있다)는 재시도하기전에 몇초의 딜레이를 주는 목적!
	// >> 정말 맞냐> 검증해라! 더 써보자.
    // 혹은 notificationHandler에서 반환하는 시퀀스가 complete 안되는 녀석으로 반환하고 계속 대기타면서 조건에 맞게 되면 retry 되게 할수 있다!
    
    // 혹은 에러를 회피하여 어떻게든 동작을 시키기 위한 방편이다.
    // 매우 매우 사용하기에 좋고, 실무에서 많이 쓸만한 오퍼레이터!
    // !!!14장, Error Handling in Practice(14장에 포함된 샘플 프로젝트(starter_MY >> 향후 참고할 프로젝트!! > 챌린지 내용도 포함) 를 참고해봐라.
    public static func test_retryWhen1() {
        print(#function)
        
        let someStream = Observable<String>.create { (observer) -> Disposable in
            print("🤡[create!]")

            //observer.onNext("Normal Value")
            //observer.onNext("1111")
            observer.onError(MyError.anError("에러 값!"))
                
            return Disposables.create {
                print("[disposed!]")
            }
        }
        
        
        // #1 - 재시도 횟수를 정해두고 처리하는 방법
        /*
        let maxRetryAttempt = 3
        _ = someStream
            .debug("🤓[someStream]")
        	// .retryWhen(<#T##notificationHandler: (Observable<Error>) -> ObservableType##(Observable<Error>) -> ObservableType#>)
            .retryWhen({ errorSequence in

                errorSequence
                    .enumerated()
                    .observeOn(MainScheduler.asyncInstance)
                    .flatMap { idx, error -> Observable<Int> in
                        if idx < 3 {
                            // 지정된 횟수동안 재시도를 하는데, 딜레이가 필요하니 이렇게 준다. 단, complete되는 시퀀스여야 함!
                            return Observable<Int>
                                .timer(.seconds(3), scheduler: MainScheduler.instance)
                                .do(onNext: { _ in print("3초 대기완료!") })
                        } else {
                            // 재시도 했지만 결국 해결이 안됐으니, 원래 전달해야 했던 에러 전달!
                            return Observable.error(error)
                        }
                    }
            })
        */

            
        // #2 - 잘못된 case > 왜냐면, error가 유실되어 버린다. 그냥 3초 딜레이 이후 complete되어 버린다.
        // 상황에 따라서는 가능한 시나리오가 있을수는 있겠으나....
        /*
        .retryWhen({ errObservable -> Observable<Int> in
            print("3초 딜레이!")
            return Observable.timer(.seconds(3), scheduler: MainScheduler.instance)
        })
        */
        
        // #3 - 복잡한 예(에러 처리전략 적용)
        //.retryWhen(<#T##notificationHandler: (Observable<Error>) -> ObservableType##(Observable<Error>) -> ObservableType#>)
        // recusive하게 반복하면서 retry를 할수 있게 처리할수 있다!
        // 14장, Error Handling in Practice 를 참고해봐라.
        // Reentrancy anomaly was detected 에러가 나는데... 별 문제 없는것 같다. (회피방법도 제시해주니 그대로 하면 OK)
         .retryWhen({ (errObservable) in
             return errObservable.enumerated().flatMap { attempt, error -> Observable<Int> in
                 if attempt >= 3 {
                     return Observable.error(error)
                 }
                 return Observable<Int>.timer(.seconds(1), scheduler: MainScheduler.instance).take(1)
             }
         })
        
        
        .subscribe { event in
            print("🤡[구독] \(event)")
        }
        
        // #3 - retryWhen() 사용시, notificationHandler가 반환하는 시퀀스가 종료될때 retry가 된다는 것에 착안한 방법
        // !!!14장, Error Handling in Practice(14장에 포함된 샘플 프로젝트(starter_MY >> 향후 참고할 프로젝트!! > 챌린지 내용도 포함) 를 참고해봐라.
        
        // notificationHandler를 바깥으로 빼서 사용하는 경우
        
        /* 컴파일은 안되니, 실제 프로젝트에서 테스트해볼것!
        let retryHandler: (Observable<Error>) -> Observable<Int> = { err in
            return err.enumerated().flatMap { attempt, error -> Observable<Int> in
                // 에러 처리
                if attempt >= maxAttempts - 1 {
                    return Observable.error(error)
                }
                    // 이 코드의 의미! > api 키값이 올바르지 않은 경우, 그리고 apiKey가 ""로 설정을 해놨다면,
                    // 올바른 apikey값을 입력(requestKey()의 alert 통해)되면, "filter { !$0.isEmpty }" 부분이 통과되고
                    // retry 되어 다시 날씨값을 가져오도록 시도된다!! 와.... 이거 대단하다.. 근데 너무 복잡혀.....
                else if let casted = error as? ApiController.ApiError, casted == .invalidKey {
                    return ApiController.shared.apiKey
                        // .do(onNext: delayClosure) // 이거 내가 추가한 테스트코드 > 쓰잘뗴기 없다.
                        //  BehaviorSubject<String> 객체인데 filter가 먹는다! > 당연혀!
                        .filter { !$0.isEmpty }
                        .map { _ in 1 } // Observable<Int> 반환값을 맞추기위한 Dummy형식
                }
                print("🤡 >>> retrying after \(attempt + 1) seconds >>>")
                return Observable<Int>.timer(.seconds(5), scheduler: MainScheduler.instance).take(1)
            }
        }
        */
    }
    
    // materlize와 dematerlize는 보통 같이 사용한다.
    public static func test_materlize_simple() {
        print(#function)
        
        let numbers: [Int] = [1, 2, 3, 0, 4, 5]
        
        _ = Observable<Int>
            .timer(.seconds(1), period: .seconds(1), scheduler: MainScheduler.instance)
            .debug("🦹‍♂️🦹‍♂️🦹‍♂️")
            .take(numbers.count)
            .map { numbers[$0] }
            .flatMap({ num -> Observable<Any> in
                if num == 0 {
                    return Observable.error(NSError.init(domain: "에러!", code: 0, userInfo: nil))
                } else {
                    return Observable.just(num)
                }
            })
            
            .materialize()
            
            .subscribe(onNext: {
                print("🤡[결과]", $0)
            })
            
            /*
            .take(Int(numbers.count))
            .map({ num in numbers[num] })
            .flatMap {
                if $0 == 0 {
                    return Observable.error(NSError.init(domain: "에러!", code: 0, userInfo: nil))
                } else {
                    return Observable.just($0)
                }
            }
            .subscribe(onNext: { print("🤡[결과]", $0) })
            */
        
        
        //let someStream = PublishSubject<Int>()
    }
    
    // materlize와 dematerlize는 보통 같이 사용한다.
    public static func test_materlize() {
        print(#function)

        enum MyError: Error {
            case anError(String)
        }

        struct Student {
            var score = BehaviorSubject.init(value: 0)
        }
        
        let s1: Student = .init(score: BehaviorSubject<Int>(value: 80))
        let s2: Student = .init(score: BehaviorSubject<Int>(value: 100))
                
        let subject: BehaviorSubject<Student> = .init(value: s1)
                
        subject.flatMap { $0.score }
        .debug("[🦹‍♂️check!]")
            
            .materialize()
//            .dematerialize()
            
            .subscribe(onNext: { num in
                print("🤡[결과] \(num)")
            })
        
        s1.score.onNext(81)
        
        s1.score.onError(MyError.anError("s1 에러!"))
        
        subject.onNext(s2)
        
        s1.score.onNext(82)
        
        s2.score.onNext(101)
        
    }
    
}
