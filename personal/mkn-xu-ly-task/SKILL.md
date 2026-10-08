---
name: mkn-xu-ly-task
description: "Quy trình xử lý một task/lỗi của MKN v3 theo cách của chủ kho (thu/Hà): nhận ảnh + mô tả từ web dev → tìm nguyên nhân → đề xuất giải thuật chờ gật → nhánh mới từ develop → test đầy đủ (ma trận dữ liệu, ca API/UI, subagent chạy song song) → báo cáo tổng thể → draft PR chỉ khi người dùng bảo dùng được. Dùng khi người dùng gửi một task kiểu 'trạng thái/hiển thị/số liệu sai' kèm ảnh, hoặc nói 'làm theo quy trình', 'có đầy đủ test như vừa rồi'. KHÔNG dùng cho câu hỏi giải thích, đổi nhỏ một dòng đã rõ."
---

# Xử lý task MKN — quy trình của chủ kho

Luật kho (`CLAUDE.md`, `AGENTS.md`) luôn thắng skill này. Nhắc lại ba luật hay vi phạm:
**không tự commit/push**, **không đụng CSDL prod/máy chủ thật** (tệp `vaap` soạn và kiểm ở
máy mình, đưa lệnh cho chủ kho chạy), **mã tên tiếng Anh · chú thích tiếng Việt, tối đa 6 dòng**.

## 0. Nói rõ đang dùng skill này
Mở đầu câu trả lời đầu tiên: "Dùng skill `mkn-xu-ly-task`" để chủ kho chặn kịp nếu chọn sai.

## 1. Hiểu task (không sửa gì)
1. Đọc ảnh + mô tả: trang nào, vai trò nào, mã tàu/sự vụ, **đúng thì phải ra sao**.
2. Tìm nguyên nhân trong mã. Đối chiếu nguồn thẩm quyền (`01-schema.sql`, `code/contract/`,
   `docs/01-mo-hinh-du-lieu.html`). Phân biệt: lỗi **mã** · lỗi **dữ liệu cũ** · lỗi **thiết kế**.
3. Trả lời ngắn: nguyên nhân (đã đối chiếu mã) + đề xuất giải thuật + câu hỏi chọn hướng,
   kèm khuyến nghị. **Chờ người dùng gật** mới sang bước 2. Không có dữ liệu thật trên máy:
   không đoán số ca, nói thẳng "chưa biết" và đề xuất tệp xem trước chỉ đọc cho chủ kho chạy.

## 2. Nhánh
`git fetch origin develop` → `git switch -c <fix|feat>/<tên-ca> origin/develop` →
`git branch --unset-upstream` (khỏi lỡ push vào develop). Gốc là **develop**, không phải main.
Thay đổi chưa commit của người dùng (`AGENTS.md`, `.codex/`, `env.zip`) để nguyên, không add.

## 3. Cài đặt môi trường test (local, không prod)
Theo memory `may-ha-cach-chay-mkn`: `docker start mkn-postgres` (5433), be-core cổng 3001,
fe-admin 5173. Kiểm PID giữ cổng trước. Script từ chối chạy khi host ≠ localhost.
Dữ liệu test mang **tiền tố riêng** (vd `TEST-<TÊN>-`) để dọn được, không chạy `seed.js`.

## 4. Thiết kế bộ test TRƯỚC khi sửa
Viết vào `code/qa-runner/<tên-ca>/` (mẫu: nhánh `fix/alert-penalty-popup`, thư mục
`code/qa-runner/popup-bien-ban/`: `seed.mjs`, `api-test.mjs`, `ui-test.mjs`, `ma-tran-ca.json`,
`gen_report.py`, `mau-bao-cao.md`).
- **Ma trận dữ liệu**: mỗi dòng là một ca nghiệp vụ khác nhau — ca đúng, ca biên, ca mơ hồ,
  ca ngoài phạm vi tài khoản, ca đã có sẵn, ca dữ liệu thiếu, ca xung đột trạng thái.
- **Ma trận ca**: ID · mục tiêu + kết quả mong đợi · dữ liệu · tài khoản · loại (tự động/thủ công)
  · ưu tiên P1/P2/P3. Kết quả: PASS · FAIL · GHI NHẬN (chỉ mô tả) · CHƯA CHẠY.
- Luôn có ca **phân quyền/phạm vi** (`scopeWhere`), ca **lùi/hoàn tác**, ca **chạy lại hai lần
  (idempotent)**, ca **hồi quy** cho thứ lân cận.
- **Đỏ trước, xanh sau**: chạy bộ test trên mã/dữ liệu CHƯA sửa, ghi nhận đỏ; sửa; chạy lại xanh.
- **Mutation**: gỡ bản sửa (hoặc phá có chủ đích) → test phải FAIL đúng chỗ → khôi phục
  (so md5 trước/sau).
