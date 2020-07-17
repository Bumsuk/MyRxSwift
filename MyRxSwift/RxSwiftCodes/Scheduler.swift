//
//  Scheduler.swift
//  MyRxSwift
//
//  Created by brown on 2020/03/16.
//  Copyright © 2020 brown. All rights reserved.
//

import Foundation

// 지긋지긋한 스케줄러 설정을 확실히 마스터하자.
// 참고: https://pilgwon.github.io/blog/2017/10/14/RxSwift-By-Examples-4-Multithreading.html
// RxSwift 공식문서 : https://github.com/ReactiveX/RxSwift/blob/master/Documentation/Schedulers.md#custom-schedulers
public class Scheduler {
    
    static let bag = DisposeBag()
    
    // 현재 스레드 이름반환 함수 🤡
    static func currentQueueName() -> String {
        let name = __dispatch_queue_get_label(nil)
        return String(cString: name, encoding: .utf8)!
    }
    
    // 아주 기본적인 스케줄러 변경형태
    public static func test_scheduler0() {
        print(#function)
        _ = Observable.just("1111")
            .map { num -> String in
                print("[현제 스레드(map)] \(currentQueueName())")
                return "\(num)"
            }
			.subscribeOn(SerialDispatchQueueScheduler.init(qos: .default))
			.observeOn(MainScheduler.instance)
			.subscribe { event in
				print("[결과] \(event), 스레드 : \(currentQueueName())")
			}
        
        /*
        test_scheduler0()
        [현제 스레드(map)] rx.global_dispatch_queue.serial
        [결과] next(1111), 스레드 : com.apple.main-thread
        [결과] completed, 스레드 : com.apple.main-thread
        */
    }
    
    public static func test_scheduler1() {
        print(#function)
        
        
        let timer = Observable<Int>.timer(.seconds(0), period: .seconds(1), scheduler: SerialDispatchQueueScheduler.init(qos: .default))
        
        let mapCloser: (String) -> String = { str in
            print("[스레드] \(currentQueueName())")
            return str
        }
        
        // [스케줄러 종류]
        // 1. CurrentThreadScheduler (시리얼 스케줄러)
        /*
        현재 스레드에서 작업 단위를 예약합니다. 이것은 요소를 생성하는 연산자의 기본 스케줄러입니다.
        이 스케줄러는 때때로 "트램폴린 스케줄러"라고도합니다.
        일부 스레드에서 CurrentThreadScheduler.instance.schedule (state) {}가 처음 호출되면,
        예약 된 작업이 즉시 실행되고 재귀 적으로 예약 된 모든 작업이 일시적으로 대기하는 숨겨진 대기열이 생성됩니다.
        호출 스택의 일부 상위 프레임이 이미 CurrentThreadScheduler.instance.schedule (state) {}을 실행중인 경우,
        예약 된 작업은 현재 실행중인 작업과 이전에 대기열에 추가 된 모든 작업이 완료되면 대기열에 추가되고 실행됩니다.
        */
        
        // 2. MainScheduler (시리얼 스케줄러)
        /*
        MainThread에서 수행해야하는 작업을 추상화합니다. 메인 스레드에서 스케줄 메소드를 호출하는 경우 스케줄없이 즉시 조치를 수행합니다.
        이 스케줄러는 일반적으로 UI 작업을 수행하는 데 사용됩니다.
        */
        
        // 3. SerialDispatchQueueScheduler (시리얼 스케줄러)
        /*
        특정 dispatch_queue_t에서 수행해야하는 작업을 추상화합니다. 동시 디스패치 큐가 전달 되더라도 직렬 큐로 변환되는지 확인합니다.
        직렬 스케줄러는 observeOn에 대한 특정 최적화를 활성화합니다.
        기본 스케줄러는 SerialDispatchQueueScheduler의 인스턴스입니다.
        */

        /* 4. ConcurrentDispatchQueueScheduler (동시 스케줄러)
        특정 dispatch_queue_t에서 수행해야하는 작업을 추상화합니다. 직렬 디스패치 큐를 전달해도 아무런 문제가 발생하지 않습니다.
        이 스케줄러는 백그라운드에서 일부 작업을 수행해야 할 때 적합합니다.
        */

        /* 5. OperationQueueScheduler (동시 스케줄러)
        특정 NSOperationQueue에서 수행해야하는 작업을 추상화합니다.
        이 스케줄러는 백그라운드에서 수행해야하는 더 큰 작업 청크가 있고 maxConcurrentOperationCount를 사용하여 동시 처리를 미세 조정하려는 경우에 적합합니다.
        */
        
        timer.take(1)
            .map { num in
                print("[스레드] \(currentQueueName())")
                return "\(num)"
            }
            .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .background))
            .map(mapCloser)
            .observeOn(MainScheduler.instance)
            .map(mapCloser)
            .observeOn(ConcurrentDispatchQueueScheduler.init(qos: .background))
            .map(mapCloser)
            
            .observeOn(CurrentThreadScheduler.instance)
            
            //.observeOn(ConcurrentDispatchQueueScheduler.init(qos: .background))
            .observeOn(OperationQueueScheduler.init(operationQueue: .init()))
            .map(mapCloser)
            //.observeOn(MainScheduler.instance)
            .observeOn(OperationQueueScheduler.init(operationQueue: OperationQueue.init(), queuePriority: .high))

            .map(mapCloser)
            //.observeOn(ConcurrentMainScheduler.instance)
            .observeOn(MainScheduler.instance)
            //.subscribeOn(OperationQueueScheduler.init(operationQueue: .init()))
            .subscribe { (event) in
                print("[결과]", currentQueueName())
            }.disposed(by: bag)
        
    }
}
