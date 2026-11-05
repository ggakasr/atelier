---
name: sdd-plan
description: "Turn an approved spec.md into a technical plan: plan.md with Technical Context and a Constitution Check gate, research.md (Decision/Rationale/Alternatives), data-model.md, contracts/ and a verification-only quickstart.md. Use when the user says 'plan this feature', 'tech plan from the spec', 'lập kế hoạch kỹ thuật từ spec', 'thiết kế kỹ thuật cho tính năng', 'chọn stack cho spec này'. Not for writing the spec (sdd-specify), one agreed change (work-order) or security review (security-logic)."
---

# SDD Plan

`specs/NNN-slug/spec.md` -> `plan.md` + `research.md` + `data-model.md` + `contracts/` + `quickstart.md`. Đây là chỗ **HOW** được phép xuất hiện (stack, cấu trúc, hợp đồng). Chưa sinh `tasks.md`.

## Conventions

- Feature folder `specs/NNN-slug/` (spec.md, plan.md, tasks.md, checklists/). Không rõ folder: lấy `specs/*/` mới nhất hoặc hỏi một lần.
- ID `FR-###` / `SC-###` ổn định, không đánh số lại; plan trích ID thay vì chép lại nội dung.
- Hiến pháp: `docs/constitution.md` (nếu có). Chưa có thì ghi "no constitution" trong Constitution Check và gợi ý `sdd-constitution`.

## Quy trình

1. **Đọc**: `spec.md` (bắt buộc), `docs/constitution.md`, code hiện có liên quan. Spec còn `[NEEDS CLARIFICATION]` hoặc chưa có spec: dừng, quay về `sdd-clarify` / `sdd-specify`.
2. Copy `templates/plan-template.md` -> `plan.md`. Điền **Summary** (yêu cầu chính + hướng kỹ thuật) và **Technical Context**; cái chưa biết ghi `NEEDS CLARIFICATION`.
3. **Constitution Check (cổng 1)**: liệt kê từng nguyên tắc MUST liên quan, ghi pass/fail. Vi phạm không giải trình được: **dừng, báo lỗi**.
4. **Phase 0 -> `research.md`**: mỗi `NEEDS CLARIFICATION`, mỗi dependency, mỗi tích hợp là một việc nghiên cứu (giao `explorer`/`builder` nếu rộng). Mỗi mục ghi: **Decision** (chọn gì) / **Rationale** (vì sao) / **Alternatives considered** (đã cân nhắc gì khác). Xong Phase 0: không còn `NEEDS CLARIFICATION` nào trong Technical Context.
5. **Phase 1**, cần research xong:
   - `data-model.md`: entity, field, quan hệ, luật validate rút từ FR, chuyển trạng thái nếu có. Ràng buộc (độ dài tối đa, bắt buộc/null, enum) viết **chính xác**, vì tasks sẽ trích nguyên văn.
   - `contracts/`: chỉ khi có giao diện ra ngoài (API công khai, lệnh CLI, endpoint, UI contract). Dự án nội bộ thuần thì bỏ qua.
   - `quickstart.md`: **chỉ các bước kiểm chứng chạy được** (điều kiện, lệnh chạy/test, kết quả mong đợi), link sang contracts/data-model thay vì chép lại. **Không** code cài đặt, thân model/service, migration hay bộ test đầy đủ.
6. **Constitution Check (cổng 2)**: chạy lại sau thiết kế. Vi phạm chỉ được giữ nếu ghi vào bảng **Complexity Tracking**:

   | Violation | Why needed | Simpler alternative rejected because |
   |---|---|---|

7. Điền **Project Structure** bằng đường dẫn thật (xoá phương án không dùng, không để nhãn Option).

## Quy tắc

- Mỗi quyết định kỹ thuật truy được về FR/SC hoặc ràng buộc có thật; thêm thứ không ai yêu cầu thì bỏ.
- Rủi ro RED của atelier (DROP, ALTER mất dữ liệu, nới quyền truy cập, đụng dữ liệu prod) gặp trong thiết kế: ghi rõ trong plan và hỏi user một câu, đừng chọn ngầm.
- Đường dẫn tuyệt đối khi thao tác file, đường dẫn tương đối dự án khi viết trong tài liệu.

## Báo cáo cuối

Đường dẫn plan.md, các artifact đã tạo, kết quả hai cổng Constitution, các dòng Complexity Tracking (nếu có). Bước tiếp theo: `sdd-checklist` (soát chất lượng yêu cầu) rồi `sdd-tasks`. Họ sdd-*: specify -> clarify -> plan -> checklist -> tasks -> analyze -> implement -> converge.

Adapted from github/spec-kit (MIT, Copyright GitHub, Inc.); see LICENSE-spec-kit.md. Rewritten for atelier.
