---
name: sdd-converge
description: "Closes the loop between built code and intent: compares the ACTUAL current code against spec.md, plan.md and tasks.md, then appends a '## Phase N: Convergence' section of new traceable tasks for anything missing, partial, contradicting or unrequested. Use when the user asks whether the code matches the spec, code đã khớp spec chưa, còn thiếu gì so với spec, after implement. Not for bugs (diagnosing-bugs) or code review (review-lenses)."
---

# SDD Converge

Sau `sdd-implement`: so sánh **code hiện tại** với spec/plan/tasks, rồi **chỉ thêm** task cho phần còn thiếu. Không phải diff tool: không dùng git, không so branch, không xem lịch sử.

## Conventions (dùng chung cả họ sdd-*)

- Feature folder: `specs/NNN-slug/` gồm `spec.md`, `plan.md`, `tasks.md`, `checklists/`. Không rõ folder: lấy `specs/*/` mới nhất hoặc hỏi một lần.
- `FR-###` / `SC-###` ổn định, không đánh số lại. Constitution: `docs/constitution.md` (nếu có; template chưa điền thì bỏ qua phần này).
- Thiếu spec/plan/tasks: dừng, nêu skill cần chạy trước (`sdd-specify`, `sdd-plan`, `sdd-tasks`). Chỉ chạy sau khi đã implement ít nhất một lượt trên `tasks.md` hiện tại.

## Ràng buộc: APPEND-ONLY

Thao tác ghi **duy nhất** là thêm một section `## Phase N: Convergence` vào **cuối** `tasks.md`. KHÔNG:
- sửa `spec.md` hoặc `plan.md`;
- viết lại, đánh số lại, đổi thứ tự, xóa task có sẵn (kể cả task của phase Convergence trước);
- sửa/tạo/xóa code ứng dụng (việc đó là của `sdd-implement`).

Constitution MUST bị vi phạm = finding nặng nhất.

## Bước làm

1. **Nạp tối thiểu**: spec (FR, SC cần xây dựng thật, user stories + acceptance scenarios, edge cases); plan (quyết định kỹ thuật, data model, file/thành phần plan nói sẽ tạo/sửa); tasks (ID để tính ID kế tiếp + số phase kế tiếp, mô tả, file); constitution (MUST/SHOULD).
2. **Dựng intent inventory** (nội bộ): một khóa cho mỗi FR / SC / acceptance scenario (vd `US1/AC2`), cộng quyết định plan và nguyên tắc constitution có nghĩa vụ xây dựng. **Code-scope map**: các file nêu trong plan/tasks + tìm theo từ khóa khái niệm của từng requirement. Chỉ đánh giá trong phạm vi này, không suy rộng.
3. **Đánh giá code thật**: mở và đọc code trong phạm vi, kiểm tra hành vi hiện tại. **Ô đã tick hay lời "done" không phải bằng chứng**: mọi task có sẵn (dù tick hay không, dù thuộc phase Convergence cũ) đều đưa vào inventory và kiểm lại bằng code. Với chuỗi task sửa lỗi, đánh giá hành vi kết quả, không chi tiết đã bị thay thế. Kiểm cả nghĩa vụ chưa đạt lẫn code trái/vượt ý định. Chỉ tạo finding khi có khoảng cách. Gap type:
   - `missing`: việc cần làm hoàn toàn chưa có trong code
   - `partial`: có nhưng chưa thỏa đủ requirement/criterion/quyết định plan
   - `contradicts`: code làm điều xung đột với ý định hoặc constitution MUST
   - `unrequested`: code có việc không ai yêu cầu (chỉ để biết; converge không xóa code, chỉ thêm task review/biện minh/gỡ)
   Ít/không có code: coi toàn bộ phạm vi là `missing`, không báo lỗi.
4. **Severity**: **CRITICAL** = vi phạm constitution MUST, hoặc `missing`/`contradicts` chặn chức năng nền của user story P1. **HIGH** = `missing`/`partial` ở FR hay acceptance criterion cốt lõi. **MEDIUM** = `partial` ở yêu cầu phụ, hoặc `unrequested` chưa rõ lý do. **LOW** = lệch nhỏ, polish, `unrequested` rủi ro thấp.
5. **Tóm tắt trong phiên trước khi ghi** (chưa ghi file):

```
## Convergence Findings
| ID | Gap Type | Severity | Source | Evidence | Remaining Work |
| F1 | missing | HIGH | FR-008 | no guard found in path/module.py | Add enforcement |
```
   Kèm metrics: số requirement/criterion đã kiểm, số quyết định plan, số nguyên tắc constitution (hoặc "skipped - template"), finding theo gap type và theo severity.
6. **Có finding hành động được**: ở cuối `tasks.md`, tìm ID lớn nhất `M` và phase cao nhất, viết một header `## Phase N: Convergence` (N = phase cao nhất + 1), rồi mỗi finding một dòng, CRITICAL/HIGH trước (vi phạm constitution đứng đầu, mô tả "CRITICAL"), ID tiếp `T{M+1}`, `T{M+2}`...:

```
- [ ] T042 <mô tả mệnh lệnh> per <source-ref> (<gap-type>)
```
   `source-ref` = `FR-003`, `SC-002`, `US1/AC2`, `plan: <quyết định>`, `Constitution II`. Có phase Convergence cũ thì thêm phase mới bên dưới, không động vào cũ.
7. **Không còn gì**: KHÔNG sửa `tasks.md` (không để header rỗng). Báo **"Converged: code đáp ứng spec, plan và tasks"** kèm số lượng đã kiểm.
8. **Next**: đã thêm task thì nêu số task và phase, chạy `sdd-implement` rồi converge lại. Converged thì sang review/PR.

## Vòng lặp và giới hạn

implement <-> converge lặp tới khi Converged. **Trần của atelier: sau 3 vòng converge mà vẫn chưa hội tụ thì DỪNG**, báo user: finding nào còn lặp lại, khả năng spec/plan mâu thuẫn hoặc quá mơ hồ (gợi ý `sdd-clarify`, `sdd-analyze`, hoặc `course-correct`). Không tự chạy vòng thứ 4. Lỗi thật khi chạy: `diagnosing-bugs`.

Adapted from github/spec-kit (MIT, Copyright GitHub, Inc.); see LICENSE-spec-kit.md. Rewritten for atelier.
