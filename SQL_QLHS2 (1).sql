CREATE DATABASE QL_HS4
GO

USE QL_HS4
GO

--SELECT * FROM ADMIN

CREATE TABLE ADMIN(
    Ma_AD CHAR(10) PRIMARY KEY,
	Ten NVARCHAR(50),
	MK_AD VARCHAR(50) NOT NULL
);
GO 

INSERT INTO ADMIN(Ma_AD, Ten, MK_AD) VALUES
('admin', N'ADMIN', '2')
CREATE TABLE MONHOC(
    Ma_MON CHAR(10) PRIMARY KEY,
	Tenmon NVARCHAR(50) UNIQUE,
	Sotiet_mt INT NOT NULL,
);
GO
sp_columns ADMIN;
CREATE TABLE HOCKY(
    Ma_HK CHAR(20) PRIMARY KEY,
	Ten_HK VARCHAR(50) NOT NULL,
	Nam_hoc VARCHAR(50)
);
GO

CREATE TABLE GIAOVIEN(
    Ma_GV CHAR(10) PRIMARY KEY,
	Hoten_GV NVARCHAR(50) NOT NULL,
	Ngaysinh_GV DATETIME NOT NULL,
	Gioitinh_GV NVARCHAR(5) ,
	SDT_GV VARCHAR(50) ,
	email_GV VARCHAR(50) ,
	Diachi_GV NVARCHAR(100),
	Matkhau_GV VARCHAR(50) NOT NULL,
	Ma_MON CHAR(10) CONSTRAINT GIAOVIEN_Ma_MON_FK FOREIGN KEY (Ma_MON) REFERENCES MONHOC(Ma_MON),
);
GO

CREATE TABLE LOPHOC(
    Ma_LOP CHAR(10) PRIMARY KEY,
	Tenlop VARCHAR(50) NOT NULL,
	Khoi INT NOT NULL,
	Namhoc VARCHAR(50),
	GVCN CHAR(10) CONSTRAINT LOPHOC_Ma_GV_FK FOREIGN KEY (GVCN) REFERENCES GIAOVIEN(Ma_GV),
);
GO


CREATE TABLE HOCSINH(
    Ma_HS CHAR(10)  PRIMARY KEY,
	Hoten_HS NVARCHAR(50) NOT NULL,
	Ngaysinh DATETIME NOT NULL,
	Gioitinh NVARCHAR(5),
	Diachi NVARCHAR(100),
	Dantoc NVARCHAR(50),
	SDT_HS CHAR(50),
	email_HS VARCHAR(50),
	Matkhau_HS VARCHAR(50) NOT NULL,
	Ma_LOP CHAR(10) CONSTRAINT HOCSINH_Ma_LOP_FK FOREIGN KEY (Ma_LOP) REFERENCES LOPHOC(Ma_LOP), 
);
GO

CREATE TABLE THOIKHOABIEU(
    Ma_TKB CHAR(20) PRIMARY KEY,
    Ma_LOP CHAR(10) CONSTRAINT TKB_Ma_LOP_FK FOREIGN KEY (Ma_LOP) REFERENCES LOPHOC(Ma_LOP), 
	Ma_MON CHAR(10) CONSTRAINT TKB_Ma_MON_FK FOREIGN KEY (Ma_MON) REFERENCES MONHOC(Ma_MON), 
	Ma_GV CHAR(10) CONSTRAINT TKB_Ma_GV_FK FOREIGN KEY (Ma_GV) REFERENCES GIAOVIEN(Ma_GV), 
	Ma_HK CHAR(20) CONSTRAINT TKB_Ma_HK_FK FOREIGN KEY (Ma_HK) REFERENCES HOCKY(Ma_HK), 
    
	Thu NVARCHAR(50) NOT NULL,
	Tiet_batdau INT NOT NULL,
	Sotiet INT NOT NULL,
	CHECK (Tiet_batdau >= 1 AND Tiet_batdau <= 10),
	CHECK (Sotiet IN (1, 2))
);
GO

CREATE TABLE DIEM(
    Ma_HS CHAR(10) CONSTRAINT DIEM_Ma_HS_FK FOREIGN KEY (Ma_HS) REFERENCES HOCSINH(Ma_HS),
	Ma_MON CHAR(10) CONSTRAINT DIEM_Ma_MON_FK FOREIGN KEY (Ma_MON) REFERENCES MONHOC(Ma_MON), 
	Ma_HK CHAR(20) CONSTRAINT DIEM_Ma_HK_FK FOREIGN KEY (Ma_HK) REFERENCES HOCKY(Ma_HK),
	Loai_Diem NVARCHAR(20),
	Diem FLOAT NOT NULL CHECK (Diem BETWEEN 0 AND 10),
	CHECK (Loai_Diem IN (N'Miệng', N'15 phút', N'Một tiết', N'Giữa kỳ', N'Cuối kỳ')),
	PRIMARY KEY (Ma_HS, Ma_MON, Ma_HK, Loai_Diem)
);
GO

CREATE TABLE HANHKIEM(
    Ma_HS CHAR(10) CONSTRAINT HANHKIEM_Ma_HS_FK FOREIGN KEY (Ma_HS) REFERENCES HOCSINH(Ma_HS),
	Ma_HK CHAR(20) CONSTRAINT HANHKIEM_Ma_HK_FK FOREIGN KEY (Ma_HK) REFERENCES HOCKY(Ma_HK), 
	Xep_loai NVARCHAR(50) NOT NULL
        CHECK (Xep_loai IN (N'Tốt', N'Khá', N'Trung bình', N'Yếu')),
	PRIMARY KEY(Ma_HS, Ma_HK)
)

DELETE FROM DIEM
WHERE Ma_MON = 'THEDUC';

ALTER TABLE DIEM
ADD CONSTRAINT CK_DIEM_KhongTheDuc
CHECK (Ma_MON <> 'THEDUC');

