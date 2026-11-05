# System Audit Report: <tên hệ thống>

Ngày: <YYYY-MM-DD> | Target: <env, phiên bản/commit> | Depth: quick | standard | deep | Mode: full | read-only (production)

Chú giải trạng thái: **Verified** = đã tái hiện/đo, có evidence. **Suspected** = có dấu hiệu, chưa chứng minh. **Untested** = không chạy được hoặc bị bỏ qua (nêu lý do).

## A. Executive Summary

- Dùng được cho thực tế chưa: <một câu thẳng: có / chưa / có điều kiện nào>
- Điểm mạnh nhất (3 tối đa): ...
- Vấn đề lớn nhất (3 tối đa, kèm ID F-xxx): ...
- Phạm vi đã kiểm: <lane đã chạy / untested + lý do>

## B. System Assessment

Mỗi lane 3-6 dòng, mỗi dòng dẫn finding hoặc evidence.

- Kiến trúc + code: ...
- Độ bao phủ dữ liệu (bảng Hạng mục | Hiện trạng | Mức độ bao phủ | Vấn đề, xem references/lanes.md): ...
- UI/UX: ...
- Chức năng và quy trình: ...
- Hiệu năng (có số đo): ...
- Bảo mật: ...

## C. Testing Report

| Function | Steps | Expected | Actual | PASS/FAIL | Severity |
|---|---|---|---|---|---|
| ... | ... | ... | ... | PASS | - |

Evidence: danh sách link `evidence/<lane>/...`. Test chưa chạy được liệt kê riêng với trạng thái Untested.

## D. Issues & Recommendations

| ID | Severity | Status | Vấn đề | Fix đề xuất | Đã sửa? |
|---|---|---|---|---|---|

Nhóm theo: **P0 Critical** / **P1 High** / **P2 Medium** / **P3 Low**. Cột "Đã sửa?" ghi `fixed (proof)` hoặc `not fixed (lý do)`.

Assumptions (YELLOW): ...
Dữ liệu test đã tạo, cần dọn: ...

### Điểm số

| Tiêu chí | Điểm /10 | Lý do + evidence |
|---|---|---|
| Kiến trúc | | |
| Chất lượng code | | |
| Độ bao phủ dữ liệu | | |
| Độ chính xác dữ liệu | | |
| UI | | |
| UX | | |
| Chức năng và quy trình | | |
| Độ ổn định | | |
| Hiệu năng | | |
| Bảo mật | | |

Chưa có evidence → ghi `chưa kiểm tra`, không ghi số. Áp dụng cap theo references/scoring.md.

## E. Final Verdict

1. Hệ thống đã tốt chưa?
2. Dữ liệu bao phủ đến đâu, còn thiếu gì?
3. UI/UX đạt chưa?
4. Đủ ổn định để dùng thực tế chưa?
5. Cần làm gì tiếp? (thứ tự ưu tiên, tối đa 5 việc)

Mỗi câu trả lời: một kết luận thẳng + một dòng lý do dẫn finding/evidence.
