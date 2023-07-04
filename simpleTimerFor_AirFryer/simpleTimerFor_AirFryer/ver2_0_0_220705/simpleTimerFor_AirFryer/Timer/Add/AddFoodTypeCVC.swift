//
//  AddFoodTypeCVC.swift
//  simpleTimerFor_AirFryer
//
//  Created by inooph on 2023/07/05.
//

import UIKit

class AddFoodTypeCVC: UICollectionViewCell {
    
    @IBOutlet weak var btn_foodType: UIButton!
    
    func updateUI(type: (type: String, isSelected: Bool)) {
        btn_foodType.setTitle(type.type, for: .normal)
        btn_foodType.backgroundColor = type.isSelected ? .systemBlue.withAlphaComponent(0.3) : .gray.withAlphaComponent(0.15)
    }
}
