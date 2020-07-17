//
//  Sample3.swift
//  MyRxSwift
//
//  Created by brown on 2020/07/17.
//  Copyright © 2020 brown. All rights reserved.
//

import Foundation
import RxSwift

public class Sample3 {
	static let disposeBag = DisposeBag()
	
	// Completable 시퀀스가 success 되면, 같이 묶은 시퀀스를 출력한다. concat의 확장형!
	public static func test_andThen() {
		print(#function)
		
		let stream1 = Observable.of(1, 2).ignoreElements()
		let stream2 = Observable.of(3, 4).ignoreElements()
//		let stream2 = Completable.create { observer -> Disposable in
//			observer(.error(NSError.init(domain: "강제 에러!!", code: 0, userInfo: nil)))
//			return Disposables.create()
//		}

		// case1 - stream1 success되면 10, 20, 30 방출!
		stream1.andThen(Observable.from([10, 20, 30]))
			.subscribe {
				print("완료1! - \($0)")
			}.disposed(by: disposeBag)
		
		// case2 - stream1이 success되고 stream2도 success 되어야 complete 됨!
		stream1
			.andThen(stream2)
			.subscribe { event in
				print("완료2! - \(event)")
			}
			.disposed(by: disposeBag)
		
		print("🤡check!")
	}
	
	public static func test1() {
		enum MyError: Error {
			case normal
			case complex(String)
		}
		
		var stream = Observable<Int>.create { (observer) -> Disposable in
			observer.onNext(1)
			observer.onError(NSError.init(domain: "", code: 0, userInfo: nil))
			observer.onNext(2)
			return Disposables.create()
		}
		
		stream = Observable.empty()
		stream = Observable.range(start: 777, count: 10)
		stream = Observable.create({ observer -> Disposable in
			let start = 777
			for num in 0...10 {
				observer.onNext(start+num)
			}
			// observer.onError(MyError.complex("허허허"))
			return Disposables.create()
		})
		
		stream
			.do(onCompleted: {
				print("[do - onCompleted]")
			}, onDispose: {
				print("[do - onDispose]")
			})
			.subscribe {
				print("[구독] \($0)")
				if case .error(let err) = $0, let myError = err as? MyError {
					if case .complex(let str) = myError {
						print("[에러!] str = \(str)")
					}
				}
			}
			.disposed(by: disposeBag)
	
		print("🤡check!")
	}
	
}
