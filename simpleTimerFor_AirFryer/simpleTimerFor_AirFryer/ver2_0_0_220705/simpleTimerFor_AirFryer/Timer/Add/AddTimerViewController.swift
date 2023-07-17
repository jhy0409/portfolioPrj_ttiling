//
//  AddTimerViewController.swift
//  simpleTimerFor_AirFryer
//
//  Created by inooph on 2021/07/16.
//

import UIKit

class AddTimerViewController: UIViewController, UITextFieldDelegate, fVmodel {
    
    
    // MARK: ------------------- IBOutlets -------------------
    @IBOutlet weak var containerView: UIScrollView!
    
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
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var cvFoodType: UICollectionView!
    
    
    // MARK: ------------------- Variables -------------------
    
    var foodTypeArr: [(type: String, isSelected: Bool)] = [
        ("고기", true), ("과자", false), ("냉동식품", false),
        ("빵", false), ("야채", false), ("해산물", false), ("기타", false)]
    
    var foodBtnType: (() -> String)?
    static let uiLabelColorArr = [#colorLiteral(red: 1, green: 0, blue: 0, alpha: 0.2), #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 0.2), #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 0.2), #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 0.2), #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 0.2), #colorLiteral(red: 0.2196078449, green: 0.2030190556, blue: 0.8549019694, alpha: 0.2), #colorLiteral(red: 0.5, green: 0.007843137719, blue: 0.4200693323, alpha: 0.2)]
    var uiTxtFields = [UITextField]()
    
    var btnSenderTxt: String {
        return foodTypeArr.filter { (type: String, isSelected: Bool) in
            isSelected == true
        }.first?.type ?? "NONE"
    }
    
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
    
    var str: String {
        var tempRes: String = ""
        
        if if1_hourNMinZero == true { tempRes.append("- 시간, 분이 둘 다 0일 수 없습니다.\n") }
        if if2_hourZero == true { tempRes.append("- 분으로 설정시 시간 값을 비우십시오.\n") }
        if if3_foodNameEmpty == true { tempRes.append("- 음식이름은 필수항목입니다.\n") }
        if if4_ondoZero == true { tempRes.append("- 온도를 0 이상의 값으로 설정하십시오.\n") }
        
        let strArr = tempRes.split(separator: "\n")
        var res: String = ""
        
        for (i, obj) in strArr.enumerated() {
            res.append("\(obj)\(i == strArr.count - 1 ? "" : "\n")")
        }
        
        return res
    }
    
    var editFoodObj: Food?
    var editDel: fVmodel?
    
    // MARK: ------------------- View Life Cycle -------------------
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        super.viewDidLoad()
        uiTxtFields = [foodNameTxt, ondoTxt, hourTxt, minTxt, turnTimeTxt ]
        
        cvFoodType.reloadData()
        
        let tapG: UITapGestureRecognizer = .init(target: self, action: #selector(endEdit))
        containerView.addGestureRecognizer(tapG)
        
        if let fObj = editFoodObj {
            settingAlltxtField(obj: fObj)
        }
    }
    
    
    // [ㅇ] tmpFood에서 현재타이머의 속성 전체 가져와서 세팅
    func settingAlltxtField(obj: Food) {
        foodNameTxt.text    = obj.foodName
        ondoTxt.text        = String(describing: obj.ondo)
        hourTxt.text        = String(describing: obj.hour)
        minTxt.text         = String(describing: obj.min)
        turnTimeTxt.text    = String(describing: obj.turningFood)
        
        addButton.setTitle("수정", for: .normal)
    }
    
    // MARK: ------------------- IBAction functions -------------------
    
    @IBAction func addButtonTap(_ sender: Any) {
        // [ㅇ] 유효값 검사 후 반환값이 true일 때만 아래코드 실행
        
        if [if1_hourNMinZero, if2_hourZero, if3_foodNameEmpty, if4_ondoZero].filter({ $0 == true }).count <= 0 {
            // [ㅇ] 분으로 세팅 ex) 80분 -> 1h 20min, 조건 : 시간이 0이고 분이 60분 이상일 때
            //if let minIf = Int(min), if5_minToH_T == true {
            //    let h = minIf / 60 // 60으로 나눈 몫
            //    let m = minIf % 60 // 60으로 나눈 나머지
            //    hour = String(h); min = String(m)
            //}
            
            let foodType: String    = btnSenderTxt == "NONE" ? "기타" : btnSenderTxt
            let created: String     = currentTime()
            if let edObj = editFoodObj {
                
                for i in foodShared.foods {
                    if i.foodId == edObj.foodId { // 기존 수정
                        print("\n\nupdate food Func ----> curr id \(i.foodId)")
                        let food: Food = .init(foodId: edObj.foodId, ondo: Int(ondo)!, hour: Int(hour)!, min: Int(min)!, turn: Int(turn)!, foodType: foodType, isTimerOn: false, foodName: foodName, created: created)

                        foodShared.updateFood(food) { [weak self] in
                            guard let `self` = self else { return }
                            
                            self.txtField_makeEmpty(txtFields: self.uiTxtFields) // 문자입력 창 초기화
                            
                            self.showAlert("타이머 수정 완료", actions: [
                                ["닫기" : { [weak self] UIAlertAction in
                                    guard let `self` else { return }

                                    self.dismiss(animated: true) {
                                        self.editDel?.afterLeaveView()
                                    }
                                }]
                            ])
                            
                        }
                        break
                    }
                }
                
            } else { // 신규추가
                
                let food: Food = FoodManager.shared.createFood(ondo: Int(ondo)!, hour: Int(hour)!, min: Int(min)!, turn: Int(turn)!, foodType: foodType, isTimerOn: false, foodName: foodName, created: created)
                
                foodShared.addFood(food, isLast: true) { [weak self] in // 음식 배열에 추가
                    guard let `self` = self else { return }
                    txtField_makeEmpty(txtFields: uiTxtFields) // 문자입력 창 초기화
                    showAlert("타이머 추가 완료")
                }
            }
            
        } else {
            showAlert()
        }
    }
    
    
    // MARK: ------------------- function -------------------
    @objc func endEdit(_ sender: UITapGestureRecognizer) {
        print("--> 컨테이너 스크롤뷰 탭, 입력종료 / func endEdit")
        view.endEditing(true)
    }
    
    
}

extension AddTimerViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { // 다른곳 터치시 키보드 내리기
        self.foodNameTxt.resignFirstResponder()
        self.ondoTxt.resignFirstResponder()
        self.hourTxt.resignFirstResponder()
        self.minTxt.resignFirstResponder()
        self.turnTimeTxt.resignFirstResponder()
    }
    
