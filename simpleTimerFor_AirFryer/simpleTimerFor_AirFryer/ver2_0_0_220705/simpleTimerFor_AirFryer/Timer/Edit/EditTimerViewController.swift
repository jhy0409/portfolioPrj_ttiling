//
//  EditViewController.swift
//  simpleTimerFor_AirFryer
//
//  Created by inooph on 2021/07/24.
//

import UIKit

class EditTimerViewController: UIViewController {
    var tmpFood: Food? // 모달로 창 띄우면서 값 받은 상태.
    
    @IBOutlet weak var foodNameTxt: UITextField!
    @IBOutlet weak var ondoTxt: UITextField!
    @IBOutlet weak var hourTxt: UITextField!
    @IBOutlet weak var minTxt: UITextField!
    @IBOutlet weak var turnTimeTxt: UITextField!
    
    @IBOutlet weak var gogiButton: UIButton!
    @IBOutlet weak var snackButton: UIButton!
    @IBOutlet weak var ganpeyonButton: UIButton!
    @IBOutlet weak var breadButton: UIButton!
    @IBOutlet weak var chesoButton: UIButton!
    @IBOutlet weak var hesanmulButton: UIButton!
    @IBOutlet weak var etcFoodButton: UIButton!
    
    @IBOutlet weak var conformButton: UIButton!
    let uiLabelColorArr = AddTimerViewController.uiLabelColorArr
    var uiButton = [UIButton]()
    var uiTxtFields = [UITextField]()
    var btnSenderTxt = ""
    let foodViewModel = FoodViewModel.shared
    
    var isDismissed: (() -> Void)?
    let didDismiss_EditTimerViewController: Notification.Name = Notification.Name("EditTimerViewController")
    
    // [ㅇ] 기본값 세팅
    /// 온도
    var ondo: String {
        return ondoTxt.text == "" ? "0" : String(ondoTxt.text ?? "")
    }

    /// 뒤집는 횟수
    var turn: String {
      return turnTimeTxt.text == "" ? "0" : String(turnTimeTxt.text ?? "")
    }
    
    /// 시간
    var hour: String {
        return hourTxt.text == "" ? "0" : String(hourTxt.text ?? "")
    }
    
    /// 분
    var min: String {
        return minTxt.text == "" ? "0" : String(minTxt.text ?? "")
    }
    
    /// 음식이름
    var foodName: String {
        return foodNameTxt.text == "" ? "" : String(foodNameTxt.text ?? "")
    }
    
    // [ㅇ] 유효값 확인목록
    var if1_hourNMinZero: Bool {
        return (hour == "0" && min == "0")
    }
    
    var if2_hourZero: Bool {
        return (hour != "0" && Int(min)! > 60)
    }
    
    var if3_foodNameEmpty: Bool {
        return foodName.isEmpty
    }
    
    var if4_ondoZero: Bool {
        return ondo == "0"
    }
    
    var if5_minToH_T: Bool {
        return (hour == "0" && Int(min)! > 60 )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiButton = [gogiButton, snackButton, ganpeyonButton,
                    breadButton, chesoButton, hesanmulButton, etcFoodButton]
        uiTxtFields = [foodNameTxt, ondoTxt, hourTxt, minTxt, turnTimeTxt ]
        tintBtn(uiButton)
        
        conformButton.layer.cornerRadius = 15
        settingAlltxtField()
        btnSenderTxt = tmpFood!.foodType
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: true, completion: { self.isDismissed?() })
        NotificationCenter.default.post(name: didDismiss_EditTimerViewController, object: nil, userInfo: nil)
    }
}

