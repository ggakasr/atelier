---
name: sdd-analyze
description: "Read-only consistency check across spec.md, plan.md, tasks.md and the constitution: finds duplication, ambiguity, underspecification, constitution violations, coverage gaps and inconsistencies, and reports them by severity without editing anything. Use when the user says analyze the spec/plan/tasks, check consistency before implementing, kiểm tra spec/plan/tasks nhất quán, soát chéo tài liệu. Not for code review (review-lenses) or checking built code against the spec (sdd-converge)."
---

# SDD Analyze

Soát chéo `spec.md` + `plan.md` + `tasks.md` + constitution **trước khi implement**. **CHỈ ĐỌC**: không sửa bất kỳ file nào.

## Conventions (dùng chung cả họ sdd-*)

- Feature folder: `specs/NNN-slug/` gồm `spec.md`, `plan.md`, `tasks.md`, `checklists/`. Không rõ folder: lấy `specs/*/` mới nhất hoặc hỏi một lần.
- `FR-###` / `SC-###` ổn định, không đánh số lại. Constitution: `docs/constitution.md` (nếu có; nếu chỉ là template chưa điền thì bỏ qua phần constitution và nói rõ).
- Thiếu spec/plan/tasks: dừng, nêu skill cần chạy trước (`sdd-specify`, `sdd-plan`, `sdd-tasks`). Không tạo báo cáo dở.

## Ràng buộc

- Không ghi file. Chỉ xuất báo cáo và (nếu user đồng ý) đề xuất sửa.
- **Constitution là bất khả thương lượng**: xung đột = CRITICAL, phải sửa spec/plan/tasks, không pha loãng hay diễn giải lại nguyên tắc. Muốn đổi nguyên tắc thì làm riêng bằng `sdd-constitution`.
- Không bịa mục thiếu: thiếu thì báo đúng là thiếu. Dẫn ví dụ cụ thể, không nói chung chung.

## Bước làm

1. **Nạp tối thiểu** (progressive disclosure): spec (overview, FR, SC, user stories, edge cases); plan (kiến trúc/stack, data model, phases, ràng buộc); tasks (ID, mô tả, phase, đánh dấu [P], đường dẫn file); constitution (các câu MUST/SHOULD).
2. **Dựng mô hình nội bộ** (không in nguyên văn): inventory requirement (khóa = ID FR/SC; SC chỉ tính khi cần việc xây dựng thật, bỏ KPI sau launch), inventory user story/hành động, ánh xạ task -> requirement (theo ID hoặc cụm từ khóa), tập luật constitution.
3. **Detection passes** (tập trung tín hiệu cao, tối đa **50 finding**, phần dư gộp thành tóm tắt overflow):
   - **A Duplication**: yêu cầu gần trùng; chọn bản diễn đạt tốt hơn để giữ.
   - **B Ambiguity**: tính từ mơ hồ không số đo (fast, scalable, secure, intuitive, robust); placeholder (TODO, ???, `<...>`).
   - **C Underspecification**: động từ thiếu đối tượng/kết quả đo được; user story không khớp acceptance criteria; task nhắc file/thành phần không có trong spec/plan.
   - **D Constitution**: yêu cầu hay plan trái nguyên tắc MUST; thiếu mục/cổng chất lượng constitution bắt buộc.
   - **E Coverage gaps**: requirement không có task; task không map tới requirement/story; SC cần xây dựng (perf, security, availability) mà tasks không có.
   - **F Inconsistency**: thuật ngữ lệch giữa các file; entity có ở plan mà thiếu ở spec (hoặc ngược lại); thứ tự task mâu thuẫn (integration trước setup nền mà không ghi phụ thuộc); yêu cầu xung đột (một bên Next.js, một bên Vue).
4. **Severity**:
   - **CRITICAL**: vi phạm constitution MUST, thiếu artifact lõi, hoặc requirement không có task chặn chức năng nền.
   - **HIGH**: yêu cầu trùng/xung đột, thuộc tính security/performance mơ hồ, acceptance criterion không kiểm thử được.
   - **MEDIUM**: lệch thuật ngữ, thiếu task non-functional, edge case thiếu chi tiết.
   - **LOW**: văn phong, dư thừa nhẹ không ảnh hưởng thứ tự thực thi.
5. **Báo cáo** (chỉ in ra, không ghi file):

```
## Specification Analysis Report
| ID | Category | Severity | Location(s) | Summary | Recommendation |
| A1 | Duplication | HIGH | spec.md:L120-134 | ... | ... |
```
   - ID ổn định, tiền tố là chữ cái đầu của category (D = Duplication, A = Ambiguity, U = Underspec, C = Constitution, G = Coverage gap, I = Inconsistency; đánh số theo thứ tự xuất hiện trong file để chạy lại ra cùng ID).
   - **Coverage table**: `Requirement Key | Has Task? | Task IDs | Notes`.
   - **Constitution alignment issues** (nếu có); **Unmapped tasks** (nếu có).
   - **Metrics**: tổng requirement, tổng task, coverage % (requirement có >=1 task), số ambiguity, số duplication, số CRITICAL.
   - Không có vấn đề: báo thành công kèm thống kê coverage.
6. **Next actions**: có CRITICAL thì giải quyết trước `sdd-implement`; chỉ LOW/MEDIUM thì có thể đi tiếp, kèm gợi ý cải thiện. Nêu skill cụ thể: chỉnh yêu cầu bằng `sdd-clarify`/`sdd-specify`, đổi kiến trúc bằng `sdd-plan`, thiếu task bằng `sdd-tasks`.
7. **Hỏi trước khi sửa**: "Muốn tôi đề xuất chỉnh sửa cụ thể cho N vấn đề hàng đầu không?" Không tự áp dụng.

## Nguyên tắc

- **Deterministic**: chạy lại khi file không đổi phải ra cùng ID và số liệu.
- Ít token, nhiều tín hiệu: bảng tối đa 50 dòng, còn lại tóm tắt.
- Đọc từng phần, không đổ nguyên file vào báo cáo.

Adapted from github/spec-kit (MIT, Copyright GitHub, Inc.); see LICENSE-spec-kit.md. Rewritten for atelier.
