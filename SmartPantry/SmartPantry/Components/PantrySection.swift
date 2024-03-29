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
    var body: some View {
        VStack {
            HStack {
                Text(sectionTitle.title)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/ .infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
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
        .frame(maxWidth: /*@START_MENU_TOKEN@*/ .infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity, alignment: .top)
        .background(Color(white: 0.95))
        .padding([.top], 5)
    }
}

#Preview {
    PantrySection(itemList: [PantryItemModel(id: "1", itemTitle: "Apple", loggedDate: Date(), quantity: "3",expiredDate: Date.now), PantryItemModel(id: "2", itemTitle: "Apple", loggedDate: Date(), quantity: "3",expiredDate: Date.now), PantryItemModel(id: "3", itemTitle: "Apple", loggedDate: Date(), quantity: "3",expiredDate: Date.now)], sectionTitle: REFRIGERATOR_SECTION_TITLE)
}
