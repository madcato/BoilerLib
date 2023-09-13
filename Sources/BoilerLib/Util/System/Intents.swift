//
//  Intents.swift
//  
//
//  Created by Daniel Vela on 13/9/23.
//

/// This class represents a user intent to do some functionality
public protocol Intent {
  var intentId: String { get }
  var localizedDescription: String { get }
}

public extension Intent {
  var intentId: String {
    String(describing: type(of: self))
  }
}

/// This class represents a reducer of `Intents`.
/// Extend  this protocol and impletment the
/// method `func internalReduce(_ intent: T)`
/// to handle user intents
public protocol Reducer {
}

extension Reducer {
  var intentId: String {
    String(describing: type(of: self))
  }
}

public typealias ReducerClosure = (any Intent) -> Void
public typealias IntentIndex = String

public class ReducerCenter {
  public static var shared: ReducerCenter = ReducerCenter()

  private var reducersBlock: [IntentIndex: ReducerClosure] = [:]

  public func reduce(_ intent: any Intent) {
    guard let block = reducersBlock[intent.intentId] else {
      fatalError("Cannot reduce a intent \"\(intent.intentId) before it is registered")
    }
#if DEBUG
    print("INTENT: \(intent.intentId), WITH PARAMS: \(intent.localizedDescription)")
#endif
    block(intent)
  }

  public func register(intentId: IntentIndex, block: @escaping ReducerClosure) {
    reducersBlock[intentId] = block
  }
}