CREATE TABLE KQ_THECHAT (
    Ma_HS CHAR(10) FOREIGN KEY REFERENCES HOCSINH(Ma_HS),
    Ma_MON CHAR(10) FOREIGN KEY REFERENCES MONHOC(Ma_MON),
    Ma_HK CHAR(10),
    Ket_qua NVARCHAR(20) CHECK (Ket_qua IN (N'Đạt', N'Không đạt')),
    PRIMARY KEY (Ma_HS, Ma_MON, Ma_HK),
    CONSTRAINT CK_THECHAT_ChiTheDuc CHECK (Ma_MON = 'THEDUC')
);

CREATE TABLE KQ_NAMHOC (
    Ma_HS CHAR(10) CONSTRAINT FK_KQNH_HS FOREIGN KEY (Ma_HS) REFERENCES HOCSINH(Ma_HS),
    NamHoc CHAR(9), 
    DTB_CN FLOAT,   
    HocLuc NVARCHAR(20), -- Tốt, Khá, Đạt, Chưa đạt
    PRIMARY KEY (Ma_HS, NamHoc)
);
-- Xóa dữ liệu cũ nếu muốn chạy lại
DELETE FROM KQ_NAMHOC;

-- Chèn dữ liệu trung bình cả năm
INSERT INTO KQ_NAMHOC (Ma_HS, NamHoc, DTB_CN, HocLuc)
SELECT 
    HS.Ma_HS,
    SUBSTRING(HK.Nam_hoc, 1, 9) AS NamHoc,  -- lấy năm học từ HOCKY
    CAST(AVG(D.Diem) AS DECIMAL(3,2)) AS DTB_CN,
    CASE 
        WHEN AVG(D.Diem) >= 8.0 THEN N'Tốt'
        WHEN AVG(D.Diem) >= 6.5 THEN N'Khá'
        WHEN AVG(D.Diem) >= 5.0 THEN N'Đạt'
        ELSE N'Chưa đạt'
    END AS HocLuc
FROM HOCSINH HS
JOIN DIEM D ON HS.Ma_HS = D.Ma_HS
JOIN HOCKY HK ON D.Ma_HK = HK.Ma_HK
JOIN MONHOC MH ON D.Ma_MON = MH.Ma_MON
WHERE MH.Ma_MON NOT IN ('THEDUC','GVCN','SHDC')
GROUP BY HS.Ma_HS, SUBSTRING(HK.Nam_hoc, 1, 9)
ORDER BY HS.Ma_HS;



-- SELECT * FROM KQ_NAMHOC
-- SELECT * FROM MONHOC
INSERT INTO MONHOC(Ma_MON, Tenmon, Sotiet_mt) VALUES
('TOAN', N'Toán', 4),
('VATLY', N'Vật lý', 3),
('HOA', N'Hóa học', 3),
('NGUVAN', N'Ngữ văn', 4),
('LICHSU', N'Lịch sử', 2),
('DIALY', N'Địa lý', 1),
('SINHHOC', N'Sinh học', 2),
('TIENGANH', N'Tiếng anh', 4),
('GDCD', N'Giáo dục công dân', 1),
('CONGNGHE', N'Công nghệ', 1),
('GDQP', N'Giáo dục quốc phòng', 2),
('THEDUC', N'Thể dục', 2),
('TINHOC', N'Tin học', 2), 
('GVCN', N'Họp GVCN', 2),
('SHDC', N'Sinh hoạt dưới cờ', 1)

-- SELECT * FROM HOCKY
INSERT INTO HOCKY(Ma_HK, Ten_HK, Nam_hoc) VALUES 
('HK2526_1', 'HKI', '2025-2026'),
('HK2526_2', 'HKII', '2025-2026')

INSERT INTO HOCKY(Ma_HK, Ten_HK, Nam_hoc) VALUES 
('HK2627_1', 'HKI', '2026-2027'),
('HK2627_2', 'HKII', '2026-2027'),
('HK2728_1', 'HKI', '2027-2028'),
('HK2728_2', 'HKII', '2027-2028'),
('HK2425_1', 'HKI', '2024-2025'),
('HK2425_2', 'HKII', '2024-2025')

-- SELECT * FROM GIAOVIEN
SET DATEFORMAT dmy;  
INSERT INTO GIAOVIEN(Ma_GV, Hoten_GV, Ngaysinh_GV, Gioitinh_GV, SDT_GV, email_GV, Diachi_GV, Matkhau_GV, Ma_MON) VALUES
('GV00001', N'Nguyễn Chí Bảo', '10-04-1997', N'Nam', '0238493843', 'chibao123@gmail.com', 'TP HCM', 'CHIBAO123', 'TOAN'),
('GV00002', N'Phan Lê Thi', '23-07-1993', N'Nữ', '0524394873', 'lethi123@gmail.com', 'Tây Ninh', 'LETHI123', 'LICHSU'),
('GV00003', N'Đăng Kiêm Lực', '05-09-2000', N'Nam', '0945388321', 'kiemluc123@gmail.com', 'Cà Mau', 'KIEMLUC123', 'GDQP'),
('GV00004', N'Phạm Thanh Điền', '28-12-1991', N'Nam', '0764839462', 'thanhdien123@gmail.com', 'Hà Nội', 'THANHDIEN123', 'CONGNGHE'),
('GV00005', N'Trần Văn Nghĩa', '23-02-1999', N'Nam', '0245673928', 'vannghi123@gmail.com', 'Bắc Ninh', 'VANNGHIA123', 'DIALY'),
('GV00006', N'Trần Hồng Thư', '09-04-1992', N'Nữ', '0943988752', 'hongthu123@gmail.com', 'Đồng Nai', 'HONGTHU123', 'VATLY'),
('GV00007', N'Lê Văn Tài', '18-03-1997', N'Nam', '0325983792', 'vantai123@gmail.com', 'TP HCM', 'VANTAI123', 'HOA'),
('GV00008', N'Ngô Thanh Trúc', '13-10-2001', N'Nữ', '0342873929', 'thanhtruc123@gmail.com', 'Cần Thơ', 'THANHTRUC123', 'NGUVAN'),
('GV00009', N'Phạm Thị Hiền', '20-12-2000', N'Nữ', '0328292935', 'thihien123@gmail.com', 'An Giang', 'THIHIEN123', 'GDCD'), 
('GV00010', N'Nguyễn Tiến Linh', '08-09-2002', N'Nam', '0393898928', 'tienlinh123@gmail.com', 'TP HCM', 'TIENLINH123', 'TIENGANH'),
('GV00011', N'Lương Thế Vinh', '16-06-1993', N'Nam', '0248378893', 'thevinh123@gmail.com', 'Ninh Bình', 'THEVINH123', 'SINHHOC'),
('GV00012', N'Nguyễn Ngọc Mỹ Trang', '03-05-2002', N'Nữ', '0392285038', 'mytrang123@gmail.com', 'Lâm Đồng', 'MYTRANG123', 'TINHOC'),
('GV00013', N'Nguyễn Hữu Cường', '19-11-1996', N'Nam', '0439328839', 'huucuong@gmail.com', 'Vĩnh Long', 'HUUCUONG123', 'THEDUC')

