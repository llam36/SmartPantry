//
//  PantryItemManager.swift
//  SmartPantry
//
//  Created by Long Lam on 3/7/24.
//

import Foundation

class PantryItemManager: ObservableObject {
    @Published var pantries: [PantryItemModel] = []
    
    func addPantry(pantriesJson: [PantryItemJson]) {
        for item in pantriesJson {
            pantries.append(PantryItemModel(id: UUID().uuidString, itemTitle: item.name, loggedDate: Date(), quantity: item.quantity.value, expiredDate:  Calendar.current.date(byAdding: .day, value: item.quantity.ttl + 10, to: Date())!))
        }
     
    }
    
    func addPantry(pantriesInput: [PantryItemModel]) {
        for item in pantriesInput {
            pantries.append(item)
        }
    }
    
    func clearPantry() {
        pantries = []
    }
    
    func remove(offsets: IndexSet) {
        pantries.remove(atOffsets: offsets)
        print("Pantries after remove: ")
        print(pantries)
        
    }
    func removeById(id: String) {
        if let index = pantries.firstIndex(where: { $0.id == id }) {
            pantries.remove(at: index)
            print("Pantries after remove: ")
            print(pantries)
        }
    }
    func getExpiringItem() -> [PantryItemModel] {
        let shuffledPantries = pantries.shuffled()
        
        if shuffledPantries.count >= 3 {
            return Array(shuffledPantries.prefix(3))
        } else {
            return shuffledPantries
        }
    }

}
