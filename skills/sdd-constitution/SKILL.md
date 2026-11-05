---
name: sdd-constitution
description: "Create or amend docs/constitution.md, the project's standing principles: testable MUST/SHOULD rules with rationale, governance, amendment procedure, semver versioning and a Sync Impact Report. Use when the user says 'set project principles', 'amend the constitution', 'nguyên tắc dự án', 'hiến pháp dự án', 'quy tắc bất biến của repo'. Not for one decision (decision-log/ADR), a feature spec (sdd-specify), a coding task, or security review (security-logic)."
---

# SDD Constitution

Tạo hoặc sửa `docs/constitution.md`: các nguyên tắc **thường trực** của dự án. `sdd-plan` dùng nó làm cổng (Constitution Check).

## Quan hệ với atelier

- ADR ghi **một quyết định** tại một thời điểm; constitution ghi **nguyên tắc đứng yên** áp dụng cho mọi quyết định sau. Quyết định lẻ -> `decision-log`/ADR.
- Risk tier GREEN/YELLOW/RED vẫn áp dụng. Nới một nguyên tắc MUST hoặc xoá nó là thay đổi RED-ish: hỏi user một câu trước khi ghi.
- Feature folder `specs/NNN-slug/` (spec.md, plan.md, tasks.md, checklists/); ID `FR-###`/`SC-###` ổn định. Constitution không chứa FR/SC.

## Scope Guard

Skill này **chỉ sửa `docs/constitution.md`**.
- Phân loại từng phần của input: nội dung hiến pháp hay ý định khác.
- Yêu cầu code, refactor, build, deploy, tạo feature: **không thực hiện**. Gom vào mục `Next Actions` (ý định gốc + skill gợi ý, vd `sdd-specify`), không gọi chúng.
- Không tạo/sửa/xoá file nguồn, test, config deploy hay file khác. Không rõ có phải nội dung hiến pháp không: hỏi trước khi sửa.
- Không có ý định ngoài lề thì bỏ mục `Next Actions`.

## Quy trình

1. Đọc `docs/constitution.md` (nếu có) làm nguồn giá trị hiện tại, giữ phần còn đúng. Chưa có: dùng `templates/constitution-template.md`. User muốn nhiều/ít nguyên tắc hơn mẫu: theo số user nêu.
2. Điền mọi placeholder `[ALL_CAPS]` từ input, hoặc suy từ README/docs/ADR. `RATIFIED` = ngày thông qua ban đầu (không biết: `TODO(RATIFICATION_DATE): lý do`); `LAST_AMENDED` = hôm nay nếu có sửa.
3. **Nguyên tắc** phải: có tên ngắn, luật không thương lượng, **MUST/SHOULD kiểm chứng được** (có người/công cụ trả lời pass/fail), kèm **rationale** nếu không hiển nhiên. Bỏ từ mơ hồ ("nên cố gắng", "tốt", "nhanh"): thay bằng ngưỡng hoặc hành vi cụ thể.
4. **Governance**: thủ tục sửa đổi (ai đề xuất, ai duyệt, kế hoạch migrate), chính sách version, kỳ vọng review tuân thủ (PR/review phải kiểm).
5. **Version** (semver): MAJOR = xoá hoặc định nghĩa lại nguyên tắc/governance không tương thích ngược; MINOR = thêm nguyên tắc/section hoặc mở rộng đáng kể; PATCH = làm rõ câu chữ, sửa lỗi. Mơ hồ: nêu lý lẽ đề xuất rồi mới chốt.
6. **Sync Impact Report** đặt thành HTML comment ở đầu file: version cũ -> mới; nguyên tắc đã đổi (tên cũ -> mới); section thêm; section xoá; TODO còn hoãn. Đây là ghi chú để người duyệt, gỡ trước khi commit.
7. **Propagate-check** (chỉ kiểm, **không sửa** ở đây): đối chiếu với `sdd-plan` plan-template (Constitution Check), spec-template, tasks-template, docs hướng dẫn. Chỗ lệch ghi vào Sync Impact Report và `Next Actions`.
8. **Validate**: không còn token ngoặc vuông chưa giải thích; dòng Version khớp report; ngày ISO `YYYY-MM-DD`; nguyên tắc khai báo, kiểm chứng được; giữ nguyên cấp heading của mẫu.
9. Ghi đè `docs/constitution.md`.

## Báo cáo cuối

Version mới và lý do bump; TODO/hoãn cần người làm; gợi ý commit (vd `docs: amend constitution to vX.Y.Z (principle additions)`) - chỉ gợi ý, không commit; mục `Next Actions` nếu có. Bước tiếp theo thường là `sdd-specify` cho tính năng đầu tiên. Họ sdd-*: specify -> clarify -> plan -> checklist -> tasks -> analyze -> implement -> converge.

Adapted from github/spec-kit (MIT, Copyright GitHub, Inc.); see LICENSE-spec-kit.md. Rewritten for atelier.