SET DATEFORMAT dmy;  
INSERT INTO GIAOVIEN(Ma_GV, Hoten_GV, Ngaysinh_GV, Gioitinh_GV, SDT_GV, email_GV, Diachi_GV, Matkhau_GV, Ma_MON) VALUES
('GV99999', N'Nhà Trường', '29-01-1990', N'Nam', '0999999999', 'truongthpt@gmail.com', 'TP HCM', 'NHATRUONG123', 'SHDC')
SELECT 
    Ma_GV,
    Hoten_GV,
    FORMAT(Ngaysinh_GV, 'dd/MM/yyyy') AS Ngaysinh_GV,
    Gioitinh_GV,
    SDT_GV,
    email_GV,
    Diachi_GV
FROM GIAOVIEN;


-- SELECT * FROM LOPHOC
INSERT INTO LOPHOC(Ma_LOP, Tenlop, Khoi, Namhoc, GVCN) VALUES
('L10A1', '10A1', 10, '2025-2026', 'GV00004'),
('L10A2', '10A2', 10, '2025-2026', 'GV00008'),
('L11A1', '11A1', 11, '2025-2026', 'GV00002'),
('L11A2', '11A2', 11, '2025-2026', 'GV00010'),
('L12A1', '12A1', 12, '2025-2026', 'GV00003'),
('L12A2', '12A2', 12, '2025-2026', 'GV00009')



-- SELECT * FROM HOCSINH
-- Ma_HS giải thích mã hs : HS25(học sinh vào trường niên khóa 2025); 1 ( lớp A1 ) ; 0001(số thứ tự trong mã học sinh) 
SET DATEFORMAT dmy; 
INSERT INTO HOCSINH(Ma_HS, Hoten_HS, Ngaysinh, Gioitinh, Diachi, Dantoc, SDT_HS, email_HS, Matkhau_HS, Ma_LOP) VALUES
('HS2510001', N'Nguyễn Tiến Đạt', '02/04/2010', N'Nam', 'Tây Ninh', 'Kinh', '0325875058', 'hs2510001@gmail.com', '02042010', 'L10A1'),
('HS2510002', N'Trần Tấn Phát', '28-08-2010', N'Nam', 'TP HCM', 'Kinh', '0329393978', 'hs2510002@gmail.com', '28082010', 'L10A1'),
('HS2510003', N'Lê Mỹ Hương', '04-05-2010', N'Nữ', 'TP HCM', 'Kinh', '0839392339', 'hs2510003@gmail.com', '04052010', 'L10A1'),
('HS2510004', N'Ngô Thanh Mẫn', '19-11-2010', N'Nam', 'Tây Ninh', 'Tày', '0293929425', 'hs2510004@gmail.com', '19112010', 'L10A1')

