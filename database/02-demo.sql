SET NAMES utf8mb4;
INSERT INTO tblThanhVien (tenDangNhap,matKhau,hoTen,vaiTro) VALUES
('khach','khach-demo-08:ffb5684975abfaee60cec08468983d793bbef14098d835697cef6bab481b805c','Minh Anh','KH'),
('quanly','quanly-demo-08:50e7e692770a8e985615dc96ec52b4d41ea34ea2bdc6c3c43c0c1c863bf200b1','Hoàng An','QL');
INSERT INTO tblPhim (tenPhim,theLoai,thoiLuong,moTa) VALUES
('Mắt biếc','Tình cảm',117,'Câu chuyện của Ngạn và Hà Lan ở làng Đo Đo.'),
('Song Lang','Chính kịch',101,'Hai cuộc đời gặp nhau giữa sân khấu cải lương Sài Gòn.'),
('Tôi thấy hoa vàng trên cỏ xanh','Gia đình',103,'Tuổi thơ của hai anh em tại một làng quê miền Trung.');
INSERT INTO tblSuatChieu (idPhim,ngayGioChieu,phongChieu,giaVe) VALUES
(1,CURDATE()+INTERVAL 1 DAY+INTERVAL 18 HOUR,'01',80000),
(2,CURDATE()+INTERVAL 1 DAY+INTERVAL 19 HOUR,'02',90000),
(3,CURDATE()+INTERVAL 2 DAY+INTERVAL 16 HOUR,'01',75000),
(1,CURDATE()+INTERVAL 30 DAY+INTERVAL 20 HOUR,'01',85000);
INSERT INTO tblVeMua (idThanhVien,idSuatChieu,ngayMua) VALUES
(1,1,NOW()-INTERVAL 2 DAY),(1,2,NOW()-INTERVAL 1 DAY),(1,1,NOW());
INSERT INTO tblGheVeMua (idVeMua,idSuatChieu,soGhe) VALUES
(1,1,'B3'),(1,1,'B4'),(2,2,'E5'),(3,1,'D4');
