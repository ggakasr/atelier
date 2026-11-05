---
name: sdd-implement
description: "Execute a feature's tasks.md phase by phase: checklist gate, ignore-file check, builder subagent per phase, [P] tasks in parallel, tasks marked [X] with proof, stop on a failed sequential task. Use when the user says 'implement the tasks', 'run tasks.md', 'triển khai theo tasks.md', 'làm theo danh sách task', 'bắt đầu code theo plan'. Not for a single agreed change with no tasks.md (work-order), bug hunting (diagnosing-bugs) or test-first of one unit (tdd)."
---

# SDD Implement

Thực thi `specs/NNN-slug/tasks.md`. Phiên chính là **foreman**: không tự code, giao từng phase cho `builder`.

## Conventions

- Feature folder `specs/NNN-slug/` (spec.md, plan.md, tasks.md, checklists/). Không rõ folder: lấy `specs/*/` mới nhất hoặc hỏi một lần.
- ID `FR-###` / `SC-###` ổn định. Hiến pháp `docs/constitution.md` (nếu có) là ràng buộc cứng.
- Rủi ro RED (DROP, ALTER mất dữ liệu, nới quyền, dữ liệu prod, chạy cron): dừng, hỏi user một câu gộp; phần không RED vẫn làm tiếp. Không commit/push/deploy nếu user chưa cho phép.

## 1. Cổng checklist (chỉ đọc)

Quét `checklists/*.md`; đếm mục `- [ ]` (chưa) và `- [x]`/`- [X]` (xong). In bảng `Checklist | Total | Checked | Unchecked | Status`.
- Mọi file hết mục chưa tick: PASS, đi tiếp.
- Còn mục chưa tick: **dừng và hỏi** "tiếp tục triển khai dù còn mục chưa tick?" Chờ trả lời; "no/wait/stop" thì dừng hẳn.
- Skill này **không** tự tick checklist. Với checklist chất lượng yêu cầu, `[x]` nghĩa là reviewer đã duyệt, không phải đã code xong.

## 2. Nạp ngữ cảnh

Bắt buộc: `tasks.md`, `plan.md`. Nếu có: `spec.md`, `data-model.md`, `contracts/`, `research.md`, `quickstart.md`, `docs/constitution.md`. Thiếu hoặc rỗng `tasks.md`: dừng, gợi ý `sdd-tasks`.

## 3. Ignore file

Theo stack trong plan.md: là git repo thì tạo/kiểm `.gitignore`; có Dockerfile thì `.dockerignore`; có ESLint/Prettier/npm/terraform/helm thì file ignore tương ứng. Đã có: chỉ **thêm** pattern thiết yếu còn thiếu. Chưa có: tạo với bộ pattern chuẩn của công nghệ đó (vd Node: `node_modules/`, `dist/`, `*.log`, `.env*`; Python: `__pycache__/`, `.venv/`, `*.pyc`; Rust/Java/Go: thư mục build). Không bao giờ ignore thứ cần commit.

## 4. Chạy từng phase (giao cho builder)

Thứ tự: Setup -> Foundational -> story theo ưu tiên -> Polish. Xong phase này mới sang phase sau; dừng ở mỗi `Checkpoint` để kiểm chứng.

- **Một phase = một `builder`** (sonnet, medium; high nếu đa module). Subagent **không có Skill tool**, nên brief phải tự đủ: dán đường dẫn tasks/plan/spec/data-model/contracts cần đọc, danh sách task của phase (nguyên văn), luật bên dưới, và điều kiện "Done when".
- Task `[P]` khác file: giao song song (hoặc builder song song, mỗi người một worktree nếu có nguy cơ đụng file). Task cùng file hoặc không có `[P]`: tuần tự theo thứ tự.
- Test-first: task test chạy trước task cài đặt tương ứng và phải fail trước (xem `tdd`).
- Brief cho builder nhắc: không đụng file ngoài task; ràng buộc dữ liệu trong mô tả task là bắt buộc; không commit.

## 5. Bằng chứng và đánh dấu

- Mỗi task builder phải trả **proof**: output lệnh (test/lint/build) hoặc `file:line` nơi việc đã nằm. Thiếu proof = chưa xong.
- Foreman kiểm proof rồi mới đổi `- [ ]` thành `- [X]` trong tasks.md.
- Báo tiến độ sau mỗi task hoặc nhóm `[P]`.

## 6. Lỗi

- Task tuần tự fail: **dừng** phase, báo lỗi kèm ngữ cảnh và gợi ý bước tiếp theo; không nhảy qua.
- Nhóm `[P]`: task thành công vẫn ghi nhận, task fail thì báo riêng.
- Cùng lỗi hai lần hoặc builder báo xong mà không có proof: nâng một bậc (sonnet -> opus hoặc effort cao hơn), tối đa 2 bậc, rồi dừng và báo user cái gì còn fail.

## 7. Kết thúc

Xác nhận mọi task `[X]`, test pass, kết quả khớp spec (FR/SC) và plan. Báo cáo: outcome, file đổi, kiểm chứng đã chạy, assumption, việc hoãn. Bước tiếp theo: gợi ý `sdd-converge` (đối chiếu code với spec, vá chỗ lệch). Họ sdd-*: specify -> clarify -> plan -> checklist -> tasks -> analyze -> implement -> converge.

Adapted from github/spec-kit (MIT, Copyright GitHub, Inc.); see LICENSE-spec-kit.md. Rewritten for atelier.
