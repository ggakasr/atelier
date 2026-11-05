# Scoring

Chấm 10 tiêu chí trên thang 10. Điểm phản ánh bằng chứng, không phản ánh cảm giác. Lý do: một con số không có evidence đằng sau khiến báo cáo trông chính xác mà thực ra là đoán.

## Quy tắc

1. **Không có evidence = `chưa kiểm tra`**, không ghi số. `N/A` được phép khi tiêu chí không áp dụng (vd hệ thống không có UI). Không bao giờ chấm điểm đoán. Điểm trung bình tính chỉ trên tiêu chí có số, và báo cáo nêu rõ số tiêu chí `chưa kiểm tra`.
2. **"Chạy được" tự nó không vượt 5.** Từ 6 trở lên cần bằng chứng về chất lượng (test, đo, đối chiếu), không chỉ demo thấy chạy.
3. Mỗi điểm ghi một dòng lý do kèm ID finding hoặc đường dẫn evidence.
4. Finding `suspected` không hạ điểm xuống dưới 5 một mình; ghi vào lý do như rủi ro. Chỉ `verified` mới kéo điểm xuống.

## Cap

- Có P0 verified về mất dữ liệu hoặc bypass auth: **Bảo mật <= 4** và **Độ ổn định <= 4**.
- Có P0 verified khác (hệ thống không khởi động, chức năng lõi hỏng hoàn toàn): **Chức năng và quy trình <= 4**.
- Có secret thật lộ trong repo/response: **Bảo mật <= 3**.
- Dữ liệu mock/hardcode được trình bày như dữ liệu thật: **Độ chính xác dữ liệu <= 3**.
- Không có test tự động nào chạy được: **Chất lượng code <= 6**.
- Lane `untested` do không chạy được hệ thống: tiêu chí liên quan là `chưa kiểm tra`, không phải điểm thấp.

## Anchor (2 / 5 / 8 / 10)

| Tiêu chí | 2 | 5 | 8 | 10 |
|---|---|---|---|---|
| Kiến trúc | Module rối, phụ thuộc vòng, không rõ ranh giới, lệch tài liệu | Có cấu trúc nhưng trùng lặp, coupling cao, vài chỗ lệch tài liệu | Ranh giới rõ, luồng dữ liệu nhất quán, trùng lặp nhỏ, tài liệu khớp | Rõ, đơn giản, dễ thay thế từng phần, tài liệu khớp, đã chứng minh qua thay đổi thật |
| Chất lượng code | Không test, lỗi lint/type nhiều, copy-paste, nuốt lỗi | Chạy được, test thưa, lint sạch một phần | Test phủ luồng chính chạy xanh, lint/type sạch, xử lý lỗi nhất quán | Test phủ rộng gồm edge, CI xanh, code dễ đọc, nợ kỹ thuật có theo dõi |
| Độ bao phủ dữ liệu | Dưới ~30% thực thể chuẩn có dữ liệu thật | ~50-70%, nhiều field rỗng, vài nguồn không phản hồi | ~90% thực thể, field quan trọng đầy, nguồn đều phản hồi | Đủ thực thể chuẩn, field đầy, khoảng thời gian phủ đủ, thiếu gì cũng được ghi nhận |
| Độ chính xác dữ liệu | Sai/mock/trùng nhiều, không đối chiếu được | Mẫu đối chiếu sai ~20-30% hoặc có dữ liệu cũ không cờ | Mẫu khớp ~95%+, lỗi nhỏ đã biết | Mẫu khớp gần như tuyệt đối, có kiểm tra tự động, không mock/trùng |
| UI | Vỡ layout, không nhất quán, thiếu state chính | Dùng được, lệch nhất quán, vài state thiếu, responsive yếu | Nhất quán, đủ state, responsive dùng được | Nhất quán toàn hệ thống, mọi state, responsive + a11y cơ bản tốt, đã kiểm trên nhiều viewport |
| UX | Người mới không hoàn thành tác vụ chính | Hoàn thành được nhưng nhiều bước thừa, phản hồi mơ hồ | Tác vụ chính ít bước, phản hồi rõ, lỗi dễ hiểu | Tác vụ trôi chảy, ngăn lỗi trước khi xảy ra, người mới không cần hướng dẫn |
| Chức năng và quy trình | Chức năng chính hỏng hoặc "lưu giả" | Luồng chính chạy, edge/invalid input hỏng vài chỗ | Mọi chức năng chính PASS, edge xử lý đúng, lỗi nhỏ P2-P3 | Mọi chức năng + edge + luồng đầu-cuối PASS, không lưu giả, dữ liệu nhất quán sau reload |
| Độ ổn định | Crash/treo thường xuyên, mất dữ liệu | Ổn định khi dùng nhẹ, lỗi khi dữ liệu lớn/mất kết nối | Chịu được dữ liệu lớn, phục hồi sau restart, không crash trong test | Phục hồi tự động, failure-injection đã chạy và pass, không mất dữ liệu |
| Hiệu năng | Mỗi thao tác chính > ~5s hoặc không đo được trong khi có dấu hiệu chậm | Số đo chấp nhận được với dữ liệu nhỏ, chậm rõ khi nhiều record | p95 API và page load trong ngưỡng hợp lý với dữ liệu lớn hơn thường | Số đo tốt kể cả dữ liệu lớn, có budget/giám sát, bottleneck đã biết và xử lý |
| Bảo mật | Auth bypass, secret lộ, injection khả thi | Auth có nhưng thiếu kiểm quyền vài chỗ, dependency lỗi thời | Authn/authz đúng theo vai, không secret lộ, injection chặn, dependency sạch lỗi nghiêm trọng | Defense in depth, kiểm quyền ở server cho mọi endpoint, secret quản lý đúng, đã test chéo vai trò |

Giữa các anchor nội suy (3-4, 6-7, 9). Cần đúng điều kiện của anchor đó mới được điểm đó; thiếu một điều kiện thì xuống mức dưới.
