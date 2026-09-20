import { describe, expect, it } from 'vitest'
import { filenameFromDisposition } from './download'

describe('下载文件名', () => {
  it('优先取 filename* 并解码中文', () => {
    expect(
      filenameFromDisposition(
        'attachment; filename="PicoSeek-x.pdf"; ' +
          "filename*=UTF-8''PicoSeek-20260919-%E9%97%AE%E9%A2%98.pdf",
      ),
    ).toBe('PicoSeek-20260919-问题.pdf')
  })
  it('只有 filename 时取引号内的名字，缺头返回 null', () => {
    expect(filenameFromDisposition('attachment; filename="a.pdf"')).toBe(
      'a.pdf',
    )
    expect(filenameFromDisposition(null)).toBeNull()
  })
})
