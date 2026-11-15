import 'package:shared_preferences/shared_preferences.dart';

class DichVuLuuTru {
  static const String _keyDaDangNhap = 'da_dang_nhap';
  static const String _keyEmail = 'email_nguoi_dung';
  static const String _keyHoTen = 'ho_ten_nguoi_dung';
  static const String _keyGiaoDienToi = 'giao_dien_toi';
  static const String _keyNguoiDungHienTai = 'nguoi_dung_hien_tai';

  // Tài khoản đang dùng dữ liệu (kể cả khi không tick "Ghi nhớ đăng nhập")
  static Future<void> luuNguoiDungHienTai(String? email) async {
    final prefs = await SharedPreferences.getInstance();
    if (email == null || email.isEmpty) {
      await prefs.remove(_keyNguoiDungHienTai);
    } else {
      await prefs.setString(_keyNguoiDungHienTai, email);
    }
  }

  static Future<String?> layNguoiDungHienTai() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNguoiDungHienTai);
  }

  // Lưu trạng thái sau khi đăng nhập thành công
  static Future<void> luuDangNhap({
    required String email,
    String hoTen = 'HỨA TRÍ NGUYÊN',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDaDangNhap, true);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyHoTen, hoTen);
  }

  // Kiểm tra trạng thái đã đăng nhập chưa
  static Future<bool> kiemTraKiemTrangThaiDangNhap() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDaDangNhap) ?? false;
  }

  // Lấy thông tin người dùng đã lưu
  static Future<Map<String, String>> layThongTinNguoiDung() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString(_keyEmail) ?? 'huatringuyen345@gmail.com',
      'hoTen': prefs.getString(_keyHoTen) ?? 'HỨA TRÍ NGUYÊN',
    };
  }

  // Xóa trạng thái đăng nhập khi người dùng bấm Đăng xuất
  static Future<void> xoaDangXuat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDaDangNhap, false);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyHoTen);
  }

  // Lưu cấu hình Giao diện tối
  static Future<void> luuGiaoDienToi(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyGiaoDienToi, isDark);
  }

  // Lấy cấu hình Giao diện tối
  static Future<bool> layGiaoDienToi() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyGiaoDienToi) ?? false;
  }
}
