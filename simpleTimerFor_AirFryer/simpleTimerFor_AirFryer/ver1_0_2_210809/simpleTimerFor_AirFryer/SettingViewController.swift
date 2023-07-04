//
//  SettingViewController.swift
//  simpleTimerFor_AirFryer
//
//  Created by inooph on 2021/07/19.
//

import UIKit
import Firebase

class SettingTableViewController: UITableViewController {
    let foodViewModel = FoodViewModel()
    
    @IBOutlet weak var downSample: UISwitch! // 토글스위치 - 서버 데이터 다운
    @IBOutlet weak var delFoodsAll: UISwitch! // 토글스위치 - 타이머 전체삭제
    
    // [] 버전정보
    @IBOutlet weak var versionDescription: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        foodViewModel.loadFoods()
    }
    
    // [ㅇ] firebase에서 내려받기
    @IBAction func downToggle(_ sender: Any) {
        // [ㅇ] toggle버튼 ON -> 기본 json file 다운로드
        if downSample.isOn == true {
            downSample.isEnabled = false // 다운시작 - 비활성화
            print("\n---> [설정창 스위치 - On] 서버데이터 받기 toggle")
            let tmpRange = 0...18
            getData(of: tmpRange)
            
            // [ㅇ] 다운완료 알림창
            // [] 다운 후 객체 정렬
            showAlert("알림","다운로드가 완료되었습니다.", {
                self.downSample.isEnabled = true // 다운완료 후 동작 - 스위치 끄기
                self.downSample.isOn = false
            })
        }
    }
    
    @IBAction func delAllFoodArr(_ sender: Any) { // 스위치 함수 - 서버데이터 전체삭제
        if delFoodsAll.isOn {
            // [ㅇ] foods Arr 갯수가 0이면 return
            if foodViewModel.foods.count == 0 {
                showAlert("알림", "저장된 타이머가 없습니다.", { self.delFoodsAll.isOn = false })
                return
            }
            print("\n---> [설정창 스위치 - On] 모든 데이터를 삭제합니다.")
            deleteAlert("경고","저장된 모든 타이머를 삭제하시겠습니까?")
        }
    }
    
    func getData(of closedRange: ClosedRange<Int>) {
        //var v1_foodId = 0
        var v2_foodName = String()
        var v3_foodType = String()
        var v4_foodHour = 0
        var v5_timerOn = false
        var v6_foodMin = 0
        var v7_foodOndo = 0
        var v8_foodTurnNum = 0
        var count = 0
        
        let ref: DatabaseReference! = Database.database().reference()
        for i in closedRange {
            ref.child("sample").child(String(i)).observeSingleEvent(of: .value, with: { snapshot in
                let value = snapshot.value as? NSDictionary
                
                //v1_foodId = value?["foodId"] as? Int ?? 0
                v2_foodName = value?["foodName"] as? String ?? "NONE"
                v3_foodType = value?["foodType"] as? String ?? "NONE"
                v4_foodHour = value?["hour"] as? Int ?? 0
                v5_timerOn = value?["isTimerOn"] as? Bool ?? false
                v6_foodMin = value?["min"] as? Int ?? 0
                v7_foodOndo = value?["ondo"] as? Int ?? 0
                v8_foodTurnNum = value?["turningFood"] as? Int ?? 0
                
                count += 1
                let food: Food = self.foodViewModel.manager.createFood(ondo: v7_foodOndo, hour: v4_foodHour, min: v6_foodMin, turn: v8_foodTurnNum, foodType: v3_foodType, isTimerOn: v5_timerOn, foodName: v2_foodName)
                
                self.foodViewModel.addFood(food)
                print("\n------> [ 함수실행 ] add getData : \(count)\n------> [ 타이머 전체 수 ] foodsArr current count : \(self.foodViewModel.foods.count) ")
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
    
    func deleteAlert(_ title: String, _ strMsg: String) {
        let alertController = UIAlertController(title: title, message: strMsg, preferredStyle: .alert)
        
        let yes = UIAlertAction(title: "네", style: .default, handler: { _ in self.yesClick() })
        alertController.addAction(yes)
        let no = UIAlertAction(title: "아니오", style: .default, handler: { _ in self.noClick() })
        alertController.addAction(no)
        present(alertController, animated: true, completion: nil)
    }
    
    func yesClick() {
        foodViewModel.deleteAllFoods()
        print("삭제 ㅇ : \(foodViewModel.foods.count)")
        delFoodsAll.isOn = false
    }
    
    func noClick() {
        print("삭제 X : \(foodViewModel.foods.count)")
        delFoodsAll.isOn = false
    }
}


