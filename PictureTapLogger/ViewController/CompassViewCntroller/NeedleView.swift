//
//  NeedleView.swift
//  PictureTapLogger
//
//  Created by 古賀真一郎 on 2023/04/02.
//

import Foundation
import UIKit

class NeedleView: UIViewController {
    var myBeam:MyBeam!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myBeam = MyBeam(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        //myBeam.backgroundColor = UIColor.green
        //myBeam.alpha = 0.4
        myBeam.isOpaque = false //透過

    }
    
}
