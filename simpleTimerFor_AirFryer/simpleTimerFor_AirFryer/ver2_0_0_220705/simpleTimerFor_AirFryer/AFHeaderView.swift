//
//  AFHeaderView.swift
//  simpleTimerFor_AirFryer
//
//  Created by inooph on 2023/08/07.
//

import UIKit

class AFHeaderView: UICollectionReusableView {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var sg_svUser: UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setNeedsLayout()
        layoutIfNeeded()
        
    }
    
    
    func setView(sortArr: [(title: SortType, selected: Bool)]) {
        //containerView.backgroundColor = .white.withAlphaComponent(0.5)
        containerView.backgroundColor = .white
        
        for (i, sObj) in sortArr.enumerated() {
            sg_svUser.setTitle(sObj.title.rawValue, forSegmentAt: i)

            if sObj.selected {
                sg_svUser.selectedSegmentIndex = i
            }
        }
        
        //for (i, sObj) in sortArr[1].enumerated() {
        //    sg_created.setTitle(sObj.title, forSegmentAt: i)
        //
        //    if sObj.selected {
        //        sg_created.selectedSegmentIndex = i
        //    }
        //}
        
    }
}
