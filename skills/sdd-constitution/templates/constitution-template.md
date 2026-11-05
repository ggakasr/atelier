<!--
Sync Impact Report (ghi chú để người duyệt, gỡ trước khi commit)
Version change: [OLD] -> [NEW]
Modified principles: [tên cũ -> tên mới, hoặc none]
Added sections: [...]
Removed sections: [...]
Propagate-check (chỉ kiểm): plan-template [ok/lệch], spec-template [ok/lệch], tasks-template [ok/lệch]
Deferred TODOs: [...]
-->

# [PROJECT_NAME] Constitution

## Core Principles

### I. [PRINCIPLE_1_NAME]

[Luật không thương lượng, viết bằng MUST/SHOULD kiểm chứng được. Vd: "Mọi module MUST có test tự động chạy được bằng một lệnh."]

**Rationale**: [vì sao, nếu không hiển nhiên]

### II. [PRINCIPLE_2_NAME]

[Luật. Vd: "Mọi giao diện công khai MUST ghi rõ định dạng vào/ra; lỗi MUST đi ra stderr."]

**Rationale**: [...]

### III. [PRINCIPLE_3_NAME]

[Luật. Vd: "Test MUST được viết và thấy fail trước khi cài đặt."]

**Rationale**: [...]

### IV. [PRINCIPLE_4_NAME]

[Luật. Có thể thêm hoặc bớt nguyên tắc theo nhu cầu dự án.]

**Rationale**: [...]

## [SECTION_2_NAME]

[Ràng buộc bổ sung: yêu cầu công nghệ, bảo mật, hiệu năng, tuân thủ, quy tắc deploy. Dùng ngưỡng cụ thể.]

## [SECTION_3_NAME]

[Quy trình làm việc: yêu cầu review, cổng chất lượng, duyệt deploy. Risk tier GREEN/YELLOW/RED của atelier áp dụng.]

## Governance

- **Thẩm quyền**: constitution này ưu tiên hơn các thực hành khác; xung đột thì constitution thắng.
- **Sửa đổi**: [ai đề xuất, ai duyệt, kế hoạch migrate khi đổi nguyên tắc]
- **Versioning**: MAJOR = xoá/định nghĩa lại nguyên tắc không tương thích; MINOR = thêm hoặc mở rộng đáng kể; PATCH = làm rõ câu chữ.
- **Tuân thủ**: [PR/review MUST kiểm nguyên tắc nào; vi phạm phải giải trình trong bảng Complexity Tracking của plan]

**Version**: [X.Y.Z] | **Ratified**: [YYYY-MM-DD] | **Last Amended**: [YYYY-MM-DD]
