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

class EventsViewController: UIViewController, UITableViewDataSource {
  let bag = DisposeBag()
  let events = BehaviorRelay<[EOEvent]>(value: [])
  let days = BehaviorRelay<Int>(value: daysForRequest)
  let filteredEvents = BehaviorRelay<[EOEvent]>(value: [])
    
  var vcTitle: String = ""
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var slider: UISlider!
  @IBOutlet var daysLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()

    vcTitle = self.title!
    
    setupUI()

    slider.rx.value.map { Int($0) }
      .do(onNext: { [weak self] days in
        self?.daysLabel.text = "Last \(days) days"
      })
      .bind(to: days) // 구독으로 생각해! 즉 시퀀스가 방출된다!
      .disposed(by: bag)
    
    Observable.combineLatest(days, events)
      .map({ (days, events) -> [EOEvent] in
        let newEvents = events.filter { event -> Bool in
          let maxInterval = TimeInterval.init(days * 24 * 3600)
          if let date = event.date {
            return abs(date.timeIntervalSinceNow) < maxInterval
          }
          return true
        }
        // Log.i("newEvents.count : \(newEvents.count)")
        return newEvents
      })
      .bind(to: filteredEvents)
      .disposed(by: bag)
    
    filteredEvents
      .asObservable()
      .subscribe { [weak self] _ in
        guard let `self` = self else { return }
        self.title = "\(self.vcTitle) (\(self.filteredEvents.value.count))"
        self.tableView.reloadData()
    }.disposed(by: bag)
  }
  
  func setupUI() {
    slider.minimumValue = 1
    slider.maximumValue = Float(daysForRequest)
    slider.setValue(Float(daysForRequest), animated: false)
    
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 60

    let refreshControl = UIRefreshControl()
    refreshControl.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
    refreshControl.tintColor = UIColor.darkGray
    refreshControl.attributedTitle = NSAttributedString(string: "🦊 Pull to refresh 🤡")
    refreshControl.rx.controlEvent(.valueChanged)
      .subscribe(onNext: { [weak self] in
        self?.tableView.refreshControl?.endRefreshing()
      }).disposed(by: bag)
    self.tableView.refreshControl = refreshControl
  }

  @IBAction func sliderAction(slider: UISlider) {
    // 안써도 됨!
    // slider.rx.value 로 사용함
  }

  // MARK: UITableViewDataSource
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // Log.i("❤️reload! - \(filteredEvents.value.count)")
    return filteredEvents.value.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as! EventCell
    
    let event = filteredEvents.value[indexPath.row]
    cell.configure(event: event)
    
    return cell
  }

}
