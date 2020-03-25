//
//  ViewController.swift
//  MyRxSwift
//
//  Created by brown on 2020/02/13.
//  Copyright © 2020 brown. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

// 이렇게 수동으로 확장도 가능하다.
extension Reactive where Base: UISwitch {
    func hello() { print("안뇽 범석!") }
    var tap: ControlEvent<Void> {
        return controlEvent(.touchUpInside)
    }
}

extension Reactive where Base: UIButton {
    var longTap: ControlEvent<Void> {
        return controlEvent(.touchDownRepeat)
    }
}

// MARK: ====
class ViewController: UIViewController {
    @IBOutlet weak var swTemp: UISwitch!
    @IBOutlet weak var btnClick: UIButton!
    var disposeBag: DisposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
                   
        // ThottleDebounce.test_throttle()
        // ThottleDebounce.test_debounce()
        
        //MakeObserver_Sample.makeObserver_test1()

        // C0_Bind_Binder_Etc.test_bind_to_relays()
        
        // C0_MySnippet.test_delaySubscription()
        // C0_MySnippet.test_debug()
        // C0_BInd_Binder_Etc.test_bind1()
        // C0_BInd_Binder_Etc.test_bind_to_relay()

        // Multicast_Publish_Share.test_multicast()
        // Multicast_Publish_Share.test_publish()
        // Multicast_Publish_Share.test_replay()
        // Multicast_Publish_Share.test_replay_simple()
        // Multicast_Publish_Share.test_replayAll()
        // Multicast_Publish_Share.test_share()
        // Multicast_Publish_Share.test_share_option_test()
        // Multicast_Publish_Share.test_share_api_requests()
        
        // check_TRACE_RESOURCES()
                                
        // testUI_Switch()
        // testUI_Button()
        
        // testNotiCenter()
        // testNotiCenterKeyboard()
    
        // sample1_test()
        // sample2_test()
        
        // Sample2.test8()
        
        // C3_Subject.test0()
        // C3_Subject.test1()
        // C3_Subject.test2()
        // C3_Subject.test3_ReplaySubject()
        
        // C3_Relay.test_PublishRelay()
        // C3_Relay.test_BehaviorRelay()
        C3_Relay.test_BehaviorRelay_force_sendError()
        
        // C3_Relay.test_Challange1()
        // C3_Relay.test_Challange2()
        
        // C4_Operators.test_skipUntil()
        // C4_Operators.test1()
        // C4_Challenge.exam1()
        // C4_Operators.test_timeout()
        // C4_Operators.test_catchError()
        // C4_Operators.test_ErorrInChain()
        
        // C6_Filtering_Operator.test_No_Share()
        // C6_Filtering_Operator.test_Share()
        // C6_Filtering_Operator.test_Share_Normal()
        // C6_Filtering_Operator.test_Share_Sample1()
        // C6_Filtering_Operator.test_Share_Subject()
        
        // C7_Transforming.test_toArray()
        // C7_Transforming.test_toArray_error()
        // C7_Transforming.test_map()
        // C7_Transforming.test_flatMap1()
        // C7_Transforming.test_flatMap1()
        // C7_Transforming.test_flatMap_why()
        // C7_Transforming.test_flatMapLatest2()
        // C7_Transforming.test_Materialize()
        // C7_Challenge.exam1_starter()
        
        // C9_Combining_Operators.test_startWith()
        // C9_Combining_Operators.test_concat()
        // C9_Combining_Operators.test_concat_withError()
        // C9_Combining_Operators.test_concatMap1()
        // C9_Combining_Operators.test_concatMap2()
        // C9_Combining_Operators.test_concatMap3()
        // C9_Combining_Operators.test_merge1()
        // C9_Combining_Operators.test_merge2()
        // C9_Combining_Operators.test_combineLatest()
        // C9_Combining_Operators.test_zip()
        // C9_Combining_Operators.test_combineLatest2()
        // C9_Combining_Operators.test_latestFrom()
        // C9_Combining_Operators.test_sample()
        // C9_Combining_Operators.test_amb()
        // C9_Combining_Operators.test_merge_with_APIs()
        
        // C9_Combining_Operators.test_amb_exercie()
        // C9_Combining_Operators.test_amb_exercie2()
        // C9_Combining_Operators.test_switchLatest()
        // C9_Combining_Operators.test_reduce()
        // C9_Combining_Operators.test_scan()
        // C9_Combining_Operators.test_scan2()
        // C9_Combining_Operators.test_scan_advance1()
        
        // C9_Combining_Operators.test_scan_with_noZip()
        // C9_Combining_Operators.test_scan_with_Zip()
        
        // C11_buffer.test_buffer1()
        // C11_window.test_window1()
        // C11_delaySubscription.test_delaySubscription()
        // C11_Timer_Repeat_Timeout.test_timer_repeat()
        // C11_Timer_Repeat_Timeout.test_timer_no_repeat()
        // C11_Timer_Repeat_Timeout.test_timer_timeout()
        // C11_Timer_Repeat_Timeout.test_timer_timeout_other()
        
        // 스케줄러 변환 사용!!
        // Scheduler.test_scheduler0()
        // Scheduler.test_scheduler1()
        
        // ErrorRecovery.test_retry1()
        // ErrorRecovery.test_retry2()

        // ErrorRecovery.test_retryWhen1()
        // ErrorRecovery.test_retryWhen2()

        // ErrorRecovery.test_materlize()
        // ErrorRecovery.test_materlize_simple()
        
        // ErrorRecovery.test_throw_error1()

    }
    
    
    // TRACE_RESOURCES 확인
    func check_TRACE_RESOURCES() {
        #if TRACE_RESOURCES
        print("TRACE_RESOURCES 선언됨!")
        #else
        print("TRACE_RESOURCES 선언 안됨!")
        #endif
    }

    func testUI_Button() {
        // 직접 확장한 longTap
        btnClick.rx.longTap
            .subscribe { event in
            print("[longTap event] \(event)")
        }.disposed(by: disposeBag)
        
        let tap$ = btnClick.rx.tap
        let tapDebounce$ = tap$.debounce(.milliseconds(500), scheduler: MainScheduler.instance)
        
        tapDebounce$.subscribe { event in
            print("[tap event] \(event)")
        }
    }
    
    func testUI_Switch() {
        swTemp.rx.tap.subscribe {
            print("[스위치 탭!] \($0)")
        }
        
        swTemp.rx.isOn.subscribe(onNext: {
            print("[스위치 상태] \($0)")
            }).disposed(by: disposeBag)
    }
    
    func testNotiCenter() {
        let notiName = Notification.Name("크하하하")
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidChangeFrameNotification,
                                               object: nil,
                                               queue: nil,
                                               using: {
                                                print("[노티피케이션]", $0)
        })
        NotificationCenter.default.post(name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        
        NotificationCenter.default.addObserver(forName: notiName,
                                               object: nil,
                                               queue: nil,
                                               using: {
                                                print("[노티피케이션 - 커스텀]", $0)
        })
        NotificationCenter.default.post(name: notiName, object: "object 정보1")
        NotificationCenter.default.post(name: notiName, object: "object 정보2", userInfo: ["name": "범석", "gender": "male"])

        // 전부 제거
        NotificationCenter.default.removeObserver(self)
    }
    
    func testNotiCenterKeyboard() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil, using: {
            print("[키보드 보일 예정!]", $0)
        })
    }

}