    func txtField_makeEmpty(txtFields: [UITextField]) { // 글자입력칸 초기화
        for item in txtFields {
            item.text = ""
        }
    }
}

extension AddTimerViewController {
    // MARK: - [ㅇ] 유효성 검사 후 경고창 실행
    func showAlert() {
        let alertController = UIAlertController(title: "확인", message: str, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "닫기", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - [ㅇ] 단순 알림창
    func showAlert(_ strMsg: String) {
        let alertController = UIAlertController(title: "확인", message: strMsg, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "닫기", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func showAlert(_ strMsg: String, actions: [[ String: (UIAlertAction)->Void ]]? = nil ) {
        let alertController = UIAlertController(title: "확인", message: strMsg, preferredStyle: .alert)
        
        if let acts = actions {
            for i in acts {
                alertController.addAction(.init(title: i.keys.first ?? "", style: .default, handler: i.values.first ))
            }
            
        } else {
            let defaultAction = UIAlertAction(title: "닫기", style: .default, handler: nil)
            alertController.addAction(defaultAction)
        }
        
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: =================== collectionView ===================
extension AddTimerViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (collectionView.frame.width - 20) / 3
        let height: CGFloat = 50
        return .init(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return foodTypeArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddFoodTypeCVC", for: indexPath) as! AddFoodTypeCVC
        cell.tag = indexPath.item
        
        cell.btn_foodType.addTarget(self, action: #selector(btnFoodTypeTapAction), for: .touchUpInside)
        cell.updateUI(type: foodTypeArr[indexPath.item])
        
        return cell
    }
    
    @objc func btnFoodTypeTapAction(_ sender: UIButton) {
        for i in 0..<foodTypeArr.count {
            foodTypeArr[i].isSelected = sender.tag == i
        }
        
        cvFoodType.reloadItems(at: cvFoodType.indexPathsForVisibleItems)
    }
    
}

extension UIView {
    @IBInspectable var cornerRadi: CGFloat {
        get {
            return layer.cornerRadius
        }
        
        set {
            layer.cornerRadius = newValue
        }
    }
}
