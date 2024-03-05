//
//  ContentView.swift
//  Test SwiftUI API Call
//
//  Created by Jonathan Råsmark on 2024-02-13.
//

import SwiftUI



struct ChangeProduct: Encodable {
    let stock: Int
}




struct Product: Codable, Identifiable {
    var id: UUID = UUID()
    let productID: Int
    let name: String
    let description: String
    let price: Int
    var stock: Int
    let imageUrl: String
    
    
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case price
        case stock
        case imageUrl
        case productID = "id"
    }
    
    init(productID: Int, name: String,
         description: String,
         price: Int,
         stock: Int,
         imageUrl: String)
    {
        self.productID = productID
        self.name = name
        self.description = description
        self.price = price
        self.stock = stock
        self.imageUrl = imageUrl
    }
    
    
}





struct ContentView: View {
    

    @State var product: Product?
    @State var allProducts: [Product]?
    @State var itemsBought: Int = 0
    @State var boughtQuantityByProduct : [ Int : Int] = [ : ]
    
    @State var showAlert = false

    @State private var theOptions : [Int] = Array(1...10)
    
    
    
    @State var selectedQuantity: [Int : Int]
    
    var body: some View {
     
        
        
//        VStack {
//
//
//
//            if let product {
//                Text(product.name)
//                Text(product.description)
//                Text("Price: \(String(product.price))")
//                Text("Stock: \(String(product.stock))")
//                Text(product.imageUrl)
//                Text(String(product.productID))
//            }
//
//
//        }
//        .padding()
//        .task {
//            do {
//
//                product = try await performAPICallProduct()
//
//
//            } catch {
//                product = nil
//            }
//
//
//
//        }
        NavigationStack {
            VStack {
                HStack {
                    
                    TopView(itemsInCart: $itemsBought, allProducts: $allProducts, boughtQuantityByProduct: $boughtQuantityByProduct)
                    
                }
            }
            
            VStack {
                
                
                if let allProducts {
                    
                    List(allProducts) { (product) in
                        
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text(product.name).font(.title)
                                
                                Text(product.description).font(.caption)
                                
                                Image(product.imageUrl).resizable().frame(width: 60, height: 60)
                                
                            }.frame(width: 120)
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("Price: \(String(product.price)) SEK").bold()
                                if (product.stock > 0) {
                                    Text("In stock: \(String(product.stock))").font(.caption) }
                                else {
                                    Text("OUT OF STOCK").foregroundStyle(.red)
                                }
                                
                                if (product.stock > 0) {
                                    
                                    
                                    
                                    HStack(alignment: .center) {
                                        Text("Quantity:").font(.caption)
                                        
                                        MenuView(selectedOption: $selectedQuantity, actualProductID: product.productID, numbersArray: product.stock >= 10 ? Array(1...10) : Array(1...product.stock))
                                        
                                        
                                        
                                        
                                    }.buttonStyle(BorderlessButtonStyle())
                                    
                                    VStack {
                                        
                                        Button(action:  {
                                            
                                            if let theQuantity = boughtQuantityByProduct[product.productID] {
                                                
                                                
                                                if (selectedQuantity[product.productID]! + theQuantity) <= product.stock {
                                                    
                                                    itemsBought += selectedQuantity[product.productID]!
                                                    
                                                    boughtQuantityByProduct[product.productID]! += selectedQuantity[product.productID]!
                                                    
                                                    
                                                } else {
                                                    showAlert = true
                                                }
                                                
                                                
                                            }
                                            else {
                                                if selectedQuantity[product.productID]! <= product.stock {
                                                    
                                                    itemsBought += selectedQuantity[product.productID]!
                                                    
                                                    if let theQuantity = boughtQuantityByProduct[product.productID] {
                                                        
                                                        boughtQuantityByProduct[product.productID]! += selectedQuantity[product.productID]!
                                                        
                                                    } else {
                                                        boughtQuantityByProduct[product.productID] = selectedQuantity[product.productID]!
                                                    }
                                                    
                                                } else {
                                                    showAlert = true
                                                }
                                            }
                                            
                                            
                                            //  Task {
                                            //
                                            //                                            try await buyProduct(productID: product.productID, stock: product.stock, amount: selectedQuantity[product.productID]!)
                                            //
                                            //  }
                                        }, label: {
                                            Text("BUY")
                                        }).alert("Not enough in stock!", isPresented: $showAlert) {
                                            Button("OK", role: .cancel) { showAlert = false }
                                        }
                                    }
                                    
                                }
                                
                            } // .frame(height: 140)
                            
                            
                            
                        }
                    }
                }
            }.task {
                do {
                    
                    allProducts = try await performAPICallAllProducts()
                    
                    for product in allProducts ?? [] {
                        selectedQuantity[product.productID] = 1
                    }
                    
                }
                catch {
                    allProducts = nil
                }
                
                
                
                
                
                
            }
        }
    }

//    func performAPICall() async throws -> Film {
//        let url = URL(string: "https://swapi.dev/api/films/1")
//        let (data, _) = try await URLSession.shared.data(from: url!)
//        let wrapper = try JSONDecoder().decode(Film.self, from: data)
//        return Film(title: wrapper.title, episodeId: wrapper.episodeId)
//
//    }

    func performAPICallAllProducts() async throws -> [Product] {
        print("performAPICallAllProducts")
        let url = URL(string: "http://localhost:8080/products")

        let (data, _) = try await URLSession.shared.data(from: url!)

        let wrapper = try JSONDecoder().decode([Product].self, from: data)

        return wrapper;
    }
    
    func performAPICallProduct() async throws -> Product {
        let url = URL(string: "http://localhost:8080/product/2")
        let (data, _) = try await URLSession.shared.data(from: url!)
        let wrapper = try JSONDecoder().decode(Product.self, from: data)
        
        return Product(productID: wrapper.productID ,name: wrapper.name, description: wrapper.description, price: wrapper.price, stock: wrapper.stock, imageUrl: wrapper.imageUrl)
        
    }
    
    
    
    
    
    
}

#Preview {
    ContentView(selectedQuantity: [ 1 : 1])
}
