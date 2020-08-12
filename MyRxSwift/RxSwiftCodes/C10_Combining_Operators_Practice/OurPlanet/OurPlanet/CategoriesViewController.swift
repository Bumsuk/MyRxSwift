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

import UIKit
import RxSwift
import RxCocoa

class CategoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  @IBOutlet var tableView: UITableView!
  
  let categories = BehaviorRelay<[EOCategory]>(value: [])
  let bag = DisposeBag()
    
  var activityIndicator: UIActivityIndicatorView!
  let download = DownloadView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    
    // 여기서 asObservable() 오퍼레이터가 꼭 필요할까? subject에서 변환한다는 의도를 명확히 하기 위해서?? 
    categories
      .asObservable()
      // 여기서의 subscribe는 트리거 역할은 아니다. categories가 BehaviorRelay 이므로 이 시점에서는 [] 값만 전달받는다.
      .observeOn(MainScheduler.instance)
    	.subscribe(onNext: { [weak self] categories in
        print("[⚡️⚡️⚡️⚡️카테고리 리스트 데이터 획득(\(categories.count))⚡️]")
          self?.tableView.reloadData()
      }).disposed(by: bag)
    
    startDownload()
  }

  // 화이또!
  func startDownload() {
    // 왜 EONET.categories가 share(replay: 1, scope: .forever) 인지를 확실히 이해해야 한다!!
    let eoCategories: Observable<[EOCategory]> = EONET.categories
    // downloadedEvents는 카테고리별 이벤트 묶음들이 방출됨.
    let downloadedEvents: Observable<[EOEvent]> = eoCategories
      .flatMap { (categories: [EOCategory]) -> Observable<Observable<[EOEvent]>> in
        return Observable.from(categories.map { EONET.events(forLast: daysForRequest, category: $0) })
      }
      .merge() // 배열안의 여러개 시퀀스들을 하나의 시퀀스로 합쳐줌!
      //.merge(maxConcurrent: 1) // 동시에 몇개의 시퀀스(여기선 API 통신)를 허용할지 선택! 매우 중요함!
    
    let updatedCategories = eoCategories.flatMap { categories in
      // 이 scan도 아주 유용하다!
      downloadedEvents.scan(categories, accumulator: { updated, events in
        return updated.map { category in
          let eventsForCategory = EONET.filteredEvents(events: events, forCategory: category) // 이거 스트림 아니다!
          if !eventsForCategory.isEmpty {
            var cat = category
            cat.events = cat.events + eventsForCategory
            return cat
          }
          return category
        }
      })
    }
    .do(onCompleted: { [weak self] in
      DispatchQueue.main.async {
        self?.activityIndicator.stopAnimating()
      }
    })

    // 챌린지 2-1 방식 사용
    eoCategories.flatMap { categories in
      return updatedCategories.scan(0) { count, _ in
        return count + 1
      }
      .startWith(0)
      .map { ($0, categories.count) }
    }
    .subscribe(onNext: { tuple in
      DispatchQueue.main.async { [weak self] in
        print("[❤️check] ", tuple)
        let progress = Float(tuple.0) / Float(tuple.1)
        self?.download.progress.progress = progress
        let percent = Int(progress * 100.0)
        self?.download.label.text = "Download: \(percent)%"
      }
    })
    .disposed(by: bag)

    eoCategories
      .concat(updatedCategories)
      .bind(to: self.categories) // bind!!!! 아주 중요함!!!!! >> 일종의 subscription이 발생된다! 그래서 disposable이 반환되는것임!
      .disposed(by: bag)
  }
  
  func setupUI() {
    title = "Our Planet - Categories - \(daysForRequest)d"
    
    activityIndicator = UIActivityIndicatorView.init(style: .gray)
    activityIndicator.color = .black
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
    activityIndicator.startAnimating()

    // 챌린지 2-1 방식 사용
    view.addSubview(download)
    view.layoutIfNeeded()
    
    let refreshControl = UIRefreshControl()
    refreshControl.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
    refreshControl.tintColor = UIColor.darkGray
    refreshControl.attributedTitle = NSAttributedString(string: "🦊 Pull to refresh 🤡")
    
    refreshControl.rx.controlEvent(.valueChanged)
      .subscribe(onNext: { [weak self] in
        self?.startDownload()
        self?.tableView.refreshControl?.endRefreshing()
      }).disposed(by: bag)
    
    self.tableView.refreshControl = refreshControl
  }
}

// MARK: UITableViewDataSource
extension CategoriesViewController {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return categories.value.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell")!
    
    let category = self.categories.value[indexPath.row]
    let eventCounts = category.events.count
    
    cell.textLabel?.text = "◦ \(category.name)"  + " (\(category.events.count))"
    cell.accessoryType = eventCounts > 0 ? .disclosureIndicator : .none
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let category = categories.value[indexPath.row]
    tableView.deselectRow(at: indexPath, animated: true)
    
    guard !category.events.isEmpty else { return }
    
    let eventController: EventsViewController = getVCFromSB()
    //let eventController = storyboard?.instantiateViewController(withIdentifier: "events") as! EventsViewController
    eventController.title = category.name
    eventController.events.accept(category.events)
    navigationController?.pushViewController(eventController, animated: true)
  }

}
