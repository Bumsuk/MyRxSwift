/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import RxSwift

private var internalCache = [String: Data]()

// 앞으로 많이 써야 할 커스텀 리액티브 연산자 만들기! 잘 익혀두자. 별로 어렵지 않다!
extension ObservableType where Element == (HTTPURLResponse, Data) {
	func cache() -> Observable<Element> {
		return self.do(onNext: { response, data in
			guard let url = response.url?.absoluteString,
				  200..<300 ~= response.statusCode else { return }
			internalCache.updateValue(data, forKey: url)
			print("👺[cached!!!]")
		})
	}
}

public enum RxURLSessionError: Error {
  case unknown
  case invalidResponse(response: URLResponse)
  case requestFailed(response: HTTPURLResponse, data: Data?)
  case deserializationFailed
}

// 잘보면 RxSwift에서 이미 구현해놓은 Reactive 확장과 거의 비슷하다.
extension Reactive where Base: URLSession {
	
	// MARK: -  기본 통신 메서드
	func response(request: URLRequest) -> Observable<(HTTPURLResponse, Data)> {
		if let url = request.url?.absoluteString, let data = internalCache[url] {
			print("🤡🤡🤡🤡🤡🤡🤡🤡[cache hit!!]")
			let dummyResponse = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
			return .just((dummyResponse, data))
		} else {
			return Observable.create { observer -> Disposable in
				print("🤡🤡[create!]")
				
				let task = self.base.dataTask(with: request) { data, response, error in
					guard let response = response, let data = data else {
						observer.onError(error ?? RxURLSessionError.unknown); return
					}
					
					guard let httpResponse = response as? HTTPURLResponse else {
						observer.onError(RxURLSessionError.invalidResponse(response: response)); return
					}
					
					print("🤡[suggestedFilename] \(httpResponse.suggestedFilename ?? "unknown")")
					
					observer.onNext((httpResponse, data))
					observer.onCompleted()
				}
				task.resume()
				
				return Disposables.create {
					// 캡쳐까지 되니 더욱 좋다!
					task.cancel() // 구독 객체가 삭제될때 요청이 살아있다면 리소스 낭비 안하기 위해 취소!
				}
			}
		}
	}
	
	// MARK: - 랩핑 처리한 메서드
	func data(request: URLRequest) -> Observable<Data> {
		return response(request: request).cache().map { response, data -> Data in
			guard 200..<300 ~= response.statusCode else {
				// map 오퍼레이터 안에서 throw 호출은 error 이벤트로 변환되어 emit 된다.
				throw RxURLSessionError.requestFailed(response: response, data: data)
			}
			return data
		}
	}

	// MARK: - 랩핑 처리한 메서드
	func string(request: URLRequest) -> Observable<String> {
		return data(request: request)
			.map { data -> String in
				let str = String(data: data, encoding: .utf8) ?? ""
				guard str.count > 0 else {
					throw RxURLSessionError.unknown
				}
				return str
			}.catchErrorJustReturn("")
	}
	
	// MARK: - 랩핑 처리한 메서드
	func json(request: URLRequest) -> Observable<Any> {
		return data(request: request).map { data in
			return try JSONSerialization.jsonObject(with: data)
		}
	}
	
	// MARK: - 랩핑 처리한 메서드
	func decodable<T: Decodable>(request: URLRequest, type: T.Type) -> Observable<T> {
		return data(request: request).map {
			let decoder = JSONDecoder()
			return try decoder.decode(type, from: $0)
		}
	}

	// MARK: - 랩핑 처리한 메서드
	func image(request: URLRequest) -> Observable<UIImage> {
		return data(request: request).map { data in
			guard let image = UIImage(data: data) else {
				throw RxURLSessionError.deserializationFailed
			}
			
			return image
		}
	}
}
