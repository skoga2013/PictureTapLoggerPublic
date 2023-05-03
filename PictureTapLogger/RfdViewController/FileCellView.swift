//
//  FileCellView.swift
//  PictureTapLogger
//
//  Created by 古賀真一郎 on 2023/03/29.
//

import Foundation
import UIKit

final class FileCellView:UITableViewCell {
    static let reuseIdentifier = "FileCellView"
    
    @IBOutlet weak var sampleImage: UIImageView!
    @IBOutlet weak var FileName: UILabel!
    @IBOutlet weak var DirSign: UILabel!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }

    static func nib() -> UINib {
        return UINib(nibName: FileCellView.reuseIdentifier, bundle: nil)
    }
    static func hiight() -> Double {
        return 50
        
    }
    
    func bind(FileName: String, isDir: Bool=false) {
        self.FileName.text = FileName
        

    }
}
