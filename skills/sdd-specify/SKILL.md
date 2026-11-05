---
name: sdd-specify
description: "Turn a natural-language feature description into specs/NNN-slug/spec.md: WHAT and WHY only, prioritised independently-testable user stories, FR-### requirements, technology-agnostic SC-### criteria, max 3 clarification markers. Use when the user says 'write a spec for', 'specify this feature', 'viết spec cho tính năng', 'đặc tả tính năng', 'mô tả yêu cầu tính năng mới'. Not for fuzzy multi-user business analysis (ba-flow-logic), nor a single agreed change for builder (work-order)."
---

# SDD Specify

Mô tả tính năng (ngôn ngữ tự nhiên) -> `specs/NNN-slug/spec.md`. Chỉ **WHAT/WHY**, không tech stack, không API, không cấu trúc code. Viết cho người không-kỹ-thuật.

## Conventions (dùng chung cả họ sdd-*)

- Feature folder: `specs/NNN-slug/` gồm `spec.md`, `plan.md`, `tasks.md`, `checklists/`.
- ID `FR-###` (requirement) và `SC-###` (success criteria): ổn định, **không đánh số lại**. Cùng quy ước với ba-spec / work-order của atelier.
- Hiến pháp dự án (nếu có): `docs/constitution.md`. Đọc trước khi viết.
- Không rõ feature folder nào: lấy `specs/*/` mới nhất hoặc hỏi một lần.

## Quan hệ với atelier

- Đã có ba-spec (từ `ba-flow-logic`): **trích ID của nó**, không viết lại nghiệp vụ.
- Nhu cầu còn mờ, nhiều vai trò, nhiều luồng nghiệp vụ: dùng `ba-flow-logic` trước.
- Mô tả rỗng: dừng, hỏi. Không xác định được luồng người dùng: dừng, hỏi.

## Quy trình

1. **Slug**: 2-4 từ, dạng hành động-danh từ (`user-auth`, `fix-payment-timeout`); giữ nguyên thuật ngữ/viết tắt (OAuth2, API).
2. **NNN**: quét `specs/`, lấy số lớn nhất + 1, 3 chữ số (`003`). Thư mục chưa có thì tạo. Một lần chỉ một feature.
3. Copy `templates/spec-template.md` vào `specs/NNN-slug/spec.md`, điền theo thứ tự section cũ.
4. Rút ra: actors, actions, data, constraints.
5. **User story**: ưu tiên P1/P2/P3 (P1 = quan trọng nhất). Mỗi story phải **độc lập kiểm thử được**: chỉ làm riêng nó vẫn ra MVP có giá trị. Mỗi story có `Independent Test` + kịch bản Given/When/Then.
6. **FR-###** testable, không mơ hồ. **SC-###** đo được, **không nhắc công nghệ**.
7. Chỗ chưa rõ: tự chọn mặc định hợp lý (chuẩn ngành), ghi vào `Assumptions`. Ví dụ mặc định không cần hỏi: retention theo chuẩn ngành, hiệu năng như web/mobile thường, lỗi hiển thị thân thiện, auth session/OAuth2 chuẩn.
8. Section không áp dụng: **xoá hẳn**, không viết "N/A".

## Giới hạn [NEEDS CLARIFICATION]

Tối đa **3** marker `[NEEDS CLARIFICATION: câu hỏi cụ thể]`, chỉ khi lựa chọn đổi mạnh scope/UX, có nhiều cách hiểu khác nhau, và không có mặc định hợp lý. Ưu tiên: **scope > security/privacy > UX > kỹ thuật**. Quá 3: giữ 3 cái quan trọng nhất, phần còn lại đoán và ghi Assumptions.

## Success criteria

- Tốt: "Người dùng hoàn tất thanh toán dưới 3 phút", "95% lượt tìm trả kết quả dưới 1 giây".
- Xấu: "API phản hồi dưới 200ms", "cache hit rate trên 80%", "React render hiệu quả" (lộ công nghệ, nói về hệ thống thay vì người dùng).

## Tự kiểm tra (tối đa 3 vòng)

Tạo `checklists/requirements.md` rồi duyệt spec theo từng mục, sửa spec, lặp tối đa 3 vòng; còn sai thì ghi vào Notes và cảnh báo user.

- [ ] Không có chi tiết cài đặt (ngôn ngữ, framework, API)
- [ ] Tập trung giá trị người dùng; đọc được bởi người không-kỹ-thuật; đủ section bắt buộc
- [ ] Không còn marker (sau khi hỏi xong); requirement testable, không mơ hồ
- [ ] SC đo được và không nhắc công nghệ
- [ ] Mọi acceptance scenario, edge case đã có; scope có ranh giới; dependency/assumption đã ghi
- [ ] Mỗi FR có tiêu chí chấp nhận rõ; story phủ các luồng chính

## Hỏi marker còn lại

Gom tối đa 3 câu, đánh số Q1-Q3, hỏi một lượt rồi **chờ** (ví dụ trả lời "Q1: A, Q2: Custom - ..."):

```
## Question N: <chủ đề>
Context: <trích đoạn spec>   |   Cần biết: <câu hỏi>
| Option | Answer | Implications |
|--------|--------|--------------|
| A      | ...    | tác động lên tính năng |
| B      | ...    | ... |
| Custom | Tự trả lời | cách đưa câu trả lời |
```

Có đáp án: thay marker bằng đáp án, chạy lại tự kiểm tra.

## Báo cáo cuối

Đường dẫn feature folder + spec.md, kết quả checklist, assumptions đã chọn. Bước tiếp theo: `sdd-clarify` (còn điểm mờ) rồi `sdd-plan`. Họ sdd-*: specify -> clarify -> plan -> checklist -> tasks -> analyze -> implement -> converge; thêm sdd-constitution, sdd-bug, sdd-assess.

Adapted from github/spec-kit (MIT, Copyright GitHub, Inc.); see LICENSE-spec-kit.md. Rewritten for atelier.
