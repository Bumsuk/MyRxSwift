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
import Gifu

class GifTableViewCell: UITableViewCell {
  @IBOutlet private var gifImageView: UIImageView!
  @IBOutlet private var activityIndicator: UIActivityIndicatorView!
  
  // 근데 이 녀석은 객체가 deinit 될때 자동으로 가지고 있는 Disposeable 을 처리하지 않는듯 싶다. > 그냥 DisposeBag 을 쓰던가 다른 타입을 사용해야 하나?
  var disposable = SingleAssignmentDisposable() // 보통 셀에서 처리하는 rx 시퀀스 관련해 처리할때 사용하면 OK!
  // 여러개를 관리하려면 이걸 쓰자. var bag = DisposeBag()
	
  // 셀이 재사용될때 (deque 되어 반환되기 직전에) 호출됨. > 초기화 및 제반처리할때 사용
  override func prepareForReuse() {
	print("🤩🤩🤩🤩", #function)
    super.prepareForReuse()
    gifImageView.prepareForReuse()
    gifImageView.image = nil
    disposable.dispose()
    disposable = SingleAssignmentDisposable()
  }
	
  func downloadAndDisplay(gif url: URL) {
    let request = URLRequest(url: url)
    activityIndicator.startAnimating()
	
	let s = URLSession.shared.rx.data(request: request)
		.observeOn(MainScheduler.instance)
		.subscribe(onNext: { [weak self] imageData in
			guard let self = self else { return }
			self.gifImageView.animate(withGIFData: imageData)
			self.activityIndicator.stopAnimating()
		})
	disposable.setDisposable(s)
  }
}

// 이게 핵심이다.
extension UIImageView: GIFAnimatable {
  private struct AssociatedKeys {
    static var AnimatorKey = "gifu.animator.key"
  }
  
  override open func display(_ layer: CALayer) {
    updateImageIfNeeded()
  }
  
  public var animator: Animator? {
    get {
      guard let animator = objc_getAssociatedObject(self, &AssociatedKeys.AnimatorKey) as? Animator else {
        let animator = Animator(withDelegate: self)
        self.animator = animator
        return animator
      }
      
      return animator
    }
    
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.AnimatorKey, newValue as Animator?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
}
