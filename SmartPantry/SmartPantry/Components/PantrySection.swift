//
//  RefridgeratorSection.swift
//  SmartPantry
//
//  Created by Long Lam on 3/6/24.
//

import SwiftUI

struct PantrySection: View {
    var itemList: [PantryItemModel]
    var sectionTitle: PantrySectionModel
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    @EnvironmentObject var pantryItemManager: PantryItemManager
    @EnvironmentObject var abtManager: ABTManager
    @State private var isEditing = false
    
    func deleteItems (at offsets: IndexSet) {
        // Delete items from the itemList
//        pantryItemManager.remove(offsets: offsets)
        print("Pantries after remove: ")
        pantryItemManager.pantries.remove(atOffsets: offsets)
        print(pantryItemManager.pantries)
        print("hihihihihihihihihihihihihihihihihihihihihihihihi")
    }
    
    var body: some View {
        VStack {
          
            HStack {
                Text(sectionTitle.title)
                    .frame(maxWidth:  .infinity, alignment: .leading)
                    .padding(.leading, 20)
                    .padding(.bottom, 5)
                    .padding(.top, 10)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(white: 0.3))
                Image(systemName: "line.3.horizontal.decrease")
                    .resizable()
                    .frame(maxWidth: 20, maxHeight: 12)
                    .padding(.trailing, 20)
                    .foregroundColor(Color(white: 0.3))
                
            }
            
            if (abtManager.isSwipeDelete) {
                if (!itemList.isEmpty) {
    //                VStack {
                        List {
                            Section {
                                ForEach(itemList) { item in
                                        PantryItem(pantryItem: item, pantryItemSectionTitle: sectionTitle)
                                    }
                                .onDelete(perform: deleteItems)
                            }
                        }
    //                    .frame(minHeight: minRowHeight * 3).border(Color.red)
    //                }
    //                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    //                .padding(.bottom, 10)
                }
            } else {
                if (!itemList.isEmpty) {
                    VStack {
                                ForEach(itemList) { item in
                                        PantryItem(pantryItem: item, pantryItemSectionTitle: sectionTitle)
                            }
                        }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.bottom, 10)
                }
            }
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(white: 0.95))
        .padding([.top], 5)
    }
}

struct PantrySection_Previews: PreviewProvider {
    static var previews: some View {
        PantrySection(itemList: [PantryItemModel(id: "1", itemTitle: "Apple", loggedDate: Date(), quantity: "3", expiredDate: Date()), PantryItemModel(id: "2", itemTitle: "Apple", loggedDate: Date(), quantity: "3", expiredDate: Date()), PantryItemModel(id: "3", itemTitle: "Apple", loggedDate: Date(), quantity: "3", expiredDate: Date())], sectionTitle: REFRIGERATOR_SECTION_TITLE).environmentObject(PantryItemManager())
    }
}
