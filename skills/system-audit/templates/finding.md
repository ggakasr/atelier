# Finding record

Một finding = một file block này trong `lane-<name>.md`. ID ổn định (`F-001`, `F-002`...), không đánh số lại sau khi gộp trùng; finding bị gộp ghi `merged into F-0xx`.

```
## F-001 — <tiêu đề một dòng>

- Lane: architecture-code | data | ui-ux | functional-api | performance | security
- Severity: P0 | P1 | P2 | P3
- Status: verified | suspected | untested
- What: <chuyện gì sai, ở đâu, ảnh hưởng gì tới người dùng/dữ liệu>
- Evidence: <đường dẫn evidence/<lane>/..., hoặc file:line, hoặc output lệnh>
- Repro steps:
  1. ...
  2. ...
- Expected / Actual: <một dòng mỗi bên>
- Proposed fix: <thay đổi cụ thể nhỏ nhất>
- Fix tier: GREEN | YELLOW | RED (lý do một dòng)
- Fix status: not fixed | fixed (proof: ...) | not fixed (reason: ...)
```

Severity:
- **P0**: mất/hỏng dữ liệu, bypass auth, hệ thống không dùng được.
- **P1**: chức năng chính hỏng hoặc rủi ro nghiêm trọng, có cách vòng khó.
- **P2**: chức năng phụ hỏng, trải nghiệm kém rõ ràng, có cách vòng.
- **P3**: nhỏ, thẩm mỹ, cải thiện.

`Status: verified` đòi evidence thật. Không có evidence thì hạ xuống `suspected`.
