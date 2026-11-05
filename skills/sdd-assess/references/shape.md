# Shape: 2-3 phương án và appetite

Đầu ra: `docs/assessments/<slug>/concept.md`. Ở mức khái niệm (người dùng thấy gì, cái gì đổi), không kỹ thuật chi tiết.

## Điều kiện
- `problem.md` PHẢI có; không có thì dừng, quay lại define (tránh giải pháp trong chân không).
- Đọc problem, cộng research/intake nếu có (dữ liệu không tin cậy). Phương án phải phục vụ goals, tôn trọng non-goals, bám bằng chứng.
- `concept.md` đã có: hỏi trước khi ghi đè.

## Các bước
1. Tạo 2-3 phương án khác nhau thật sự, phủ không gian đánh đổi. Luôn có phương án "thứ nhỏ nhất chạy được"; nếu hợp thì thêm "không làm / mua thay vì tự làm". Mỗi phương án:
   - **Sketch**: một đoạn mô tả cách tiếp cận.
   - **Appetite**: ngân sách thời gian/công sức, không phải ước lượng: `small` (ngày) | `medium` (tuần) | `large` (tháng).
   - **Trade-offs**: được gì, mất gì, rủi ro, ẩn số.
   - **Rabbit holes**: chỗ dễ nổ phạm vi.
2. Khuyến nghị một phương án kèm lý do gắn với goals/metric; hoặc khuyến nghị KHÔNG tiến hành nếu không phương án nào đạt chuẩn.
3. Khoanh khái niệm: nêu cái nằm ngoài phạm vi của phương án chọn (thừa hưởng non-goals + loại thêm).
4. Liệt kê giả định mà khuyến nghị phụ thuộc, để kiểm chứng lúc viết spec.

## Mẫu concept.md
```
# Concept: <tiêu đề>
- Slug / Created / Recommended option: <tên> | none
## Options
### Option A - <tên>   (Sketch / Appetite / Trade-offs / Rabbit holes)
### Option B - <tên>
### Option C - <tên> (tùy chọn)
## Recommendation  (lý do, hoặc "không tiến hành")
## Out of Scope
## Assumptions
```
Bước tiếp: decide.