extension EditTimerViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.foodNameTxt.resignFirstResponder()
        self.ondoTxt.resignFirstResponder()
        self.hourTxt.resignFirstResponder()
        self.minTxt.resignFirstResponder()
        self.turnTimeTxt.resignFirstResponder()
    }
    
    func tintBtn(_ uiBtn: [UIButton]) { // 음식유형 버튼 초기화
        var i: Int = 0
        for item in uiBtn {
            item.backgroundColor = AddTimerViewController.uiLabelColorArr[i]
            item.layer.cornerRadius = 5
            i += 1
        }
    }
    
    // [ㅇ] tmpFood에서 현재타이머의 속성 전체 가져와서 세팅
    func settingAlltxtField() {
        foodNameTxt.text = tmpFood?.foodName
        ondoTxt.text = "\(tmpFood?.ondo ?? 0)"
        hourTxt.text = "\(tmpFood?.hour ?? 0)"
        minTxt.text = "\(tmpFood?.min ?? 0)"
        turnTimeTxt.text = "\(tmpFood?.turningFood ?? 0)"
        titleAlphaSetting(foodType: tmpFood!.foodType)
    }
    
    // [ㅇ] 음식유형에 따른 버튼글자 투명도 조정
    func titleAlphaSetting(foodType: String) {
        for i in uiButton {
            if let currTxt = i.titleLabel?.text, currTxt == foodType {
                print("\nfoodType과 같다 ---> \(foodType)")
            } else {
                i.titleLabel?.alpha = 0.45
            }
        }
    }
    
    // [ㅇ] 음식 버튼글자 투명도 초기화
    func titleAlphaReset() {
        for i in uiButton {
            i.titleLabel?.alpha = 1
        }
    }
    
    // [ㅇ] food id값 일치 -> 수정된 값으로 뷰모델에 있는 foods배열의 위치에 업데이트
    @IBAction func editCurrentFood(_ sender: Any) {
        
        if [if1_hourNMinZero, if2_hourZero, if3_foodNameEmpty, if4_ondoZero].filter({ $0 == true }).count <= 0 {
            // [ㅇ] 분으로 세팅 ex) 80분 -> 1h 20min, 조건 : 시간이 0이고 분이 60분 이상일 때
                if let minIf = Int(min), if5_minToH_T == true {
                let h = minIf / 60 // 60으로 나눈 몫
                let m = minIf % 60 // 60으로 나눈 나머지
                //hour = String(h); min = String(m)
            }
            
            let foodType: String = btnSenderTxt == "NONE" ? "기타" : btnSenderTxt
            
            tmpFood?.foodName = foodName
            tmpFood?.ondo = Int(ondo)!
            tmpFood?.hour = Int(hour)!
            tmpFood?.min = Int(min)!
            tmpFood?.turningFood = Int(turn)!
            tmpFood?.foodType = foodType
            
            guard let index = tmpFood?.foodId else { return }
            for i in foodViewModel.foods {
                if i.foodId == index {
                    print("\n\nupdate food Func ----> curr id \(i.foodId)")
                    foodViewModel.updateFood(tmpFood!)
                }
            }
            txtField_makeEmpty(txtFields: uiTxtFields) // 문자입력 창 초기화
            titleAlphaReset() // 버튼 글자 투명도 초기화
            showAlert("타이머 수정 완료")
        }
    }
}

// MARK: - [ㅇ] 각 버튼 클릭시 음식분류 내용 전달
extension EditTimerViewController {
    @IBAction func gogiBtn_Clicked(_ sender: Any) {
        guard let str = sender as? UIButton else { return }
        btnSenderTxt = str.titleLabel?.text ?? "NONE"
        titleAlphaSetting(foodType: btnSenderTxt)
    }
    
    @IBAction func snackBtn_Clicked(_ sender: Any) {
        guard let str = sender as? UIButton else { return }
        btnSenderTxt = str.titleLabel?.text ?? "NONE"
        titleAlphaSetting(foodType: btnSenderTxt)
    }
    
    @IBAction func ganpeyonBtn_Clicked(_ sender: Any) {
        guard let str = sender as? UIButton else { return }
        btnSenderTxt = str.titleLabel?.text ?? "NONE"
        titleAlphaSetting(foodType: btnSenderTxt)
    }
    
    @IBAction func breadBtn_Clicked(_ sender: Any) {
        guard let str = sender as? UIButton else { return }
        btnSenderTxt = str.titleLabel?.text ?? "NONE"
        titleAlphaSetting(foodType: btnSenderTxt)
    }
    
    @IBAction func chesoBtn_Clicked(_ sender: Any) {
        guard let str = sender as? UIButton else { return }
        btnSenderTxt = str.titleLabel?.text ?? "NONE"
        titleAlphaSetting(foodType: btnSenderTxt)
    }
    
    @IBAction func hesanmulBtn_Clicked(_ sender: Any) {
        guard let str = sender as? UIButton else { return }
        btnSenderTxt = str.titleLabel?.text ?? "NONE"
        titleAlphaSetting(foodType: btnSenderTxt)
    }
    
    @IBAction func etcFoodBtn_Clicked(_ sender: Any) {
        guard let str = sender as? UIButton else { return }
        btnSenderTxt = str.titleLabel?.text ?? "NONE"
        titleAlphaSetting(foodType: btnSenderTxt)
    }
}

extension EditTimerViewController {
    // [ㅇ] 글자입력칸 초기화
    func txtField_makeEmpty(txtFields: [UITextField]) {
        for item in txtFields {
            item.text = ""
        }
    }
    
    // [ㅇ] 알림창 - 유효값 검사
    func showAlert() {
        var str = String()
        if if1_hourNMinZero == true { str.append("- 시간, 분이 둘 다 0일 수 없습니다.\n") }
        if if2_hourZero == true { str.append("- 분으로 설정시 시간 값을 비우십시오.\n") }
        if if3_foodNameEmpty == true { str.append("- 음식이름은 필수항목입니다.\n") }
        if if4_ondoZero == true { str.append("- 온도를 0 이상의 값으로 설정하십시오.\n") }
        
        let alertController = UIAlertController(title: "확인", message: str, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "닫기", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func showAlert(_ strMsg: String) {
        let alertController = UIAlertController(title: "확인", message: strMsg, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "닫기", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
}