SET DATEFORMAT dmy; 
INSERT INTO HOCSINH(Ma_HS, Hoten_HS, Ngaysinh, Gioitinh, Diachi, Dantoc, SDT_HS, email_HS, Matkhau_HS, Ma_LOP) VALUES
('HS2510005', N'Phạm Thị Mai', '15/01/2010', N'Nữ', N'Hà Nội', N'Kinh', '0987654321', 'hs2510005@gmail.com', '15012010', 'L10A1'),
('HS2510006', N'Lê Văn Hoàng', '22/03/2010', N'Nam', N'Đà Nẵng', N'Kinh', '0912345678', 'hs2510006@gmail.com', '22032010', 'L10A1'),
('HS2510007', N'Trần Thị Lan', '30/07/2010', N'Nữ', N'Hải Phòng', N'Kinh', '0978123456', 'hs2510007@gmail.com', '30072010', 'L10A1'),
('HS2510008', N'Nguyễn Đức Anh', '12/09/2010', N'Nam', N'Cần Thơ', N'Kinh', '0965432198', 'hs2510008@gmail.com', '12092010', 'L10A1'),
('HS2510009', N'Hoàng Thị Hà', '05/12/2010', N'Nữ', N'Đồng Nai', N'Kinh', '0932165498', 'hs2510009@gmail.com', '05122010', 'L10A1'),
('HS2510010', N'Vũ Minh Khôi', '18/02/2010', N'Nam', N'Đồng Nai', N'Kinh', '0945678321', 'hs2510010@gmail.com', '18022010', 'L10A1'),
('HS2510011', N'Đặng Thị Ngọc', '25/04/2010', N'Nữ', N'Tây Ninh', N'Kinh', '0923456789', 'hs2510011@gmail.com', '25042010', 'L10A1'),
('HS2510012', N'Bùi Văn Đức', '08/06/2010', N'Nam', N'Đồng Tháp', N'Kinh', '0918765432', 'hs2510012@gmail.com', '08062010', 'L10A1'),
('HS2510013', N'Lý Thị Hồng', '14/10/2010', N'Nữ', N'An Giang', N'Kinh', '0987123456', 'hs2510013@gmail.com', '14102010', 'L10A1'),
('HS2510014', N'Mai Văn Tài', '03/11/2010', N'Nam', N'An Giang', N'Kinh', '0976543218', 'hs2510014@gmail.com', '03112010', 'L10A1'),
('HS2510015', N'Nguyễn Thị Thảo', '20/05/2010', N'Nữ', N'Vĩnh Long', N'Kinh', '0967891234', 'hs2510015@gmail.com', '20052010', 'L10A1'),
('HS2510016', N'Trịnh Văn Long', '09/08/2010', N'Nam', N'Vĩnh Long', N'Kinh', '0956789123', 'hs2510016@gmail.com', '09082010', 'L10A1'),
('HS2510017', N'Phan Thị Hằng', '17/07/2010', N'Nữ', N'Vĩnh Long', N'Kinh', '0945678912', 'hs2510017@gmail.com', '17072010', 'L10A1'),
('HS2510018', N'Đỗ Văn Sơn', '29/09/2010', N'Nam', N'Cà Mau', N'Kinh', '0934567891', 'hs2510018@gmail.com', '29092010', 'L10A1'),
('HS2510019', N'Lưu Thị Nga', '11/01/2010', N'Nữ', N'Cà Mau', N'Kinh', '0923456781', 'hs2510019@gmail.com', '11012010', 'L10A1'),
('HS2510020', N'Châu Văn Hải', '23/03/2010', N'Nam', N'Cà Mau', N'Kinh', '0912345671', 'hs2510020@gmail.com', '23032010', 'L10A1'),
('HS2510021', N'Hồ Thị Diễm', '07/05/2010', N'Nữ', N'Đắk Lắk', N'Kinh', '0987654322', 'hs2510021@gmail.com', '07052010', 'L10A1'),
('HS2510022', N'Võ Văn Tuấn', '19/07/2010', N'Nam', N'Lâm Đồng', N'Kinh', '0976543219', 'hs2510022@gmail.com', '19072010', 'L10A1'),
('HS2510023', N'Dương Thị Linh', '02/09/2010', N'Nữ', N'Gia Lai', N'Kinh', '0965432197', 'hs2510023@gmail.com', '02092010', 'L10A1'),
('HS2510024', N'Lâm Văn Dũng', '15/11/2010', N'Nam', N'Quảng Ngãi', N'Kinh', '0954321987', 'hs2510024@gmail.com', '15112010', 'L10A1'),
('HS2510025', N'Nguyễn Thị Xuân', '28/02/2010', N'Nữ', N'Điện Biên', N'Kinh', '0943219876', 'hs2510025@gmail.com', '28022010', 'L10A1'),
('HS2510026', N'Trần Văn Hùng', '10/04/2010', N'Nam', N'Sơn La', N'Kinh', '0932198765', 'hs2510026@gmail.com', '10042010', 'L10A1'),
('HS2510027', N'Lê Thị Thu', '22/06/2010', N'Nữ', N'Lào Cai', N'Kinh', '0921987654', 'hs2510027@gmail.com', '22062010', 'L10A1'),
('HS2510028', N'Phạm Văn Thắng', '04/08/2010', N'Nam', N'Lào Cai', N'Kinh', '0919876543', 'hs2510028@gmail.com', '04082010', 'L10A1'),
('HS2510029', N'Hoàng Thị Hương', '16/10/2010', N'Nữ', N'Phú Thọ', N'Kinh', '0987654323', 'hs2510029@gmail.com', '16102010', 'L10A1'),
('HS2510030', N'Vũ Văn Nam', '30/12/2010', N'Nam', N'Thái Nguyên', N'Kinh', '0976543210', 'hs2510030@gmail.com', '30122010', 'L10A1'),
('HS2510031', N'Đinh Thị Loan', '13/01/2010', N'Nữ', N'Bắc Ninh', N'Kinh', '0965432109', 'hs2510031@gmail.com', '13012010', 'L10A1'),
('HS2510032', N'Bùi Văn Thành', '25/03/2010', N'Nam', N'Bắc Ninh', N'Kinh', '0954321098', 'hs2510032@gmail.com', '25032010', 'L10A1'),
('HS2510033', N'Nguyễn Thị Hạnh', '07/05/2010', N'Nữ', N'Hưng Yên', N'Kinh', '0943210987', 'hs2510033@gmail.com', '07052010', 'L10A1'),
('HS2510034', N'Trần Văn Phúc', '19/07/2010', N'Nam', N'Hưng Yên', N'Kinh', '0932109876', 'hs2510034@gmail.com', '19072010', 'L10A1'),
('HS2510035', N'Lê Thị Thúy', '01/09/2010', N'Nữ', N'Ninh Bình', N'Kinh', '0921098765', 'hs2510035@gmail.com', '01092010', 'L10A1'),
('HS2510036', N'Phạm Văn Đạt', '14/11/2010', N'Nam', N'Ninh Bình', N'Kinh', '0910987654', 'hs2510036@gmail.com', '14112010', 'L10A1'),
('HS2510037', N'Hoàng Thị Ngân', '27/01/2010', N'Nữ', N'Quảng Ninh', N'Kinh', '0987654324', 'hs2510037@gmail.com', '27012010', 'L10A1'),
('HS2510038', N'Vũ Văn Hiếu', '09/03/2010', N'Nam', N'Tuyên Quang', N'Kinh', '0976543211', 'hs2510038@gmail.com', '09032010', 'L10A1'),
('HS2510039', N'Đặng Thị Minh', '21/05/2010', N'Nữ', N'Cao Bằng', N'Kinh', '0965432108', 'hs2510039@gmail.com', '21052010', 'L10A1'),
('HS2510040', N'Nguyễn Văn Quang', '03/07/2010', N'Nam', N'Lạng Sơn', N'Kinh', '0954321097', 'hs2510040@gmail.com', '03072010', 'L10A1'),
-- Lớp L11A1 (40 học sinh, sinh năm 2009)
('HS2409001', N'Lê Văn Anh', '05/01/2009', N'Nam', N'Hà Nội', N'Kinh', '0987654321', 'hs2409001@gmail.com', '05012009', 'L11A1'),
('HS2409002', N'Phạm Thị Bình', '12/02/2009', N'Nữ', N'TP HCM', N'Kinh', '0912345678', 'hs2409002@gmail.com', '12022009', 'L11A1'),
('HS2409003', N'Trần Văn Cường', '18/03/2009', N'Nam', N'Đà Nẵng', N'Kinh', '0978123456', 'hs2409003@gmail.com', '18032009', 'L11A1'),
('HS2409004', N'Nguyễn Thị Dung', '24/04/2009', N'Nữ', N'Hải Phòng', N'Kinh', '0965432198', 'hs2409004@gmail.com', '24042009', 'L11A1'),
('HS2409005', N'Hoàng Văn Đạt', '30/05/2009', N'Nam', N'Cần Thơ', N'Kinh', '0932165498', 'hs2409005@gmail.com', '30052009', 'L11A1'),
('HS2409006', N'Vũ Thị Hương', '06/06/2009', N'Nữ', N'Đồng Nai', N'Kinh', '0945678321', 'hs2409006@gmail.com', '06062009', 'L11A1'),
('HS2409007', N'Đặng Văn Khải', '14/07/2009', N'Nam', N'Đồng Nai', N'Kinh', '0923456789', 'hs2409007@gmail.com', '14072009', 'L11A1'),
('HS2409008', N'Bùi Thị Linh', '22/08/2009', N'Nữ', N'Tây Ninh', N'Kinh', '0918765432', 'hs2409008@gmail.com', '22082009', 'L11A1'),
('HS2409009', N'Mai Văn Minh', '08/09/2009', N'Nam', N'Đồng Tháp', N'Kinh', '0987123456', 'hs2409009@gmail.com', '08092009', 'L11A1'),
('HS2409010', N'Lý Thị Ngọc', '16/10/2009', N'Nữ', N'An Giang', N'Kinh', '0976543218', 'hs2409010@gmail.com', '16102009', 'L11A1'),
('HS2409011', N'Châu Văn Phong', '02/11/2009', N'Nam', N'An Giang', N'Kinh', '0967891234', 'hs2409011@gmail.com', '02112009', 'L11A1'),
('HS2409012', N'Hồ Thị Quỳnh', '10/12/2009', N'Nữ', N'Vĩnh Long', N'Kinh', '0956789123', 'hs2409012@gmail.com', '10122009', 'L11A1'),
('HS2409013', N'Phan Văn Sơn', '18/01/2009', N'Nam', N'Vĩnh Long', N'Kinh', '0945678912', 'hs2409013@gmail.com', '18012009', 'L11A1'),
('HS2409014', N'Đỗ Thị Tuyết', '26/02/2009', N'Nữ', N'Cà Mau', N'Kinh', '0934567891', 'hs2409014@gmail.com', '26022009', 'L11A1'),
('HS2409015', N'Lưu Văn Thành', '04/03/2009', N'Nam', N'Cà Mau', N'Kinh', '0923456781', 'hs2409015@gmail.com', '04032009', 'L11A1'),
('HS2409016', N'Trịnh Thị Uyên', '12/04/2009', N'Nữ', N'Cà Mau', N'Kinh', '0912345671', 'hs2409016@gmail.com', '12042009', 'L11A1'),
('HS2409017', N'Dương Văn Việt', '20/05/2009', N'Nam', N'Đắk Lắk', N'Kinh', '0987654322', 'hs2409017@gmail.com', '20052009', 'L11A1'),
('HS2409018', N'Lâm Thị Xuân', '28/06/2009', N'Nữ', N'Lâm Đồng', N'Kinh', '0976543219', 'hs2409018@gmail.com', '28062009', 'L11A1'),
('HS2409019', N'Võ Văn Yên', '06/07/2009', N'Nam', N'Gia Lai', N'Kinh', '0965432197', 'hs2409019@gmail.com', '06072009', 'L11A1'),
('HS2409020', N'Nguyễn Thị Ánh', '14/08/2009', N'Nữ', N'Quảng Ngãi', N'Kinh', '0954321987', 'hs2409020@gmail.com', '14082009', 'L11A1'),
('HS2409021', N'Trần Văn Bảo', '22/09/2009', N'Nam', N'Điện Biên', N'Kinh', '0943219876', 'hs2409021@gmail.com', '22092009', 'L11A1'),
('HS2409022', N'Lê Thị Cẩm', '30/10/2009', N'Nữ', N'Sơn La', N'Kinh', '0932198765', 'hs2409022@gmail.com', '30102009', 'L11A1'),
('HS2409023', N'Phạm Văn Dũng', '08/11/2009', N'Nam', N'Lào Cai', N'Kinh', '0921987654', 'hs2409023@gmail.com', '08112009', 'L11A1'),
('HS2409024', N'Hoàng Thị Hạnh', '16/12/2009', N'Nữ', N'Lào Cai', N'Kinh', '0919876543', 'hs2409024@gmail.com', '16122009', 'L11A1'),
('HS2409025', N'Vũ Văn Khoa', '24/01/2009', N'Nam', N'Phú Thọ', N'Kinh', '0987654323', 'hs2409025@gmail.com', '24012009', 'L11A1'),
('HS2409026', N'Đinh Thị Lan', '02/02/2009', N'Nữ', N'Thái Nguyên', N'Kinh', '0976543210', 'hs2409026@gmail.com', '02022009', 'L11A1'),
('HS2409027', N'Bùi Văn Mạnh', '10/03/2009', N'Nam', N'Bắc Ninh', N'Kinh', '0965432109', 'hs2409027@gmail.com', '10032009', 'L11A1'),
('HS2409028', N'Nguyễn Thị Nga', '18/04/2009', N'Nữ', N'Bắc Ninh', N'Kinh', '0954321098', 'hs2409028@gmail.com', '18042009', 'L11A1'),
('HS2409029', N'Trần Văn Phú', '26/05/2009', N'Nam', N'Hưng Yên', N'Kinh', '0943210987', 'hs2409029@gmail.com', '26052009', 'L11A1'),
('HS2409030', N'Lê Thị Quyên', '04/06/2009', N'Nữ', N'Ninh Bình', N'Kinh', '0932109876', 'hs2409030@gmail.com', '04062009', 'L11A1'),
('HS2409031', N'Phạm Văn Rạng', '12/07/2009', N'Nam', N'Ninh Bình', N'Kinh', '0921098765', 'hs2409031@gmail.com', '12072009', 'L11A1'),
('HS2409032', N'Hoàng Thị Sen', '20/08/2009', N'Nữ', N'Quảng Ninh', N'Kinh', '0910987654', 'hs2409032@gmail.com', '20082009', 'L11A1'),
('HS2409033', N'Vũ Văn Tâm', '28/09/2009', N'Nam', N'Tuyên Quang', N'Kinh', '0987654324', 'hs2409033@gmail.com', '28092009', 'L11A1'),
('HS2409034', N'Đặng Thị Uyển', '06/10/2009', N'Nữ', N'Cao Bằng', N'Kinh', '0976543211', 'hs2409034@gmail.com', '06102009', 'L11A1'),
('HS2409035', N'Nguyễn Văn Vũ', '14/11/2009', N'Nam', N'Lạng Sơn', N'Kinh', '0965432108', 'hs2409035@gmail.com', '14112009', 'L11A1'),
('HS2409036', N'Trịnh Thị Xoan', '22/12/2009', N'Nữ', N'Thanh Hóa', N'Kinh', '0954321097', 'hs2409036@gmail.com', '22122009', 'L11A1'),
('HS2409037', N'Lý Văn Yến', '30/01/2009', N'Nam', N'Nghệ An', N'Kinh', '0943210986', 'hs2409037@gmail.com', '30012009', 'L11A1'),
('HS2409038', N'Sok Srey Leak', '08/02/2009', N'Nữ', N'Hà Tĩnh', N'Khmer', '0932109875', 'hs2409038@gmail.com', '08022009', 'L11A1'),
('HS2409039', N'Châu Văn An', '16/03/2009', N'Nam', N'Quảng Trị', N'Kinh', '0921098764', 'hs2409039@gmail.com', '16032009', 'L11A1'),
('HS2409040', N'Hồ Thị Bích', '24/04/2009', N'Nữ', N'Khánh Hòa', N'Kinh', '0910987653', 'hs2409040@gmail.com', '24042009', 'L11A1')

