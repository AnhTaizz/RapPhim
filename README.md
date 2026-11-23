# Rạp 08

Ứng dụng demo ba chức năng của Nhóm 08. Khách mua vé theo suất chiếu. Nhân viên quản lý tìm và sửa phim, xem doanh thu theo ngày mua.

## Chạy bằng Docker Compose

Trong PowerShell tại thư mục project, chạy lệnh sao chép cấu hình ở lần đầu.

```powershell
Copy-Item .env.example .env
docker compose up -d --build
docker compose ps
```

Mở [Rạp 08](http://localhost:8088). Có thể đổi `HTTP_PORT` và mật khẩu CSDL trong `.env` trước khi khởi tạo. Docker cần mạng để lấy image và dependency ở lần build đầu. Dừng bằng `docker compose stop`, chạy tiếp bằng `docker compose start`. Volume giữ dữ liệu qua các lần chạy.

| Vai trò | Tên đăng nhập | Mật khẩu mẫu |
|---|---|---|
| Khách hàng | khach | Demo08! |
| Nhân viên quản lý | quanly | Demo08! |

MySQL nạp các tệp trong `database/` khi khởi tạo volume mới. Suất mẫu cách ngày khởi tạo 1, 2 và 30 ngày. Ba vé mẫu trải trên hôm nay và hai ngày trước đó. Khi chạy buổi demo độc lập vào ngày khác, có thể dùng tên project Compose mới và cổng khác để khởi tạo bộ dữ liệu mới.

## Chạy với Tomcat có sẵn

Dùng JDK 17, Maven 3.9, Tomcat 10.1 và MySQL 8. Tạo database `rapphim` dùng utf8mb4, nạp lần lượt `database/01-schema.sql` và `database/02-demo.sql`. Tài khoản JDBC cần SELECT, INSERT và UPDATE trên database. Đặt `DB_URL` (ví dụ `jdbc:mysql://localhost:3306/rapphim`), `DB_USER`, `DB_PASSWORD` trong môi trường Tomcat. Đặt múi giờ MySQL và Tomcat thành UTC+7. Chạy `mvn package`, triển khai `target/ROOT.war` vào thư mục webapps của Tomcat rồi mở trang gốc.

## Kịch bản kiểm tra

Trên dữ liệu demo, chạy `python tests/demo.py` với Python 3. Bài kiểm tra HTTP đăng nhập hai phiên khách riêng, chọn nhiều ghế, tải lại, cùng xác nhận một ghế, đối chiếu số tiền tăng đúng phim, kiểm tra ngày rỗng và ngày đảo. Bài kiểm tra cũng sửa phim, khôi phục thời lượng, kiểm tra trùng tên và gửi yêu cầu quản lý bằng tài khoản khách. Mỗi lần chạy thành công mua thêm ba ghế suất số 1. Biến `DEMO_URL` cho phép đổi địa chỉ khi kiểm tra.

## Đối chiếu báo cáo

- Hình 3.2–3.3. Khách chọn suất chiếu từ bảng, chọn ghế từ sơ đồ 8 hàng A–H, mỗi hàng 10 ghế, rồi xác nhận mua. Tổng tiền cập nhật theo ghế đã chọn. DAO khóa dòng suất, ghi vé cùng tất cả ghế trong một transaction và trả về ngày mua.
- Hình 3.7, Bảng 3.1. Khóa duy nhất theo suất và số ghế ngăn bán trùng. Khóa ngoại ghép bảo đảm ghế và vé cùng suất. Giá nguyên đồng dùng DECIMAL để cộng chính xác. Mật khẩu mẫu lưu dạng PBKDF2-HMAC-SHA256.
- Hình 3.4–3.5. Tìm theo chuỗi con, loại ID đang sửa khi đối chiếu tên. Ràng buộc UNIQUE xử lý cả hai lần cập nhật đồng thời.
- Hình 3.6. Mỗi dòng ghế đóng góp một lần giá của suất. Khoảng lọc gồm cả ngày bắt đầu và ngày kết thúc. Bảng hiển thị thể loại và doanh thu giảm dần, với tổng doanh thu tính từ các dòng kết quả.
