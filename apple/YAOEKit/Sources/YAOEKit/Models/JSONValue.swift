import Foundation

/// 后端若干字段是自由形状的 JSON（`Answer.options`、`Job.params`/`result`、SSE 事件 `detail`）。
/// 用这个枚举保存原始结构，避免为每种形状写一套模型。
public enum JSONValue: Codable, Sendable, Hashable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case null
    case array([JSONValue])
    case object([String: JSONValue])

    public init(from decoder: any Decoder) throws {
        let c = try decoder.singleValueContainer()
        if c.decodeNil() {
            self = .null
        } else if let v = try? c.decode(Bool.self) {
            self = .bool(v)
        } else if let v = try? c.decode(Double.self) {
            self = .number(v)
        } else if let v = try? c.decode(String.self) {
            self = .string(v)
        } else if let v = try? c.decode([JSONValue].self) {
            self = .array(v)
        } else if let v = try? c.decode([String: JSONValue].self) {
            self = .object(v)
        } else {
            throw DecodingError.dataCorruptedError(in: c, debugDescription: "无法识别的 JSON 值")
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self {
        case .string(let v): try c.encode(v)
        case .number(let v): try c.encode(v)
        case .bool(let v): try c.encode(v)
        case .null: try c.encodeNil()
        case .array(let v): try c.encode(v)
        case .object(let v): try c.encode(v)
        }
    }

    // MARK: - 便捷访问

    /// 对象取键；非对象返回 nil。注意：`.null` 与「键不存在」都返回 nil 之外的区分交给调用方。
    public subscript(key: String) -> JSONValue? {
        guard case .object(let dict) = self else { return nil }
        let value = dict[key]
        if case .null = value { return nil }
        return value
    }

    public var stringValue: String? {
        if case .string(let v) = self { return v }
        return nil
    }

    public var doubleValue: Double? {
        if case .number(let v) = self { return v }
        return nil
    }

    /// 数字（截断为整数）；后端 JSON 里整数也会解成 Double。
    public var intValue: Int? {
        if case .number(let v) = self { return Int(v) }
        return nil
    }

    public var boolValue: Bool? {
        if case .bool(let v) = self { return v }
        return nil
    }

    public var arrayValue: [JSONValue]? {
        if case .array(let v) = self { return v }
        return nil
    }

    public var objectValue: [String: JSONValue]? {
        if case .object(let v) = self { return v }
        return nil
    }

    public var isNull: Bool {
        if case .null = self { return true }
        return false
    }
}

/// 自由形状字段缺省为空对象：后端 `options` / `params` 老数据可能整个缺失。
@propertyWrapper
public struct DefaultJSONObject: Codable, Sendable, Hashable {
    public var wrappedValue: JSONValue

    public init(wrappedValue: JSONValue = .object([:])) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: any Decoder) throws {
        let value = try JSONValue(from: decoder)
        wrappedValue = value.isNull ? .object([:]) : value
    }

    public func encode(to encoder: any Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}

public extension KeyedDecodingContainer {
    func decode(_ type: DefaultJSONObject.Type, forKey key: Key) throws -> DefaultJSONObject {
        try decodeIfPresent(type, forKey: key) ?? DefaultJSONObject()
    }
}