SELECT 
    Ma_HS,
    Hoten_HS,
    FORMAT(Ngaysinh, 'dd/MM/yyyy') AS Ngaysinh,
    Gioitinh,
	Diachi,
	Dantoc,
    SDT_HS,
    email_HS,
    Ma_LOP
FROM HOCSINH;


-- SELECT * FROM THOIKHOABIEU
-- Ma_LOP giải thích mã thời khóa biểu:  TKB( thời khóa biểu); 10A1(tên lớp ) ; T2(thứ 2) ; _01(tiết 1) 
INSERT INTO THOIKHOABIEU(Ma_TKB, Ma_LOP, Ma_MON, Ma_GV, Ma_HK, Thu, Tiet_batdau, Sotiet) VALUES
('TKB10A1T2_02', 'L10A1', 'TOAN', 'GV00001', 'HK2526_1', N'Hai', 2, 2),
('TKB10A1T2_04', 'L10A1', 'VATLY', 'GV00006', 'HK2526_1', N'Hai', 4, 2),
('TKB10A1T3_01', 'L10A1', 'TIENGANH', 'GV00010', 'HK2526_1', N'Ba', 1, 2),
('TKB10A1T3_03', 'L10A1', 'GDCD', 'GV00009', 'HK2526_1', N'Ba', 3, 1),
('TKB10A1T3_04', 'L10A1', 'GVCN', 'GV00004', 'HK2526_1', N'Ba', 4, 2),
('TKB10A1T4_01', 'L10A1', 'LICHSU', 'GV00002', 'HK2526_1', N'Tư', 1, 2),
('TKB10A1T4_03', 'L10A1', 'NGUVAN', 'GV00008', 'HK2526_1', N'Tư', 3, 2),
('TKB10A1T4_05', 'L10A1', 'VATLY', 'GV00006', 'HK2526_1', N'Tư', 5, 1),
('TKB10A1T5_01', 'L10A1', 'SINHHOC', 'GV00011', 'HK2526_1', N'Năm', 1, 2),
('TKB10A1T5_03', 'L10A1', 'TINHOC', 'GV00012', 'HK2526_1', N'Năm', 3, 2), 
('TKB10A1T5_05', 'L10A1', 'DIALY', 'GV00005', 'HK2526_1', N'Năm', 5, 1),
('TKB10A1T6_01', 'L10A1', 'HOA', 'GV00007', 'HK2526_1', N'Sáu', 1, 2),
('TKB10A1T6_03', 'L10A1', 'NGUVAN', 'GV00008', 'HK2526_1', N'Sáu', 3, 2),
('TKB10A1T6_05', 'L10A1', 'CONGNGHE', 'GV00004', 'HK2526_1', N'Sáu', 5, 1),
('TKB10A1T7_01', 'L10A1', 'HOA', 'GV00007', 'HK2526_1', N'Bảy', 1, 1),
('TKB10A1T7_02', 'L10A1', 'TOAN', 'GV00001', 'HK2526_1', N'Bảy', 2, 2),
('TKB10A1T7_04', 'L10A1', 'TIENGANH', 'GV00010', 'HK2526_1', N'Bảy', 4, 2),
('TKB10A1T3_07', 'L10A1', 'GDQP', 'GV00003', 'HK2526_1', N'Ba', 7, 2), 
('TKB10A1T6_09', 'L10A1', 'THEDUC', 'GV00013', 'HK2526_1', N'Sáu', 9, 2)

