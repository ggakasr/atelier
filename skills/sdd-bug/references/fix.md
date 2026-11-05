# Fix: sửa tối thiểu theo assessment

Đầu ra: sửa code + `docs/bugs/<slug>/fix.md`.

## Điều kiện
- `assessment.md` phải có. Không có: dừng, quay lại assess.
- Chọn slug: người dùng đưa > slug vừa dùng trong phiên > duy nhất một `docs/bugs/*/assessment.md` > hỏi. Không đoán.
- Đọc toàn bộ assessment: Proposed Remediation, Files, Tests, Risks là "hợp đồng".
- Verdict `invalid`: dừng. `likely valid` còn `[NEEDS CLARIFICATION]`: nêu ra và hỏi trước khi sửa.
- `fix.md` đã có: hỏi trước khi ghi đè.

## Các bước
1. Nêu kế hoạch 3-6 gạch đầu dòng (đổi gì, ở đâu).
2. Áp fix tối thiểu, trong các file assessment đã liệt kê. Mở rộng phạm vi chỉ khi có bằng chứng mới, và ghi rõ trong fix.md. Không refactor lan man, không thêm dependency ngoài assessment.
3. Thêm/cập nhật test mà assessment yêu cầu.
4. Chạy test chạm đúng đường dẫn đã đổi; ghi lệnh + kết quả. Không chạy suite phá hủy hoặc cần mạng khi chưa được đồng ý.
5. Nếu assessment sai (fix không hiệu quả, root cause chỗ khác): DỪNG sửa, ghi vào `Deviations from Assessment`, đề nghị assess lại.

## Mẫu fix.md
```
# Bug Fix: <tiêu đề>
- Slug / Fixed (ISO) / Assessment: ./assessment.md / Status: applied | partial | not-applied
## Summary
## Changes  (bảng: file | thay đổi | ghi chú)
## Tests Added or Updated  (`file::test` - ghim điều gì)
## Local Verification  (lệnh -> kết quả)
## Deviations from Assessment  (trống nếu không có)
## Follow-ups
```
