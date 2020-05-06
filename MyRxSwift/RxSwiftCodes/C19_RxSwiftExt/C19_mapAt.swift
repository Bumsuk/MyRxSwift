//
//  C19_mapAt.swift
//  MyRxSwift
//
//  Created by brown on 2020/04/22.
//  Copyright © 2020 brown. All rights reserved.
//

import Foundation
import RxSwiftExt

public class C19_mapAt {
	static let bag = DisposeBag()
	
	public static func test_mapAt() {
		
		Observable.from([1, 2, 3, 4])
			.bind { num in
				print("[거봐라!] \(num)")
			}
		
		
	}
	
	
}

