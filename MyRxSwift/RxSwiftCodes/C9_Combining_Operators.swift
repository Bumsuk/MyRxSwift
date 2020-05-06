//
//  C9_Combining_Operators.swift
//  MyRxSwift
//
//  Created by brown on 2020/03/09.
//  Copyright © 2020 brown. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

// Combining_Operators 연산자들을 테스트한다.
public class C9_Combining_Operators {
    static let bag = DisposeBag()

    static func test_startWith() {
        print(#function)
        let numbers = Observable.of(2, 3, 4)
        let finalStream = numbers.startWith(0, 1)
        
        finalStream
            .subscribe { event in
                print("[구독] \(event)")
            }.disposed(by: bag)
    }
    
    static func test_concat() {
        print(#function)
        let stream1 = Observable.from([1,2,3,4])
        let stream2 = Observable.from([5,6,7,8])
        
        // 다른 방법
        // Observable.concat([stream1, stream2])
        
        stream1.concat(stream2)
        .subscribe(onNext: { num in
            print("[구독] \(num)")
        }).disposed(by: bag)
    }
    
    static func test_concat_withError() {
        print(#function)
        enum MyError: Error {
            case anError(String)
        }
        let stream1 = Observable.from([1,2,3,4])
        let stream2 = Observable<Int>.create { (observer) in
            observer.onError(MyError.anError("에러발생시켰어!"))
            return Disposables.create()
        }

        stream1
            .concat(stream2)
        	//.catchErrorJustReturn(8888)
			.subscribe({ event in
                print("[구독] event : \(event)")
            }).disposed(by: bag)
    }

    
    // [!! flatMap과 동일하나 방출된 아이템들의 순서를 보장한다!! 이게 다다!]
    static func test_concatMap1() {
        print(#function)

        let stream1 = Observable.from([Int](repeatElement(1, count: 1000)))
        let stream2 = Observable.from([Int](repeatElement(2, count: 1000)))
	
        Observable.from([stream1, stream2])
            .concatMap { $0 } // flatMap으로 바꿔서 해보자! 순서가 섞인다!!!
            .subscribe(onNext: {
                print($0)
            }).disposed(by: bag)
    }

    
    // [!! flatMap과 동일하나 방출된 아이템들의 순서를 보장한다!! 이게 다다!]
    static func test_concatMap2() {
        print(#function)
        let sequences: [String: Observable<String>] = [
            "독일": .of("베를린", "뮌헨", "프랑크프루트"),
            "스페인": .of("마드리드", "바르셀로나", "발렌시아")
        ]
        
        let stream = Observable.of("독일", "스페인")
            //.concatMap(<#T##selector: (String) throws -> ObservableConvertibleType##(String) throws -> ObservableConvertibleType#>)
            .concatMap { str -> Observable<String> in
                guard let country = sequences[str] else { return .empty() }
                return country
            }
        
        stream.subscribe({ event in
            print("구독", event)
        }).disposed(by: bag)
    }
    
    // [!! flatMap과 동일하나 방출된 아이템들의 순서를 보장한다!! 이게 다다!]
    // 단, 순서를 보장하다보니, concatMap에서의 스트림이 complte 되어야 다음 스트림이 진행된다.
    static func test_concatMap3() {
        print(#function)
        
        var second = 1
        
        Observable.from(["가", "나", "다"])
        //.concatMap(<#T##selector: (String) throws -> ObservableConvertibleType##(String) throws -> ObservableConvertibleType#>)
        .concatMap { str -> Observable<String> in
            print("🤡concatMap - \(str)")
            defer { second += 1 }
            return Observable<Int>
                    .interval(.seconds(second), scheduler: MainScheduler.instance)
                    .map { "\(str) - \($0)" }
                    .take(2)
        }.subscribe({event in
            print("[구독] \(event)")
        }).disposed(by: bag)
    }
    
    // [!! flatMap과 동일하나 방출된 아이템들의 순서를 보장한다!! 이게 다다!]
    // 단, 순서를 보장하다보니, concatMap에서의 스트림이 complte 되어야 다음 스트림이 진행된다.
    static func test_concatMap4() {
        let stream1 = Observable<String>.from(["가","나","다","라"])
        let stream2 = Observable<String>.from(["a","b","c","d"])
        
        _ = stream1.concat(stream2)
          .toArray() //!!! 이건 특이하게 배열로 만들어 한번의 emit으로 끝낸다! 이게 아니면 8번 emit 되겠지
          .subscribe { arrStr in
            print("[🦹‍♂️🦹‍♂️🦹‍♂️ 결과]", arrStr)
        }
    }
    
    static func test_merge1() {
        print(#function)
        
        let left = PublishSubject<String>()
        let right = PublishSubject<String>()
				
        let someStream = Observable.of(left, right)
        someStream
            .merge() // !! 머지 사용시 Element가 ObservableType 이어야 한다! 뭐.. 당연하긴 한데...;;
            .subscribe({ event in
                print("[결과1] \(event)")
            }).disposed(by: bag)
        		
		repeat {
			print("-")
		} while true
	
        let source = Observable
            .merge(left, right)
        
        source.subscribe { event in
            print("[결과2] \(event)")
        }.disposed(by: bag)
        
        left.onNext("left - 가")
        left.onNext("left - 나")
        right.onNext("right - 다")
        
        print("check - end 👺")
    }

    
    // API 요청 + share 심화예제
    static func test_merge_with_APIs() {
        print(#function)

        let apiServer1 = "https://images.pexels.com/photos/2028885/pexels-photo-2028885.jpeg?cs=srgb&dl=pexels-2028885.jpg&fm=jpg"
        let apiServer2 = "https://images.pexels.com/photos/3802666/pexels-photo-3802666.jpeg?cs=srgb&dl=pexels-3802666.jpg&fm=jpg"
        let apiServer3 = "https://images.pexels.com/photos/1054391/pexels-photo-1054391.jpeg"
        
        // 로그 중지!
        // Logging.URLRequests = { _ in false }
        // public typealias LogURLRequest = (URLRequest) -> Bool
        
        func getAPIStream(urlString: String) -> Observable<Bool> {
            let request = Observable.just(urlString)
                .map { strURL -> URLRequest in URLRequest(url: URL(string: strURL)!) }
                .flatMap { req -> Observable<(response: HTTPURLResponse, data: Data)> in URLSession.shared.rx.response(request: req)}
                .map({ (response, data) -> Bool in
                    if let date = response.allHeaderFields["Date"] as? String {
                        Log.i("[❤️서버에 요청한 시간❤️] \(date), data.count : \(data.count)")
                    }
                    return true
                })

            return request
        }
        
        let stream1: Observable<Bool> = getAPIStream(urlString: apiServer1)
        let stream2: Observable<Bool> = getAPIStream(urlString: apiServer2)
        let stream3: Observable<Bool> = getAPIStream(urlString: apiServer3)
        
        Observable
            .merge([stream1, stream2, stream3])
            //.merge(stream1, stream2, stream3)
            .subscribe(onNext: {
                Log.d("[구독] \($0)")
        }).disposed(by: bag)
        
        
//        Observable.concat(stream1, stream2, stream3)
//            .subscribe(onNext: { bResult in
//                Log.i("[구독] \(bResult)")
//            })
        
        print("🤡 check - end")
    }

    
    // 많이 사용되는 녀석!
    // 여러개의 스트림들을 합치되, 가장 최근 값들을 Pair로 Tuple 형식으로 반환
    static func test_combineLatest1() {
        print(#function)
        
        let left = PublishSubject<String>()
        let right = PublishSubject<String>()
        
        // combineLatest의 요소는 같은 타입일 필요가 없다!!
        let source = Observable.combineLatest(left, right)
        
        source
            .startWith(("초기값", "입니다!")) // 이렇게 초기값을 지정할수 있다!
        	// 이렇게 필터링도 가능(당연)
            //.filter { $0.0 != "Hello," }
            
            .map { l, r in "\(l) : \(r)" } // tuple을 분해해(패턴) l, r로 받아 문자열 변환
            .subscribe { event in
                print("[결과] \(event)")
            }.disposed(by: bag)

        left.on(.next("Hello,"))
        right.onNext("world")
        right.onNext("RxSwift")
        left.onNext("Have a good day")
             
        left.onCompleted()
        right.onCompleted()
        
    }
    
    // combineLatest의 resultSelector를 사용한 예 > startWith 로 안해도 초기값이 제공됨?
    static func test_combineLatest2() {
        print(#function)
        
        let choice: Observable<DateFormatter.Style> = .of(.short, .long) // 스타일 2개를 emit
        let dates = Observable.of(Date()) // 날짜 1개만 emit 하지만, combineLatest 니까 최신값 1:1 Pair된다!
        
        let observable = Observable.combineLatest(choice, dates, resultSelector: { format, when -> String in
            let formatter = DateFormatter()
            formatter.dateStyle = format
            return formatter.string(from: when)
        })
        
        _ = observable.subscribe(onNext: { value in
            print("[구독1] \(value)")
        })
        
        // 동일결과 다른예
        Observable.combineLatest(choice, dates)
        //.map(<#T##transform: ((DateFormatter.Style, Date)) throws -> Result##((DateFormatter.Style, Date)) throws -> Result#>)
            .map { style, date -> String in
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = style
                return dateFormatter.string(from: date)
        }.subscribe(onNext: {
            print("[구독2] \($0)")
        }).disposed(by: bag)
    }
    
    // combineLatest 와의 차이는 무조건 1:1 Pair여야 동작함.
    static func test_zip() {
        print(#function)
        
        let left = PublishSubject<String>()
        let right = PublishSubject<String>()
        
        let source = Observable.zip(left, right)
            .startWith(("좌측", "우측"))
            .share()
        
        source.subscribe({ event in
            print("[구독]", event)
        }).disposed(by: bag)

        
        source.enumerated().subscribe(onNext: { idx, tupple in
            print("[enumertated] idx : \(idx), value : \(tupple)")
        }).disposed(by: bag)
        
        
        left.onNext("좌: 111")
        right.onNext("우: 222")
        
        left.onNext("좌: 222")
        // zip은 확실히 Pair가 되어야만 값이 emit 된다!
        
    }
    
    // MARK: Triggers
    
    // 많이 사용한다고 하지만.... 음.. 기억이나 할수 있을까 싶다 ㅋ
    // 버튼 탭에 반응해서 특정 옵저버블의 최신값을 획득!!
	// !! 아님!! 많이 씀! 필수임!
    static func test_withLatestFrom() {
        print(#function)
    
        let button$ = PublishSubject<String>() // 원래는 Void 타입이 더 적합하다. 이 값은 출력이 안되므로...
        let textField$ = PublishSubject<String>()
		
        // button 이벤트와 textField$의 최신 이벤트가 페어가 되어 textField$값만 출력!
        let stream = button$.withLatestFrom(textField$)
            //.distinctUntilChanged() // 동일한 값이면 emit 안함. 무시!
        
        _ = stream.subscribe(onNext: { value in
            print("[구독]", value)
        })
        
        textField$.onNext("a")
        textField$.onNext("ab")
        textField$.onNext("abc")
        
        button$.onNext("Tap1!")
        button$.onNext("Tap2!")
        
        print("check - end 🤡")
    }
    
    // withLatestFrom 과 비슷함 > 잘 보면 반대임!
    static func test_sample() {
        print(#function)
        
        let button$ = PublishSubject<Void>()
        let textField$ = PublishSubject<String>()
        
        let stream = textField$.sample(button$)
        _ = stream.subscribe(onNext: { value in
            print("[구독]", value)
        })

        textField$.onNext("a")
        textField$.onNext("ab")
        textField$.onNext("abc")
        
        button$.onNext(())
        button$.onNext(())
                
        print("check - end 🤡")
    }
    
    
    //MARK: Switches
    
    // 다름 고급 오퍼레이터 > 흠흠..
    // 먼저 반응하는 관찰 가능한 시퀀스를 전파!
    // 주어진 순서 중 어느 하나가 먼저 반응하는 것을 관찰 할수있는 시퀀스
    /*
    디버그 출력에는 왼쪽 주제의 항목 만 표시됩니다. 수행 한 작업은 다음과 같습니다.
    1. 왼쪽과 오른쪽의 모호성을 해결하는 Observable을 만듭니다.
    2. 두 개의 관측 가능 데이터가 모두 데이터를 보내도록합니다.
       amb (_ :) 연산자는 왼쪽 및 오른쪽 관찰 가능 항목을 구독합니다.
       그들 중 하나가 요소를 방출 할 때까지 기다린 다음 다른 하나에서 구독을 취소합니다.
       그런 다음 첫 번째 활성 관찰 가능 요소의 요소 만 릴레이합니다. 그것은 애매 모호하다라는 용어에서 실제로 그 이름을 이끌어냅니다.
       처음에, 당신은 당신이 관심있는 순서를 알지 못하고 언제 화를 낼 것인지 결정하고 싶습니다.

    이 연산자는 종종 간과됩니다. 중복 서버에 연결하고 처음 응답하는 서버를 고수하는 등 몇 가지 실용적인 애플리케이션이 있습니다.
    */
    
    // !!! 즉, 요약하면 먼저 방출되는 시퀀스의 값을 끝까지! 사용한다(늦은 놈은 취소!!!)
    static func test_amb() {
        print(#function)

        enum MyError: Error { case anError }
        
        let left = PublishSubject<String>() // 이 스트림의 값만 출력됨!!
        let right = PublishSubject<String>()
        
        // 1
        let stream = left.amb(right)
        _ = stream.subscribe(onNext: { (value: String) in
            print("[구독]", value)
        }, onError: { err in
            print("[에러] \(err)")
        })
        
        // 2
        // [MY Test]
        //left.onError(MyError.anError)
        right.onNext("right - 쿠펜하겐1")
        left.onNext("left - 크허헣")
		
        right.onNext("right - 쿠펜하겐2")
        
        // [ORIGINAL]
		left.onNext("left - 리스본")
//        right.onNext("right - 쿠펜하겐")
//        left.onNext("left - 런던")
//        left.onNext("left - 마드리드")
//        right.onNext("right - 비엔나")
        
        left.onCompleted()
        right.onCompleted()
        
        print("check - end 🤡")
    }
    
    // amb 사용의 예 : API 요청 결과를 2군데 서버에서 먼저 받은 데이터를 사용! 안그런놈은 종료
    static func test_amb_exercie() {
        print(#function)

        let apiServer1 = "https://echo.paw.cloud/"
        let apiServer2 = "https://api.github.com/repos/ReactiveX/RxSwift/events"
        
        // 로그 중지!
        // Logging.URLRequests = { _ in false }
        // public typealias LogURLRequest = (URLRequest) -> Bool        
        
        let requests = Observable.from([apiServer1, apiServer2])
            .map { strURL -> URLRequest in
                URLRequest(url: URL(string: strURL)!)
            }
            .map { req -> Observable<Data> in
                URLSession.shared.rx.data(request: req)
            }
			.toArray()
        
        _ = requests.subscribe(onSuccess: { streams in
            _ = Observable.amb(streams).subscribe(onNext: { (data: Data) in
                print("[amb 결과] data : \(data)")
            })
        }) { err in
            print("[에러]", err)
        }
        
        
        print("🤡 check - end")
    }

    // amb 사용의 예 : 단순히 interval 사용
    static func test_amb_exercie2() {
        print(#function)

        // stream1,2 는 1 or 2초 딜레이가 랜덤으로 정해지고, 이에따라 amb 연산자로 먼저 값을 방출하는 시퀀스가 샤용됨!
        let stream1 = Observable<Int>.interval(.seconds(Int.random(in: 1...2)), scheduler: MainScheduler.instance).take(1).map { "stream1 : \($0+1)" }
        let stream2 = Observable<Int>.interval(.seconds(Int.random(in: 1...2)), scheduler: MainScheduler.instance).take(1).map { "stream2 : \($0+1)" }
        
        _ = stream1
            //.debug()
            .amb(stream2)
            .subscribe { (strValue) in
                print("[amb결과] \(strValue)")
            }
        
        print("🤡 check - end")
    }

    
    // switchLatest 사용예 - 더 많이 사용됨!
    // Observable 를 입력으로 받아 그 시퀀스의 값을 방출
    static func test_switchLatest() {
        print("➡️", #function)
        
        // 1
        let one = PublishSubject<String>()
        let two = PublishSubject<String>()
        let three = PublishSubject<String>()
        
        // 요소가 Observable 타입이다.
        let source = PublishSubject<Observable<String>>()
        
        // 2 : switchLatest()
        let observable = source.switchLatest()
        // 이 둘은 같은 동작이다.
        //let observable = source.flatMapLatest { (sequence) in sequence }
        
        
        // 구독은 소스 옵저버 블에 푸시 된 최신 순서의 항목 만 인쇄합니다. 이것이 switchLatest ()의 목적입니다.
        let disposable = observable.subscribe { value in
            print("[구독]", value)
        }
        
        // 3
        source.onNext(one)
        one.onNext("Some text from sequence one")
        two.onNext("Some text from sequence two")
        
        source.onNext(two)
        two.onNext("More text from sequence two")
        one.onNext("and also from sequence one")
        
        source.onNext(three)
        two.onNext("Why don't you see me?")
        one.onNext("I'm alone, help me")
        three.onNext("Hey it's three. I win")
        
        source.onNext(one)
        one.onNext("Nope. It's me, one!")
        
        disposable.dispose()
        
        print("🤡 check - end")
    }
    
    // reduce 테스트
    // http://reactivex.io/documentation/operators/reduce.html
    // 주의! > 최종 결과값을 1번 방출하는 시퀀스! > 왜 헷갈렸냐? 흠흠...ㅓㅏ러라
    static func test_reduce() {
        print("➡️", #function)
        let source = Observable.of(1, 3, 5, 7, 9)
        source.reduce(0) { (acc, num) -> Int in
            acc + num
        }
        .subscribe { result in
            print("[구독]", result)
        }.disposed(by: bag)
    }

    // scan 테스트
    static func test_scan() {
        print("➡️", #function)
        let source = Observable.of(1, 3, 5, 7, 9)
        source.scan(0) { (acc, num) -> Int in
            acc + num
        }
        .subscribe { result in
            print("[구독]", result)
        }.disposed(by: bag)
    }
    
    static func test_scan2() {
        print("➡️", #function)
        let source = Observable.of(1, 3, 5, 7, 9)        
        source.scan("=== 계속 이 값출력! ===") { (acc, num) in
            acc
        }
        .subscribe { result in
            print("[구독]", result)
        }.disposed(by: bag)
    }
	
	static func test_scan3() {
		print("➡️", #function)
		let source = Observable.of([1], [1, 2], [1, 2, 3], [1, 2, 3, 4])
		
		_ = source.scan(0) { (acc, nums) in
			acc + nums.reduce(0, +)
		}.subscribe(onNext: {
			print("[구독] \($0)")
		})

	}

    
    // scan 테스트 > 주로 많이 쓰이는 방식
    static func test_scan_advance1() {
        print("➡️", #function)
        
        var 저금통: Int = 100
        let source = Observable.of(1, 3, 5, 7, 9)

        #if true
        source.scan(저금통) { (updated, coin) in
            updated + coin
        }.subscribe(onNext: { coin in
            print("[구독] \(coin)")
        }).disposed(by: bag)
        #else // inout 방식
        source.scan(into: 저금통) { (updated, num) in
            updated += num
        }.subscribe(onNext: {
            print("[구독] \($0)")
        }).disposed(by: bag)
        #endif
        
        print("check - end!")
    }

    

    // scan + zip 연습문제 : zip 사용안하고 tuple로
    static func test_scan_with_noZip() {
        print("➡️", #function)
        let source = Observable.of(1, 3, 5, 7, 9)
        source.scan((0, 0)) { (acc, num) -> (Int, Int) in
            return (num, acc.1 + num)
        }
        .subscribe { tuple in
            print("[구독 - noZip]", tuple)
        }.disposed(by: bag)
    }
    
    // scan + zip 연습문제 : zip 사용
    static func test_scan_with_Zip() {
        print("➡️", #function)
        let source = Observable.of(1, 3, 5, 7, 9)
        let scan = source.scan(0, accumulator: { (acc, num) -> Int in
            acc + num
        })
		
        Observable.zip([source, scan])
        .subscribe { tuple in
            print("[구독 - Zip]", tuple)
        }.disposed(by: bag)
    }

    
}
