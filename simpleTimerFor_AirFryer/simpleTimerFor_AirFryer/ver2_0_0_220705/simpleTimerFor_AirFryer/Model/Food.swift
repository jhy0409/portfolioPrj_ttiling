//
//  Food.swift
//  simpleTimerFor_AirFryer
//
//  Created by inooph on 2021/07/15.
//
import Foundation
import UIKit

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
    
    mutating func update(ondo: Int, hour: Int, min: Int, turn: Int, foodType: String, isTimerOn: Bool, foodName: String) {
        self.ondo = ondo
        self.hour = hour
        self.min = min
        self.turningFood = turn
        self.foodType = foodType
        self.isTimerOn = isTimerOn
        self.foodName = foodName
    }
}

class FoodManager {
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
        foods[index].update(ondo: food.ondo, hour: food.hour, min: food.min, turn: food.turningFood, foodType: food.foodType, isTimerOn: food.isTimerOn, foodName: food.foodName)
         saveFood(completion)
    }
    
    func saveFood() {
        Storage.store(foods, to: .documents, as: "foods.json")
    }
    
    func saveFood(_ completion: (()->Void)? = nil) {
        Storage.store(foods, to: .documents, as: "foods.json", completion)
    }
    
    func retrieveFood(completion: (()->Void)? = nil) {
        foods = Storage.retrive("foods.json", from: .documents, as: [Food].self, completion: completion) ?? []
        
        let lastId = foods.last?.foodId ?? 0
        FoodManager.lastId = lastId
    }
    
    func getFoodsArr() -> [Food] {
        return foods
    }
    
    func setFoodsArr(tempArr: [Food]) -> Void {
        self.foods = tempArr
        saveFood()
    }
}

class FoodViewModel {
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
    
    func loadFoods(completion: (()->Void)? = nil) {
        manager.retrieveFood(completion: completion)
    }
    
    func deleteAllFoods() {
        manager.setFoodsArr(tempArr: [])
    }
}