INSERT INTO THOIKHOABIEU(Ma_TKB, Ma_LOP, Ma_MON, Ma_GV, Ma_HK, Thu, Tiet_batdau, Sotiet) VALUES
('TKB11A1T2_02', 'L11A1', 'GDQP', 'GV00003', 'HK2526_1', N'Hai', 2, 2),
('TKB11A1T2_06', 'L11A1', 'NGUVAN', 'GV00008', 'HK2526_1', N'Hai', 6, 2),
('TKB11A1T2_08', 'L11A1', 'GVCN', 'GV00002', 'HK2526_1', N'Hai', 8, 2),
('TKB11A1T3_06', 'L11A1', 'LICHSU', 'GV00002', 'HK2526_1', N'Ba', 6, 2),
('TKB11A1T3_08', 'L11A1', 'DIALY', 'GV00005', 'HK2526_1', N'Ba', 8, 1),
('TKB11A1T3_09', 'L11A1', 'TIENGANH', 'GV00010', 'HK2526_1', N'Ba', 9, 2),
('TKB11A1T4_06', 'L11A1', 'TOAN', 'GV00001', 'HK2526_1', N'Tư', 6, 2),
('TKB11A1T4_08', 'L11A1', 'NGUVAN', 'GV00008', 'HK2526_1', N'Tư', 8, 2),
('TKB11A1T4_10', 'L11A1', 'VATLY', 'GV00006', 'HK2526_1', N'Tư', 10, 1),
('TKB11A1T5_06', 'L11A1', 'HOA', 'GV00007', 'HK2526_1', N'Năm', 6, 2),
('TKB11A1T5_08', 'L11A1', 'CONGNGHE', 'GV00004', 'HK2526_1', N'Năm', 8, 1),
('TKB11A1T5_09', 'L11A1', 'SINHHOC', 'GV00011', 'HK2526_1', N'Năm', 9, 2),
('TKB11A1T6_06', 'L11A1', 'GDCD', 'GV00009', 'HK2526_1', N'Sáu', 6, 1),
('TKB11A1T6_07', 'L11A1', 'TINHOC', 'GV00012', 'HK2526_1', N'Sáu', 7, 2),
('TKB11A1T6_09', 'L11A1', 'TIENGANH', 'GV00010', 'HK2526_1', N'Sáu', 9, 2),
('TKB11A1T7_06', 'L11A1', 'VATLY', 'GV00006', 'HK2526_1', N'Bảy', 6, 2),
('TKB11A1T7_08', 'L11A1', 'TOAN', 'GV00001', 'HK2526_1', N'Bảy', 8, 1),
('TKB11A1T7_09', 'L11A1', 'HOA', 'GV00007', 'HK2526_1', N'Bảy', 9, 2),
('TKB11A1T4_01', 'L11A1', 'THEDUC', 'GV00013', 'HK2526_1', N'Tư', 1, 2)

