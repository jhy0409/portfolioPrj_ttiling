//
//  ViewController.swift
//  simpleTimerFor_AirFryer
//
//  Created by inooph on 2021/07/15.
//

import UIKit
import UserNotifications

class AFTimerViewController: UIViewController, fVmodel {
    // MARK: ------------------- IBOutlets -------------------
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lbl_empty: UILabel!
    
    // MARK: ------------------- Variables -------------------
    var startTime: Date?
    static let userNotiCenter = UNUserNotificationCenter.current()
    
    var emptyStr: String {
        var res: String = ""

        if foodShared.saveSpot == .local {
            if foodShared.foods.isEmpty {
                res = "로컬에 저장된 값이 없습니다."
            } else {
                res = ""
            }
            
        } else if foodShared.saveSpot == .server {
            if foodShared.foods.isEmpty {
                res = hasCrntUser ? "서버에 저장된 값이 없습니다." : "서버에 저장된 데이터를 가져오기 위해 인증이 필요합니다."
            } else {
                res = ""
            }
        }
        
        return res
    }
    
    // MARK: ------------------- View Life Cycle -------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(.init(nibName: "AFHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "AFHeaderView")
        requestAuthNoti() // 사용자에게 알림 권한 요청
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionHeadersPinToVisibleBounds = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        foodShared.loadFoods(save: foodShared.saveSpot, sort: foodShared.selectedType) { [weak self] in
            guard let `self` = self else { return }
            
            self.lbl_empty.text        = self.emptyStr
            self.lbl_empty.isHidden    = self.emptyStr.isEmpty
            self.collectionView.reloadData()
        }
    }
    
    
    func requestAuthNoti() { // 사용자에게 알림 권한 요청
        let notiAuthOptions = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound])
        AFTimerViewController.userNotiCenter.requestAuthorization(options: notiAuthOptions) { (success, error) in
            if let error = error { print(#function, error) }
        }
    }
    
    // 알림 전송
    func requestSendNoti(seconds: Double) {
        let notiContent = UNMutableNotificationContent()
        notiContent.title = "알림"
        notiContent.body = "띠링! 타이머가 완료되었습니다."
        notiContent.userInfo = ["targetScene": "splash"] // 푸시 받을때 오는 데이터
        // 알림이 trigger되는 시간 설정
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: notiContent,
            trigger: trigger
        )
        AFTimerViewController.userNotiCenter.add(request) { (error) in
            print(#function, error as Any)
        }
        print("\n\n-----> [AFViewCon] Line 38 : requestSendNoti(seconds: Double) Called")
    }
    
    
    // MARK: ------------------- functions -------------------
    
    @objc func setSortArr(_ sender: UISegmentedControl) {
        let titleStr: String = sender.titleForSegment(at: sender.selectedSegmentIndex) ?? ""
        print("--> sender selected = \(titleStr)\n")
        
        for i in 0..<foodShared.sortType[sender.tag].count {
            foodShared.sortType[sender.tag][i].selected = i == sender.selectedSegmentIndex
        }
        
        if let data = try? JSONEncoder().encode(foodShared.sortType) {
            usrDef.setValue(data, forKey: "sortType")
        }
        
        foodShared.loadFoods(save: foodShared.saveSpot, sort: foodShared.selectedType) { [weak self] in
            guard let `self` = self else { return }
            
            self.lbl_empty.text        = self.emptyStr
            self.lbl_empty.isHidden    = self.emptyStr.isEmpty
            
            self.collectionView.reloadData()
        }
    }
  
}

extension AFTimerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return foodShared.foods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerview = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "AFHeaderView", for: indexPath) as! AFHeaderView
        
        headerview.setView(sortArr: self.foodShared.sortType)
        headerview.sg_svSave.addTarget(self, action: #selector(setSortArr), for: .valueChanged)
        headerview.sg_svUser.addTarget(self, action: #selector(setSortArr), for: .valueChanged)
        
        return headerview
    }
    
    // [ㅇ] cell 표시
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AFTimerCell", for: indexPath) as? AFTimerCell else { return UICollectionViewCell() }
        let food: Food = foodShared.foods[indexPath.item]
        cell.updateUI(food: food)
        cell.viewController = self
        cell.editDel = self
        
        // [ㅇ] 삭제 버튼 누를 때 동작
        cell.closeBtnHandler = {
            self.foodShared.deleteFood(food)
            
            self.lbl_empty.text        = self.emptyStr
            self.lbl_empty.isHidden    = self.emptyStr.isEmpty
            self.collectionView.reloadData()
        }
        
        // [ㅇ] 타이머 스위치 누를 때 동작
        cell.timerTapHandler = {
            self.startTime = Date()
            guard let startTime = self.startTime else  {
                cell.setTimer(startTime: Date(), food: food)
                return
            }
            cell.setTimer(startTime: startTime, food: food) // 라벨을 바꿈
        }
        return cell
    }
}

// [ㅇ] 콜렉션뷰 레이아웃
extension AFTimerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSpacing: CGFloat = 15
        let margin: CGFloat = 18
        let width = (collectionView.bounds.width - itemSpacing - (margin * 2)) / 2
        //let height = width + 150
        let height: CGFloat = 380
        return CGSize(width: width, height: height)
    }
    
    // MARK: - [ㅇ] 타이머뷰셀에서 스위치 On -> 이 메소드 호출 (ViewController에서만 실행되므로 타입메소드로 선언)
    static func notiOutside(_ second: Double) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "띠링"
        content.body = "예약한 알람이 완료되었습니다."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: second-1, repeats: false)
        
        let request = UNNotificationRequest(identifier: "reminder", content: content, trigger: trigger)
        center.add(request) { (error) in
            if error != nil {
                print("\n\n\n ---> Error : \(String(describing: error?.localizedDescription))")
            }
        }
    }
}

extension AFTimerViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) { completionHandler() }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    func afterLeaveView() {
        print("--> afterLeaveView / afTimerVC")
        foodShared.loadFoods(save: foodShared.saveSpot, sort: foodShared.selectedType) { [weak self] in
            guard let `self` = self else { return }
            
            self.lbl_empty.text        = self.emptyStr
            self.lbl_empty.isHidden    = self.emptyStr.isEmpty
            self.collectionView.reloadData()
        }
    }
}

enum SortType: String, Codable {
    case server = "서버"
    case local  = "로컬"
    case name   = "이름순"
    case latest = "최신순"
}
