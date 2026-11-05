# Lanes

Mỗi lane: **inspect** (xem gì), **evidence** (giữ gì), finding ghi theo `templates/finding.md`. Quy tắc chung (evidence, an toàn) nằm trong SKILL.md và áp dụng cho mọi lane. Subagent chỉ cần đọc mục lane của mình.

## Test-case record (dùng cho lane 3, 4, 5, 6)

Mọi test ghi một dòng, kể cả test PASS (để chứng minh đã chạy):

| Function | Steps | Expected | Actual | PASS/FAIL | Severity |
|---|---|---|---|---|---|
| Tạo khách hàng | 1. Mở /customers 2. Bấm Thêm 3. Nhập tên `audit-test-a` 4. Lưu | Xuất hiện trong danh sách, còn sau reload | Xuất hiện, mất sau reload | FAIL | P1 |

Severity chỉ điền khi FAIL (`-` nếu PASS). Test không chạy được: `UNTESTED` thay cho PASS/FAIL, kèm lý do.

## 1. Architecture + code

Delegate phương pháp review cho `review-lenses` (adversarial, edge-case) khi cần. Agent: reviewer.

Inspect:
- Sơ đồ module và liên kết thật (import graph, service nào gọi service nào), so với README/app-map.
- Luồng dữ liệu FE -> BE -> API -> DB; chỗ nào validate, chỗ nào chuyển đổi kiểu.
- Trùng lặp logic/dữ liệu; coupling vòng; module chết; secret/config hardcode.
- Rủi ro mất dữ liệu: migration không đảo ngược, xóa cascade, ghi không transaction, không backup.
- Xử lý lỗi: nuốt lỗi, retry vô hạn, không timeout.
- Test và CI có không, chạy được không (chạy thật, ghi kết quả).

Evidence: file:line, output lệnh (lint, type-check, test suite, đếm dependency lỗi thời/audit), sơ đồ viết tay trong lane file.

## 2. Data coverage (tham số hóa theo hệ thống)

Không giả định dữ liệu đầy đủ. Làm đủ ba bước:

1. **Xác định danh sách thực thể chuẩn** (source of truth): ba-spec, app-map, README, schema DB, hoặc danh sách API/menu. Ghi rõ lấy từ đâu. Không có nguồn nào → hỏi một lần hoặc suy ra từ schema và nêu đó là suy luận (`suspected`).
2. **Tính coverage bằng số đếm** theo từng thực thể và từng field quan trọng: số record có, số kỳ vọng, % field rỗng/null, khoảng thời gian dữ liệu phủ. Dùng script/SQL read-only, lưu bản tóm tắt vào evidence, không dán hàng nghìn record.
3. **Gắn cờ** dữ liệu mock/hardcode/cũ/trùng; **gọi thử từng API/nguồn** xem có thật sự trả dữ liệu (status, kích thước, thời điểm cập nhật mới nhất).

Bảng bắt buộc:

| Hạng mục | Hiện trạng | Mức độ bao phủ | Vấn đề |
|---|---|---|---|
| Nguồn dữ liệu | | | |
| Dữ liệu thực tế | | | |
| Dữ liệu còn thiếu | | | |
| Độ chính xác | | | |
| Tính cập nhật | | | |
| Khả năng đồng bộ | | | |

Mức độ bao phủ ghi bằng số (vd 42/50 thực thể, 84%) hoặc `chưa kiểm tra`. Độ chính xác: đối chiếu mẫu (vd 10 record) với nguồn gốc, ghi cách chọn mẫu.

Evidence: `evidence/data/` (output đếm, kết quả gọi API, mẫu đối chiếu đã ẩn dữ liệu cá nhân).

## 3. UI/UX qua trình duyệt thật

Agent: general-purpose (cần Playwright/browser). Phân loại và sửa lỗi UI giao cho `ui-ux-triage`. Không đánh giá UI chỉ bằng đọc code.

