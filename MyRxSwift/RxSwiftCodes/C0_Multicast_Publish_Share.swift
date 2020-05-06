//
//  C0_Multicast_Publish_Share.swift
//  MyRxSwift
//
//  Created by brown on 2020/03/10.
//  Copyright © 2020 brown. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

// share(::)의 상세설명
// https://medium.com/gett-engineering/rxswift-share-ing-is-caring-341557714a2d

// 가장 혼란스럽게 느껴졌던 녀석들, 공유 오퍼레이터에 대해서 테스트한다.
class Multicast_Publish_Share {
    
    static let bag = DisposeBag()
    
    // Observable의 시퀀스를 하나의 Subject를 통해 multicast로 전달할수 있다.(공유됨!)
    // https://brunch.co.kr/@tilltue/15
    // muticast를 사용(subject 필수) > 동일기능인 publish()를 사용하는게 더 나을듯!
    static func test_multicast() {
        print(#function)

        let interval$ = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
        let subject$ = PublishSubject<Int>()
        
        // 멀티캐스트를 위해 subject가 필요
        let connectable$: ConnectableObservable<Int> = interval$.multicast(subject$)
        
        // 연결!! connect() 되어야 구독한 옵저버들에게 시퀀스 방출~
        let subscription = connectable$.connect()

        _ = connectable$.subscribe(onNext: {
            print("[구독1]", $0)
        })

        _ = connectable$.subscribe(onNext: {
            print("[구독2]", $0)
        })
        
        // 5초 뒤에 connectable$ dispose!
        DispatchQueue.global().asyncAfter(deadline: .now()+5, execute: {
            print("[connectable$ dispose!]")
            subscription.dispose()
        })
    }
    
    // publish는 multicast + subject 구성과 동일한 효과! 더 간단하게 사용가능! (이벤트 공유!)
    static func test_publish() {
        print(#function)

        let interval$ = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance).do(onNext: { print(["[🤡onNext] \($0)"]) })
        
        // multicast와 다르게 subject가 필요없다. 내부적으로 subject를 생성해 사용하기 때문!
        let connectable$: ConnectableObservable<Int> = interval$.publish()

        // 연결!! connect() 되어야 구독한 옵저버들에게 시퀀스 방출~
        let subscription = connectable$.connect()

        _ = connectable$.subscribe(onNext: {
            print("[구독1]", $0)
        })

        _ = connectable$.delaySubscription(.seconds(5), scheduler: MainScheduler.instance).subscribe(onNext: {
            print("[구독2]", $0)
        })
        
        // 잘보면 interval$에서의 이벤트가 공유된다. 따로 emit 되는게 아니다!
        
        /*
        test_publish()
        [구독1] 0
        [구독1] 1
        [구독1] 2
        [구독1] 3
        [구독1] 4
        [구독1] 5
         
        [구독2] 5
        [구독1] 6
        [구독2] 6
        [구독1] 7
        [구독2] 7

        */
    }
    
    // replay 사용예
    static func test_replay_simple() {
        print(#function)
        
        // 이 코드가 왜 잘 안되냐면, replay 시퀀스가 유한 시퀀스이기때문에 이 시퀀스가 종료되면, connect를 해도 의미가 없다.
        // 차라리 share(replay:scope:)를 사용해라. 물론 스코프는 .forever로. 해야 구독완료되도 replay됨.
        let replay3 = Observable.from([1, 2, 3, 4, 5])
            //.share(replay: 3, scope: .forever)
            .replay(2)
        
        // replay3.connect() // 여기서 connect하면 구독된게 없으니 시퀀스 방출이 안됨.
        
        replay3
            .subscribe(onNext: { print("[구독1]", $0) }).disposed(by: bag)
        replay3
            .subscribe(onNext: { print("[구독2]", $0) }).disposed(by: bag)

        replay3.connect() // 여기서 connect하면 방출됨! 하지만 5까지 방출하고 더이상 끗!

        
        replay3.subscribe(onNext: { print("[구독3]", $0) }).disposed(by: bag)
        

    }
    
    // replay 사용예
    static func test_replay() {
        print(#function)

        let interval$ = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .do(onNext: { print(["[🤡onNext] \($0)"]) })

        // replay() 사용! 버퍼를 두어 이후 구독될때 방출된 값들을 재방출한다.
        let replay$: ConnectableObservable<Int> = interval$
            .replay(3)
            //.replayAll() // 이건 무조건 전부다 리플레이해준다. 메모리 주의!
        
        // 역시 connect()를 해줘야 구독자들에게 시퀀스 출력됨.
        _ = replay$.connect()
        
        
        _ = replay$.subscribe(onNext: {
            print("[구독1]", $0)
        })

        _ = replay$.delaySubscription(.seconds(15), scheduler: MainScheduler.instance).subscribe(onNext: {
            print("[구독2]", $0)
        })

        /*
        test_replay()
        [구독1] 0
        [구독1] 1
        [구독1] 2
        [구독1] 3
        [구독1] 4
         
        [구독2] 2 // <- replay 됐음!
        [구독2] 3
        [구독2] 4
        
        [구독1] 5
        [구독2] 5
        [구독1] 6
        [구독2] 6
        */
    }

    
    // replayAll 사용예 > 이미 방출한 모든 값들을 재방출! 무식하니 잘 써야겠지?
    static func test_replayAll() {
        print(#function)

        let interval$ = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .do(onNext: { print(["[🤡onNext] \($0)"]) })
        
        // replayAll() 사용! > 밑도끝도없이 방출된 값들 전부 replay!
        let replay$: ConnectableObservable<Int> = interval$.replayAll()
        
        // 역시 connect()를 해줘야 구독자들에게 시퀀스 출력됨.
        _ = replay$.connect()
        /*
        DispatchQueue.main.asyncAfter(wallDeadline: .now()+5, execute: {
            _ = replay$.connect()
        })
        */
        
        _ = replay$.subscribe(onNext: {
            print("[구독1]", $0)
        })

        _ = replay$
            .delaySubscription(.seconds(5), scheduler: MainScheduler.instance)
            .subscribe(onNext: {
            print("[구독2]", $0)
        })
        
        /*
        test_replayAll()
        [구독1] 0
        [구독1] 1
        [구독1] 2
        [구독1] 3
        [구독1] 4
         
        [구독2] 0 // 전부 재방출!!
        [구독2] 1
        [구독2] 2
        [구독2] 3
        [구독2] 4
         
        [구독1] 5
        [구독2] 5
        [구독1] 6
        [구독2] 6
        [구독1] 7
        [구독2] 7

        */
    }
    
    // share(::)의 상세설명
    // https://medium.com/gett-engineering/rxswift-share-ing-is-caring-341557714a2d

    // share 사용예 > 기존의 shareReplay는 Deprecated되었다. share(replay:scope:)를 사용하면 됨!
    static func test_share() {
        print(#function)

        let interval$ = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .do(onNext: { print(["[🤡onNext] \($0)"]) })
            
        // ConnectableObservable 이 아니라, Observable 타입이다! 즉, connect가 필요없다.
        let share$: Observable<Int> = interval$.share()

        let subscription1 = share$.subscribe { num in
            print("[구독1]", num)
        }
        
        let subscription2 = share$.subscribe { num in
            print("[구독2]", num)
        }
        
        DispatchQueue.main.asyncAfter(wallDeadline: .now()+5, execute: {
            subscription1.dispose()
        })
        
        /*
        test_share()
        ["[🤡onNext] 0"]
        [구독1] next(0)
        [구독2] next(0)
        ["[🤡onNext] 1"]
        [구독1] next(1)
        [구독2] next(1)
        ["[🤡onNext] 2"]
        [구독1] next(2)
        [구독2] next(2)
        */
    }
    
    // share를 사용할때 옵션 테스트
    static func test_share_option_test() {
        print(#function)
        
        let interval$ = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .do(onNext: { print(["[🤡onNext] \($0)"]) })
            
        // ConnectableObservable 이 아니라, Observable 타입이다! 즉, connect가 필요없다.
        // [scope 옵션설명!]
        // 이 옵션은 replay 값이 0 초과일때 의미가 있다. 이벤트를 공유하는 것을 제어하기 때문!
        // - .whileConnected: 1개 이상 subscriber가 존재하는 동안에만, replay 버퍼가 유지된다.
        //     따라서 subscription이 0개가 된 뒤에 발생하는 subscription은 새로운(latest) 결과를 갖게됨.
        // - .forever: 버퍼를 생성한 뒤, subscription의 존재 여부에 관계 없이 버퍼가 유지된다.
        //     구독 횟수가 다 취소되어 0이 되어도 새로 구독하는 순간 replay 갯수만큼 다시 replay된다.
        
        let share$: Observable<Int> = interval$.share(replay: 10, scope: .forever)
        // let share$: Observable<Int> = interval$.share(replay: 10, scope: .whileConnected) // 구독수가 0가 되면 replay 수에 상관없이 새로 시작!
        
        let subscription1 = share$.subscribe { num in
            print("[구독1]", num)
        }
        
        DispatchQueue.main.asyncAfter(wallDeadline: .now()+5, execute: {
            subscription1.dispose()
        })
        
        let subscription2 = share$
			// 6초 뒤에 구독을 하면 subscription이 이 시점에는 하나도 없는 상태서 구독하므로 0부터 새로 받는다. (물론 이전 값들은 한번에 받는다)
            .delaySubscription(.seconds(6), scheduler: MainScheduler.instance)
            .subscribe { num in
            print("[구독2]", num)
        }
    }
    
    
    // API 요청 + share 심화예제
    static func test_share_api_requests() {
        print(#function)

        let apiServer1 = "https://echo.paw.cloud/"
        let apiServer2 = "https://api.github.com/repos/ReactiveX/RxSwift/events"
		
        // 로그 중지!
        // Logging.URLRequests = { _ in false }
        // public typealias LogURLRequest = (URLRequest) -> Bool
        
        // 잘 테스트해보자. 앞으로의 여정에서 중요한 기능중 하나.
        #if true
        let requests = Observable.from([apiServer1])
            .map { strURL -> URLRequest in URLRequest(url: URL(string: strURL)!) }
            .flatMap { req -> Observable<Data> in URLSession.shared.rx.data(request: req) }
			//.asSingle()
            .share(replay: 1, scope: .forever)
            //.share(replay: 1, scope: .whileConnected) // 이 코드에서 whileConnected로 하면 replay가 동작하지 않는다. requests가 1회 emit후 dispose(complete)되므로..
        
        _ = Observable<Int>
            .interval(.seconds(1), scheduler: MainScheduler.instance)
            .flatMap { _ in requests }
            .subscribe(onNext: { data in
                print("[✅완료] data size : \(data.count)")
            })
        #else
        /*
        let requests = Observable.from([apiServer1])
            .map { strURL -> URLRequest in URLRequest(url: URL(string: strURL)!) }
            .flatMap { req -> Observable<Data> in URLSession.shared.rx.data(request: req) }
            .share(replay: 1, scope: .forever)
            //.share(replay: 1, scope: .whileConnected) // 이 코드에서 whileConnected로 하면 replay가 동작하지 않는다. requests가 1회 emit후 dispose(complete)되므로..
        
        let interval$ = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
        _ = interval$.subscribe(onNext: { _ in
            _ = requests
                .do(onDispose: { print("🚫 disposed!") })
                .subscribe(onNext: { data in
                print("[✅완료] data size : \(data.count)")
            })
        })
         */
        #endif
        
        print("🤡 check - end")
    }


}
