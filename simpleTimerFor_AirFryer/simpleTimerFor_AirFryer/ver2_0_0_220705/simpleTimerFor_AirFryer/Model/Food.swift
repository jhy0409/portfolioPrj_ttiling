//
//  Food.swift
//  simpleTimerFor_AirFryer
//
//  Created by inooph on 2021/07/15.
//
import Foundation
import UIKit
import Firebase

struct Food: Codable, Equatable {
    let foodId: Int
    var ondo: Int
    var hour: Int
    var min: Int
    var totalSec: Int { (hour * 60 * 60) + (min * 60) }
    
    var turningFood: Int 
    var foodType: String
    var isTimerOn: Bool = false // 생성시에는 타이머 꺼진게 기본값
    var foodName: String
    
    var created: String
    /// 생성 타입
    /// 1. 유저가 직접 생성 : user
    /// 2. 서버에서 다운 : server
    var crType: String
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        // [] 동등조건 추가 -> 추후 구현
        return lhs.foodId == rhs.foodId
    }
    
    init(foodId: Int, ondo: Int, hour: Int, min: Int, turn: Int, foodType: String, isTimerOn: Bool, foodName: String, created: String, crType: String) {
        self.foodId = foodId
        self.ondo = ondo
        self.hour = hour
        self.min = min
        self.turningFood = turn
        self.foodType = foodType
        self.isTimerOn = isTimerOn
        self.foodName = foodName
        self.created = created
        self.crType = crType
    }
    
    mutating func update(ondo: Int, hour: Int, min: Int, turn: Int, foodType: String, isTimerOn: Bool, foodName: String, created: String) {
        self.ondo = ondo
        self.hour = hour
        self.min = min
        self.turningFood = turn
        self.foodType = foodType
        self.isTimerOn = isTimerOn
        self.foodName = foodName
        self.created = created
    }
}

class FoodManager: NSObject {
    static let shared = FoodManager()
    static var lastId: Int = 0
    
    var foods: [Food] = []
    
    func createFood(ondo: Int, hour: Int, min: Int, turn: Int, foodType: String, isTimerOn: Bool, foodName: String, created: String, crType: String) -> Food {
        let nextId = FoodManager.lastId + 1
        FoodManager.lastId = nextId
        return Food(foodId: nextId, ondo: ondo, hour: hour, min: min,
                    turn: turn, foodType: foodType, isTimerOn: isTimerOn, foodName: foodName, created: created, crType: crType)
    }
    
    func addFood(_ food: Food) {
        foods.append(food)
         saveFood()
    }
    
    func addFood(_ food: Food, isLast: Bool, completion: (()->Void)? = nil) {
        foods.append(food)
        if isLast {
            saveFood(completion)
        }
    }
    
    func deleteFood(_ food: Food) {
        foods = foods.filter{ $0.foodId != food.foodId }
         saveFood()
    }
    
    func updateFood(_ food: Food, completion: (()->Void)? = nil) {
        guard let index = foods.firstIndex(of: food) else { return }
        print("\n [func updateFood] currunt index is ---->\(index)")
        foods[index].update(ondo: food.ondo, hour: food.hour, min: food.min, turn: food.turningFood, foodType: food.foodType, isTimerOn: food.isTimerOn, foodName: food.foodName, created: food.created)
         saveFood(completion)
    }
    
    func saveFood() {
        Storage.store(foods, to: .documents, as: "foods.json")
    }
    
    func saveFood(_ completion: (()->Void)? = nil) {
        Storage.store(foods, to: .documents, as: "foods.json", completion)
    }
    
