struct Reducer<Store: ~Copyable, Value: ~Copyable>: ~Copyable {
  private var _store: UnsafeMutablePointer<Store>
  private var _value: UnsafePointer<Value>

  private init(_ store: UnsafeMutablePointer<Store>, _ value: UnsafePointer<Value>) {
    self._store = store
    self._value = value
  }

  var store: Store {
    _read { yield _store.pointee }
    _modify { yield &_store.pointee }
  }

  var value: Value {
    _read { yield _value.pointee }
  }

  mutating func reduce<T, E: Error>(next: borrowing Value, _ block: (inout Self) throws(E) -> T) throws(E) -> T {
    try withUnsafePointer(to: next) { next in
      Self(_store, next).apply(block: block)
    }
    .get()
  }

  static func reduce<T, E: Error>(into store: inout Store, _ value: borrowing Value, _ block: (inout Self) throws(E) -> T) throws(E) -> T {
    try withUnsafePointer(to: value) { value in
      withUnsafeMutablePointer(to: &store) { store in
        Self(store, value).apply(block: block)
      }
    }
    .get()
  }

  static func reduce<T, E: Error>(seed store: consuming Store, _ value: borrowing Value, _ block: (inout Self) throws(E) -> T) throws(E) -> T {
    try withUnsafePointer(to: value) { value in
      withUnsafeMutablePointer(to: &store) { store in
        Self(store, value).apply(block: block)
      }
    }
    .get()
  }

  private consuming func apply<T, E: Error>(block: (inout Self) throws(E) -> T) -> Result<T, E> {
    do {
      return try .success(block(&self))
    } catch {
      return .failure(error)
    }
  }

  typealias Block<T, E: Error> = (inout Self) throws(E) -> T
}
