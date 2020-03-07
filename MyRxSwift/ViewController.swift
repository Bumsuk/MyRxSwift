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
                
        
        // check_TRACE_RESOURCES()
        
        // Do any additional setup after loading the view.
                                
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
        // C3_Relay.test_Challange1()
        // C3_Relay.test_Challange2()
        
        // C4_Operators.test1()
        // C4_Challenge.exam1()
        
        // C6_Filtering_Operator.test_No_Share()
        // C6_Filtering_Operator.test_Share()
        // C6_Filtering_Operator.test_Share_Normal()
        //C6_Filtering_Operator.test_Share_Sample1()
        //C6_Filtering_Operator.test_Share_Subject()
        
        // C7_Transforming.test_toArray()
        // C7_Transforming.test_map()
        C7_Transforming.test_flatMap1()
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
