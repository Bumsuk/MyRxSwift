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
    static let disposeBag = DisposeBag()
    let a: Int = 0
    let b: String = "default"

    static func test_toArray() {
        Observable.from([1, 2, 3, 4])
            // .debug()
            // .filter { $0 != 3 }
            .toArray()
            .subscribe(onSuccess: {
                print("[구독] \($0)")
            }, onError: {
                print("[error] \($0)")
            }).disposed(by: disposeBag)
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
            .disposed(by: disposeBag)
    }

    class Student<T> {
        let score: BehaviorSubject<T>
        init(score: BehaviorSubject<T>) {
            self.score = score
        }
        deinit {
            print("[🦹‍♂️Student 객체 deint!]")
        }
    }

    static func test_flatMap1() {

        let laura = Student(score: BehaviorSubject(value: 80))
        let charlotte = Student(score: BehaviorSubject(value: 90))
        
        let student = PublishSubject<Student<Int>>()
        
        student
            //.skip(1)
            .debug()
            //.flatMap { $0.score } // 이 부분이 매우 중요한 Point!
            .flatMap { try! Observable.of($0.score.value()) } // 이렇게 하면 score.onNext 할때 스트림이 이어지지 않는다.
            .subscribe(onNext: {
                print("[구독]", $0)
            }, onDisposed: {
                print("[Disposed!]")
            })
            .disposed(by: disposeBag)
        
        
        student.onNext(laura)
        laura.score.onNext(88)
        // student.onNext(laura)

        student.onNext(charlotte)
        charlotte.score.onNext(100)
        
    }
    
    static func test_flatMap2() {
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
            }).disposed(by: disposeBag)
    }
}
