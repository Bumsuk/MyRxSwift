//
//  Example.swift
//  MyRxSwift
//
//  Created by brown on 2020/02/24.
//  Copyright © 2020 brown. All rights reserved.
//

import Foundation

// 내가 직접 코딩하는 부분에서는 필요없다. 중요한 코드도 아니고..
public func example(of description: String, action: () -> Void) {
    print("\n--- Example of:", description, "---")
    action()
}

