# Test: chứng minh bug hết, không vỡ chỗ khác

Đầu ra: `docs/bugs/<slug>/test-report.md` với verdict `verified | partial | failed`.

## Điều kiện
Cần `assessment.md` và `fix.md` (cùng quy tắc chọn slug như fix). Thiếu: dừng, nói bước còn thiếu. `test-report.md` đã có: hỏi trước khi ghi đè.

## Regression test (cốt lõi)
Phải có ít nhất một test tái hiện đúng bug: **FAIL trước fix, PASS sau fix**.
- Chứng minh "fail trước": chạy test trên code chưa fix (worktree riêng, hoặc tạm hoàn tác hunk fix rồi khôi phục; không động vào việc dở của người dùng). Không làm được: ghi `not-run` + lý do và KHÔNG tuyên bố verified.
- Test pass cả trước fix = test không bắt được bug, viết lại.

## Các bước
1. Lập kế hoạch kiểm: repro từ assessment (hoặc bản tự động), test mới/đã sửa, suite regression liên quan, lint/type-check nếu dự án có.
2. Chạy từng kiểm. Ghi lệnh, exit status, đoạn output ngắn (dòng tóm tắt, assertion lỗi). Kiểm phá hủy/cần mạng/đắt: `skipped` kèm lý do. Không chạy được: `not-run` kèm lý do. Không bịa kết quả.
3. Verdict:
   - **verified**: mọi kiểm quan trọng pass, regression test fail-trước/pass-sau, triệu chứng gốc không còn.
   - **partial**: triệu chứng hết nhưng có regression khác, hoặc kiểm chưa kết luận được.
   - **failed**: triệu chứng vẫn còn, hoặc fix làm vỡ suite.
   Không nói quá: repro chưa thật sự chạy (cần môi trường production) thì nói rõ.

## Mẫu test-report.md
```
# Bug Verification: <tiêu đề>
- Slug / Tested (ISO) / Assessment / Fix / Result: verified | partial | failed
## Summary
## Checks Performed  (bảng: kiểm | lệnh | kết quả pass/fail/skipped/not-run | ghi chú)
   gồm hàng: regression test trước fix (phải fail), sau fix (phải pass)
## Output Excerpts
## Residual Risks
## Recommendation  (đóng bug | giữ lại, cần xác minh | mở lại -> assess lại)
```
