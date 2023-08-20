//
//  SettingViewController.swift
//  simpleTimerFor_AirFryer
//
//  Created by inooph on 2021/07/19.
//

import UIKit
import Firebase

import FirebaseCore
import FirebaseAuth
// [END auth_import]

// For Sign in with Google
// [START google_import]
import GoogleSignIn

class SettingTableViewController: UITableViewController, fVmodel {
    
    
    // MARK: =================== IBOutlet ===================
    /// 토글스위치 - 서버 데이터 다운
    @IBOutlet weak var downSample: UISwitch!
    /// 토글스위치 - 타이머 전체삭제
    @IBOutlet weak var delFoodsAll: UISwitch!
    
    /// 버전정보
    @IBOutlet weak var versionDescription: UILabel!
    
    // MARK: =================== Variables ===================
    var defCells: [[[String: Any]]] {
        return [
            [
                ["title" : "Google", "type": stType.btn, "action": { [weak self] in
                    guard let `self` = self else { return }
                    
                    print("--> Google tapped\n")
                    self.performGoogleSignInFlow()
                    
                } ] as [String : Any]
            ],
            [
                ["title" : "user name", "type": stType.lbl, "rightDesc": "-", "action": {}] as [String : Any],
                ["title" : "email", "type": stType.lbl, "rightDesc": "-", "action": {}],
                ["title" : "phone number", "type": stType.lbl, "rightDesc": "-", "action": {}]
                //["title" : "phone number", "type": stType.hide, "action": {}],
            ]
        ]
    }
    