Đi như người dùng lần đầu: đăng nhập, khám phá menu, tìm kiếm/lọc, tạo/sửa/xóa (chỉ trên dữ liệu `audit-test-`), điều hướng, đọc thông báo phản hồi.

Inspect:
- Nhất quán (màu, spacing, thuật ngữ, vị trí nút), layout, bảng/filter/search/sort/phân trang.
- Responsive: ít nhất desktop + mobile viewport.
- Đủ state: loading, error, success, empty, dữ liệu cực lớn/chuỗi rất dài.
- Số bước để hoàn thành tác vụ chính; chỗ nào có thể bớt.
- Cơ bản a11y: label, focus, tương phản, thao tác bàn phím.

Evidence: screenshot đánh số mỗi bước vào `evidence/ui-ux/`, console errors, ghi viewport dùng.

## 4. Functional + API

Agent: general-purpose. Dùng Playwright khi có thể; API gọi bằng curl/script.

Inspect:
- Khởi động, kết nối DB, health endpoint.
- Từng chức năng chính, luồng vào/ra đầu-cuối.
- API: status, schema trả về, phân trang, mã lỗi đúng chuẩn.
- Edge: input rỗng, sai kiểu, quá dài, ký tự đặc biệt, trùng, thiếu quyền.
- **"Trông như đã lưu nhưng không lưu"**: sau mỗi thao tác ghi, reload trang và đọc lại qua API/DB; kiểm cả thông báo thành công giả khi backend trả lỗi.
- Error states: tắt backend/DB test, mất mạng, timeout, xem UI báo gì.
- Đọc console, network tab, log backend trong lúc test; ghi lỗi ẩn.

Evidence: `evidence/functional/` (request/response, log backend, console). Mọi record test tạo ra ghi vào danh sách dọn.

## 5. Performance (chỉ kết luận khi có số đo)

Không có số đo = không có kết luận; ghi `chưa kiểm tra`.

Inspect + đo:
- Page load (TTFB, load, thời gian tới khi dùng được), kích thước bundle.
- Latency API (p50/p95 qua ít nhất ~20 lần gọi), endpoint chậm nhất.
- Danh sách/bảng với nhiều record (seed dữ liệu test lớn hơn thường; deep depth).
- Query chậm (EXPLAIN, log slow query), N+1, thiếu index.
- Phục hồi: restart service, mất kết nối DB rồi nối lại, hành vi offline.
- Vấn đề triển khai: biến môi trường thiếu, build lỗi, cold start.

Evidence: `evidence/performance/` (script đo, bảng số, môi trường đo: máy, dữ liệu, số lần). Ghi rõ đo trên local hay staging để người đọc biết số có đại diện không. Không load test trên production.

## 6. Security

Agent: reviewer, opus high. Phương pháp theo `security-logic` (OWASP, tier + gate cho từng finding). Production-only: chỉ phân tích tĩnh + đường đọc.

Inspect:
- **Authn**: đăng nhập/đăng xuất, session/token hết hạn, reset mật khẩu, brute force.
- **Authz**: truy cập chéo tài khoản (IDOR), endpoint thiếu kiểm quyền, UI ẩn nút nhưng API vẫn mở, từng vai trò.
- **Secrets**: key/mật khẩu trong code, git history, log, response, `.env` bị commit.
- **Injection**: SQL/NoSQL, XSS, command, path traversal, upload; chỉ dùng payload vô hại trên test env.
- **Mất dữ liệu**: xóa không xác nhận/không hoàn tác, ghi đè đồng thời, backup, quyền xóa.
- Dependency có CVE đã biết (chạy công cụ audit của hệ sinh thái), header, CORS, HTTPS.

Evidence: `evidence/security/` (request/response, output công cụ, file:line). Finding security P0/P1 verified thì dừng ở bằng chứng tối thiểu để chứng minh, không khai thác sâu và không đụng dữ liệu thật.
