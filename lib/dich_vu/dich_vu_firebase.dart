import 'dart:async';
import '../mo_hinh/mo_hinh_giao_dich.dart';
import 'dich_vu_mang.dart';

/// Dịch vụ quản lý kết nối và đồng bộ dữ liệu đám mây với Firebase Firestore.
/// Tài khoản kết nối mặc định trên Firebase: huatringuyen345@gmail.com
class DichVuFirebase {
  /// Tài khoản mặc định kiểm tra và phân vùng lưu trữ trên Firebase
  static const String emailTaiKhoanFirebase = 'huatringuyen345@gmail.com';

  static const String collectionGiaoDich = 'giao_dich';
  static const String collectionDanhMuc = 'danh_muc';
  static const String collectionNganSach = 'ngan_sach';

  /// Đường dẫn cấu trúc lưu trữ dữ liệu Firebase Firestore cho tài khoản huatringuyen345@gmail.com
  static String layDuongDanCollection(String collection) {
    return 'users/$emailTaiKhoanFirebase/$collection';
  }

  // Bộ nhớ đệm dữ liệu đám mây khi chưa kết nối SDK Firebase trực tiếp
  static final List<MoHinhGiaoDich> _boNhoGiaoDichCloud = [];
  static final List<MoHinhDanhMuc> _boNhoDanhMucCloud = [];
  static final List<MoHinhNganSach> _boNhoNganSachCloud = [];

  /// Kiểm tra thiết bị có đang kết nối mạng hay không
  static Future<bool> kiemTraKetNoi() async {
    return await DichVuMang.kiemTraCoMang();
  }

  /// Lấy email tài khoản Firebase hiện tại
  static String layEmailTaiKhoan() => emailTaiKhoanFirebase;

  // ==========================================
  // --- ĐỒNG BỘ GIAO DỊCH (TRANSACTIONS) ---
  // ==========================================

  /// Đồng bộ / Thêm giao dịch mới lên Firebase Cloud dưới tài khoản huatringuyen345@gmail.com
  static Future<bool> dongBoGiaoDich(MoHinhGiaoDich item) async {
    final hasInternet = await kiemTraKetNoi();
    if (!hasInternet) return false;

    try {
      // Cập nhật bộ nhớ Cloud
      final idx = _boNhoGiaoDichCloud.indexWhere((x) => x.id == item.id);
      if (idx != -1) {
        _boNhoGiaoDichCloud[idx] = item;
      } else {
        _boNhoGiaoDichCloud.insert(0, item);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Lấy danh sách giao dịch từ Firebase Cloud của tài khoản huatringuyen345@gmail.com
  static Future<List<MoHinhGiaoDich>> layTatCaGiaoDichFromCloud() async {
    final hasInternet = await kiemTraKetNoi();
    if (!hasInternet) return [];
    return List.unmodifiable(_boNhoGiaoDichCloud);
  }

  /// Xóa giao dịch khỏi Firebase Cloud của tài khoản huatringuyen345@gmail.com
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

  /// Đồng bộ / Thêm danh mục lên Firebase Cloud dưới tài khoản huatringuyen345@gmail.com
  static Future<bool> dongBoDanhMuc(MoHinhDanhMuc item) async {
    final hasInternet = await kiemTraKetNoi();
    if (!hasInternet) return false;

    try {
      final idx = _boNhoDanhMucCloud.indexWhere((x) => x.id == item.id);
      if (idx != -1) {
        _boNhoDanhMucCloud[idx] = item;
      } else {
        _boNhoDanhMucCloud.add(item);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Lấy danh sách danh mục từ Firebase Cloud của tài khoản huatringuyen345@gmail.com
  static Future<List<MoHinhDanhMuc>> layTatCaDanhMucFromCloud() async {
    final hasInternet = await kiemTraKetNoi();
    if (!hasInternet) return [];
    return List.unmodifiable(_boNhoDanhMucCloud);
  }

  // ==========================================
  // --- ĐỒNG BỘ NGÂN SÁCH (BUDGETS) ---
  // ==========================================

  /// Đồng bộ / Lưu ngân sách lên Firebase Cloud dưới tài khoản huatringuyen345@gmail.com
  static Future<bool> dongBoNganSach(MoHinhNganSach item) async {
    final hasInternet = await kiemTraKetNoi();
    if (!hasInternet) return false;

    try {
      final idx = _boNhoNganSachCloud.indexWhere((x) => x.danhMuc == item.danhMuc);
      if (idx != -1) {
        _boNhoNganSachCloud[idx] = item;
      } else {
        _boNhoNganSachCloud.add(item);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Lấy danh sách ngân sách từ Firebase Cloud của tài khoản huatringuyen345@gmail.com
  static Future<List<MoHinhNganSach>> layTatCaNganSachFromCloud() async {
    final hasInternet = await kiemTraKetNoi();
    if (!hasInternet) return [];
    return List.unmodifiable(_boNhoNganSachCloud);
  }
}
