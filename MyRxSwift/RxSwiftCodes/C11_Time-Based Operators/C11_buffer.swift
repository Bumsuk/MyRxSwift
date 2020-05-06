//
//  C11_buffer.swift
//  MyRxSwift
//
//  Created by brown on 2020/03/13.
//  Copyright © 2020 brown. All rights reserved.
//

import Foundation


// [참고]
// http://reactivex.io/documentation/operators/buffer.html
// http://blog.davepang.com/post/649
// https://brunch.co.kr/@tilltue/9
public class C11_buffer {
    static let bag = DisposeBag()
    
    static func test_buffer1() {
        print(#function)
        
        Observable.of(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
        //Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)

        // count 의 갯수(3)를 만족하거나, 시간이 2초 지나면 방출, 시퀀스 완료되면 나머지 방출
        .buffer(timeSpan: .seconds(2), count: 3, scheduler: MainScheduler.instance)
        //.buffer(timeSpan: 2, count: 3, scheduler: MainScheduler.instance) // deprecated RxSwift 5.x
            
        .subscribe(onNext: { (result) in
            print(result)
        })
        .disposed(by: bag)
        
        print("🤡check - end")
    }
    
}

