//
//  C11_Timer.swift
//  MyRxSwift
//
//  Created by brown on 2020/03/14.
//  Copyright © 2020 brown. All rights reserved.
//

import Foundation

public class C11_Timer_Repeat_Timeout {
    static let bag = DisposeBag()

    // interval 은 생략한다.
        
    static func test_timer_no_repeat() {
        print(#function)

        // 반복안하는 타이머 // period 생략되면 1회만 방출! (헷갈리지 마라!)
        let timer = Observable<Int>.timer(.seconds(2), scheduler: MainScheduler.instance)
        .map({ _ in "흠흠" })
        .subscribe(onNext: { print("결과 - \($0)") })
        
        // 타이머를 취소하려면 dispose로 가능
        //timer.dispose()
    }
    
    // 2초간 계속 반복 타이머
    static func test_timer_repeat() {
        print(#function)
        
        // period 생략되면 1회만 방출! (헷갈리지 마라!)
        let timer = Observable<Int>.timer(.seconds(0), period: .seconds(2), scheduler: MainScheduler.instance)
        .map({ _ in "흠흠" })
        .enumerated()
        .subscribe(onNext: { print("결과 - \($0)") })
        
        // 타이머를 취소하려면 dispose로 가능 > disposeBag에 넣는건 상황에 맞춰서...
        //timer.dispose()

    }

    // 타임아웃! 지정시간동안 emit 안되면 RxError(RxError.timeout) 발생
    static func test_timer_timeout() {
        print(#function)
        
        // 일부러 5초 emit 딜레이 준 상태에서, 타임아웃 2초 설정 >
        Observable.just("안녕하세요!")
            .delay(.seconds(5), scheduler: MainScheduler.instance)      // 구독은 즉시하되, emit을 5초 뒤로!
            .timeout(.seconds(2), scheduler: MainScheduler.instance)    // 2초간 emit 안되면, 타임아웃 에러
            .subscribe({ event in
                print("[결과] \(event)")
            }).disposed(by: bag)
        /*
        [결과] error(Sequence timeout.)
        */
    }
    
    // other 타입 timeout 사용!
    static func test_timer_timeout_other() {
        print(#function)
        
        // 일부러 5초 emit 딜레이 준 상태에서, 타임아웃 2초 설정
        let otherForTimeout = Observable.just("다시, 안녕요!")
        
        Observable.just("안녕하세요!")
            .delay(.seconds(5), scheduler: MainScheduler.instance)
            .timeout(.seconds(2), other: otherForTimeout, scheduler: MainScheduler.instance)
            //.timeout(.seconds(2), other: Observable.from(["하하", "크크", "이거 other로 설정한거야!"]), scheduler: MainScheduler.instance)
            .subscribe({ event in
                print("[결과] \(event)")
            }).disposed(by: bag)
        /*
         test_timer_timeout_other()
         [결과] next(다시, 안녕요!)
         [결과] completed
        */
    }


}