INSERT INTO THOIKHOABIEU(Ma_TKB, Ma_LOP, Ma_MON, Ma_GV, Ma_HK, Thu, Tiet_batdau, Sotiet) VALUES
('TKB10A1T2_01', 'L10A1', 'SHDC', 'GV99999', 'HK2526_1', N'Hai', 1, 1),
('TKB10A1T2_10', 'L11A1', 'SHDC', 'GV99999', 'HK2526_1', N'Hai', 10, 1)


-- SELECT * FROM DIEM
-- Loai_Diem quy định :( N'Miệng', N'15 phút', N'Một tiết', N'Giữa kỳ', N'Cuối kỳ'),
INSERT INTO DIEM(Ma_HS, Ma_MON, Ma_HK, Loai_Diem, Diem) VALUES
('HS2510001', 'TOAN', 'HK2526_1', N'Miệng', 10),
('HS2510001', 'TOAN', 'HK2526_1', N'15 phút', 8.25),
('HS2510001', 'TOAN', 'HK2526_1', N'Giữa kỳ', 8.75),
('HS2510001', 'TOAN', 'HK2526_1', N'Cuối kỳ', 9.25),
('HS2510001', 'VATLY', 'HK2526_1', N'Miệng', 9),
('HS2510001', 'VATLY', 'HK2526_1', N'15 phút', 7),
('HS2510001', 'VATLY', 'HK2526_1', N'Giữa kỳ', 8),
('HS2510001', 'VATLY', 'HK2526_1', N'Cuối kỳ', 7.25),
('HS2510001', 'HOA', 'HK2526_1', N'Miệng', 7),
('HS2510001', 'HOA', 'HK2526_1', N'15 phút', 9.75),
('HS2510001', 'HOA', 'HK2526_1', N'Giữa kỳ', 8.5),
('HS2510001', 'HOA', 'HK2526_1', N'Cuối kỳ', 8.75),
('HS2510001', 'NGUVAN', 'HK2526_1', N'Miệng', 7),
('HS2510001', 'NGUVAN', 'HK2526_1', N'15 phút', 6.25),
('HS2510001', 'NGUVAN', 'HK2526_1', N'Giữa kỳ', 6.5),
('HS2510001', 'NGUVAN', 'HK2526_1', N'Cuối kỳ', 5.75),
('HS2510001', 'LICHSU', 'HK2526_1', N'Miệng', 10),
('HS2510001', 'LICHSU', 'HK2526_1', N'15 phút', 10),
('HS2510001', 'LICHSU', 'HK2526_1', N'Giữa kỳ', 9),
('HS2510001', 'LICHSU', 'HK2526_1', N'Cuối kỳ', 9.25),
('HS2510001', 'DIALY', 'HK2526_1', N'Miệng', 10),
('HS2510001', 'DIALY', 'HK2526_1', N'15 phút', 10),
('HS2510001', 'DIALY', 'HK2526_1', N'Giữa kỳ', 9.25),
('HS2510001', 'DIALY', 'HK2526_1', N'Cuối kỳ', 9.5),
('HS2510001', 'SINHHOC', 'HK2526_1', N'Miệng', 10),
('HS2510001', 'SINHHOC', 'HK2526_1', N'15 phút', 8),
('HS2510001', 'SINHHOC', 'HK2526_1', N'Giữa kỳ', 7.25),
('HS2510001', 'SINHHOC', 'HK2526_1', N'Cuối kỳ', 7.75),
('HS2510001', 'TIENGANH', 'HK2526_1', N'Miệng', 7),
('HS2510001', 'TIENGANH', 'HK2526_1', N'15 phút', 8.25),
('HS2510001', 'TIENGANH', 'HK2526_1', N'Giữa kỳ', 8),
('HS2510001', 'TIENGANH', 'HK2526_1', N'Cuối kỳ', 6.25),
('HS2510001', 'GDCD', 'HK2526_1', N'Miệng', 10),
('HS2510001', 'GDCD', 'HK2526_1', N'15 phút', 10),
('HS2510001', 'GDCD', 'HK2526_1', N'Giữa kỳ', 10),
('HS2510001', 'GDCD', 'HK2526_1', N'Cuối kỳ', 9.75),
('HS2510001', 'CONGNGHE', 'HK2526_1', N'Miệng', 10),
('HS2510001', 'CONGNGHE', 'HK2526_1', N'15 phút', 9),
('HS2510001', 'CONGNGHE', 'HK2526_1', N'Giữa kỳ', 8.75),
('HS2510001', 'CONGNGHE', 'HK2526_1', N'Cuối kỳ', 9.5),
('HS2510001', 'GDQP', 'HK2526_1', N'Miệng', 9),
('HS2510001', 'GDQP', 'HK2526_1', N'15 phút', 9.5),
('HS2510001', 'GDQP', 'HK2526_1', N'Giữa kỳ', 9.25),
('HS2510001', 'GDQP', 'HK2526_1', N'Cuối kỳ', 9),
('HS2510001', 'THEDUC', 'HK2526_1', N'Miệng', 10),
('HS2510001', 'THEDUC', 'HK2526_1', N'15 phút', 10),
('HS2510001', 'THEDUC', 'HK2526_1', N'Giữa kỳ', 10),
('HS2510001', 'THEDUC', 'HK2526_1', N'Cuối kỳ', 10),
('HS2510001', 'TINHOC', 'HK2526_1', N'Miệng', 10),
('HS2510001', 'TINHOC', 'HK2526_1', N'15 phút', 10),
('HS2510001', 'TINHOC', 'HK2526_1', N'Giữa kỳ', 10),
('HS2510001', 'TINHOC', 'HK2526_1', N'Cuối kỳ', 10)