    lazy var tblArr: [[String: Any]] = [
        [
            "header" : "로그인",
            "cells" : defCells[0]
        ],
        
        [
            "header" : "유저정보",
            "cells" : defCells[1]
        ],
        
        [
            "header" : "설정",
            "cells" : [
                ["title" : "서버와 연동", "type": stType.swch, "isOn": fetchServer, "action": {}] as [String : Any],
                ["title" : "서버에서 샘플받기", "type": stType.swch, "isOn": false, "action": {}],
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
        
        
        if let usr = usrInfo {
            let emptyStr: String = "-"
            let userNm: String    = (usr.displayName?.isEmpty ?? true) ? emptyStr : (usr.displayName ?? emptyStr)
            let email: String     = (usr.email?.isEmpty ?? true) ? emptyStr : (usr.email ?? emptyStr)
            let phonNm: String    = (usr.phoneNumber?.isEmpty ?? true) ? emptyStr : (usr.phoneNumber ?? emptyStr)
            
            self.tblArr[0].updateValue([
                ["title" : "Google", "type": stType.btn,
                 "action": { [weak self] in guard let `self` = self else { return }
                    print("--> Google tapped\n")
                    self.performGoogleSignInFlow()
                    
                } ] as [String : Any]
            ], forKey: "cells")
            
            self.tblArr[1].updateValue( [
                ["title" : "user name", "type": stType.lbl, "rightDesc": "\(userNm)", "action": {}] as [String : Any],
                ["title" : "email", "type": stType.lbl, "rightDesc": "\(email)", "action": {}],
                ["title" : "phone number", "type": stType.lbl, "rightDesc": "\(phonNm)", "action": {}]
            ], forKey: "cells")
            
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    
    @objc func switchAction(_ sender: idxSwitch) {
        
        switch sender.menuTypeStr {
            
        case .fetch:
            fetch(sender)
            
        case .downSample:
            downToggle(sender)
            
        case .delete:
            delAllFoodArr(sender)
        }
    }
    
    func fetch(_ sender: idxSwitch) {
        print("--> fetchFromServer 연동 = \(sender.isOn)\n")
        UserDefaults.standard.setValue(sender.isOn, forKey: "fetchServer")
        
        if sender.isOn {
            
            if (tblArr[1]["cells"] as? [[String: Any]] ?? [])[1]["rightDesc"] is String {
                //rfr.child("users/\(usrEmail)").removeValue()
                
                var uniqueFoods = [Food]()
                
                foodShared.manager.localFoods.forEach { lcFd in
                    let hasValue: Bool = foodShared.manager.serverFoods.filter { $0.key == lcFd.key }.count > 0
                    
                    if !hasValue {
                        uniqueFoods.append(lcFd)
                    }
                }
                
                for (_, obj) in uniqueFoods.enumerated() {
                    rfr.child("users/\(usrEmail)/\(obj.key)/foodName").setValue(obj.foodName)
                    rfr.child("users/\(usrEmail)/\(obj.key)/ondo").setValue(obj.ondo)
                    rfr.child("users/\(usrEmail)/\(obj.key)/hour").setValue(obj.hour)
                    rfr.child("users/\(usrEmail)/\(obj.key)/min").setValue(obj.min)
                    rfr.child("users/\(usrEmail)/\(obj.key)/turningFood").setValue(obj.turningFood)
                    rfr.child("users/\(usrEmail)/\(obj.key)/foodType").setValue(obj.foodType)
                    
                    rfr.child("users/\(usrEmail)/\(obj.key)/crType").setValue(obj.crType)
                    rfr.child("users/\(usrEmail)/\(obj.key)/isTimerOn").setValue(obj.isTimerOn)
                    rfr.child("users/\(usrEmail)/\(obj.key)/foodId").setValue(obj.foodId)
                    rfr.child("users/\(usrEmail)/\(obj.key)/created").setValue(obj.created)
                }
            }
        }
    }
    
    // [ㅇ] firebase에서 내려받기
    @objc func downToggle(_ sender: idxSwitch) {
        // [ㅇ] toggle버튼 ON -> 기본 json file 다운로드
        if sender.isOn == true {
            sender.isEnabled = false // 다운시작 - 비활성화
            print("\n---> [설정창 스위치 - On] 서버데이터 받기 toggle")
            
            getData(completion: [
                { [weak self] in
                    guard let `self` else { return }
                    
                        print("\n--> [ 함수실행 ] add getData : \n---> [ 타이머 전체 수 ] foodsArr current count : \(self.foodShared.foods.count) ")
                                self.tableView.reloadData()
                        
                        self.showAlert("알림","다운로드가 완료되었습니다.", {
                            sender.isEnabled = true // 다운완료 후 동작 - 스위치 끄기
                            sender.isOn = false
                            
                            self.foodShared.loadFoods(save: self.foodShared.saveSpot, sort: self.foodShared.selectedType)
                            self.tableView.reloadData()
                        })
                    
                },
                
                {
                    self.showAlert("알림", "현재 추가된 타이머와 동일합니다.") {
                        sender.isEnabled = true // 다운완료 후 동작 - 스위치 끄기
                        sender.isOn = false
                    }
                }
            ])
            
           
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
    
    func getData(completion: [()->Void]? = nil ) {
        //var v1_foodId = 0
        
        // [ㅇ] 다운완료 알림창
        // [] 다운 후 객체 정렬
        rfr.child("sample").getData { [weak self] err, snapshot in
            guard let `self` = self else { return }

            let prevFoods = self.foodShared.foods
            
            if let arrs = snapshot.value as? Array<NSDictionary> {
                for (i, value) in arrs.enumerated() {
                    
                    //v1_foodId = value?["foodId"] as? Int ?? 0
                    let crType          = value["crType"] as? String ?? "server"
                    let foodName        = value["foodName"] as? String ?? "NONE"
                    let foodType        = value["foodType"] as? String ?? "NONE"
                    let hour            = value["hour"] as? Int ?? 0
                    let isTimerOn       = value["isTimerOn"] as? Bool ?? false
                    let min             = value["min"] as? Int ?? 0
                    
                    let ondo            = value["ondo"] as? Int ?? 0
                    let turningFood     = value["turningFood"] as? Int ?? 0
                    let created         = value["created"] as? String ?? ""
                    
                    let food: Food = self.foodShared.manager.createFood(ondo: ondo, hour: hour, min: min, turn: turningFood, foodType: foodType, isTimerOn: isTimerOn, foodName: foodName, created: created, crType: crType)
                    
                    /// 생성타입이 서버값과 같지 않을 때 추가함
                    let hasValue: Bool = foodShared.foods.filter { $0.crType == crType }.count > 0
                    
                    if !hasValue {
                        self.foodShared.addFood(food)
                        print("--> addFood from server = \(food.foodName)\t\(food.crType)\((i+1) % 5 == 0 ? "\n" : "")")
                    }
                }
                
                DispatchQueue.main.async {
                    if prevFoods == self.foodShared.foods {
                        completion?[1]()
                    } else {
                        completion?[0]()
                    }
                }
                
            }
            
            
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
        
        tableView.reloadData()
    }
    
    func noClick(_ sender: idxSwitch) {
        print("삭제 X : \(foodShared.foods.count)")
        sender.isOn = false
    }
    
    
    @objc func showCellAlert(sender: UIButton) {
        let sdid = switchMenuStr(rawValue: sender.restorationIdentifier ?? "")
        print("--> sdid = \(sdid?.rawValue ?? "")\n")
        
        switch sdid {
        case .fetch, .downSample:
            showAlert(msg: "구글 계정 로그인이 필요합니다.")
            
        case .delete:
            showAlert(msg: "조리시간 탭의 리스트 수가 \n1개이상이어야 합니다.")
 
        case .none:
            break
        }
    }
    
    // MARK: ------------------- google sign in -------------------
    private func performGoogleSignInFlow() {
        
        
        if hasCrntUser {
            print("title is 로그아웃")
            showAlert(msg: "로그아웃 하시겠습니까", actions: [
                ["확인" : { [weak self] act in
                    guard let `self` = self else { return }
                    do {
                        try Auth.auth().signOut()
                        self.tblArr[0].updateValue(self.defCells[0], forKey: "cells")
                        self.tblArr[1].updateValue(self.defCells[1], forKey: "cells")
                        self.tableView.reloadData()
                        
                    } catch let err {
                        self.showAlert("알림", err.localizedDescription, nil)
                    }
                }],
                ["닫기" : { [weak self] act in
                    guard let `self` = self else { return }
                    self.dismiss(animated: true) }
                ],
            ])
           
        } else {
            // [START headless_google_auth]
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
            
            // Create Google Sign In configuration object.
            // [START_EXCLUDE silent]
            // TODO: Move configuration to Info.plist
            // [END_EXCLUDE]
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            
            // Start the sign in flow!
            GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
                guard error == nil else {
                    // [START_EXCLUDE]
                    return displayError(error)
                    // [END_EXCLUDE]
                }
                
                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString
                else {
                    // [START_EXCLUDE]
                    let error = NSError(
                        domain: "GIDSignInError",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Unexpected sign in result: required authentication data is missing.",
                        ]
                    )
                    return displayError(error)
                    // [END_EXCLUDE]
                }
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                               accessToken: user.accessToken.tokenString)
                
                // [START_EXCLUDE]
                signIn(with: credential)
                // [END_EXCLUDE]
            }
            // [END headless_google_auth]
        }
    }
    
    func signIn(with credential: AuthCredential) {
        // [START signin_google_credential]
        Auth.auth().signIn(with: credential) { [weak self] result, error in
            // [START_EXCLUDE silent]
            
            guard error == nil, let `self` = self else { return (self!.displayError(error)) }
            // [END_EXCLUDE]
            
            // At this point, our user is signed in
            // [START_EXCLUDE silent]
            // so we advance to the User View Controller
            //self.transitionToUserViewController()
            if let userInfo = result?.user {
                let emptyStr: String = "-"
                let userNm: String    = ((userInfo.displayName?.isEmpty ?? true) ? emptyStr : userInfo.displayName) ?? emptyStr
                let email: String     = (userInfo.email?.isEmpty ?? true) ? emptyStr : userInfo.email ?? emptyStr
                let phonNm: String    = (userInfo.phoneNumber?.isEmpty ?? true) ? emptyStr : userInfo.phoneNumber ?? emptyStr
                
                
                self.tblArr[1].updateValue([
                    ["title" : "user name", "type": stType.lbl, "rightDesc": "\(userNm)", "action": {}] as [String : Any],
                    ["title" : "email", "type": stType.lbl, "rightDesc": "\(email)", "action": {}],
                    ["title" : "phone number", "type": stType.lbl, "rightDesc": "\(phonNm)", "action": {}]
                ], forKey: "cells")
                
                self.tableView.reloadData()
            }
            // [END_EXCLUDE]
        }
        // [END signin_google_credential]
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
            cell.swch.addTarget(self, action: #selector(switchAction), for: .touchUpInside)
            
            let menuStr = switchMenuStr(rawValue: cell.swch.tit)
            
            switch menuStr {
            case .fetch:
                cell.swch.isEnabled = hasCrntUser
                cell.swch.isOn = fetchServer
                
            case .downSample:
                cell.swch.isEnabled = hasCrntUser
                
            case .delete:
                print("삭제")
                cell.swch.isEnabled = foodShared.foods.count > 0
                
            default:
                break
            }
            
            cell.btnSwch.isHidden = cell.swch.isEnabled
            cell.btnSwch.restorationIdentifier = cell.swch.tit
            cell.btnSwch.addTarget(self, action: #selector(showCellAlert), for: .touchUpInside)
            
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

    @IBOutlet weak var swchView: UIView!
    @IBOutlet weak var swch: idxSwitch!
    @IBOutlet weak var btnSwch: UIButton!
    
    @IBOutlet weak var btn_right: UIButton!
    
    
    func setView(obj: (title: String, type: stType, isOn: Bool, rightDesc: String )) {
        let views: [UIView] = [lbl_desc, swchView, btn_right]
        
        for (i, viewObj) in views.enumerated() {
            viewObj.tag                 = i + 1
            viewObj.isHidden            = obj.type.rawValue != viewObj.tag
            viewRhtContainer.isHidden   = obj.type == .hide
            
            switch viewObj {
            case swch:
                swch.idx = (viewObj.tag, tag)
                
            case btn_right:
                btn_right.setImage(.init(systemName: hasCrntUser ? "" : "chevron.right"), for: .normal)
                btn_right.setTitle(hasCrntUser ? "로그아웃" : "", for: .normal)
                btn_right.sizeToFit()
                
            default:
                break
            }
        }
        
        if let visView = views.filter({ !$0.isHidden }).first {
            switch visView {
            case lbl_desc:
                let lblWidth: CGFloat = (obj.rightDesc as NSString).size(withAttributes: [NSAttributedString.Key.font : lbl_desc.font as Any]).width
                viewRhtAccWidth.constant = lblWidth > (frame.width - lblWidth) ? 100 : lblWidth
                
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
    
    var menuTypeStr: switchMenuStr {
        return .init(rawValue: tit) ?? .fetch
    }
}

enum switchMenuStr: String {
    case fetch = "서버와 연동"
    case downSample = "서버에서 샘플받기"
    case delete = "타이머 전체 삭제"
    
    init?(rawValue: String) {
        switch rawValue {
        
        case switchMenuStr.fetch.rawValue:
            self = switchMenuStr.fetch
            
        case switchMenuStr.downSample.rawValue:
            self = switchMenuStr.downSample
            
        case switchMenuStr.delete.rawValue:
            self = switchMenuStr.delete
            
        default:
            return nil
        }
    }
}

extension UIViewController {
    func showAlert(msg: String, actions: [[ String: (UIAlertAction)->Void ]]? = nil ) {
        let alertController = UIAlertController(title: "확인", message: msg, preferredStyle: .alert)
        
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
    
    public func displayError(_ error: Error?, from function: StaticString = #function) {
      guard let error = error else { return }
      print("ⓧ Error in \(function): \(error.localizedDescription)")
      let message = "\(error.localizedDescription)\n\n Ocurred in \(function)"
      let errorAlertController = UIAlertController(
        title: "Error",
        message: message,
        preferredStyle: .alert
      )
      errorAlertController.addAction(UIAlertAction(title: "OK", style: .default))
      present(errorAlertController, animated: true, completion: nil)
    }
}

extension NSObject {
    var usrDef: UserDefaults {
        return UserDefaults.standard
    }
    
    var rfr: DatabaseReference {
      return Database.database().reference()
    }
    
    var usrInfo: User? {
        return Auth.auth().currentUser
    }
    
    var usrEmail: String {
        return String(usrInfo?.email?.split(separator: "@").first ?? "")
    }
    
    var hasCrntUser: Bool {
        let res = Auth.auth().currentUser != nil
        
        if res == false {
            UserDefaults.standard.setValue(false, forKey: "fetchServer")
        }
        
        return res
    }
    
    var fetchServer: Bool {
        return UserDefaults.standard.value(forKey: "fetchServer") as? Bool ?? false
    }
    
    func currentTime() -> String {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyMMdd HH:mm:ss"
        
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
