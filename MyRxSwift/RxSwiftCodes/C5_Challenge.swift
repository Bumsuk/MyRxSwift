//
//  C5_Challenge.swift
//  MyRxSwift
//
//  Created by brown on 2020/03/02.
//  Copyright © 2020 brown. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class C5_Challenge {
    
    static func exam1() {
        let disposeBag = DisposeBag()
        
        let contacts = [
          "603-555-1212": "Florent",
          "212-555-1212": "Junior",
          "408-555-1212": "Marin",
          "617-555-1212": "Scott"
        ]
        
        func phoneNumber(from inputs: [Int]) -> String {
            var phone = inputs.map(String.init).joined()
            phone.insert("-", at: phone.index(phone.startIndex, offsetBy: 3))
            phone.insert("-", at: phone.index(phone.startIndex, offsetBy: 7))
            return phone
        }
        
        let input = PublishSubject<Int>()
        
        // Add your code here
        input
        .debug("d-1")
          .skipWhile { $0 == 0 } // 딱한번 true 일때 skip됨.
        .debug("d-2")
          .filter { $0 < 10 }
        .debug("d-3")
          .take(10)
        .debug("d-4")
          .toArray()
        .debug("d-5")
        .subscribe({ event in
            print("check - \(event)")
            switch event {
            case .success(let result):
                let phone = phoneNumber(from: result)
                if let contact = contacts[phone] {
                  print("Dialing \(contact) (\(phone))...")
                } else {
                  print("Contact not found")
                }
            case .error(let error):
                print("[error] \(error)")
            }
        }).disposed(by: disposeBag)
            
            
          /* 원본 코드이지만 문제가 있었다.
          .subscribe(onSuccess: {
            let phone = phoneNumber(from: $0)
            
            if let contact = contacts[phone] {
              print("Dialing \(contact) (\(phone))...")
            } else {
              print("Contact not found")
            }
          })
          .disposed(by: disposeBag)
          */
                
        input.onNext(0)
        input.onNext(603)
        
        input.onNext(2)
        input.onNext(1)
        
        // Confirm that 7 results in "Contact not found", and then change to 2 and confirm that Junior is found
        input.onNext(2)
        
        "5551212".forEach {
          if let number = (Int("\($0)")) {
            input.onNext(number)
          }
        }
        
        input.onNext(9)

    }
}



