import Foundation

/// 所有 API 调用的统一错误类型。
public enum APIError: Error, Sendable {
    /// 后端返回非 2xx；`code` 取自 Problem，缺省 `internal_error`。
    case http(status: Int, code: String, detail: String, errors: [ValidationIssue]?, retryAfter: Int?)
    /// 网络层失败（URLError 等）。
    case transport(underlying: any Error)
    /// 响应体无法按预期模型解码。
    case decoding(underlying: any Error)
    /// 非 HTTPURLResponse 等异常情况。
    case invalidResponse
}

public extension APIError {
    var status: Int? {
        if case .http(let status, _, _, _, _) = self { return status }
        return nil
    }

    var code: String? {
        if case .http(_, let code, _, _, _) = self { return code }
        return nil
    }

    var detail: String {
        if case .http(_, _, let detail, _, _) = self { return detail }
        return ""
    }

    var retryAfter: Int? {
        if case .http(_, _, _, _, let retryAfter) = self { return retryAfter }
        return nil
    }

    /// 与 Web 端 `problemMessage` 逐字一致的用户可见文案。
    var userMessage: String {
        guard case .http(_, let code, let detail, let errors, let retryAfter) = self else {
            return "网络连接失败，请稍后重试"
        }
        switch code {
        case "validation_error":
            let joined = (errors?.map(\.msg) ?? []).joined(separator: "；")
            return "参数校验失败：" + (joined.isEmpty ? detail : joined)
        case "login_rate_limited":
            if let retryAfter { return "登录尝试过多，请 \(retryAfter) 秒后再试" }
            return "登录尝试过多，请稍后再试"
        case "upstream_unavailable":
            return "上游服务不可用：" + detail
        default:
            return Self.messages[code] ?? "服务器内部错误"
        }
    }

    private static let messages: [String: String] = [
        "unauthenticated": "登录已失效，请重新登录",
        "forbidden": "需要管理员权限",
        "not_found": "资源不存在或无权访问",
        "not_ready": "答案尚未生成完成",
        "conflict": "当前状态不允许该操作",
        "username_exists": "用户名已存在",
        "cannot_disable_self": "不能禁用自己",
        "last_admin": "必须保留至少一个活跃管理员",
        "too_many_jobs": "进行中的任务已达上限，请等待完成或先取消",
        "unavailable": "服务暂不可用",
        "fulltext_unavailable": "无可用全文",
    ]
}

/// 任务失败码 → 中文文案（与 Web 端 `jobErrorMessage` 一致）。
public enum JobErrorMessage {
    public static func text(for code: String) -> String {
        switch code {
        case "no_papers": "没有文献通过筛选，请放宽年份 / 分区 / 期刊，或勾选「含未收录期刊」"
        case "nothing_relevant": "检索到的文献都与问题无关，请换个问法或放宽筛选"
        case "llm_unavailable": "模型服务不可用，请稍后重试"
        case "timeout": "任务超时"
        case "internal_error": "内部错误"
        default: "任务执行失败"
        }
    }
}
