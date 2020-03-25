//
//  MakeObserver.swift
//  MyRxSwift
//
//  Created by brown on 2020/03/14.
//  Copyright © 2020 brown. All rights reserved.
//

import Foundation

public class MakeObserver_Sample {
    static let bag = DisposeBag()
    
    // 옵저버로 객체로 만들어서 다양하게 사용해보자.
    static public func makeObserver_test1() {
        print(#function)
        
        let stream = Observable<Int>.interval(.seconds(2), scheduler: MainScheduler.instance)
        
        struct MyObserver: ObserverType {
            var name: String = "디폴트"
            init(name: String) {
                self.name = name
            }
            func on(_ event: Event<Int>) {
                switch event {
                case .next(let number): print("\(name) [next] \(number)")
                case .completed:        print("\(name) [completed]")
                case .error(let error): print("\(name) [error] \(error)")
                }
            }
        }
         
        let observer1 = MyObserver.init(name: "1번 옵저버")
        
        stream.subscribe(observer1).disposed(by: bag)
        
        print("🤡check - end!")
    }
    
}
