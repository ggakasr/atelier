<!-- atelier project template: TINY profile (ai-simple principles 01 + 06). Vietnamese rule text is from ai-simple; fill the {{...}} blanks. Grow it with atelier-core methodology 01 when the repo grows. -->
# {{TÊN_PROJECT}}

**Stack**: {{STACK — vd Node + Supabase}}. **Mục đích**: {{1 câu}}.

## Quy tắc cho AI agent

1. **LOGIC vs REQUEST**: tôi HỎI ("tại sao", "có nên", paste error không kèm "fix") → trả lời, KHÔNG sửa code. Tôi YÊU CẦU (động từ mệnh lệnh) → làm.
2. **Risk tier** — phân theo khả năng đảo ngược, không theo "có đụng DB không":
   - 🟢 GREEN (git revert được: code/UI/doc/test/file mới/read-only) → làm thẳng, không hỏi.
   - 🟡 YELLOW (đảo ngược có chủ đích: bảng mới, cột nullable, config) → tự làm phương án an toàn + ghi mục `## Assumptions` cuối task. KHÔNG hỏi trước.
   - 🔴 RED (không quay đầu: xóa data, mutate prod, đổi auth đang chạy) → dừng, hỏi ĐÚNG 1 câu gộp kèm phương án khuyến nghị.
3. **Git là sự thật**: đọc `git status` trước khi sửa; KHÔNG stash/reset/checkout đè thay đổi dở của tôi; không xóa branch không rõ nguồn.
4. Trả lời cùng câu hỏi 2 lần → tự ghi nhớ, đừng hỏi lại.

## Bản đồ nhanh

{{3–7 DÒNG: file/thư mục quan trọng + 1 câu mỗi cái — vd `src/index.ts` — entry; `db/` — migrations}}

## Không đụng tới

{{VÙNG CẤM NẾU CÓ — vd file .env, thư mục data/}}

## Atelier

- Docs layout: `docs/app-map/` (ba-spec, design-spec, security-review — canonical, with `covers:` / `last_verified:` frontmatter) · `docs/work-orders/` (work orders + `deferred.md`) · `docs/decision-log/` (append-only per-task logs) · `docs/decisions/` (ADRs).
- Workflow and delegation: skill `atelier-core`. Templates live in the skills (`ba-flow-logic/templates`, `ui-design-logic/design-spec.md.template`, `work-order/templates`, `decision-log/templates`) and in `docs/*/_template*.md` here.
- Test command: `{{vd npm test}}` · Lint: `{{vd npm run lint}}`
