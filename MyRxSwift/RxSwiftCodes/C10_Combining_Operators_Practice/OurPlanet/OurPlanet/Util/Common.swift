//
//  Common.swift
//  OurPlanet
//
//  Created by brown on 2020/03/12.
//  Copyright © 2020 Ray Wenderlich. All rights reserved.
//

import Foundation
import UIKit

let daysForRequest: Int = 3600

extension UIViewController {
  func getVCFromSB<ViewContoller>(name: String = "Main") -> ViewContoller {
    let storyboard = UIStoryboard.init(name: name, bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: String(describing: ViewContoller.self)) as! ViewContoller
    return vc
  }
}
