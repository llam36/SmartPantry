//
//  PantryItem.swift
//  SmartPantry
//
//  Created by Long Lam on 3/5/24.
//

import Foundation
import SwiftUI

struct PantryItem: View {
    var pantryItem: PantryItemModel
    var pantryItemSectionTitle: PantrySectionModel
    @EnvironmentObject var abtManager: ABTManager
    @EnvironmentObject var pantryItemManager: PantryItemManager
    var body: some View {
        if (abtManager.isSwipeDelete){
            HStack(alignment: .center) {
                HStack {
                    VStack {
                        Image(uiImage: getFoodImage(urlString: "https://spoonacular.com/cdn/ingredients_100x100/apple.jpg"))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.red)
                    }
                    .background(Color(white: 0.95)).clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(10)
                    .frame(maxHeight: 90)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(pantryItem.itemTitle)
                            .font(.headline)
                            .foregroundColor(.black)
                            .fontWeight(/*@START_MENU_TOKEN@*/ .bold/*@END_MENU_TOKEN@*/)
                        Text(calculateDayInterval(start: pantryItem.loggedDate, end: Date()))
                            .fontWeight(.thin)
                            .font(.footnote)
                            .foregroundColor(.black)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }.frame(maxWidth: .infinity, alignment: .leading)

                Text(pantryItem.quantity + "pc")
                    .foregroundColor(.black)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(10)
                    .frame(minWidth: 60, alignment: .trailing)
              
            }
    //        .padding([.trailing, .leading], 10)
    //        .frame(maxWidth: 400)
    //        .cornerRadius(3.0)
    //        .background(Color(.white)).clipShape(RoundedRectangle(cornerRadius: 15))
        } else {
            HStack(alignment: .center) {
                HStack {
                    VStack {
                        Image(uiImage: getFoodImage(urlString: "https://spoonacular.com/cdn/ingredients_100x100/apple.jpg"))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.red)
                    }
                    .background(Color(white: 0.95)).clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(10)
                    .frame(maxHeight: 90)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(pantryItem.itemTitle)
                            .font(.headline)
                            .foregroundColor(.black)
                            .fontWeight(/*@START_MENU_TOKEN@*/ .bold/*@END_MENU_TOKEN@*/)
                        Text(calculateDayInterval(start: pantryItem.loggedDate, end: Date()))
                            .fontWeight(.thin)
                            .font(.footnote)
                            .foregroundColor(.black)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }.frame(maxWidth: .infinity, alignment: .leading)

                Text(pantryItem.quantity + "pc")
                    .foregroundColor(.black)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(10)
                    .frame(minWidth: 60, alignment: .trailing)
                Button(action: {
                    print("Delete button tapped")
                    pantryItemManager.removeById(id: pantryItem.id)
                    
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14))
                                .font(.title)
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Color.red)
                                .clipShape(Circle())
                        }
            }
            .padding([.trailing, .leading], 10)
            .frame(maxWidth: 400)
            .cornerRadius(3.0)
            .background(Color(.white)).clipShape(RoundedRectangle(cornerRadius: 15))
            
        }
    }

    func calculateDayInterval(start: Date, end: Date) -> String {
        let daysBetween = Calendar.current.dateComponents([.day], from: start, to: end).day
        var stringDaysBetween = ""
        if daysBetween! <= 0 {
            stringDaysBetween = "Today"
        } else if daysBetween! == 1 {
            stringDaysBetween = "1 day ago"
        } else {
            stringDaysBetween = String(daysBetween!) + " days ago"
        }
        return stringDaysBetween
    }

    func getFoodImage(urlString: String) -> UIImage {
        let image: UIImage
        do {
            let url = URL(string: urlString)
            let data = try Data(contentsOf: url!)
            image = UIImage(data: data)!
        } catch {
            image = UIImage(systemName: pantryItemSectionTitle.systemImageName)!
        }
        return image
        
    }
}

#Preview {
    PantryItem(pantryItem: PantryItemModel(id: "1", itemTitle: "Apple", loggedDate: Date(), quantity: "3", expiredDate: Date.now), pantryItemSectionTitle: REFRIGERATOR_SECTION_TITLE)
}