INSERT INTO DIEM (Ma_HS, Ma_MON, Ma_HK, Loai_Diem, Diem)
SELECT HS.Ma_HS, MH.Ma_MON, 'HK2526_1', LD.Loai, 0
FROM HOCSINH HS
CROSS JOIN MONHOC MH
CROSS JOIN (
    SELECT N'Miệng' AS Loai UNION
    SELECT N'15 phút' UNION
    SELECT N'Một tiết' UNION
    SELECT N'Giữa kỳ' UNION
    SELECT N'Cuối kỳ'
) LD
WHERE NOT EXISTS (
    SELECT 1 
    FROM DIEM D
    WHERE D.Ma_HS = HS.Ma_HS
      AND D.Ma_MON = MH.Ma_MON
      AND D.Ma_HK = 'HK2526_1'
      AND D.Loai_Diem = LD.Loai
)


-- SELECT * FROM ADMIN
-- SELECT * FROM HANHKIEM
INSERT INTO HANHKIEM(Ma_HS, Ma_HK, Xep_loai) VALUES
('HS2510001', 'HK2526_1', N'Tốt'),
('HS2510002', 'HK2526_1', N'Tốt'),
('HS2510003', 'HK2526_1', N'Tốt'),
('HS2510004', 'HK2526_1', N'Khá')

--SELECT * FROM  KQ_NAMHOC
CREATE PROCEDURE Tinh_KQ_NamHoc
    @NamHoc CHAR(9)
AS
BEGIN
    SET NOCOUNT ON;

    -- Xóa dữ liệu cũ (nếu đã tính trước đó cho năm này)
    DELETE FROM KQ_NAMHOC WHERE NamHoc = @NamHoc;

    -- Tính toán và chèn kết quả mới
    INSERT INTO KQ_NAMHOC (Ma_HS, NamHoc, DTB_CN, HocLuc)
    SELECT 
        d.Ma_HS,
        @NamHoc,
        AVG(Diem) AS DTB_CN,
        CASE 
            WHEN AVG(Diem) >= 8.0 
                 AND (SELECT COUNT(*) 
                      FROM DIEM d2
                      JOIN HOCKY hk2 ON d2.Ma_HK = hk2.Ma_HK
                      WHERE d2.Ma_HS = d.Ma_HS 
                        AND hk2.Nam_hoc = @NamHoc 
                        AND d2.Diem >= 8.0) >= 6
                 THEN N'Tốt'

            WHEN AVG(Diem) >= 6.5 
                 AND (SELECT COUNT(*) 
                      FROM DIEM d2
                      JOIN HOCKY hk2 ON d2.Ma_HK = hk2.Ma_HK
                      WHERE d2.Ma_HS = d.Ma_HS 
                        AND hk2.Nam_hoc = @NamHoc 
                        AND d2.Diem >= 6.5) >= 6
                 THEN N'Khá'

            WHEN AVG(Diem) >= 5.0 THEN N'Đạt'
            ELSE N'Chưa đạt'
        END AS HocLuc
    FROM DIEM d
    JOIN HOCKY hk ON d.Ma_HK = hk.Ma_HK
    WHERE hk.Nam_hoc = @NamHoc
    GROUP BY d.Ma_HS;
END;
EXEC Tinh_KQ_NamHoc '2024-2025';
EXEC Tinh_KQ_NamHoc '2025-2026';


SELECT 
    d.Ma_HS,
    hk.Nam_hoc,
    AVG(Diem) AS DTB_CN
FROM DIEM d
JOIN HOCKY hk ON d.Ma_HK = hk.Ma_HK
WHERE hk.Nam_hoc = '2024-2025'
GROUP BY d.Ma_HS, hk.Nam_hoc;



--random DIEM 

DELETE FROM DIEM;

INSERT INTO DIEM(Ma_HS, Ma_MON, Ma_HK, Loai_Diem, Diem)
SELECT HS.Ma_HS, MH.Ma_MON, HK.Ma_HK, LD.Loai_Diem,
       CAST(
           CASE 
               WHEN RAND(CHECKSUM(NEWID())) < 0.1 THEN 3 + RAND(CHECKSUM(NEWID())) * 2   -- 10%: 3–5
               WHEN RAND(CHECKSUM(NEWID())) < 0.9 THEN 6 + RAND(CHECKSUM(NEWID())) * 3   -- 80%: 6–9
               ELSE 9 + RAND(CHECKSUM(NEWID())) * 1                                     -- 10%: 9–10
           END
       AS DECIMAL(3,1)) AS Diem
FROM HOCSINH HS
CROSS JOIN MONHOC MH
CROSS JOIN HOCKY HK
CROSS JOIN (VALUES (N'Miệng'), (N'15 phút'), (N'Một tiết'), (N'Giữa kỳ'), (N'Cuối kỳ')) LD(Loai_Diem)
WHERE MH.Ma_MON NOT IN ('THEDUC','GVCN','SHDC'); 

