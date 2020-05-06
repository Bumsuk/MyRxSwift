//
//  ViewController.swift
//  ActionSample
//
//  Created by brown on 2020/05/06.
//  Copyright © 2020 brown. All rights reserved.
//

import UIKit
import RxSwift
import Action

// [결론!] 이걸 정말 적극적으로 써야할지 어떨지 확신이 안선다... 그리 좋은지 모르겠음....

class ViewController: UIViewController {
	
	@IBOutlet weak var btnTest: UIButton!
	
	@IBOutlet weak var tfID: UITextField!
	@IBOutlet weak var tfPasswd: UITextField!
	@IBOutlet weak var btnLogin: UIButton!
	
	var btnActionLogin: Action<(String, String), Bool>!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		
		test_simple()
		test_login()
	}
	
	func test_simple() {
		// 간단한 Action 동작 테스트
		let btnAction: CocoaAction = Action { // Action<Void, Void> 와 같다.
			print("🤡 간단 버튼 액션!")
			return Observable.empty()
		}
					
		btnTest.rx.action = btnAction
	}
	
	func test_login() {
		
		// 액션처리할 객체
		btnActionLogin = Action { credential in
			print("🤡 네트워크 통신을 이용한 로그인처리 버튼 액션!")
			let (name, passwd) = credential
			print("🤡 액션으로 전달된 입력값 : \(name), \(passwd)")
			// 더미작업으로 처리(예제니까)
			return Observable.just(true)
		}
		
		// 로그인시 입력할 ID, 암호 스트림
		let loginPasswodStream = Observable.combineLatest( tfID.rx.text.orEmpty,tfPasswd.rx.text.orEmpty, resultSelector: { id, passwd in
			return (id, passwd)
		})
		
		// btnActionLogin.execute(("초기값1 - id", "초기값2 - passwd"))
		
		// 버튼에 반응하는 스트림(id, 암호)
		_ = btnLogin.rx.tap
			.withLatestFrom(loginPasswodStream)
			.filter { !$0.0.isEmpty && !$0.1.isEmpty }
			.debug("⚡️⚡️")
			.bind(to: btnActionLogin.inputs)
//			.subscribe { result in
//				print("로그인 결과", result)
//			}
		
//		_ = loginPasswodStream.skip(1).subscribe { result in
//			print("구독결과", result)
//		}
		
		_ = btnActionLogin.errors.subscribe(onError: { error in
			// guard case .underlyingError(let err) = error else { return }
			// print("에러발생!", err)
		})
		
		
		_ = btnActionLogin.elements.subscribe { bResult in
			print("[액션 btnActionLogin 결과] \(bResult)")
		}

		
	}



}

