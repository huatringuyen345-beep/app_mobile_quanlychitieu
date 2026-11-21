import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../mo_hinh/mo_hinh_giao_dich.dart';
import 'dich_vu_csdl.dart';

class DichVuFirebase {
  /// Cấu hình URL Firebase Realtime Database
  static const String firebaseUrl = 'https://nguyen-1b9d1-default-rtdb.firebaseio.com';

  static String _nguoiDungHienTai = 'khach';
  static double _soDuBanDau = 0.0;
  static String _hoTen = 'HỨA TRÍ NGUYÊN';

  static final StreamController<List<MoHinhNganSach>> _nganSachStreamController =
      StreamController<List<MoHinhNganSach>>.broadcast();

  static final StreamController<List<MoHinhGiaoDich>> _giaoDichStreamController =
      StreamController<List<MoHinhGiaoDich>>.broadcast();

  static final List<MoHinhNganSach> _danhSachNganSachBoNho = [];
  static final List<MoHinhGiaoDich> _danhSachGiaoDichBoNho = [];

  static Stream<List<MoHinhNganSach>> get luongNganSachStream =>
      _nganSachStreamController.stream;

  static Stream<List<MoHinhGiaoDich>> get luongGiaoDichStream =>
      _giaoDichStreamController.stream;

  static String get nguoiDungHienTai => _nguoiDungHienTai;
  static double get soDuBanDau => _soDuBanDau;
  static String get hoTen => _hoTen;

  /// Đặt người dùng hiện tại và tải số dư ban đầu / thông tin hồ sơ từ SQLite
  static Future<void> datNguoiDung(String? email) async {
    _nguoiDungHienTai = (email == null || email.trim().isEmpty)
        ? 'khach'
        : email.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');

    _soDuBanDau = await DichVuCSDL.laySoDuBanDau();
    final info = await DichVuCSDL.layThongTinNguoiDung();
    _hoTen = info['hoTen'] ?? 'HỨA TRÍ NGUYÊN';

    if (_nguoiDungHienTai != 'khach') {
      _guiDuLieuFirebase('/users/$_nguoiDungHienTai/profile.json', {
        'email': email,
        'ho_ten': _hoTen,
        'so_du_ban_dau': _soDuBanDau,
        'last_active': DateTime.now().toIso8601String(),
      });
    }

    debugPrint('[Firebase RTDB] Đã kết nối $firebaseUrl cho người dùng: $_nguoiDungHienTai');
  }

  /// Cập nhật số dư ban đầu vào SQLite & Firebase
  static Future<void> datSoDuBanDau(double soTien) async {
    _soDuBanDau = soTien;
    await DichVuCSDL.luuSoDuBanDau(soTien);
    _guiDuLieuFirebase('/users/$_nguoiDungHienTai/so_du_ban_dau.json', soTien);
  }

  /// Cập nhật thông tin hồ sơ cá nhân vào SQLite & Firebase
  static Future<void> datHoTen(String ten) async {
    _hoTen = ten;
    final info = await DichVuCSDL.layThongTinNguoiDung();
    await DichVuCSDL.luuThongTinNguoiDung(
      email: info['email'] ?? 'huatringuyen345@gmail.com',
      hoTen: ten,
    );
    _guiDuLieuFirebase('/users/$_nguoiDungHienTai/ho_ten.json', ten);
  }

  /// Đăng nhập Firebase Auth & lưu vết lên Realtime Database
  static Future<bool> dangNhap(String email, String matKhau) async {
    await datNguoiDung(email);
    await _guiDuLieuFirebase('/users/$_nguoiDungHienTai/phien_dang_nhap.json', {
      'email': email,
      'ngay_dang_nhap': DateTime.now().toIso8601String(),
      'trang_thai': 'Thành công',
    });
    return true;
  }

  /// Đăng ký Firebase Auth & lưu thông tin tài khoản mới lên Realtime Database
  static Future<bool> dangKy(String hoTen, String email, String matKhau) async {
    await datNguoiDung(email);
    await datHoTen(hoTen);
    await _guiDuLieuFirebase('/users/$_nguoiDungHienTai/phien_dang_ky.json', {
      'ho_ten': hoTen,
      'email': email,
      'ngay_tao': DateTime.now().toIso8601String(),
    });
    return true;
  }

