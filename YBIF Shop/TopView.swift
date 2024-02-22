//
//  TopView.swift
//  Test SwiftUI API Call
//
//  Created by Jonathan Råsmark on 2024-02-16.
//

import SwiftUI



struct TopView: View {

    @Binding var itemsInCart: Int
    @Binding var allProducts: [Product]?
    @Binding var boughtQuantityByProduct : [ Int : Int]
    
    
    var body: some View {
        
            VStack {
                HStack {
                    Text("YBIF SHOP").font(.largeTitle).padding()
                    Spacer()
//                    Button(action: {}, label: {
//                        Image(systemName: "cart").font(.largeTitle)
//                    })
                    NavigationLink(destination: { CartView(allProducts: $allProducts, itemsBought: $itemsInCart, boughtQuantityByProduct: $boughtQuantityByProduct) }, label: {Image(systemName: "cart").font(.largeTitle)})
                    
                    Text("(\(String(itemsInCart)))").padding(5).font(.title)
                }
                
                
                
                
            
        }
    }
}

#Preview {
    TopView(itemsInCart: .constant(10), allProducts: .constant([]), boughtQuantityByProduct: .constant([:]))
}

