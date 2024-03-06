//
//  CartView.swift
//  Test SwiftUI API Call
//
//  Created by Jonathan Råsmark on 2024-02-22.
//

import SwiftUI

struct OrderInput: Encodable {
    let customerId : Int
    let customerName: String
    let totalPrice: Int
    let purchaseDate: String
    
}

struct OrderProductInput: Encodable {
    let amount: Int
}

struct OrderResult: Codable, Identifiable {
    var id : UUID = UUID()
    let orderId : Int
    
    enum CodingKeys : String, CodingKey {
        case orderId = "id"
    }
    
    init(orderId: Int) {
        self.orderId = orderId
    }
}

struct CartView: View {
    
    @Binding var allProducts : [Product]?
    @Binding var itemsBought : Int
    @Binding var boughtQuantityByProduct : [ Int : Int]
    @State var totalPrice : Int = 0
    @State var name : String = ""
    
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
            
            Text("Enter your details:").font(.title)
            Text("Name:")
            TextField("", text: $name).textFieldStyle(.roundedBorder).frame(width: 200)
            
            Text("Total price: \(totalPrice) SEK").fontWeight(.bold).font(.largeTitle)
            // outside of list
            if basketContains() && boughtQuantityByProduct.count != 0 {
                NavigationLink(destination: { ThankYouView(name: $name) }, label: {Text("BUY PRODUCTS")}).simultaneousGesture(TapGesture().onEnded {
                    let totalSavedPrice : Int = totalPrice
                    print(boughtQuantityByProduct)
                    if let allProducts {
                        var orderResultUse : OrderResult? = nil
                        
                        
                        
                        do { try registerOrder(boughtQuantityByProduct: boughtQuantityByProduct, totalPrice: totalSavedPrice, name: name, completion: {(success, orderResult) -> Void in
                            if success {
                                if let orderResult {
                                    orderResultUse = orderResult
                                }
                            }
                            
                        }) }
                        catch {
                            print("Something went wrong")
                        }
                            
                        var counter : Int = 0
                        while true {
                            counter += 1
                            if counter == 5 {
                                break
                            }
                            
                            if let orderResultUse {
                                print("ORDERRESULTUSE: \(orderResultUse)")
                                print("BREAKING SLEEP LOOP")
                                break
                            } else {
                                print("ORDER RESULT USE IS NIL")
                                sleep(2)
                            }
                        }
                        
                        for (productID, quantity) in boughtQuantityByProduct {
                            Task {
                                if let orderResultUse {
                                    try await addProductToOrder(orderResult: orderResultUse, productID: productID, quantity: quantity)
                                }
                            }
                        }
                        
                        
                        
                        
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
    
    func addProductToOrder(orderResult: OrderResult, productID: Int, quantity: Int) async throws {
        
        let productInput : OrderProductInput = OrderProductInput(amount: quantity)
        
        let url = URL(string:"http://localhost:8080/orderlines/\(orderResult.orderId)/\(productID)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let theData = try! JSONEncoder().encode(productInput)
        
        request.httpBody = theData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let statusCode = (response as! HTTPURLResponse).statusCode
            if statusCode == 200 {
                print("Success --- POST product to order")
            } else {
                print("Failure --- POST product to order")
            }
        }
        task.resume()
    }
    
    func registerOrder(boughtQuantityByProduct: [Int : Int], totalPrice: Int, name: String, completion: @escaping (_ success: Bool, _ orderResult: OrderResult?) -> Void) throws {
        
        let customerId: Int = 1
        let customerName: String = name
        let dateAndTime = Date()
        let purchaseDate = dateAndTime.description
        let orderInput : OrderInput = OrderInput(customerId: customerId, customerName: customerName, totalPrice: totalPrice, purchaseDate: purchaseDate)
        
        let url = URL(string:"http://localhost:8080/orders")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let theData = try! JSONEncoder().encode(orderInput)
        
        request.httpBody = theData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        
        let task1 = URLSession.shared.dataTask(with: request, completionHandler: { (data, response,  error) -> Void in
            let statusCode = (response as! HTTPURLResponse).statusCode
            if statusCode == 200 {
                print("Success inside POST order")
                if let data {
                    let result : OrderResult = try! JSONDecoder().decode(OrderResult.self, from: data)
                    print(result)
                    print("Order successfully stored")
                    completion(true, result)
                    
                }
            } else {
                completion(false, nil)
                print("Failure inside POST order")
            }
        
            
        })
        
        task1.resume()
        
        
        
        
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
