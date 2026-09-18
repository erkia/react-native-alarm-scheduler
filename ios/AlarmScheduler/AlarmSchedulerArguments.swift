import Foundation
import CoreFoundation

/// Validate input at the React Native boundary, preserving optional fields and defaults.
enum AlarmSchedulerArguments {
  private static func value(_ values: [String: Any], _ key: String) -> Any? {
    guard let value = values[key], !(value is NSNull) else { return nil }
    return value
  }

  static func required<T>(_ value: T?, _ key: String) throws -> T {
    guard let value else { throw InvalidAlarmException("Missing alarm field: \(key)") }
    return value
  }

  static func string(_ values: [String: Any], _ key: String) throws -> String? {
    guard let value = value(values, key) else { return nil }
    guard let result = value as? String else { throw InvalidAlarmException("\(key) must be a string.") }
    return result
  }

  static func boolean(_ values: [String: Any], _ key: String) throws -> Bool? {
    guard let value = value(values, key) else { return nil }
    guard let number = value as? NSNumber, CFGetTypeID(number) == CFBooleanGetTypeID() else {
      throw InvalidAlarmException("\(key) must be a boolean.")
    }
    return number.boolValue
  }

  static func double(_ values: [String: Any], _ key: String) throws -> Double? {
    guard let value = value(values, key) else { return nil }
    guard let number = value as? NSNumber, CFGetTypeID(number) != CFBooleanGetTypeID(), number.doubleValue.isFinite else {
      throw InvalidAlarmException("\(key) must be a finite number.")
    }
    return number.doubleValue
  }

  static func int(_ values: [String: Any], _ key: String) throws -> Int? {
    guard let value = try double(values, key) else { return nil }
    guard let result = Int(exactly: value) else { throw InvalidAlarmException("\(key) must be an integer.") }
    return result
  }

  static func object(_ values: [String: Any], _ key: String) throws -> [String: Any]? {
    guard let value = value(values, key) else { return nil }
    guard let result = value as? [String: Any] else { throw InvalidAlarmException("\(key) must be an object.") }
    return result
  }

  static func intList(_ values: [String: Any], _ key: String) throws -> [Int]? {
    guard let value = value(values, key) else { return nil }
    guard let array = value as? [Any] else { throw InvalidAlarmException("\(key) must be an array.") }
    return try array.map { try required(int([key: $0], key), key) }
  }

  static func stringList(_ values: [String: Any], _ key: String) throws -> [String]? {
    guard let value = value(values, key) else { return nil }
    guard let array = value as? [String] else { throw InvalidAlarmException("\(key) must be a string array.") }
    return array
  }
}
