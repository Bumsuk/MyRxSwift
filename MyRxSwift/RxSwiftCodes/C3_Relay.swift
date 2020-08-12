//
//  3_Relay.swift
//  MyRxSwift
//
//  Created by brown on 2020/02/26.
//  Copyright © 2020 brown. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

// 본격적으로 서적의 소스를 실습하면서 추후 레퍼런싱 가능하도록 구성한다.
public class C3_Relay {
    static let disposeBag = DisposeBag()

    enum MyError: Error {
        case anError
    }

    public static func test_PublishRelay() {
		print(#function)

        let relay = PublishRelay<String>() // Relay는 각각의 Subject들을 랩핑하고 있다. 종료없음/에러없음!
        relay.accept("가")
        
        relay.subscribe(onNext: {
            print("[relay] \($0)")
        })
        .disposed(by: disposeBag)
        
        relay.accept("나")
        relay.accept("다")
        
        print("end - 🤡")
    }
    
    public static func test_BehaviorRelay() {
		print(#function)

        let relay = BehaviorRelay<String>(value: "-초기값-")
        relay.accept("1")
        relay.accept("2")
        
        relay.subscribe({
            print("[1]", $0)
        }).disposed(by: disposeBag)
     
        relay.subscribe({
            print("[2]", $0)
        }).disposed(by: disposeBag)
        
        print("end - 🤡")
    }
    
    // BehaviorRelay는 에러/완료 안되는 trait 그렇다면 강제로 bind 하여 에러를 보내면?
    // bind 자체가 UI에서 사용하려고 만든 trait이고, 에러가 송출되는 시퀀스를 bind하면 디버그에선 fatalError!, 릴리즈에선 로그!
    // 암튼 애초에 말이 안되는 상황이므로 고려하지 말자!
    public static func test_BehaviorRelay_force_sendError() {
		print(#function)

        let relay = BehaviorRelay<String>(value: "-초기값-")
        relay.subscribe({
            print("[결과]", $0)
        }).disposed(by: disposeBag)
        
        let stream = PublishSubject<String>()
        _ = stream.asObserver()
            //.catchErrorJustReturn("에러 - 복구!") // bind는 에러가 난다!@
            .bind(to: relay)
        
        stream.onNext("1")
        stream.onNext("2")
        stream.onNext("3")
        
        stream.onError(MyError.anError)

        print("end - 🤡")
    }

    

    // 당연히 AysncRelay 는 존재하지 않는다. Completed 되어야 값이 emit 되므로, Relay의 의미를 생각해보면 존재할수가 없겠지.
    
    // 연습문제1
    public class func test_Challange1() {
		print(#function)

        let cards = [
          ("🂡", 11), ("🂢", 2), ("🂣", 3), ("🂤", 4), ("🂥", 5), ("🂦", 6), ("🂧", 7), ("🂨", 8), ("🂩", 9), ("🂪", 10), ("🂫", 10), ("🂭", 10), ("🂮", 10),
          ("🂱", 11), ("🂲", 2), ("🂳", 3), ("🂴", 4), ("🂵", 5), ("🂶", 6), ("🂷", 7), ("🂸", 8), ("🂹", 9), ("🂺", 10), ("🂻", 10), ("🂽", 10), ("🂾", 10),
          ("🃁", 11), ("🃂", 2), ("🃃", 3), ("🃄", 4), ("🃅", 5), ("🃆", 6), ("🃇", 7), ("🃈", 8), ("🃉", 9), ("🃊", 10), ("🃋", 10), ("🃍", 10), ("🃎", 10),
          ("🃑", 11), ("🃒", 2), ("🃓", 3), ("🃔", 4), ("🃕", 5), ("🃖", 6), ("🃗", 7), ("🃘", 8), ("🃙", 9), ("🃚", 10), ("🃛", 10), ("🃝", 10), ("🃞", 10)
        ]
        
        func cardString(for hand: [(String, Int)]) -> String {
          return hand.map { $0.0 }.joined(separator: "")
        }

        func points(for hand: [(String, Int)]) -> Int {
          return hand.map { $0.1 }.reduce(0, +)
		  // return hand.map { $0.1 }.reduce(0, +)
	      return hand.map { $0.1 }.reduce(0, { $0 + $1 })
        }

        enum HandError: Error {
          case busted(points: Int)
        }

        let result = cardString(for: cards)
        print("result : ", result)
        // print("all points : ", points(for: cards))
        
        let dealtHand = PublishSubject<[(String, Int)]>()
        
        func deal(_ cardCount: UInt) {
          var deck = cards
          var cardsRemaining = deck.count
          var hand = [(String, Int)]()
          
          for _ in 0..<cardCount {
            let randomIndex = Int.random(in: 0..<cardsRemaining)
            hand.append(deck[randomIndex])
            deck.remove(at: randomIndex)
            cardsRemaining -= 1
          }
          
          // Add code to update dealtHand here
          let handPoints = points(for: hand)
          if handPoints > 21 {
            dealtHand.onError(HandError.busted(points: handPoints))
          } else {
            dealtHand.onNext(hand)
          }
        }
        
        // Add subscription to handSubject here
        dealtHand
          .subscribe(
            onNext: {
              print("[OK]", cardString(for: $0), "for", points(for: $0), "points")
          },
            onError: {
              print(String(describing: $0).capitalized)
          })
          .disposed(by: disposeBag)
        
        deal(2)

		// print("check - ", cards)
    }
    
    // 연습문제2 - BehaviorRelay 사용 - 로그인 세션 처리
    public class func test_Challange2() {
        enum UserSession {
          case loggedIn, loggedOut
        }
        
        enum LoginError: Error {
          case invalidCredentials
        }
        
        // Create userSession BehaviorRelay of type UserSession with initial value of .loggedOut
        let relay = BehaviorRelay<UserSession>(value: .loggedOut)

        // Subscribe to receive next events from userSession
        relay.subscribe(onNext: { session in
            print("[relay 결과]", session)
            
            switch session {
            case .loggedIn: print("[loggedIn]")
            case .loggedOut: print("[loggedOut]")
            }
        
        }).disposed(by: disposeBag)
        
    
        func logInWith(username: String, password: String, completion: ((Error?) -> Void)? ) {
          guard username == "johnny@appleseed.com", password == "appleseed" else {
            completion?(LoginError.invalidCredentials)
            return
          }
          
          // Update userSession
          relay.accept(.loggedIn)
        }
        
        func logOut() {
          // Update userSession
          relay.accept(.loggedOut)
        }
        
        func performActionRequiringLoggedInUser(_ action: () -> Void) {
          // Ensure that userSession is loggedIn and then execute action()
            guard relay.value == .loggedIn else { return }
            
            print("[로그인시 처리할 액션 처리]", "이것도 하고 저것도 하고!!")
            action()
        }
        
        for i in 1...2 {
          let password = i % 2 == 0 ? "appleseed" : "password"
          
          logInWith(username: "johnny@appleseed.com", password: password) { error in
            guard error == nil else {
              print(error!)
              return
            }
            
            print("User logged in.")
          }
          
          performActionRequiringLoggedInUser {
            print("Successfully did something only a logged in user can do.")
          }
        }
        
        print("end - 🤡")
    }

}
