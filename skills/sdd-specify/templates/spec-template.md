# Feature Specification: [FEATURE NAME]

**Feature folder**: `specs/[NNN-slug]/`
**Created**: [DATE]
**Status**: Draft
**Input**: [mô tả tính năng gốc của user, hoặc ID ba-spec nguồn]

## User Scenarios & Testing *(mandatory)*

<!--
  Story xếp theo mức quan trọng. Mỗi story phải ĐỘC LẬP kiểm thử được:
  chỉ làm riêng một story vẫn ra MVP có giá trị.
-->

### User Story 1 - [Tiêu đề ngắn] (Priority: P1)

[Mô tả hành trình người dùng bằng ngôn ngữ thường]

**Why this priority**: [giá trị và lý do xếp mức này]

**Independent Test**: [cách kiểm thử riêng story này, và giá trị nó mang lại]

**Acceptance Scenarios**:

1. **Given** [trạng thái đầu], **When** [hành động], **Then** [kết quả mong đợi]
2. **Given** [trạng thái đầu], **When** [hành động], **Then** [kết quả mong đợi]

---

### User Story 2 - [Tiêu đề ngắn] (Priority: P2)

[Mô tả]

**Why this priority**: [...]

**Independent Test**: [...]

**Acceptance Scenarios**:

1. **Given** [...], **When** [...], **Then** [...]

---

[Thêm story P3... theo cùng mẫu; xoá block thừa]

### Edge Cases

- Chuyện gì xảy ra khi [điều kiện biên]?
- Hệ thống xử lý [tình huống lỗi] thế nào?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST [năng lực cụ thể, testable]
- **FR-002**: Users MUST be able to [tương tác chính]
- **FR-003**: System MUST [yêu cầu dữ liệu / hành vi]
- **FR-004**: System MUST authenticate users via [NEEDS CLARIFICATION: chưa rõ phương thức] *(ví dụ marker, tối đa 3 cái cho cả spec)*

### Key Entities *(chỉ khi có dữ liệu)*

- **[Entity 1]**: [là gì, thuộc tính chính, không nói cách lưu]
- **[Entity 2]**: [là gì, quan hệ với entity khác]

## Success Criteria *(mandatory)*

<!-- Đo được, không nhắc công nghệ, nói bằng kết quả người dùng/kinh doanh. -->

### Measurable Outcomes

- **SC-001**: [vd "Người dùng tạo tài khoản trong dưới 2 phút"]
- **SC-002**: [vd "90% người dùng hoàn tất tác vụ chính ngay lần đầu"]
- **SC-003**: [vd "Giảm 50% ticket hỗ trợ về [X]"]

## Assumptions

- [Mặc định về người dùng, vd "Người dùng có kết nối ổn định"]
- [Mặc định về ranh giới scope, vd "Mobile ngoài scope v1"]
- [Mặc định về dữ liệu/môi trường, vd "Dùng lại hệ thống đăng nhập hiện có"]
- [Phụ thuộc vào hệ thống/dịch vụ có sẵn]
