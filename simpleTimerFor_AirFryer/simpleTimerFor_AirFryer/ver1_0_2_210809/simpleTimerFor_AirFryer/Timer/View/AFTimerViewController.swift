//
//  ViewController.swift
//  simpleTimerFor_AirFryer
//
//  Created by inooph on 2021/07/15.
//

import UIKit
import UserNotifications

class AFTimerViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    let foodViewModel = FoodViewModel.shared
    var startTime: Date?
    static let userNotiCenter = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.didDismiss_EditTimerViewController(_:)), name: didDismiss_EditTimerViewController, object: nil)
        foodViewModel.loadFoods()
        collectionView.reloadData()
        requestAuthNoti() // 사용자에게 알림 권한 요청
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
    
    // [ㅇ] 타이머 수정 모달창이 닫힌 후 컬렉션뷰 업데이트
    let didDismiss_EditTimerViewController: Notification.Name = Notification.Name("EditTimerViewController")
    
    @objc func didDismiss_EditTimerViewController(_ noti: Notification) {
        OperationQueue.main.addOperation {
            self.collectionView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.collectionView.reloadData()
        let editController = EditTimerViewController()
        editController.isDismissed = { [weak self] in
            self?.collectionView.reloadData()
        }
    }
}

extension AFTimerViewController: UICollectionViewDataSource {
    // [ㅇ] item 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return foodViewModel.foods.count
    }
    
    // [ㅇ] cell 표시
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AFTimerCell", for: indexPath) as? AFTimerCell else { return UICollectionViewCell() }
        let food: Food = foodViewModel.foods[indexPath.item]
        cell.tmpFoodFromCell = food
        cell.updateUI(food: food)
        cell.viewController = self
        
        // [ㅇ] 삭제 버튼 누를 때 동작
        cell.closeBtnHandler = {
            self.foodViewModel.deleteFood(food)
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
        self.foodViewModel.updateFood(food)
        return cell
    }
}

// [ㅇ] 콜렉션뷰 레이아웃
extension AFTimerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSpacing: CGFloat = 10
        let margin: CGFloat = 20
        let width = (collectionView.bounds.width - itemSpacing - (margin * 2)) / 2
        let height = width + 150
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
}
