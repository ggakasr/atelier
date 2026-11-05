---
name: sdd-checklist
description: "Generates a requirements-quality checklist (\"unit tests for the spec\") in specs/NNN-slug/checklists/<domain>.md: questions about completeness, clarity, consistency, measurability and coverage of the written requirements, never about code. Use when the user asks for a spec/requirements checklist, soát yêu cầu, checklist cho ux/api/security, kiểm tra spec đủ chưa. Not for code review (review-lenses) or test cases for the implementation."
---

# SDD Checklist

Checklist = **unit test cho văn bản yêu cầu**: kiểm tra yêu cầu được viết có đủ, rõ, nhất quán, đo được không. KHÔNG kiểm tra code hay hệ thống chạy đúng không.

## Conventions (dùng chung cả họ sdd-*)

- Feature folder: `specs/NNN-slug/` gồm `spec.md`, `plan.md`, `tasks.md`, `checklists/`. Không rõ folder: lấy `specs/*/` mới nhất hoặc hỏi một lần.
- `FR-###` / `SC-###` ổn định, không đánh số lại. Constitution: `docs/constitution.md` (nếu có).

## Quyền sở hữu dấu tick

Checklist là tài liệu của reviewer. `[x]` = reviewer xác nhận tiêu chí chất lượng yêu cầu đã đạt (không có nghĩa là code xong). **Agent KHÔNG BAO GIỜ tự tick `[x]`**: mọi item sinh ra đều `[ ]`. Chỉ đánh giá item khi reviewer/user yêu cầu rõ.

## Quy trình

1. **Làm rõ ý định** (tối đa 3 câu; thêm tối đa 2 câu nếu >=2 scenario class còn mù mờ; tổng <=5). Chỉ hỏi điều làm đổi nội dung checklist: phạm vi, rủi ro ưu tiên, độ sâu (sanity nhẹ hay cổng release), người dùng (tác giả hay reviewer PR), phần loại trừ. Không hỏi lại điều user đã nói. Không tương tác được thì mặc định: depth Standard, audience Reviewer nếu liên quan code còn lại Author, focus 2 cụm liên quan nhất.
2. **Đọc ngữ cảnh**: spec.md; plan.md, tasks.md, constitution nếu có. Chỉ đọc phần liên quan focus. Không bịa.
3. **Sinh file** `checklists/<domain>.md` (tên ngắn: `ux`, `api`, `security`, `performance`...) theo `templates/checklist-template.md`. Chưa có: tạo, bắt đầu `CHK001`. Đã có: **nối thêm**, tiếp ID cuối (CHK015 -> CHK016); không xóa/ghi đè nội dung cũ.
4. **Báo cáo**: đường dẫn, số item, tạo mới hay nối thêm, focus, depth, audience, item bắt buộc của user.

## Viết item

5 chiều chất lượng (mỗi item thuộc ít nhất một):
- **Completeness**: có đủ yêu cầu chưa
- **Clarity**: rõ, không mơ hồ
- **Consistency**: không mâu thuẫn nhau
- **Measurability**: đo/kiểm được khách quan
- **Coverage**: đủ kịch bản và edge case

Gom nhóm: Requirement Completeness / Clarity / Consistency, Acceptance Criteria Quality, Scenario Coverage, Edge Cases, Non-Functional, Dependencies & Assumptions, Ambiguities & Conflicts.

Scenario classes cần rà: **primary, alternate, exception/error, recovery, non-functional**. Thiếu lớp nào: hỏi "Are [X] requirements intentionally excluded or missing? [Gap]". Có thay đổi trạng thái (migration...) thì hỏi về rollback.

Mẫu câu: "Are ... defined for ...?", "Is '<từ mơ hồ>' quantified?", "Are requirements consistent between A and B?", "Can ... be objectively measured?", "Does the spec define ...?"

Quy tắc item:
- Tag: `[Gap]` `[Ambiguity]` `[Conflict]` `[Assumption]` (+ nhãn chiều như `[Clarity]`). Tham chiếu: `[FR-###]`, `[SC-###]` hoặc `[Spec §x.y]`.
- **>=80% item phải có ít nhất một tag/tham chiếu.** Chưa có hệ ID: thêm item "Is a requirement & acceptance criteria ID scheme established? [Traceability]".
- ID tuần tự toàn cục `CHK001`, `CHK002`...
- Trên 40 ứng viên: ưu tiên theo rủi ro, gộp item trùng; >5 edge case nhẹ thì gộp thành một item.

**CẤM**: item mở đầu bằng Verify / Test / Confirm / Check + hành vi triển khai; "displays correctly", "works properly"; click/navigate/render/load/execute; test case, QA procedure; chi tiết framework/API/thuật toán.

Anti-examples:

```
SAI   - [ ] CHK001 Verify landing page displays 3 episode cards [FR-001]
SAI   - [ ] CHK002 Test hover states work on desktop [FR-003]
SAI   - [ ] CHK003 Confirm logo click navigates home [FR-010]
DUNG  - [ ] CHK001 Are the number and layout of featured episodes specified? [Completeness, FR-001]
DUNG  - [ ] CHK002 Are hover state requirements consistent across interactive elements? [Consistency, FR-003]
DUNG  - [ ] CHK003 Is 'prominent display' quantified with measurable properties? [Ambiguity, FR-004]
DUNG  - [ ] CHK004 Are loading-state requirements defined for async data? [Gap]
```

Bước tiếp: sửa chỗ hổng tìm được bằng `sdd-clarify`; sau khi có tasks thì `sdd-analyze`.

Adapted from github/spec-kit (MIT, Copyright GitHub, Inc.); see LICENSE-spec-kit.md. Rewritten for atelier.
