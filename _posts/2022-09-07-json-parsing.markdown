---
layout: epic
title: "Short thoughts dumped on JSON parsing in Swift 5"
subtitle: 
date: 2022-09-07
categories: [Networking, Generics, Swift]
author: "Marina Huber"
---

Networking code can definitely be improved. Thanks Apple! No third parties here!
👌 So since Swift 4 we got Codable with Decodable and Encodable protocols that 
provide support for native class (reference type), struct and enum as well (value types) all concrete data types…



First of all Codable is defined as typealias Codable = Decodable & Encodable and we go for two required protocols:
* 		Decodable: to parse JSON (get response)
- By decoding the JSONData we will receive/read the data
2. Encodable: to generate JSON (post response)
- To convert your codable type into Data.

<!-- more -->

## In practice
It works with primitive types (Int, String and Float etc.), some Foundation types (Data, URL, Date etc.) as well as with arrays, dictionaries and optionals(Enums).
- NSData
- NSString
- NSNumber
	- UInt
	- Int
	- Float
	- Double
	- Bool
- NSDate
- NSArray
- NSDictionary
Why?
* 		To simplify dependencies in our Data Manager
* 		Converting data structures to JSON data has never been easier(hmmmm..), allowing developers to store JSON data to disk or encode it into a URLRequest’s httpBody.
You can write an app that uses JSON from an external source or tests from a stub. The start problem here the inconsistencies between the structure of the concepts you’re modeling in your app and concepts modeled by the producer of the JSON. Some examples of changing and using JSON structure in your app:
* 		Change name properties with CodingKey
2. Simplify the complex structure with Encoding and Decoding manually 📝
3. Work with Nested Data (array inside of an array JSON)
For 1. even tho we do not have to parse every element of JSON representation, we need to create properties with same name as in JSON Data or rename them with CodingKey for direct persistent storage for basic examples. Easy peasy so far! 🤠🤠
Essential tasks here at the object level:
1. Identify Objects
2. Use nested type for supporting or to hide complexity
🃏♦️🃏
struct SurfBoard: Codable {
    var brand: String
    var size: Size
    
    enum CodingKeys: String, CodingKey {
        case brand = "name"
        case size
    }
}

struct Size: Codable {
    var width: Double
    var height: Double
}
Note: For JSON properties that declares in NULL element we need to mirror that instance with ❓Optional. This way, data isn’t silently lost as a result of typos or a misunderstanding of the guarantees made by the provider of the JSON.
For 2. in that case, you can provide your own custom logic 📝 of Encodable and Decodable to define your own encoding and decoding logic. You need to implement encode(to:) and init(from:) methods of Encodable and Decodable protocols explicitly.
On that note:
The tool that I find very useful in creating model structs faster is QuickType which is a desktop application that turns JSON into Codable with typealias for collections. I use it with copyright in comments and Equatable and Hashable protocols for making sure that collection is not duplicated…
Here is when the JSON goes wild and we need to taim it:
struct SurfBoard {
    var brand: String
    var size: Size
    
    enum CodingKeys: String, CodingKey {
        case brand = "name"
        case width
        case height
    }
}

extension SurfBoard: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(brand, forKey: .title)
        try container.encode(size.width, forKey: .width)
        try container.encode(size.height, forKey: .height)
    }
}

extension SurfBoard: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        brand = try values.decode(String.self, forKey: .brand)
        let width = try values.decode(Double.self, forKey: .width)
        let height = try values.decode(Double.self, forKey: .height)
        size = Size(width: width, height: height)
    }
}
You can get nice use scenario here and here ✅.
For 3. in that case of Nested Data you need to decode and read the JSON. The decodable type serves as an intermediate type that’s safe to decode. It serves as the data source in an initializer for the type that you’ll use in the rest of your app.
//Swift structural incompatibility with external JSON
struct SurfBoard {
    var brand: String
    var products: [Products]
    
    struct Products: Codable {
        var name: String
        var points: Int
        var description: String?
    }
}
The JSON returned by the API contains more information than is needed to populate the corresponding Swift type.
//Swift structure that we need for the nested Arrays
struct SurfBoard: Decodable {
    let brand: String
    let aisles: [Aisle]
    struct Aisle: Decodable {
        let name: String
        let shelves: [Shelf]
        struct Shelf: Decodable {
           let name: String
           let product: SurfStore.Product
        }
    }
}
The extension adds an initializer that takes a SurfBoardService instance and removes the unnecessary nesting by looping through and discarding the aisles and shelves.
To extract the data you need from the outer array, you write a type that mirrors the shape of the source JSON and mark it as Decodable. Then, write an initializer on the type you’ll use in the rest of your app that takes an instance of the type that mirrors the source JSON.
extension SurfStore {
    init(from service: SurfBoardService) {
         brand = service.brand
         products = []
         for aisle in service.aisles {
           for shelf in aisle.shelves {
             products.append(shelf.product)
            }
         }
     }
 }
On that note:
Extensions can only provide convenience initializers
* 		Initializers that are implemented as a result of protocol conformance must be marked as required(on classes).
* 		required init can only be implemented within the body of a class.
* 		Structs can have initializers in extensions because there is no inheritance.
AND FINALLY READ THE NESTED JSON…
let decoder = JSONDecoder()
let serviceStores = try decoder.decode([SurfBoardService].self,        from: json)
     let stores = serviceStores.compactMap { SurfBoard(from: $0) }
for store in stores {
     print("\(store.name) is selling:")
    for product in store.products { 
       print("\t\(product.name) (\(product.points) points)")
          if let description = product.description {
          print("\t\t\(description)")
     }
   }
}
more in documentation: Merge Data from Different Depths
Feel free to leave comments if you have any doubts 🙂 Thank you!
Reference on:
https://hackernoon.com/everything-about-codable-in-swift-4-97d0e18a2999
http://aplus.rs/2017/highly-maintainable-app-architecture/