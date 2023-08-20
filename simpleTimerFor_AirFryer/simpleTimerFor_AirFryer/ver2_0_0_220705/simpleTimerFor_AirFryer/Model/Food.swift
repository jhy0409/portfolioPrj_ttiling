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
    
    var key: String {
        return String(describing: "\(crType)_\(created)") 
    }
    
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
    
    
    var localFoods: [Food] = []
    
    var serverFoods: [Food] = []
    
    var saveSpot: SortType = .local 
    
    func createFood(ondo: Int, hour: Int, min: Int, turn: Int, foodType: String, isTimerOn: Bool, foodName: String, created: String, crType: String) -> Food {
        let nextId = FoodManager.lastId + 1
        FoodManager.lastId = nextId
        return Food(foodId: nextId, ondo: ondo, hour: hour, min: min,
                    turn: turn, foodType: foodType, isTimerOn: isTimerOn, foodName: foodName, created: created, crType: crType)
    }
    
    func addFood(_ food: Food) {

        if saveSpot == .local {
            localFoods.append(food)
            
        } else if saveSpot == .server {
            serverFoods.append(food)
        }
        
        saveFood(save: saveSpot)
    }
    
    func addFood(_ food: Food, isLast: Bool, completion: (()->Void)? = nil) {
        
        if saveSpot == .local {
            localFoods.append(food)
            
        } else if saveSpot == .server {
            serverFoods.append(food)
        }

        if isLast {
            saveFood(save: saveSpot, completion)
        }
    }
    
    func deleteFood(_ food: Food) {
        
        if saveSpot == .local {
            localFoods = localFoods.filter{ $0.foodId != food.foodId }
            
        } else if saveSpot == .server {
            serverFoods = serverFoods.filter{ $0.foodId != food.foodId }
        }
        
        saveFood(save: saveSpot)
    }
    
    func updateFood(_ food: Food, completion: (()->Void)? = nil) {
        
        if saveSpot == .local {
            guard let index = localFoods.firstIndex(of: food) else { return }
            print("\n [func updateFood - local] currunt index is ---->\(index)")
            
            localFoods[index].update(ondo: food.ondo, hour: food.hour, min: food.min, turn: food.turningFood, foodType: food.foodType, isTimerOn: food.isTimerOn, foodName: food.foodName, created: food.created)
            
        } else if saveSpot == .server {
            guard let index = serverFoods.firstIndex(of: food) else { return }
            print("\n [func updateFood - server] currunt index is ---->\(index)")
            
            serverFoods[index].update(ondo: food.ondo, hour: food.hour, min: food.min, turn: food.turningFood, foodType: food.foodType, isTimerOn: food.isTimerOn, foodName: food.foodName, created: food.created)
        }
        saveFood(save: saveSpot, completion)
    }
    
    func  saveFood(save: SortType) {
        if save == .local {
            Storage.store(localFoods, to: .documents, as: "foods.json")
            
        } else if save == .server {
            rfr.child("users/\(usrEmail)").removeValue()
            
            for (_, obj) in serverFoods.enumerated() {
                rfr.child("users/\(usrEmail)/\(obj.key)/foodName").setValue(obj.foodName)
                rfr.child("users/\(usrEmail)/\(obj.key)/ondo").setValue(obj.ondo)
                rfr.child("users/\(usrEmail)/\(obj.key)/hour").setValue(obj.hour)
                rfr.child("users/\(usrEmail)/\(obj.key)/min").setValue(obj.min)
                rfr.child("users/\(usrEmail)/\(obj.key)/turningFood").setValue(obj.turningFood)
                rfr.child("users/\(usrEmail)/\(obj.key)/foodType").setValue(obj.foodType)
                
                rfr.child("users/\(usrEmail)/\(obj.key)/crType").setValue(obj.crType)
                rfr.child("users/\(usrEmail)/\(obj.key)/created").setValue(obj.created)
                rfr.child("users/\(usrEmail)/\(obj.key)/isTimerOn").setValue(obj.isTimerOn)
                rfr.child("users/\(usrEmail)/\(obj.key)/foodId").setValue(obj.foodId)
            }
        }
    }
    
    func saveFood(save: SortType, _ completion: (()->Void)? = nil) {
        if save == .local {
            Storage.store(localFoods, to: .documents, as: "foods.json", completion)
            
        } else if save == .server {
            rfr.child("users/\(usrEmail)").removeValue()
            
            for (_, obj) in serverFoods.enumerated() {
                rfr.child("users/\(usrEmail)/\(obj.key)/foodName").setValue(obj.foodName)
                rfr.child("users/\(usrEmail)/\(obj.key)/ondo").setValue(obj.ondo)
                rfr.child("users/\(usrEmail)/\(obj.key)/hour").setValue(obj.hour)
                rfr.child("users/\(usrEmail)/\(obj.key)/min").setValue(obj.min)
                rfr.child("users/\(usrEmail)/\(obj.key)/turningFood").setValue(obj.turningFood)
                rfr.child("users/\(usrEmail)/\(obj.key)/foodType").setValue(obj.foodType)
                
                rfr.child("users/\(usrEmail)/\(obj.key)/crType").setValue(obj.crType)
                rfr.child("users/\(usrEmail)/\(obj.key)/created").setValue(obj.created)
                rfr.child("users/\(usrEmail)/\(obj.key)/isTimerOn").setValue(obj.isTimerOn)
                rfr.child("users/\(usrEmail)/\(obj.key)/foodId").setValue(obj.foodId)
            }
        }
    }
    
    func retrieveFood(sort: SortType, completion: (()->Void)? = nil) {
        var lastId: Int = 0
        
        if saveSpot == .local {
            localFoods = Storage.retrive("foods.json", from: .documents, as: [Food].self, completion: completion) ?? []
            sortFoods(sort: sort, completion: completion)
            
            lastId = localFoods.sorted { $0.foodId > $1.foodId }.first?.foodId ?? 0
            
        } else if saveSpot == .server {
            self.serverFoods.removeAll()
            guard usrInfo != nil else { return }
            
            rfr.child("users/\(usrEmail)").getData { [weak self] err, snapshot in
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
                        let created         = value["created"] as? String ?? ""
                        
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
                        lastId = self.serverFoods.sorted { $0.foodId > $1.foodId }.first?.foodId ?? 0
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        self.sortFoods(sort: sort, completion: completion)
                        lastId = self.serverFoods.sorted { $0.foodId > $1.foodId }.first?.foodId ?? 0
                    }
                }
            }
            
        }
        
        //let tmp = foods.sorted { $0.foodId > $1.foodId }
        //tmp.forEach { print("--> food id\($0.foodId)") }
        //print("\n--> lastId = \(lastId)")
        
        FoodManager.lastId = lastId
    }
    
    func sortFoods(sort: SortType, completion: (()->Void)? = nil) {
        switch sort {
        case .name:
            if saveSpot == .local {
                localFoods = localFoods.sorted(by: { $0.foodName.lowercased() < $1.foodName.lowercased() })

            } else if saveSpot == .server {
                serverFoods = serverFoods.sorted(by: { $0.foodName.lowercased() < $1.foodName.lowercased() })
            }
            
            completion?()
            
        case .latest:
            if saveSpot == .local {
                localFoods = localFoods.sorted(by: { $0.created > $1.created })

            } else if saveSpot == .server {
                serverFoods = serverFoods.sorted(by: { $0.created > $1.created })
            }
            
            completion?()
            
        default:
            break
        }
    }
    
    func setFoodsArr(tempArr: [Food]) -> Void {
        if saveSpot == .local {
            localFoods = tempArr
            
        } else if saveSpot == .server {
            serverFoods = tempArr
        }
        
        saveFood(save: saveSpot)
    }
}

class FoodViewModel: NSObject {
    static let shared = FoodViewModel()
    public let manager = FoodManager.shared
    
    var foods: [Food] {
        get {
            if saveSpot == .local {
                return manager.localFoods
                
            } else if saveSpot == .server {
                return manager.serverFoods
                
            } else {
                return []
            }
        }
        
        set {
            if saveSpot == .local {
                manager.localFoods = newValue
                
            } else if saveSpot == .server {
                manager.serverFoods = newValue
            }
        }
    }
    
    
    var sortType: [[SortObj]] = [ ]
    
    var selectedType: SortType {
        return sortType[1].filter { $0.selected }.first?.title ?? .name
    }
    
    var saveSpot: SortType {
        let saveSpot = sortType[0].filter { $0.selected }.first?.title ?? .local
        
        manager.saveSpot = saveSpot
        
        return saveSpot
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
        manager.retrieveFood(sort: sort, completion: completion)
    }
    
    func deleteAllFoods() {
        manager.setFoodsArr(tempArr: [])
    }
}

struct SortObj: Codable {
    let title: SortType
    var selected: Bool
}
