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
import RxCocoa

// 네트워크 서비스 클래스
class EONET {
  static let API = "https://eonet.sci.gsfc.nasa.gov/api/v2.1"
  static let categoriesEndpoint = "/categories"
  static let eventsEndpoint = "/events"

  static func jsonDecoder(contentIdentifier: String) -> JSONDecoder {
    let decoder = JSONDecoder()
    decoder.userInfo[.contentIdentifier] = contentIdentifier
    decoder.dateDecodingStrategy = .iso8601
    return decoder
  }

  static func filteredEvents(events: [EOEvent], forCategory category: EOCategory) -> [EOEvent] {
    return events.filter { event in
      return event.categories.contains(where: { $0.id == category.id })
        && !category.events.contains { $0.id == event.id }
    }
    .sorted(by: EOEvent.compareDates)
  }
  
  // [필견!!!]
  // 이 제너릭은 특이하게 T의 타입이 infer 되려면 이 함수결과를 받는 변수의 타입을 명시해야만 한다.
  static func request<T: Decodable>(endpoint: String,
                                    query: [String:Any] = [:],
                                    contentIdentifier: String) -> Observable<T> {
    do {
      guard let url = URL(string: API)?.appendingPathComponent(endpoint),
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
          throw EOError.invalidURL(endpoint)
      }

      components.queryItems = try query.compactMap({ key, value in
        guard let v = value as? CustomStringConvertible else {
          throw EOError.invalidParameter(key, value)
        }
        return URLQueryItem(name: key, value: v.description)
      })
      
      guard let finalURL = components.url else {
        throw EOError.invalidURL(endpoint)
      }
      
      let request = URLRequest(url: finalURL)
      return URLSession.shared.rx.response(request: request)
        //.do(onNext: { _, data in print("[통신확인🤡] data : \(data.count)") })
        .map { response, data -> T in
          if let date = response.allHeaderFields["Date"] as? String {
            print("[❤️서버에 요청한 시간❤️] \(date)")
          }

          let decoder = self.jsonDecoder(contentIdentifier: contentIdentifier)
          let envelope = try decoder.decode(EOEnvelope<T>.self, from: data) // json 디코딩시 랩핑된 타입 사용!
          return envelope.content
        }
    } catch {
      Log.i("에러! - \(error)")
      return .empty() // 이럴땐 complete되는 empty() 시퀀스 반환(거의 관용적이네)
    }
  }
  
  // 일종의 싱글톤 시퀀스 {}()로 1회 할당
  static var categories: Observable<[EOCategory]> = {
    let request: Observable<[EOCategory]> = EONET.request(endpoint: categoriesEndpoint, contentIdentifier: "categories")
    return request
      .map { categories in categories.sorted { $0.name < $1.name } }
      .catchErrorJustReturn([])
      .share(replay: 1, scope: .forever) // 구독이 0가 되어도 마지막 1회 emit 값은 replay! // 보통 forever는 쓰지 않는다.
      //.share() // .share(replay: 0, scope: .whileConnected) 와 같다.
  }()
  
  // MARK: Private!
  private static func events(forLast days: Int, closed: Bool, endpoint: String) -> Observable<[EOEvent]> {
    let query: [String: Any] = [
      "days": days,
      "status": (closed ? "closed" : "open")
    ]
    
    let request: Observable<[EOEvent]> = EONET.request(endpoint: endpoint, query: query, contentIdentifier: "events")
    return request
      .do(onNext: { events -> Void in
        print("⚡️events count : \(events.count)")
      }, onError: { Log.i("[에러!] \($0)") })
      .catchError({ (error) -> Observable<[EOEvent]> in
        Log.i("[catchError] \(error)")
        return .just([])
      })
      //.catchErrorJustReturn([]) // 위 코드와 동일!
  }

  // MARK: 공개 메서드
  static func events(forLast days: Int = 360, category: EOCategory) -> Observable<[EOEvent]> {
    let openEvents: Observable<[EOEvent]> = events(forLast: days, closed: false, endpoint: category.endpoint)
    let closedEvents: Observable<[EOEvent]> = events(forLast: days, closed: true, endpoint: category.endpoint)
  
    #if true
    // 병렬로 event 2개 상태 동시에 request
    let result = Observable.of(openEvents, closedEvents)
      .merge() // 봐도 봐도 아주 중요한 녀석! 스트림들을 하나로 합쳐줌. 
      //.merge(maxConcurrent: 4)
      .reduce([]) { (acc, event) in // 최종 결과값을 1번 방출하는 시퀀스!
        acc + event
      }
    return result
    #else
    // 직렬로 event 2개 상태 방출 방식
    return openEvents.concat(closedEvents) // close / open 상태 events 2개 방출
    #endif
  }
}
