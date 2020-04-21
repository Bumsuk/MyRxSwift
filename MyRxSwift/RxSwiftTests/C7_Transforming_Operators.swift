//
//  C7_Transforming_Operators.swift
//  MyRxSwift
//
//  Created by brown on 2020/03/07.
//  Copyright © 2020 brown. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

// transforming 연산자들을 테스트한다.
public class C7_Transforming {
    static let bag = DisposeBag()

    static func test_toArray() {
        print(#function)

        Observable.from([1, 2, 3, 4])
            // .debug()
            // .filter { $0 != 3 }
            .toArray() // 각각의 방출된 녀석들을 시퀀스가 종료될때까지 기다렸다가 하나의 배열로 한번에 방출!
            .subscribe(onSuccess: {
                print("[구독] \($0)")
            }, onError: {
                print("[error] \($0)")
            }).disposed(by: bag)
    }

    // toArray 사용시 에러가 발생하면?? 중도에서라도 그냥 에러로 종료 > catchError.. 시리즈가 필요할듯
    static func test_toArray_error() {
        print(#function)

        enum MyError: Error {
            case anError(String)
        }
        let stream1 = Observable<Int>.of(1)
        let stream2 = Observable<Int>.create { (observer) -> Disposable in
            //observer.onError(MyError.anError("에러발생!"))
            observer.onNext(2)
            return Disposables.create()
        }
        
        Observable
            .merge(stream1, stream2.take(1))
            .catchErrorJustReturn(4444)
            .toArray()
            .subscribe(onSuccess: { (numbers) in
                Log.i("[OnSuccess] \(numbers)")
            }, onError: {
                Log.s("[onError] \($0)")
            }).disposed(by: bag)
    
    }
    
    
    static func test_map() {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut

        Observable<Int>.of(123, 4, 56)
            .map {
                formatter.string(from: NSNumber(value: $0)) ?? ""
            }
            .enumerated()
            // .flatMap(<#T##selector: ((index: Int, element: String)) throws -> ObservableConvertibleType##((index: Int, element: String)) throws -> ObservableConvertibleType#>)
            .flatMap({
                Observable.of("\($0.index)__\($0.element)")
            })
            .toArray()
            .subscribe({ print("[구독] \($0)") })
            // .toArray()
            // .subscribe(onSuccess: { print("[map 구독] \($0)") })
            // .subscribe(onNext: { print("[map 구독] \($0), \($1)") })
            .disposed(by: bag)
    }
    
    // 일반적인 분석을 위한 함수
    static func test_flatMap0() {
        Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .debug()

            // .flatMap(<#T##selector: (Int) throws -> ObservableConvertibleType##(Int) throws -> ObservableConvertibleType#>)
            .flatMap { (num) -> Observable<String> in
                print("flatMap 처리 구간----")
                if num % 2 == 0 {
                    return Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance).map { _ in "[짝수] \(num * 2)" }.skip(1).take(1)
                } else {
                    return Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance).map { _ in "[홀수] \(num * 3)" }.skip(1).take(1)
                }
            }.subscribe(onNext: {
                print("[구독] \($0)")
            }).disposed(by: bag)
    }
    
    // 왜 flatMap이 시퀀스의 흐름을 바꿀수 있는가?
    static func test_flatMap_why() {
        print(#function)
        
        Observable<Int>
            .from([1, 2, 3])
            .flatMap { _ in Observable.from([10, 20, 30])
            }.subscribe {
                print("구독", $0)
            }.disposed(by: bag)
            
        print("🤡check - end")
    }
    

    class Student<T> {
        var score: BehaviorSubject<T>
        init(score: BehaviorSubject<T>) {
            self.score = score
        }
        deinit {
            print("[🦹‍♂️Student 객체 deint!]")
        }
    }

    // 매우 중요!
    static func test_flatMap() {
        let laura = Student(score: BehaviorSubject(value: 80))
        let charlotte = Student(score: BehaviorSubject(value: 90))
        
        let student = PublishSubject<Student<Int>>()
        
        student
            //.skip(1)
            .debug()
            .flatMap { $0.score } // 이 부분이 매우 중요한 Point!
            //.flatMap { try! Observable.of($0.score.value()) } // 이렇게 하면 score.onNext 할때 스트림이 이어지지 않는다.
            .subscribe(onNext: {
                print("[구독]", $0)
            }, onDisposed: {
                print("[Disposed!]")
            })
            .disposed(by: bag)
        
        
        student.onNext(laura)
        laura.score.onNext(88)
        // student.onNext(laura)

        student.onNext(charlotte)
        charlotte.score.onNext(100)
        
        // 공유가 된다!!!! 공유가!!!!
        laura.score.onNext(88888)
        charlotte.score.onNext(99999)
        
    }
        
    static func test_flatMapLatest1() {
        print(#function)
        let laura = Student(score: BehaviorSubject(value: 80))
        let charlotte = Student(score: BehaviorSubject(value: 90))
        
        let student = PublishSubject<Student<Int>>()
        
        student
            .flatMapLatest { $0.score }
            .subscribe(onNext: {
                print("[구독] \($0)")
            })
        
        student.onNext(laura)
        laura.score.onNext(81)
        
        student.onNext(charlotte)

        laura.score.onNext(82)
        laura.score.onNext(83)
        
        charlotte.score.onNext(91)
        
        print("🤡check - end!")
    }

    static func test_flatMapLatest2() {
        print(#function)
        
        let stream1 = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance).map { "stream1 : \($0)" }.debug()
        let stream2 = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance).map { "stream2 : \($0)" }.debug()
        
        let subject = PublishSubject<Observable<String>>()
        subject
            .flatMapLatest { $0 }
            .subscribe(onNext: { num in
                print("구독", num)
            }).disposed(by: bag)
        
        subject.onNext(stream1)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+5, execute: {
            subject.onNext(stream2)
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now()+10, execute: {
            subject.onNext(stream1)
        })

        
        print("🤡check - end")
    }
    
    static func test_flatMap1() {
        print(#function)

        enum MyError: Error {
            case anError
        }
        
        let laura = Student(score: BehaviorSubject(value: 80))
        let charlotte = Student(score: BehaviorSubject(value: 90))
        
        let student = BehaviorSubject(value: laura)
     
        let studentScore = student.flatMapLatest { $0.score }
        studentScore
            .subscribe(onNext: {
                print("[구독]", $0)
            }).disposed(by: bag)
        
        laura.score.onNext(81)
        laura.score.onError(MyError.anError)

        
        print("🤡check - end!")
    }
    
    // 스트림의 방출된 값들을 Event 타입으로 랩핑해 방출한다!
    // Using the materialize operator, you can wrap each event emitted by an observable in an observable.
    static func test_Materialize() {
        print(#function)
        
        Observable.from([1, 2, 3])
            .materialize()
        	//.subscribe(onNext: <#T##((Event<Int>) -> Void)?##((Event<Int>) -> Void)?##(Event<Int>) -> Void#>)
            .subscribe(onNext: { event in
                print("[구독]", event)
            }).disposed(by: bag)

        print("🤡check - end!")
        /*
        test_Materialize()
        [구독] next(1)
        [구독] next(2)
        [구독] next(3)
        [구독] completed
        🤡check - end!
        */
    }
    
}
