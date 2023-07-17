//
//  SettingViewController.swift
//  simpleTimerFor_AirFryer
//
//  Created by inooph on 2021/07/19.
//

import UIKit
import Firebase

class SettingTableViewController: UITableViewController, fVmodel {
    
    
    // MARK: =================== IBOutlet ===================
    /// 토글스위치 - 서버 데이터 다운
    @IBOutlet weak var downSample: UISwitch!
    /// 토글스위치 - 타이머 전체삭제
    @IBOutlet weak var delFoodsAll: UISwitch!
    
    /// 버전정보
    @IBOutlet weak var versionDescription: UILabel!
    
    
    // MARK: =================== Variables ===================
    
    lazy var tblArr: [[String: Any]] = [
        [
            "header" : "login".uppercased(),
            "cells" : [
                ["title" : "Google", "type": stType.btn, "action": { print("--> Google tapped\n")} ] as [String : Any],
                ["title" : "Apple", "type": stType.btn, "action": { print("--> Apple tapped\n")} ],
            ]
        ],
        
        [
            "header" : "user info".uppercased(),
            "cells" : [
                ["title" : "user name", "type": stType.lbl, "rightDesc": "-", "action": {}] as [String : Any],
                ["title" : "email", "type": stType.lbl, "rightDesc": "-", "action": {}],
                ["title" : "phone number", "type": stType.lbl, "rightDesc": "-", "action": {}]
                //["title" : "phone number", "type": stType.hide, "action": {}],
            ]
        ],
        
        [
            "header" : "settings".uppercased(),
            "cells" : [
                ["title" : "서버에서 샘플받기", "type": stType.swch, "isOn": false, "action": {}] as [String : Any],
                ["title" : "타이머 전체 삭제", "type": stType.swch, "isOn": false, "action": {}],
                ["title" : "버전 정보", "type": stType.lbl, "rightDesc": "\(self.versionStr)", "action": {}],
            ]
        ]
    ]
    
