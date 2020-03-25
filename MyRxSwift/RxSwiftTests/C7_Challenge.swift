//
//  C4_Challenge.swift
//  MyRxSwift
//
//  Created by brown on 2020/03/02.
//  Copyright © 2020 brown. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension ObservableType {
  /**
   Takes a sequence of optional elements and returns a sequence of non-optional elements, filtering out any nil values.
   - returns: An observable sequence of non-optional elements
   */
  
  public func unwrap<T>() -> Observable<T> where Element == T? {
    return self.filter { $0 != nil }.map { $0! }
  }
}


public class C7_Challenge {
    
    static func exam1_starter() {
        let disposeBag = DisposeBag()
        
        let contacts = [
          "603-555-1212": "Florent",
          "212-555-1212": "Junior",
          "408-555-1212": "Marin",
          "617-555-1212": "Scott"
        ]
        
        let convert: (String) -> Int? = { value in
          if let number = Int(value), number < 10 {
            return number
          }
          
          let keyMap: [String: Int] = [
            "abc": 2, "def": 3, "ghi": 4,
            "jkl": 5, "mno": 6, "pqrs": 7,
            "tuv": 8, "wxyz": 9
          ]
          
          let converted = keyMap
            .filter { $0.key.contains(value.lowercased()) }
            .map { $0.value }
            .first
          
          return converted
        }
        
        let format: ([Int]) -> String = {
          var phone = $0.map(String.init).joined()
          
          phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 3)
          )
          
          phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 7)
          )
          
          return phone
        }
        
        let dial: (String) -> String = {
          if let contact = contacts[$0] {
            return "Dialing \(contact) (\($0))..."
          } else {
            return "Contact not found"
          }
        }
        
        let input = PublishSubject<String>()
        
        // Add your code here
        input
            .filter { str in
                if let num = convert(str), num < 10 {
                    return true
                } else {
                    return false
                }
            }
            .skipWhile { $0 == "0" }
            .map { convert($0)! }
            .take(10)
            //.map { "\($0)" }
            .toArray()
            .subscribe(onSuccess: { arr in
                let phoneNumber = format(arr)
                print(dial(phoneNumber))
            }).disposed(by: disposeBag)
        
        
        input.onNext("")
        input.onNext("0")
        input.onNext("408")
        
        input.onNext("6")
        input.onNext("")
        input.onNext("0")
        input.onNext("3")
        
        "JKL1A1B".forEach {
          input.onNext("\($0)")
        }
        
        input.onNext("9")
    }
    
    
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
        
        let convert: (String) -> Int? = { value in
          if let number = Int(value), number < 10 {
            return number
          }
          
          let keyMap: [String: Int] = [
            "abc": 2, "def": 3, "ghi": 4,
            "jkl": 5, "mno": 6, "pqrs": 7,
            "tuv": 8, "wxyz": 9
          ]
          
          let converted = keyMap
            .filter { $0.key.contains(value.lowercased()) }
            .map { $0.value }
            .first // Optional Int
          
          return converted
        }

        let format: ([Int]) -> String = {
          var phone = $0.map(String.init).joined()
          
          phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 3)
          )
          
          phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 7)
          )
          
          return phone
        }
        
        let dial: (String) -> String = {
          if let contact = contacts[$0] {
            return "Dialing \(contact) (\($0))..."
          } else {
            return "Contact not found"
          }
        }

        
        
        let input = PublishSubject<Int>()
        
        // Add your code here
        input
            .skipWhile { $0 == 0 } // 딱한번 true 일때 skip됨.
            .filter { $0 < 10 }
            .take(10)
            .toArray()
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



