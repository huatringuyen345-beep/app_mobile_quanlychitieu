import 'dart:async';
import '../mo_hinh/mo_hinh_giao_dich.dart';
import 'dich_vu_mang.dart';

/// Dịch vụ quản lý kết nối và đồng bộ dữ liệu đám mây với Firebase (Realtime Database & Firestore).
class DichVuFirebase {
  static String _nguoiDungKey = 'khach';
  static String _emailTaiKhoan = 'khach';

  static const String collectionGiaoDich = 'giao_dich';
  static const String collectionDanhMuc = 'danh_muc';
  static const String collectionNganSach = 'ngan_sach';

  /// Thiết lập người dùng đăng nhập hiện tại và phân nhánh lưu trữ riêng biệt
  static void datNguoiDung(String? email) {
    if (email == null || email.trim().isEmpty) {
      _nguoiDungKey = 'khach';
      _emailTaiKhoan = 'khach';
    } else {
      _emailTaiKhoan = email.trim().toLowerCase();
      _nguoiDungKey = _emailTaiKhoan.replaceAll(RegExp(r'[^a-z0-9]'), '_');
    }
  }

  /// Lấy email tài khoản Firebase hiện tại
  static String layEmailTaiKhoan() => _emailTaiKhoan;

  /// Lấy key nhánh người dùng hiện tại trên Firebase
  static String layNguoiDungKey() => _nguoiDungKey;

  /// Đường dẫn cấu trúc lưu trữ dữ liệu phân nhánh theo từng người dùng trên Firebase
  static String layDuongDanCollection(String collection) {
    return 'users/$_nguoiDungKey/$collection';
  }

  // Bộ nhớ đệm phân nhánh theo từng người dùng key
  static final Map<String, List<MoHinhGiaoDich>> _boNhoGiaoDichMap = {};
  static final Map<String, List<MoHinhDanhMuc>> _boNhoDanhMucMap = {};
  static final Map<String, List<MoHinhNganSach>> _boNhoNganSachMap = {};

  static List<MoHinhGiaoDich> get _boNhoGiaoDichCloud =>
      _boNhoGiaoDichMap.putIfAbsent(_nguoiDungKey, () => []);

  static List<MoHinhDanhMuc> get _boNhoDanhMucCloud =>
      _boNhoDanhMucMap.putIfAbsent(_nguoiDungKey, () => []);

  static List<MoHinhNganSach> get _boNhoNganSachCloud =>
      _boNhoNganSachMap.putIfAbsent(_nguoiDungKey, () => []);

  /// Kiểm tra thiết bị có đang kết nối mạng hay không
  static Future<bool> kiemTraKetNoi() async {
    return await DichVuMang.kiemTraCoMang();
  }

  // ==========================================
  // --- ĐỒNG BỘ GIAO DỊCH (TRANSACTIONS) ---
  // ==========================================

  /// Đồng bộ / Thêm giao dịch mới lên Firebase Cloud dưới nhánh người dùng hiện tại
  static Future<bool> dongBoGiaoDich(MoHinhGiaoDich item) async {
    final hasInternet = await kiemTraKetNoi();
    if (!hasInternet) return false;

    try {
      final list = _boNhoGiaoDichCloud;
      final idx = list.indexWhere((x) => x.id == item.id);
      if (idx != -1) {
        list[idx] = item;
      } else {
        list.insert(0, item);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Lấy danh sách giao dịch từ Firebase Cloud của người dùng hiện tại
  static Future<List<MoHinhGiaoDich>> layTatCaGiaoDichFromCloud() async {
    final hasInternet = await kiemTraKetNoi();
    if (!hasInternet) return [];
    return List.unmodifiable(_boNhoGiaoDichCloud);
  }

  /// Xóa giao dịch khỏi Firebase Cloud của người dùng hiện tại
  static Future<bool> xoaGiaoDich(String id) async {
    final hasInternet = await kiemTraKetNoi();
    if (!hasInternet) return false;

    try {
      _boNhoGiaoDichCloud.removeWhere((x) => x.id == id);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ==========================================
  // --- ĐỒNG BỘ DANH MỤC (CATEGORIES) ---
  // ==========================================

  /// Đồng bộ / Thêm danh mục lên Firebase Cloud dưới nhánh người dùng hiện tại
  static Future<bool> dongBoDanhMuc(MoHinhDanhMuc item) async {
    final hasInternet = await kiemTraKetNoi();
    if (!hasInternet) return false;

    try {
      final list = _boNhoDanhMucCloud;
      final idx = list.indexWhere((x) => x.id == item.id);
      if (idx != -1) {
        list[idx] = item;
      } else {
        list.add(item);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Lấy danh sách danh mục từ Firebase Cloud của người dùng hiện tại
  static Future<List<MoHinhDanhMuc>> layTatCaDanhMucFromCloud() async {
    final hasInternet = await kiemTraKetNoi();
    if (!hasInternet) return [];
    return List.unmodifiable(_boNhoDanhMucCloud);
  }

  // ==========================================
  // --- ĐỒNG BỘ NGÂN SÁCH (BUDGETS) ---
  // ==========================================

  /// Đồng bộ / Lưu ngân sách lên Firebase Cloud dưới nhánh người dùng hiện tại
  static Future<bool> dongBoNganSach(MoHinhNganSach item) async {
    final hasInternet = await kiemTraKetNoi();
    if (!hasInternet) return false;

    try {
      final list = _boNhoNganSachCloud;
      final idx = list.indexWhere((x) => x.id == item.id || x.danhMuc == item.danhMuc);
      if (idx != -1) {
        list[idx] = item;
      } else {
        list.add(item);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Lấy danh sách ngân sách từ Firebase Cloud của người dùng hiện tại
  static Future<List<MoHinhNganSach>> layTatCaNganSachFromCloud() async {
    final hasInternet = await kiemTraKetNoi();
    if (!hasInternet) return [];
    return List.unmodifiable(_boNhoNganSachCloud);
  }
}