    func retrieveFood(save: SortType, sort: SortType, completion: (()->Void)? = nil) {
        
        if save == .local {
            foods = Storage.retrive("foods.json", from: .documents, as: [Food].self, completion: completion) ?? []
            sortFoods(sort: sort, completion: completion)

        } else if save == .server {
            self.foods.removeAll()
            guard let usr = usrInfo else { return }
            let email = usr.email?.split(separator: "@").first ?? ""
            
            rfr.child("users/\(email)").getData { [weak self] err, snapshot in
                guard let `self` = self else { return }
                
                //let prevFoods = self.foods
                
                if let values = snapshot.value as? NSDictionary, let arrs = values.allValues as? [NSDictionary] {
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
                        let created         = self.currentTime()
                        
                        let food: Food = self.createFood(ondo: ondo, hour: hour, min: min, turn: turningFood, foodType: foodType, isTimerOn: isTimerOn, foodName: foodName, created: created, crType: crType)
                        
                        /// 생성타입이 서버값과 같지 않을 때 추가함
                        //let hasValue: Bool = foods.filter { $0.crType == crType }.count > 0
                        
                        //if !hasValue {
                        self.addFood(food)
                        print("--> addFood from server = \(food.foodName)\t\(food.crType)\((i+1) % 5 == 0 ? "\n" : "")")
                        //}
                    }
                    
                    DispatchQueue.main.async {
                        self.sortFoods(sort: sort, completion: completion)
                    }
                    
                }
                
                
            }
        }
     
        
        let lastId = foods.sorted { $0.foodId > $1.foodId }.first?.foodId ?? 0
        
        //let tmp = foods.sorted { $0.foodId > $1.foodId }
        //tmp.forEach { print("--> food id\($0.foodId)") }
        //print("\n--> lastId = \(lastId)")
        
        FoodManager.lastId = lastId
    }
    
    func sortFoods(sort: SortType, completion: (()->Void)? = nil) {
        switch sort {
        case .name:
            foods = foods.sorted(by: { $0.foodName.lowercased() < $1.foodName.lowercased() })
            completion?()
            
        case .latest:
            foods = foods.sorted(by: { $0.created > $1.created })
            completion?()
            
        default:
            break
        }
    }
    
    func getFoodsArr() -> [Food] {
        return foods
    }
    
    func setFoodsArr(tempArr: [Food]) -> Void {
        self.foods = tempArr
        saveFood()
    }
}

class FoodViewModel: NSObject {
    static let shared = FoodViewModel()
    public let manager = FoodManager.shared
    
    var foods: [Food] {
        get {
            return manager.foods
        }
        set {
            manager.foods = newValue
        }
    }
    
//var sortType: [[SortObj]] = [ [.init(title: .server, selected: false), .init(title: .local, selected: true) ],
//                              [.init(title: .name, selected: true), .init(title: .latest, selected: false)] ]
    
    var sortType: [[SortObj]] = [ ]
    
    var selectedType: SortType {
        //var res = [SortType]()
        //
        //sortType.forEach { arr in
        //    let selectedObj = arr.filter { $0.selected }.first?.title ?? .name
        //    res.append(selectedObj)
        //}
        //
        //return res
        return sortType[1].filter { $0.selected }.first?.title ?? .name
    }
    
    var saveSpot: SortType {
        return sortType[0].filter { $0.selected }.first?.title ?? .local
    }
    
    func addFood(_ food: Food) {
        manager.addFood(food)
    }
    
    func addFood(_ food: Food, isLast: Bool, completion: (()->Void)? = nil ) {
        manager.addFood(food, isLast: isLast, completion: completion)
    }
    
    func deleteFood(_ food: Food) {
        manager.deleteFood(food)
    }
    
    func updateFood(_ food: Food, completion: (()->Void)? = nil) {
        manager.updateFood(food, completion: completion)
    }
    
    func loadFoods(save: SortType, sort: SortType, completion: (()->Void)? = nil) {
        print("\n--> 호출 loadFoods with sort option")
        manager.retrieveFood(save: save, sort: sort, completion: completion)
    }
    
    func deleteAllFoods() {
        manager.setFoodsArr(tempArr: [])
    }
}

struct SortObj: Codable {
    let title: SortType
    var selected: Bool
}
