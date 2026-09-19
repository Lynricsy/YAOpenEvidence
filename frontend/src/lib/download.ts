/**
 * 解析 `Content-Disposition`，优先 RFC 5987 的 `filename*`（UTF-8 百分号编码，
 * 服务端给的中文名走这一支），其次 `filename="..."`；都没有返回 null。
 */
export function filenameFromDisposition(header: string | null): string | null {
  if (!header) return null
  const extended = /filename\*=(?:UTF-8|utf-8)''([^;]+)/.exec(header)
  if (extended?.[1]) {
    try {
      return decodeURIComponent(extended[1])
    } catch {
      return null // 编码坏掉时退回调用方的兜底名，不要把百分号串当文件名
    }
  }
  return /filename="([^"]+)"/.exec(header)?.[1] ?? null
}

/** 用临时 `<a download>` 触发浏览器保存；URL 在 1 秒后回收。 */
export function saveBlob(blob: Blob, filename: string): void {
  const url = URL.createObjectURL(blob)
  const anchor = document.createElement('a')
  anchor.href = url
  anchor.download = filename
  document.body.append(anchor)
  anchor.click()
  anchor.remove()
  setTimeout(() => URL.revokeObjectURL(url), 1000)
}