- Với tệp `vaap` (SQL): chạy trên CSDL local bằng `psql`, kiểm SQL thuần chạy được trong
  Adminer (không `;` trong chú thích cuối tệp), có tệp **xem trước (chỉ đọc, ROLLBACK)**,
  **áp (một giao dịch)**, **soát (cột `dat` toàn `t`)**, **lùi**.

- **Đóng gói để người khác chạy lại**: viết `chay-sql.sh` (dựng bản sao `mkn_gc_*` bằng `pg_dump`, seed, chạy từng bước, in PASS/FAIL, mã thoát) và `chay-api-ui.ps1` (bật be-core + fe-admin trên cổng riêng, chạy ca, TẮT đúng tiến trình mình bật; Vite phải khởi động bằng PowerShell). Hai script từ chối chạy lên CSDL không phải `mkn_gc_*`. Chạy chính hai script này trước khi báo kết quả, vì chúng chạy lại được test sau mỗi lần sửa.
- **Test đo hai mặt**: ca nguy hiểm (áp nhầm) VÀ ca đúng bị chặn oan (recall). Bộ lọc đọc chữ tự do không phủ hết ngữ nghĩa: để người duyệt mắt làm chốt chặn, đừng thêm từ khoá mãi.
- **Đặt tên theo `growth/rules/04-dat-ten.md` ngay từ đầu**: cột, bảng, biến, tệp mới viết bằng tiếng Anh. Mã cũ cùng thư mục dùng tên Việt không phải cớ cho mã mới.

## 5. Subagent
Tối đa 4 chạy nền cùng lúc. Chia theo tầng độc lập, mỗi agent có brief tự đủ (nó không thấy
hội thoại): (a) test be-core/SQL, (b) ca API, (c) ca giao diện Playwright, (d) review đối
kháng — đọc diff tìm lỗi, chạy mutation. Quy định trong brief: không commit, không đụng prod,
ghi kết quả JSON vào thư mục ca, báo cả ca FAIL lẫn ca không chạy được và vì sao.
**Kiểm lại kết quả agent bằng cách chạy lại ca then chốt / đối chiếu mã**, đừng chép báo cáo.

## 6. Báo cáo tổng thể
`docs/draft/plan/<yyyy-mm-dd>-bao-cao-kiem-thu-<tên-ca>.md` (thư mục này LÊN kho). Dòng đầu:
`**Người tạo:** claude · **Chủ sở hữu:** thu · **Ai xử lý tiếp:** … · <ngày>`. Cấu trúc:
1 Tóm tắt (bảng kết quả theo tầng + ba phát hiện chính) · 2 Phạm vi thay đổi (đã commit/chưa) ·
3 Môi trường · 4 Ma trận dữ liệu · 5 Ca test + kết quả (số liệu SINH TỰ ĐỘNG từ JSON, không
gõ tay) · 6 Lỗi tìm được trong chính thay đổi · 7 Test hỏng sẵn có · 8 Lỗi có sẵn chưa sửa ·
9 **Hạn chế đã biết và rủi ro** (mỗi dòng: bằng chứng, mức, thuộc "thay đổi này"/"có sẵn",
ai quyết) · 10 Cần quyết định. Trung thực: ca chưa chạy ghi "chưa kiểm", không làm tròn.
Ảnh chụp vào `.../anh/`, nhưng đừng ôm quá nặng.

## 6b. Tài liệu cho người review
Trong thư mục test: `README.md` (cần có gì, 2 lệnh chạy, thử tay, dọn dẹp) và `CA-TEST.md` (sinh tự động từ ma trận và kết quả, kèm "thử tay" 5–7 việc). Mô tả PR ở `docs/draft/plan/<ngày>-mo-ta-pr-<tên>.md`: vấn đề, nguyên nhân, giải pháp, cách review (thứ tự đọc), cách thử, kết quả đỏ→xanh, rủi ro, cần quyết định, việc chủ kho làm tay, checklist (đừng đánh [x] mục chưa kiểm).

## 7. Chốt
- Báo kết quả cho người dùng, **dừng**. Commit chỉ khi được yêu cầu thẳng (thông điệp tiếng
  Việt, đuôi Co-Authored-By theo system-reminder).
- **Draft PR chỉ sau khi người dùng nói "dùng được"**: người dùng đã duyệt → push (hỏi trước)
  → `gh pr create --draft --base develop`, mô tả PR ở `docs/draft/plan/<ngày>-mo-ta-pr-<tên>.md`
  gồm: vấn đề, giải pháp, kết quả đỏ→xanh, hạn chế đã biết, cách kiểm lại, việc chủ kho phải làm
  tay (chạy `vaap` trên prod). Đuôi PR theo system-reminder.
- Lên web dev theo thẻ `v*` + GHCR là việc của người dùng/quản trị máy chủ.
