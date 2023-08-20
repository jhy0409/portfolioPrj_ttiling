//
//  AFTimerCell.swift
//  simpleTimerFor_AirFryer
//
//  Created by inooph on 2021/07/15.
//

import UIKit
import UserNotifications

class AFTimerCell: UICollectionViewCell {
    @IBOutlet weak var foodTitleLabel: UILabel!
    @IBOutlet weak var ondoLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var turnNumLabel: UILabel!
    @IBOutlet weak var foodTypeBtn: UIButton!
    
    @IBOutlet weak var timerDescriptionLabel: UILabel!
    @IBOutlet weak var timerStartLabel: UILabel!
    @IBOutlet weak var timerSwitch: UISwitch!
    var cornerRadius: CGFloat = 10
    
    @IBOutlet weak var lblFrom: UILabel!
    @IBOutlet weak var lblCreated: UILabel!
    
    var timerTapHandler: (()-> Void)?
    var closeBtnHandler: (()-> Void)?
    var startTime: Date?
    var timer = Timer()
    
    weak var viewController: UIViewController?
    var tmpFoodStr: String? // 타이머 실행전 기본값
    var tmpFoodFromCell: Food? // foods[indexpath.item] 낱개값, 수정버튼 클릭 시 뷰 띄울 때 필요
    
    var editDel: fVmodel?
    
    func updateUI(food: Food?) {
        tmpFoodFromCell = food
        
        guard let food      = food else { return }

        lblCreated.text     = food.created
        lblFrom.text        = food.crType.replacingOccurrences(of: "sv", with: "서버").replacingOccurrences(of: "user", with: "유저")
        
        foodTitleLabel.text = "\(food.foodName)"
        ondoLabel.text      = "\(food.ondo)℃" // 온도
        
        let h = String(food.hour), m = String(food.min)
        timerLabel.text         = "\(food.hour > 0 ? "\(h)시간" : "") \(food.min > 0 ? "\(m)분" : "")" // 시간
        //timerStartLabel.text    = "\(food.hour > 0 ? "\(h) : " : "")\(m)분"
        
        timerStartLabel.text    = timerLabel.text
        tmpFoodStr = "\(h) : \(m)" // 타이머 실행전 기본값
        turnNumLabel.text = "\(food.turningFood)번" // 뒤집는 횟수
        
        // [ㅇ] 라벨별 색 변경
        foodTypeBtn.setTitle(food.foodType, for: .normal) // 음식 분류, 채소, 고기 등
        foodTypeBtn.layer.backgroundColor = food.fCol
        foodTypeBtn.layer.cornerRadius = 5
        
        // [ㅇ] 타이머 켜기끄기
        timerDescriptionLabel.text = timerSwitch.isOn ? "타이머 끄기" : "타이머 켜기"
    }
    
    func setTimer(startTime: Date, food: Food) {
        if timerSwitch.isOn == false { // 타이머가 꺼져있으면
            resetSwitch()
        }
        else { // 타이머가 켜져있을 때
            DispatchQueue.main.async { [weak self] in
                self?.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                    let elapsedTimeSeconds = Int(Date().timeIntervalSince(startTime))
                    
                    var expireLimit     = food.totalSec //hourToSec + minToSec // 초로 환산
                    if food.foodName == "test" { expireLimit = 4 } // test일 때 10초
                    var tmpStr = expireLimit - elapsedTimeSeconds // 종료시간 - 시작시간
                    
                    let (h, m, s)       = returnHMS(&tmpStr)
                    let remainSeconds   = "\(h > 0 ? "\(h)시" : "") \(m > 0 ? "\(m)분" : "") \(s > 0 ? "\(s)초" : "")"
                    self?.timerStartLabel.text = String(describing: remainSeconds)
                    
                    if h <= 0 && m <= 0 && s <= 0 { self?.resetSwitch() }
                }
            }
        }
        
        func returnHMS(_ inputTotal: inout Int) -> (h: Int, m: Int, s: Int) {
            let h = inputTotal / ( 60 * 60 )
            inputTotal %= 60 * 60
            
            let m = inputTotal / 60
            inputTotal %= 60
            let s = inputTotal
            return (h, m, s)
        }
    }
    
    func resetSwitch() { // 타이머 완료시 초기화
        timer.invalidate()
        timerSwitch.isOn = false
        timerDescriptionLabel.text = timerSwitch.isOn ? "타이머 끄기" : "타이머 켜기"
        timerStartLabel.text = tmpFoodStr
        print("===> timer is OFF : reset Switch ")
    }
}

extension AFTimerCell {
    @IBAction func switchTapped(_ sender: Any) {
        if timerSwitch.isOn == true { // [ㅇ] 타이머 On
            timerDescriptionLabel.text = timerSwitch.isOn ? "타이머 끄기" : "타이머 켜기"
            timerTapHandler?()
            
            if var sec = tmpFoodFromCell?.totalSec {
                if tmpFoodFromCell?.foodName == "test" {
                    sec = 4 
                }
                AFTimerViewController.notiOutside(Double(sec + 1))
            } 
        } else { // [ㅇ] 타이머 off
            timerDescriptionLabel.text = timerSwitch.isOn ? "타이머 끄기" : "타이머 켜기"
            print("===> timer is OFF")
            resetSwitch()
            AFTimerViewController.userNotiCenter.removeAllPendingNotificationRequests() // 예약된 모든 알림삭제
        }
    }
    
    @IBAction func closeBtnTapped(_ sender: Any) { // [ㅇ] 삭제 버튼 누를 때 동작
        closeBtnHandler?()
    }
    
    @IBAction func editBtnTapped(_ sender: Any) { // [ㅇ] 수정버튼 누를 때 동작 -> 뷰를 새로 띄움
        print("\n수정버튼 눌림")
        guard let editVC = viewController?.storyboard?.instantiateViewController(identifier: "AddTimerViewController") as? AddTimerViewController else { return }
        editVC.editFoodObj = tmpFoodFromCell
        editVC.editDel = editDel
        viewController?.present(editVC, animated: true, completion: nil)
    }
    
    // MARK: - UIView 관련 (UICollectionViewCell 모서리 둥글게, 그림자)
    override func awakeFromNib() {
        super.awakeFromNib()
        foodTypeBtn.isEnabled = false
        timerSwitch.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        
        contentView.layer.cornerRadius = cornerRadius // Apply rounded corners to contentView
        contentView.layer.masksToBounds = true
        
        layer.cornerRadius = cornerRadius // Set masks to bounds to false to avoid the shadow
        layer.masksToBounds = false // from being clipped to the corner radius
        
        layer.shadowRadius = 6.0 // Apply a shadow
        layer.shadowOpacity = 0.10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath( // Improve scrolling performance with an explicit shadowPath
            roundedRect: bounds,
            cornerRadius: cornerRadius
        ).cgPath
    }
    
   
    
}
