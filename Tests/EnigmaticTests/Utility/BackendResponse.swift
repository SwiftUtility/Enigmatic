import Foundation
import Enigmatic

/// A deterministic API fixture of approximately 1 MB of compact JSON.
struct BackendResponse: Codable, Equatable {
  var data: [Order]
  var pagination: Pagination
  var meta: Metadata

  init() {
    data = (1...900).map(Order.init)
    pagination = Pagination(
      page: 1, pageSize: data.count, totalItems: 24_873,
      totalPages: (24_873 + data.count - 1) / data.count,
      hasNextPage: true, nextCursor: "orders:900"
    )
    meta = Metadata(
      requestId: "req_8f27b14d6e9043c2", generatedAt: "2026-10-16T12:00:00Z",
      apiVersion: "2.4", currency: "RUB", amountUnit: "minor", locale: "ru-RU"
    )
  }

  struct Pagination: Codable, Equatable {
    var page: Int
    var pageSize: Int
    var totalItems: Int
    var totalPages: Int
    var hasNextPage: Bool
    var nextCursor: String
  }

  struct Metadata: Codable, Equatable {
    var requestId: String
    var generatedAt: String
    var apiVersion: String
    var currency: String
    var amountUnit: String
    var locale: String
  }

  struct Order: Codable, Equatable {
    var id: String
    var number: String
    var status: String
    var createdAt: String
    var updatedAt: String
    var customer: Customer
    var items: [Item]
    var totals: Totals
    var shippingAddress: Address
    var payment: Payment
    @Codec.Box<Codec.Nullable<Codec.Id<Tracking>>> var tracking: Tracking?
    var tags: [String]
    @Codec.Box<Codec.Nullable<Codec.Id<String>>> var comment: String?

    init(_ index: Int) {
      let statuses = ["pending", "paid", "processing", "shipped", "delivered", "cancelled"]
      id = String(format: "ord_%08d", index)
      number = String(format: "ORD-2026-%08d", index)
      status = statuses[(index - 1) % statuses.count]
      createdAt = String(format: "2026-10-%02dT%02d:%02d:00Z", 1 + index % 15, index % 24, index % 60)
      updatedAt = "2026-10-16T10:30:00Z"
      customer = Customer(index)
      items = (0..<(1 + index % 4)).map { Item(order: index, index: $0) }
      let subtotal = items.reduce(0) { $0 + $1.totalPrice }
      let shipping = subtotal >= 10_000 ? 0 : 399
      let discount = subtotal > 20_000 ? 500 : 0
      totals = Totals(
        subtotal: subtotal, discount: discount, shipping: shipping,
        total: subtotal - discount + shipping, currency: "RUB"
      )
      shippingAddress = Address(index)
      payment = Payment(
        method: index.isMultiple(of: 2) ? "card" : "sbp",
        paidAt: status == "pending" || status == "cancelled" ? nil : "2026-10-16T09:00:00Z"
      )
      tracking = status == "shipped" || status == "delivered"
        ? Tracking(carrier: "cdek", number: String(format: "TRK%010d", index)) : nil
      tags = index.isMultiple(of: 3) ? [] : ["web", "retail"]
      comment = index.isMultiple(of: 7) ? "Позвонить перед доставкой" : nil
    }
  }

  struct Customer: Codable, Equatable {
    var id: String
    var firstName: String
    var lastName: String
    var email: String
    @Codec.Box<Codec.Nullable<Codec.Id<String>>> var phone: String?
    var isVerified: Bool

    init(_ index: Int) {
      let names = [("Анна", "Иванова"), ("Дмитрий", "Смирнов"), ("Мария", "Петрова"), ("Алексей", "Соколов")]
      let name = names[(index - 1) % names.count]
      id = String(format: "usr_%06d", index)
      firstName = name.0
      lastName = name.1
      email = "customer\(index)@example.com"
      phone = nil
      isVerified = !index.isMultiple(of: 3)
    }
  }

  struct Item: Codable, Equatable {
    var id: String
    var productId: String
    var sku: String
    var name: String
    var category: String
    var quantity: Int
    var unitPrice: Int
    var totalPrice: Int
    var attributes: Attributes

    init(order: Int, index: Int) {
      let products = [
        ("Wireless headphones", "electronics", 8990),
        ("Cotton T-shirt", "clothing", 1490),
        ("Coffee beans 1 kg", "groceries", 2190),
        ("Desk lamp", "home", 3490),
        ("Running shoes", "sports", 6990),
        ("USB-C cable", "electronics", 990),
      ]
      let productIndex = (order + index) % products.count
      let product = products[productIndex]
      id = String(format: "item_%06d_%d", order, index)
      productId = String(format: "prd_%04d", productIndex + 1)
      sku = "SKU-\(product.1.uppercased())-\(product.2)"
      name = product.0
      category = product.1
      quantity = 1 + (order + index) % 3
      unitPrice = product.2
      totalPrice = quantity * unitPrice
      let colors: [String?] = ["black", "white", "blue", nil]
      attributes = Attributes(color: colors[(order + index) % colors.count], giftWrap: index.isMultiple(of: 3))
    }
  }

  struct Attributes: Codable, Equatable {
    @Codec.Box<Codec.Nullable<Codec.Id<String>>> var color: String?
    var giftWrap: Bool
  }

  struct Totals: Codable, Equatable {
    var subtotal: Int
    var discount: Int
    var shipping: Int
    var total: Int
    var currency: String
  }

  struct Address: Codable, Equatable {
    var countryCode: String
    var city: String
    var street: String
    var apartment: String
    var postalCode: String
    @Codec.Box<Codec.Nullable<Codec.Id<Coordinates>>> var coordinates: Coordinates?

    init(_ index: Int) {
      let cities = [
        ("Москва", "Тверская улица, 12", "125009"),
        ("Санкт-Петербург", "Невский проспект, 28", "191186"),
        ("Казань", "улица Баумана, 7", "420111"),
      ]
      let address = cities[(index - 1) % cities.count]
      countryCode = "RU"
      city = address.0
      street = address.1
      apartment = String(1 + index % 150)
      postalCode = address.2
      coordinates = nil
    }
  }

  struct Coordinates: Codable, Equatable {
    var latitude: Double
    var longitude: Double
  }

  struct Payment: Codable, Equatable {
    var method: String
    @Codec.Box<Codec.Nullable<Codec.Id<String>>> var paidAt: String?
  }

  struct Tracking: Codable, Equatable {
    var carrier: String
    var number: String
  }

}
