//
//  CartView.swift
//  Test SwiftUI API Call
//
//  Created by Jonathan Råsmark on 2024-02-22.
//

import SwiftUI



struct CartView: View {
    
    @Binding var allProducts : [Product]?
    @Binding var itemsBought : Int
    @Binding var boughtQuantityByProduct : [ Int : Int]
    @State var totalPrice : Int = 0
    
    
    var body: some View {
        VStack {
            
            
            
            if basketContains() && boughtQuantityByProduct.count != 0  { Text("These are the items in your cart:").font(.headline).padding(.vertical)
            } else {
                Text("There are no items in your cart.").font(.headline).padding(.vertical).foregroundStyle(.red)
            }
            
            
            
            List {
                ForEach(boughtQuantityByProduct.sorted(by: <), id: \.key) { key, value in
                    if value > 0 {
                        VStack {
                            //                        Text("Bought \(String(value)) of productID: \(String(key))")
                            
                            if let allProducts {
                                let product = allProducts.filter {$0.productID == key}.first
                                if let product {
                                    
                                    
                                    
                                    if boughtQuantityByProduct[product.productID] != 0 {
                                        HStack {
                                            VStack {
                                                Text("Product:")
                                                Text("\(product.name)")
                                                Image(product.imageUrl).resizable().frame(width: 60, height: 60)
                                            }
                                            Spacer()
                                            VStack(alignment: .leading) {
                                                Text("Price: \(String(product.price)) SEK")
                                                Text("No of items: \(value)")
                                                Text("Total: \(String(product.price * value)) SEK").fontWeight(.bold)
                                                Button {
                                                    
                                                    totalPrice -=
                                                       product.price * boughtQuantityByProduct[product.productID]!
                                                    
                                                    itemsBought -= boughtQuantityByProduct[product.productID]!
                                                    boughtQuantityByProduct[product.productID] = 0
                                                    
                                                 
                                                } label: {
                                                    Image(systemName: "trash")
                                                }
                                                
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
            
            
            
            Text("Total price: \(totalPrice) SEK").fontWeight(.bold).font(.largeTitle)
            // outside of list
            if basketContains() && boughtQuantityByProduct.count != 0 {
                NavigationLink(destination: { ThankYouView() }, label: {Text("BUY PRODUCTS")}).simultaneousGesture(TapGesture().onEnded {
                    print(boughtQuantityByProduct)
                    if let allProducts {
                        for (productID, quantity) in boughtQuantityByProduct {
                            let theProduct = allProducts.filter {$0.productID == productID }.first
                            if let theProduct {
                                Task {
                                    
                                    try await buyProduct(productID: theProduct.productID, stock: theProduct.stock, amount: quantity)
                                    
                                }
                            }
                        }
                        boughtQuantityByProduct = [:]
                        itemsBought = 0
                        totalPrice = 0
                        
                    }
                })
            }
            
            
            
        } // VStack
        .task {
            for (productID, quantity) in boughtQuantityByProduct {
                
                if let allProducts {
                    let theProduct = allProducts.filter {$0.productID == productID }.first
                    if let theProduct {
                        totalPrice += quantity * theProduct.price
                    }
                }
                
            }
        }
        Spacer()
    }
    
    func basketContains() -> Bool {
        print("basket contains function")
        var boolean : Bool = false
        for (_, value) in boughtQuantityByProduct {
            if value == 0 {
                print("value == 0")
                boolean = false
            } else if value > 0 {
                print("value > 0")
                return true
            }
        }
        print("boolean: \(boolean)")
        return boolean
    }
    
    func buyProduct(productID: Int, stock: Int, amount: Int) async throws {
        let url = URL(string:"http://localhost:8080/product/\(productID)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        let changeProduct: ChangeProduct = ChangeProduct(stock: (stock - amount))
    
        
        print("inside buyProduct")
        
        let data = try! JSONEncoder().encode(changeProduct)
        
        print("inside buyProduct after JSONEncoder")
        
        request.httpBody = data
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let statusCode = (response as! HTTPURLResponse).statusCode
            if statusCode == 200 {
                print("Success")
            } else {
                print("Failure")
            }
            // Task { allProducts = try await performAPICallAllProducts() }
            
            
            
        }
        task.resume()
        
        
        // Update products after
        
        
        
        
        
        print("end of buyProduct")
    }
    
}

#Preview {
    CartView(allProducts: .constant([]), itemsBought: .constant(0), boughtQuantityByProduct: .constant([:]))
}
