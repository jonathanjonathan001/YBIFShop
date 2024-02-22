//
//  ThankYouView.swift
//  Test SwiftUI API Call
//
//  Created by Jonathan Råsmark on 2024-02-22.
//

import SwiftUI

struct ThankYouView: View {
    
    @Binding var name : String
    
    var body: some View {
        Text("Thank you \(name) for your purchase!")
    }
}

#Preview {
    ThankYouView(name: .constant(""))
}
