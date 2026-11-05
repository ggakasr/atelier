# Tasks: [FEATURE NAME]

**Input**: `specs/[NNN-slug]/` (plan.md, spec.md bắt buộc; data-model.md, contracts/, research.md tuỳ chọn)
**Tests**: chỉ có task test nếu spec/user yêu cầu. Khi có: viết trước, phải fail trước khi cài đặt.

## Format: `- [ ] T### [P?] [US?] Mô tả kèm đường dẫn file (FR-###)`

- **[P]**: song song được (khác file, không phụ thuộc task chưa xong)
- **[USn]**: thuộc user story nào (chỉ trong phase story)
- Đường dẫn file chính xác; ràng buộc dữ liệu trích nguyên văn từ data-model.md

<!-- Task dưới đây chỉ là MẪU. Thay bằng task thật, không giữ mẫu. -->

## Phase 1: Setup

- [ ] T001 Tạo cấu trúc dự án theo plan.md
- [ ] T002 Khởi tạo [ngôn ngữ] cùng dependency [framework]
- [ ] T003 [P] Cấu hình lint/format

---

## Phase 2: Foundational (chặn mọi user story)

- [ ] T004 [Hạ tầng dùng chung, vd schema + migration]
- [ ] T005 [P] [Auth/routing/middleware dùng chung]
- [ ] T006 Cấu hình error handling và logging

**Checkpoint**: nền tảng xong, bắt đầu làm user story được.

---

## Phase 3: User Story 1 - [Tiêu đề] (Priority: P1) MVP

**Goal**: [story này giao ra cái gì]
**Independent Test**: [cách kiểm chứng riêng story này]

### Tests (chỉ nếu được yêu cầu; viết trước, phải fail)

- [ ] T007 [P] [US1] Contract test cho [endpoint] trong tests/contract/test_[name].py (FR-001)
- [ ] T008 [P] [US1] Integration test cho [hành trình] trong tests/integration/test_[name].py (SC-001)

### Implementation

- [ ] T009 [P] [US1] Tạo model [Entity1] trong src/models/[entity1].py (FR-001; [ràng buộc trích nguyên văn])
- [ ] T010 [P] [US1] Tạo model [Entity2] trong src/models/[entity2].py (FR-002)
- [ ] T011 [US1] Cài [Service] trong src/services/[service].py (phụ thuộc T009, T010)
- [ ] T012 [US1] Cài [endpoint/tính năng] trong src/[vị trí]/[file].py (FR-003)

**Checkpoint**: US1 chạy được và kiểm thử độc lập.

---

## Phase 4: User Story 2 - [Tiêu đề] (Priority: P2)

**Goal**: [...]
**Independent Test**: [...]

- [ ] T013 [P] [US2] [...] trong [đường dẫn file] (FR-0xx)
- [ ] T014 [US2] [...] trong [đường dẫn file]

**Checkpoint**: US1 và US2 đều chạy độc lập.

---

[Thêm phase story theo cùng mẫu]

---

## Phase N: Polish & Cross-Cutting

- [ ] T0xx [P] Cập nhật tài liệu trong docs/
- [ ] T0xx Chạy kiểm chứng theo quickstart.md

---

## Dependencies & Execution Order

- Setup: không phụ thuộc, bắt đầu ngay.
- Foundational: phụ thuộc Setup, **chặn** mọi story.
- Story: phụ thuộc Foundational; xong thì làm song song hoặc theo thứ tự ưu tiên P1 -> P2 -> P3.
- Polish: phụ thuộc các story cần có.
- Trong story: test (nếu có) fail trước -> model -> service -> endpoint -> tích hợp.

## Parallel Example: User Story 1

```text
# Test của US1 cùng lúc (nếu có):
T007 contract test  |  T008 integration test
# Model của US1 cùng lúc:
T009 Entity1        |  T010 Entity2
```

## Implementation Strategy

**MVP first**: Setup -> Foundational -> US1 -> DỪNG và kiểm chứng US1 độc lập -> demo/deploy nếu sẵn sàng.
**Giao tăng dần**: thêm US2, rồi US3; mỗi story thêm giá trị mà không phá story trước.

## Notes

- [P] = khác file, không phụ thuộc. Tránh task mơ hồ, xung đột cùng file, phụ thuộc chéo story làm mất tính độc lập.
- Dừng ở bất kỳ Checkpoint nào để kiểm chứng story.
