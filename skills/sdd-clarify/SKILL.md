---
name: sdd-clarify
description: "Asks the user up to 5 targeted questions about an existing spec.md, one at a time with a recommended answer, and writes each answer straight back into the spec before planning. Use when the user says clarify the spec, find gaps or ambiguities in requirements, before plan, làm rõ spec, hỏi lại yêu cầu, spec còn mơ hồ. Not for fuzzy new ideas with no spec (ba-flow-logic) or code review (review-lenses)."
---

# SDD Clarify

Làm rõ một `spec.md` **đã có** trước khi lập plan. Tối đa 5 câu hỏi, mỗi lần một câu, mỗi câu trả lời được ghi vào spec ngay.

## Conventions (dùng chung cả họ sdd-*)

- Feature folder: `specs/NNN-slug/` gồm `spec.md`, `plan.md`, `tasks.md`, `checklists/`. Không rõ folder nào: lấy `specs/*/` mới nhất hoặc hỏi một lần.
- Requirement `FR-###`, success criterion `SC-###`: ổn định, không đánh số lại (giống atelier ba-spec / work-order).
- Constitution: `docs/constitution.md` (nếu có).
- Không có spec.md: dừng, gợi ý `sdd-specify`; không tự tạo spec ở đây.
- User chủ động bỏ qua bước này (spike thử nghiệm) thì được, nhưng cảnh báo một dòng: rủi ro làm lại ở plan tăng.

## 1. Scan

Đọc spec.md (và constitution nếu có). Chấm từng nhóm **Clear / Partial / Missing** (bản đồ nội bộ, chỉ in ra khi không có câu hỏi nào):

1. Functional scope: mục tiêu, out-of-scope, vai trò người dùng
2. Domain/data: entity, định danh, vòng đời/trạng thái, quy mô dữ liệu
3. UX flow: hành trình chính, trạng thái lỗi/rỗng/loading, a11y/i18n
4. Non-functional: hiệu năng, scale, độ tin cậy, observability, security/privacy, compliance
5. Integration: dịch vụ ngoài và cách chúng hỏng, định dạng import/export, version
6. Edge cases: kịch bản âm, rate limit, xung đột đồng thời
7. Constraints/tradeoffs: ràng buộc kỹ thuật, phương án đã loại
8. Terminology: thuật ngữ chuẩn, từ cấm/đồng nghĩa
9. Completion signals: acceptance criteria kiểm thử được, "xong" đo được
10. Placeholders: TODO, tính từ mơ hồ ("robust", "nhanh") chưa định lượng

Nhóm Partial/Missing là ứng viên câu hỏi, **trừ khi** câu trả lời không đổi cách làm/kiểm thử, hoặc chỉ là chọn công nghệ / chia task (ghi nội bộ, để plan lo).

## 2. Hàng đợi

Tối đa 5 câu cho cả phiên, chọn theo Impact x Uncertainty; ưu tiên chỗ giảm rework nhất (ví dụ security trước chi tiết nhỏ). Bỏ câu đã có đáp án, sở thích thẩm mỹ, chi tiết thực thi của plan. Không lộ trước các câu sau.

## 3. Hỏi từng câu (MỘT câu mỗi lượt)

Mỗi câu phải trả lời được bằng lựa chọn 2-5 phương án loại trừ nhau, hoặc cụm ngắn (<=5 từ).

Chất lượng câu hỏi:
- Mở bằng `**Question:**` + câu hỏi đầy đủ kết thúc bằng `?`, tự đứng được. Không dùng nhãn / tên mục / ID làm câu hỏi. ID chỉ được đặt trong ngoặc sau dấu `?`: `... ? (FR-023)`.
- Ngay sau đó một câu "Why it matters" bằng lời thường (rủi ro nếu không chốt).
- Người chưa biết SDD vẫn trả lời được; thuật ngữ phải giải thích ngay trong câu.

Dạng chọn: `**Recommended:** Option X - <1-2 câu lý do>` (theo best practice, giảm rủi ro, hợp mục tiêu trong spec), rồi bảng `Option | Description`. Nhắc user: trả lời chữ cái, hoặc "ok"/"recommended" để nhận đề xuất, hoặc tự viết câu ngắn.
Dạng ngắn: `**Suggested:** <đáp án> - <lý do>`; "ok" là chấp nhận.

"ok" = dùng đúng recommendation đã nêu. Trả lời mập mờ: hỏi lại gọn (không tính là câu mới). Dừng khi hết điểm mơ hồ quan trọng, user nói "done/đủ rồi", hoặc đã hỏi 5 câu.

## 4. Ghi ngay sau MỖI câu trả lời

- Lần đầu: đảm bảo có `## Clarifications` (tạo ngay sau phần overview nếu thiếu) và `### Session YYYY-MM-DD` của hôm nay.
- Thêm `- Q: <câu hỏi> → A: <đáp án>`, rồi cập nhật phần liên quan: functional -> FR; actor/flow -> user story; data -> data model; non-functional -> SC có số đo; edge -> Edge Cases; thuật ngữ -> chuẩn hóa toàn spec (ghi `(formerly "X")` một lần).
- Câu trả lời thay phát biểu mơ hồ cũ: **thay**, không để hai phát biểu mâu thuẫn. ID FR/SC cũ giữ nguyên; ID mới thêm ở cuối.
- Lưu file sau mỗi lần ghi; không đổi thứ tự các mục không liên quan; mỗi chỉnh sửa nhỏ và kiểm thử được.
- Kiểm tra: đúng một bullet cho mỗi câu trả lời, tổng <=5, không còn placeholder hay câu mâu thuẫn, chỉ thêm 2 heading nêu trên.
- Nếu `checklists/requirements.md` có sẵn: đánh giá lại với spec mới, chỉ đổi `[ ]`/`[x]` khi trạng thái thật sự đổi; báo số item đạt trước/sau.

## 5. Kết thúc

Không có gì đáng hỏi: nói "Không có điểm mơ hồ quan trọng" + tóm tắt coverage (toàn Clear). Ngược lại báo cáo:
- Số câu đã hỏi, đường dẫn spec, các mục đã sửa.
- Bảng coverage, mỗi nhóm = **Resolved** / **Deferred** (vượt quota hoặc thuộc về plan) / **Clear** / **Outstanding** (còn Partial nhưng tác động thấp).
- Còn Deferred/Outstanding rủi ro cao: nêu lý do, và nên đi tiếp plan hay clarify lại sau plan.

Bước tiếp: `sdd-plan`; muốn soát chất lượng văn bản yêu cầu thì `sdd-checklist`.

Adapted from github/spec-kit (MIT, Copyright GitHub, Inc.); see LICENSE-spec-kit.md. Rewritten for atelier.
