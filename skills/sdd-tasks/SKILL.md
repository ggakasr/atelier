---
name: sdd-tasks
description: "Break plan.md and spec.md into an executable tasks.md grouped by user story (Setup, Foundational, one phase per story, Polish) with strict task lines, [P] parallel markers and FR/SC traceability. Use when the user says 'break this into tasks', 'generate tasks', 'chia task theo user story', 'lập danh sách task từ plan', 'tạo tasks.md'. Not for writing the spec (sdd-specify), the technical plan (sdd-plan) or one agreed change handed to builder (work-order)."
---

# SDD Tasks

`plan.md` + `spec.md` (+ data-model, contracts, research) -> `specs/NNN-slug/tasks.md`. Mỗi task đủ cụ thể để một builder lạnh làm xong mà không cần hỏi thêm.

## Conventions

- Feature folder `specs/NNN-slug/`. Không rõ folder: lấy `specs/*/` mới nhất hoặc hỏi một lần.
- ID `FR-###` / `SC-###` ổn định, không đánh số lại. Task trích ID mà nó phục vụ, vd `(FR-003, SC-001)`.
- Hiến pháp `docs/constitution.md` (nếu có): đọc để biết ràng buộc (vd test-first).

## Đầu vào

Bắt buộc: `plan.md`, `spec.md`. Tuỳ chọn: `data-model.md`, `contracts/`, `research.md`, `quickstart.md`. Thiếu plan: dừng, gợi ý `sdd-plan`. Thiếu tài liệu tuỳ chọn thì tạo task theo cái đang có.

## Cấu trúc phase

1. **Setup**: khởi tạo dự án, cấu hình dùng chung. Không nhãn story.
2. **Foundational**: tiền đề **chặn mọi story** (schema, auth, routing, error handling). Không nhãn story. Kết bằng `Checkpoint`.
3. **Một phase cho mỗi user story**, đúng thứ tự P1, P2, P3. Story đầu (P1) = **MVP**. Mỗi phase có `Goal`, `Independent Test`, tasks, `Checkpoint`. Phải có nhãn `[USn]`.
4. **Polish**: tài liệu, dọn dẹp, chạy `quickstart.md`. Không nhãn story.

Trong một story: (test nếu có) -> model -> service -> endpoint/UI -> tích hợp.

## Định dạng task (nghiêm ngặt)

```text
- [ ] T012 [P] [US1] Mô tả việc cần làm, kèm đường dẫn file chính xác (FR-003)
```

- Bắt đầu bằng `- [ ]`; ID tuần tự `T001...` theo thứ tự thực thi.
- `[P]` **chỉ khi** khác file **và** không phụ thuộc task chưa xong.
- `[USn]` bắt buộc trong phase story, cấm ở Setup/Foundational/Polish.
- Sai: thiếu checkbox, thiếu ID, thiếu đường dẫn file, task mơ hồ ("thêm validation").

## Ánh xạ

- Mỗi entity gắn vào story cần nó; phục vụ nhiều story thì đặt ở story sớm nhất hoặc Setup.
- Mỗi contract gắn vào story nó phục vụ.
- **Ràng buộc dữ liệu** trong data-model.md (độ dài tối đa, bắt buộc/null, enum, luật validate): **trích nguyên văn vào mô tả task**, không để lúc làm tự quyết.
- Mỗi task truy được về ít nhất một FR hoặc SC. Task không truy được thì bỏ.

## Test

Chỉ sinh task test khi spec hoặc user **yêu cầu** (hoặc TDD). Khi có: test viết **trước** và phải **fail** trước khi làm phần cài đặt tương ứng (xem `tdd`).

## Phần phụ trong tasks.md

Dùng `templates/tasks-template.md`: Dependencies & Execution Order, ví dụ chạy song song cho một story, chiến lược **MVP first** (Setup -> Foundational -> US1 -> dừng và kiểm chứng) và giao tăng dần.

## Báo cáo cuối

Đường dẫn tasks.md, tổng số task, số task mỗi story, cơ hội song song, `Independent Test` từng story, đề xuất MVP (thường chỉ US1), xác nhận mọi dòng đúng định dạng. Bước tiếp theo: `sdd-analyze` (soát nhất quán spec/plan/tasks) rồi `sdd-implement`. Họ sdd-*: specify -> clarify -> plan -> checklist -> tasks -> analyze -> implement -> converge.

Adapted from github/spec-kit (MIT, Copyright GitHub, Inc.); see LICENSE-spec-kit.md. Rewritten for atelier.
