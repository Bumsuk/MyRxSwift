//
//  C19_unwrap.swift
//  MyRxSwift
//
//  Created by brown on 2020/04/22.
//  Copyright © 2020 brown. All rights reserved.
//

import Foundation
import RxSwiftExt

public class C19_unwrap {
	static let bag = DisposeBag()

	// 옵셔널은 랩핑된 값을 풀어주고, nil은 제거해서 반환! > 편하다!
	// swift의 compactMap 사용이 이제 더 나을듯 함.
	public static func test_unwrap() {

		let source = Observable.of(1, 2, nil, Int?(4))
		let unwrapped = source.unwrap()

		unwrapped.subscribe { (num) in
			print("[unwrapped] \(num)")
		}.disposed(by: bag)
	
	}
	
	
}


