//
//  MenuView.swift
//  Test SwiftUI API Call
//
//  Created by Jonathan Råsmark on 2024-02-15.
//

import SwiftUI

struct MenuView: View {

    @Binding var selectedOption: [Int : Int]
    @State var actualProductID: Int
    @State var numbersArray: [Int]
    
    
    var body: some View {
        Menu {
            ForEach(numbersArray, id:\.self)  { number in
                Button(action: { selectedOption[actualProductID] = number }, label: {
                    Text(String(number))
                })
            }
        } label: {
            Label(
                title: { Text(String(selectedOption[actualProductID]!))},
                icon: { Image(systemName: "plus")}
            )
        }
    }
}

#Preview {
    MenuView(selectedOption: .constant([1:1]), actualProductID: 1, numbersArray: Array(1...10))
}

