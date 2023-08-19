//
//  AFHeaderView.swift
//  simpleTimerFor_AirFryer
//
//  Created by inooph on 2023/08/07.
//

import UIKit

class AFHeaderView: UICollectionReusableView {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var sg_svSave: UISegmentedControl!
    @IBOutlet weak var sg_svUser: UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setNeedsLayout()
        layoutIfNeeded()
        
    }
    
    
    func setView(sortArr: [[SortObj]]) {
        //containerView.backgroundColor = .white.withAlphaComponent(0.5)
        containerView.backgroundColor = .white
        
        for (i, sg) in [sg_svSave, sg_svUser].enumerated() {
            sg?.tag = i
            
            for (i, sObj) in sortArr[i].enumerated() {
                sg?.setTitle(sObj.title.rawValue, forSegmentAt: i)

                if sObj.selected {
                    sg?.selectedSegmentIndex = i
                }
            }
        }
       
    }
    
    
}