    /// v 버전정보 (빌드)
    var versionStr: String {
        guard let dict = Bundle.main.infoDictionary,
              let version = dict["CFBundleShortVersionString"] as? String,
              let build = dict["CFBundleVersion"] as? String else { return "" }
        
        return "v \(version) (\(build))"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // [ㅇ] firebase에서 내려받기
    @objc func downToggle(_ sender: idxSwitch) {
        // [ㅇ] toggle버튼 ON -> 기본 json file 다운로드
        if sender.isOn == true {
            sender.isEnabled = false // 다운시작 - 비활성화
            print("\n---> [설정창 스위치 - On] 서버데이터 받기 toggle")
            
            getData(of:  0...17) {
                DispatchQueue.main.async {
                
                    print("\n--> [ 함수실행 ] add getData : \n---> [ 타이머 전체 수 ] foodsArr current count : \(self.foodShared.manager.foods.count) ")
                    
                    // [ㅇ] 다운완료 알림창
                    // [] 다운 후 객체 정렬
                    self.showAlert("알림","다운로드가 완료되었습니다.", {
                        sender.isEnabled = true // 다운완료 후 동작 - 스위치 끄기
                        sender.isOn = false
                    })
                }
                
            }
            
           
        }
    }
    
    /// 스위치 함수 - 서버데이터 전체삭제
    @objc func delAllFoodArr(_ sender: idxSwitch) {
        if sender.isOn {
            // [ㅇ] foods Arr 갯수가 0이면 return
            if foodShared.foods.count == 0 {
                showAlert("알림", "저장된 타이머가 없습니다.", { sender.isOn = false })
                return
            }
            print("\n---> [설정창 스위치 - On] 모든 데이터를 삭제합니다.")
            deleteAlert("경고","저장된 모든 타이머를 삭제하시겠습니까?", sender)
        }
    }
    
    func getData(of closedRange: ClosedRange<Int>, _ completion: (()->Void)? = nil ) {
        //var v1_foodId = 0
        
        let ref: DatabaseReference! = Database.database().reference()
        for i in closedRange {
            ref.child("sample").child(String(i)).observeSingleEvent(of: .value, with: { [weak self] snapshot in
                guard let `self` = self else { return }
                
                let value = snapshot.value as? NSDictionary ?? [:]
                
                //v1_foodId = value?["foodId"] as? Int ?? 0
                let v2_foodName     = value["foodName"] as? String ?? "NONE"
                let v3_foodType     = value["foodType"] as? String ?? "NONE"
                let v4_foodHour     = value["hour"] as? Int ?? 0
                let v5_timerOn      = value["isTimerOn"] as? Bool ?? false
                let v6_foodMin      = value["min"] as? Int ?? 0
                
                let v7_foodOndo     = value["ondo"] as? Int ?? 0
                let v8_foodTurnNum  = value["turningFood"] as? Int ?? 0
                let created         = self.currentTime()
                
                let food: Food = self.foodShared.manager.createFood(ondo: v7_foodOndo, hour: v4_foodHour, min: v6_foodMin, turn: v8_foodTurnNum, foodType: v3_foodType, isTimerOn: v5_timerOn, foodName: v2_foodName, created: created)
                
                self.foodShared.addFood(food, isLast: i == closedRange.upperBound, completion: completion)
               
            })
            
            
        }
        
    }
    
    func showAlert(_ title: String, _ strMsg: String, _ completion: (()->())? ) {
        guard let comp = completion else { print("클로저의 변환 실패 \(String(describing: completion ?? nil))"); return }
        let alertController = UIAlertController(title: title, message: strMsg, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "닫기", style: .default, handler: { _ in comp() })
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func deleteAlert(_ title: String, _ strMsg: String, _ swch: idxSwitch) {
        let alertController = UIAlertController(title: title, message: strMsg, preferredStyle: .alert)
        
        let yes = UIAlertAction(title: "네", style: .default, handler: { _ in self.yesClick(swch) })
        alertController.addAction(yes)
        let no = UIAlertAction(title: "아니오", style: .default, handler: { _ in self.noClick(swch) })
        alertController.addAction(no)
        present(alertController, animated: true, completion: nil)
    }
    
    func yesClick(_ sender: idxSwitch) {
        foodShared.deleteAllFoods()
        print("삭제 ㅇ : \(foodShared.foods.count)")
        sender.isOn = false
    }
    
    func noClick(_ sender: idxSwitch) {
        print("삭제 X : \(foodShared.foods.count)")
        sender.isOn = false
    }
    
    
    // MARK: =================== tableView ===================
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = tblArr[section]["header"] as? String ?? ""
        
        return title
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tblArr.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let cells = tblArr[section]["cells"] as? [[String: Any]] {
            return cells.count
            
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingTVC", for: indexPath) as! settingTVC
        cell.tag = indexPath.row
        cell.selectionStyle = .none
        
        if let obj = tblArr[indexPath.section]["cells"] as? [[String: Any]] {
            let ithObj          = obj[indexPath.row]
            
            let tit: String     = ithObj["title"] as? String ?? ""
            let type: stType    = ithObj["type"] as? stType ?? .hide
            let isOn: Bool      = ithObj["isOn"] as? Bool ?? false
            let rgDesc: String  = ithObj["rightDesc"] as? String ?? ""
            
            cell.setView(obj: (title: tit, type: type, isOn: isOn, rightDesc: rgDesc))
            cell.swch.tit = tit
            
            if let idx = ["샘플받기", "삭제"].filter ({ (cell.swch.tit).lowercased().contains( $0.lowercased() ) }).first {
                
                switch idx {
                case "샘플받기":
                    cell.swch.addTarget(self, action: #selector(downToggle), for: .touchUpInside)
                    
                case "삭제":
                    print("삭제")
                    cell.swch.addTarget(self, action: #selector(delAllFoodArr), for: .touchUpInside)
                    
                default:
                    break
                }
            }
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("--> tap index = \(indexPath)")
        
        if let obj = tblArr[indexPath.section]["cells"] as? [[String: Any]] {
            let ithObj              = obj[indexPath.row]
            let act: (()->Void)     = ithObj["action"] as? ()->Void ?? { print("--> action is Nil\n") }
            
            act()
        }
        
    }
    
}

class settingTVC: UITableViewCell {
    
    @IBOutlet weak var lbl_title: UILabel!
    
    @IBOutlet weak var viewRhtContainer: UIView!
    @IBOutlet weak var viewRhtAccWidth: NSLayoutConstraint!
    
    @IBOutlet weak var lbl_desc: UILabel!
    @IBOutlet weak var swch: idxSwitch!
    @IBOutlet weak var btn_right: UIButton!
    
    
    func setView(obj: (title: String, type: stType, isOn: Bool, rightDesc: String )) {
        let views: [UIView] = [lbl_desc, swch, btn_right]
        
        for (i, viewObj) in views.enumerated() {
            viewObj.tag                 = i + 1
            viewObj.isHidden            = obj.type.rawValue != viewObj.tag
            viewRhtContainer.isHidden   = obj.type == .hide
            
            switch viewObj {
            case swch:
                swch.idx = (viewObj.tag, tag)
            
            default:
                break
            }
        }
        
        if let visView = views.filter({ !$0.isHidden }).first {
            switch visView {
            case lbl_desc:
                let lblWidth: CGFloat = (obj.rightDesc as NSString).size(withAttributes: [NSAttributedString.Key.font : lbl_desc.font as Any]).width
                viewRhtAccWidth.constant = lblWidth > 100 ? 100 : lblWidth
                
            default:
                viewRhtAccWidth.constant = visView.frame.width
            }
        }
        
        
        lbl_title.text  = obj.title

        lbl_desc.text   = obj.rightDesc
        swch.isOn       = obj.isOn
    }
    
}

enum stType: Int {
    case `hide` = 0
    case lbl = 1
    case swch = 2
    case btn = 3
}

class idxSwitch: UISwitch {
    var idx: (hide: Int, tag: Int) = (0, 0)
    var tit: String = ""
}

extension UIViewController {
    func currentTime() -> String {
        let now = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return dateFormatter.string(from: now)
    }
}


protocol fVmodel {
    var foodShared: FoodViewModel { get }
    func afterLeaveView()
}

extension fVmodel {
    var foodShared: FoodViewModel {
        get { return FoodViewModel.shared }
    }
    
    func afterLeaveView() {
        
    }
}
