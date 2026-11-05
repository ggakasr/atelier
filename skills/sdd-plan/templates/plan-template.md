# Implementation Plan: [FEATURE]

**Feature folder**: `specs/[NNN-slug]/` | **Date**: [DATE] | **Spec**: [spec.md](spec.md)

## Summary

[Yêu cầu chính từ spec (trích FR-###) + hướng kỹ thuật từ research]

## Technical Context

**Language/Version**: [vd Python 3.12, hoặc NEEDS CLARIFICATION]
**Primary Dependencies**: [vd FastAPI, hoặc NEEDS CLARIFICATION]
**Storage**: [nếu có, vd PostgreSQL, files]
**Testing**: [vd pytest, hoặc NEEDS CLARIFICATION]
**Target Platform**: [vd Linux server, iOS 15+, hoặc NEEDS CLARIFICATION]
**Project Type**: [library / cli / web-service / mobile-app / desktop-app ...]
**Performance Goals**: [theo miền, liên kết SC-###, hoặc NEEDS CLARIFICATION]
**Constraints**: [vd offline-capable, giới hạn bộ nhớ]
**Scale/Scope**: [vd 10k người dùng, 50 màn hình]

## Constitution Check

*GATE: phải qua trước Phase 0 research. Kiểm lại sau Phase 1 design.*

| Principle (docs/constitution.md) | Cổng 1 (trước research) | Cổng 2 (sau design) | Ghi chú |
|---|---|---|---|
| [tên nguyên tắc MUST] | pass / fail | pass / fail | [...] |

## Project Structure

### Documentation (feature này)

```text
specs/[NNN-slug]/
├── spec.md
├── plan.md           # file này
├── research.md       # Phase 0
├── data-model.md     # Phase 1
├── quickstart.md     # Phase 1 (chỉ bước kiểm chứng)
├── contracts/        # Phase 1 (nếu có giao diện ngoài)
├── checklists/
└── tasks.md          # do sdd-tasks tạo, KHÔNG tạo ở đây
```

### Source Code (repository root)

```text
# Thay bằng cấu trúc thật của feature, đường dẫn thật. Không để nhãn Option.
src/
tests/
```

**Structure Decision**: [chọn cấu trúc nào, trỏ tới thư mục thật ở trên]

## Complexity Tracking

> Chỉ điền khi Constitution Check có vi phạm cần giải trình. Không có thì xoá section này.

| Violation | Why needed | Simpler alternative rejected because |
|-----------|------------|--------------------------------------|
| [vd dự án thứ 4] | [nhu cầu hiện tại] | [vì sao 3 dự án không đủ] |
