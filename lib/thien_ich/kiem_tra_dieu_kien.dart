class KetQuaKiemTra {
  final bool hopLe;
  final String thongBao;

  const KetQuaKiemTra({
    required this.hopLe,
    this.thongBao = '',
  });

  static const KetQuaKiemTra thanhCong = KetQuaKiemTra(hopLe: true);
  factory KetQuaKiemTra.loi(String thongBao) => KetQuaKiemTra(hopLe: false, thongBao: thongBao);
}

class KiemTraDieuKien {
  /// 1. BẮT BUỘC Phải có thu nhập trước khi chi tiêu
  static KetQuaKiemTra kiemTraBatBuocCoThuNhap({
    required double tongThuNhap,
    required bool laChiTieu,
  }) {
    if (laChiTieu && tongThuNhap <= 0) {
      return KetQuaKiemTra.loi(
        'Bạn chưa có thu nhập nào! Vui lòng nhập khoản THU NHẬP vào trước mới được thực hiện chi tiêu.',
      );
    }
    return KetQuaKiemTra.thanhCong;
  }

  /// 2. Kiểm tra số dư khả dụng có đủ để chi tiêu không
  static KetQuaKiemTra kiemTraSoDuKhaDung({
    required double tongSoDu,
    required double soTienChi,
    required bool laChiTieu,
  }) {
    if (laChiTieu && soTienChi > tongSoDu) {
      return KetQuaKiemTra.loi(
        'Số tiền chi vượt quá số dư khả dụng hiện có (${tongSoDu.toInt()} đ). Vui lòng kiểm tra lại!',
      );
    }
    return KetQuaKiemTra.thanhCong;
  }

  /// 3. Kiểm tra số tiền hợp lệ (> 0 và không vượt quá 1 tỷ đ)
  static KetQuaKiemTra kiemTraSoTien(double? soTien) {
    if (soTien == null || soTien <= 0) {
      return KetQuaKiemTra.loi('Vui lòng nhập số tiền lớn hơn 0 đ.');
    }
    if (soTien > 1000000000) {
      return KetQuaKiemTra.loi('Số tiền nhập vào vượt quá giới hạn tối đa cho phép (1 tỷ VNĐ).');
    }
    return KetQuaKiemTra.thanhCong;
  }

  /// Kiểm tra tên / nhãn hũ tài chính
  static KetQuaKiemTra kiemTraTenHu(String tenHu) {
    final clean = tenHu.trim();
    if (clean.isEmpty) {
      return KetQuaKiemTra.loi('Vui lòng nhập tên / nội dung cho hũ tài chính.');
    }
    if (clean.length > 100) {
      return KetQuaKiemTra.loi('Tên hũ tài chính quá dài (tối đa 100 ký tự).');
    }
    return KetQuaKiemTra.thanhCong;
  }

  /// 5. Kiểm tra hạn mức ngân sách / hũ tài chính
  static KetQuaKiemTra kiemTraHanMucNganSach(double? hanMuc, double tongThuNhap) {
    final checkSoTien = kiemTraSoTien(hanMuc);
    if (!checkSoTien.hopLe) return checkSoTien;

    if (tongThuNhap > 0 && hanMuc! > tongThuNhap * 3) {
      return KetQuaKiemTra.loi(
        'Hạn mức hũ ngân sách quá cao so với tổng thu nhập (${tongThuNhap.toInt()} đ). Vui lòng điều chỉnh hợp lý!',
      );
    }
    return KetQuaKiemTra.thanhCong;
  }

  /// 6. Kiểm tra ngày giao dịch hợp lệ
  static KetQuaKiemTra kiemTraNgayGiaoDich(DateTime ngay) {
    final now = DateTime.now();
    final maxFuture = now.add(const Duration(days: 365));
    if (ngay.isAfter(maxFuture)) {
      return KetQuaKiemTra.loi('Ngày giao dịch không được vượt quá 1 năm trong tương lai.');
    }
    return KetQuaKiemTra.thanhCong;
  }

  /// 7. Kiểm tra tổng hợp toàn bộ điều kiện trước khi thêm giao dịch
  static KetQuaKiemTra kiemTraGiaoDichTongHop({
    required bool laChiTieu,
    required double? soTien,
    required String tieuDe,
    required DateTime ngayGiaoDich,
    required double tongThuNhap,
    required double tongSoDu,
  }) {
    // 1. Kiểm tra bắt buộc có thu nhập trước khi chi tiêu
    final checkThuNhap = kiemTraBatBuocCoThuNhap(
      tongThuNhap: tongThuNhap,
      laChiTieu: laChiTieu,
    );
    if (!checkThuNhap.hopLe) return checkThuNhap;

    // 2. Kiểm tra số tiền
    final checkSoTien = kiemTraSoTien(soTien);
    if (!checkSoTien.hopLe) return checkSoTien;

    // 3. Kiểm tra số dư nếu là chi tiêu
    final checkSoDu = kiemTraSoDuKhaDung(
      tongSoDu: tongSoDu,
      soTienChi: soTien!,
      laChiTieu: laChiTieu,
    );
    if (!checkSoDu.hopLe) return checkSoDu;
    // 4. Kiểm tra ngày
    final checkNgay = kiemTraNgayGiaoDich(ngayGiaoDich);
    if (!checkNgay.hopLe) return checkNgay;

    return KetQuaKiemTra.thanhCong;
  }

}