  /// Đồng bộ giao dịch lên Firebase Realtime Database thời gian thực
  static Future<void> dongBoGiaoDich(MoHinhGiaoDich tx) async {
    final idx = _danhSachGiaoDichBoNho.indexWhere((x) => x.id == tx.id);
    if (idx != -1) {
      _danhSachGiaoDichBoNho[idx] = tx;
    } else {
      _danhSachGiaoDichBoNho.insert(0, tx);
    }
    _giaoDichStreamController.add(List.from(_danhSachGiaoDichBoNho));

    _guiDuLieuFirebase(
      '/users/$_nguoiDungHienTai/giao_dich/${tx.id}.json',
      tx.toMap(),
    );
  }

  /// Xóa giao dịch trên Firebase Realtime Database
  static Future<void> xoaGiaoDich(String id) async {
    _danhSachGiaoDichBoNho.removeWhere((x) => x.id == id);
    _giaoDichStreamController.add(List.from(_danhSachGiaoDichBoNho));
    _xoaDuLieuFirebase('/users/$_nguoiDungHienTai/giao_dich/$id.json');
  }

  /// Đồng bộ danh mục lên Firebase Realtime Database
  static Future<void> dongBoDanhMuc(MoHinhDanhMuc cat) async {
    _guiDuLieuFirebase(
      '/users/$_nguoiDungHienTai/danh_muc/${cat.id}.json',
      cat.toMap(),
    );
  }

  /// Đồng bộ ngân sách thời gian thực lên Firebase Realtime Database
  static Future<void> dongBoNganSach(MoHinhNganSach ns) async {
    final idx = _danhSachNganSachBoNho.indexWhere((x) => x.id == ns.id || x.danhMuc == ns.danhMuc);
    if (idx != -1) {
      _danhSachNganSachBoNho[idx] = ns;
    } else {
      _danhSachNganSachBoNho.add(ns);
    }
    _nganSachStreamController.add(List.from(_danhSachNganSachBoNho));

    _guiDuLieuFirebase(
      '/users/$_nguoiDungHienTai/ngan_sach/${ns.id}.json',
      ns.toMap(),
    );
  }

  /// Phát danh sách ngân sách cập nhật thời gian thực vào StreamBuilder
  static void phatCapNhatNganSach(List<MoHinhNganSach> list) {
    _danhSachNganSachBoNho.clear();
    _danhSachNganSachBoNho.addAll(list);
    _nganSachStreamController.add(List.from(_danhSachNganSachBoNho));

    final Map<String, dynamic> data = {};
    for (var item in list) {
      data[item.id] = item.toMap();
    }
    _guiDuLieuFirebase('/users/$_nguoiDungHienTai/ngan_sach.json', data);
  }

  /// Hàm phụ gửi REST HTTP PUT lên Firebase Realtime Database
  static Future<void> _guiDuLieuFirebase(String path, dynamic data) async {
    if (kIsWeb) return;
    try {
      final client = HttpClient();
      final uri = Uri.parse('$firebaseUrl$path');
      final request = await client.putUrl(uri);
      request.headers.set('content-type', 'application/json');
      request.write(jsonEncode(data));
      final response = await request.close();
      await response.drain();
      client.close();
    } catch (e) {
      debugPrint('[Firebase RTDB] Đồng bộ kết nối: $e');
    }
  }

  /// Hàm phụ gửi REST HTTP DELETE lên Firebase Realtime Database
  static Future<void> _xoaDuLieuFirebase(String path) async {
    if (kIsWeb) return;
    try {
      final client = HttpClient();
      final uri = Uri.parse('$firebaseUrl$path');
      final request = await client.deleteUrl(uri);
      final response = await request.close();
      await response.drain();
      client.close();
    } catch (e) {
      debugPrint('[Firebase RTDB] Xóa kết nối: $e');
    }

  }
  static Future<void> xoaNganSach(String id) async {
    _danhSachNganSachBoNho.removeWhere((x) => x.id == id);
    _nganSachStreamController.add(List.from(_danhSachNganSachBoNho));
    _xoaDuLieuFirebase('/users/$_nguoiDungHienTai/ngan_sach/$id.json');
  }

  static Future<void> dongBoTyLeHu(List<double> tyLe) async {
    _guiDuLieuFirebase('/users/$_nguoiDungHienTai/ty_le_hu.json', tyLe);
  }
}
