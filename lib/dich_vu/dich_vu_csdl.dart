import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../mo_hinh/mo_hinh_giao_dich.dart';

class DichVuCSDL {
  // Mỗi tài khoản có CSDL SQLite/Storage riêng (khóa theo email) -> đăng nhập tài khoản khác
  // sẽ thấy dữ liệu riêng, không dính dữ liệu của người trước.
  static String _nguoiDung = 'khach';

  static Database? _database;
  static Database? _globalDatabase;

  static String _keyWeb(String prefix) => 'csdl_web_${_nguoiDung}_$prefix';

  /// CSDL dùng chung cho toàn ứng dụng (lưu trạng thái đăng nhập & giao diện tối)
  static Future<Database> get globalDatabase async {
    if (_globalDatabase != null && _globalDatabase!.isOpen) {
      return _globalDatabase!;
    }
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'quanly_chitieu_app.db');
    _globalDatabase = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS cau_hinh_chung (
            khoa TEXT PRIMARY KEY,
            giaTri TEXT NOT NULL
          )
        ''');
      },
      onOpen: (db) async {
        try {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS cau_hinh_chung (
              khoa TEXT PRIMARY KEY,
              giaTri TEXT NOT NULL
            )
          ''');
        } catch (_) {}
      },
    );
    return _globalDatabase!;
  }

  static Future<void> luuCauHinhChung(String khoa, String giaTri) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('global_cfg_$khoa', giaTri);
      return;
    }
    final db = await globalDatabase;
    await db.insert(
      'cau_hinh_chung',
      {'khoa': khoa, 'giaTri': giaTri},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<String?> layCauHinhChung(String khoa) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('global_cfg_$khoa');
    }
    final db = await globalDatabase;
    final maps = await db.query(
      'cau_hinh_chung',
      where: 'khoa = ?',
      whereArgs: [khoa],
    );
    if (maps.isNotEmpty) {
      return maps.first['giaTri'] as String?;
    }
    return null;
  }

  static Future<void> xoaCauHinhChung(String khoa) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('global_cfg_$khoa');
      return;
    }
    final db = await globalDatabase;
    await db.delete('cau_hinh_chung', where: 'khoa = ?', whereArgs: [khoa]);
  }

  /// Chuyển sang CSDL của người dùng [email]. Truyền null/rỗng = khách (đã đăng xuất).
  static Future<void> datNguoiDung(String? email) async {
    final String id = (email == null || email.trim().isEmpty)
        ? 'khach'
        : email.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    if (id == _nguoiDung && _database != null) return;
    _nguoiDung = id;
    if (!kIsWeb && _database != null) {
      await _database!.close();
      _database = null;
    }
  }

  static Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    _database = await _khoiTaoCSDL();
    return _database!;
  }

  static Future<Database> _khoiTaoCSDL() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'quanly_chitieu_$_nguoiDung.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) async {
        try {
          await db.execute('ALTER TABLE ngan_sach ADD COLUMN nhan TEXT;');
        } catch (_) {}
        try {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS cau_hinh (
              khoa TEXT PRIMARY KEY,
              giaTri TEXT NOT NULL
            )
          ''');
        } catch (_) {}
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE giao_dich (
            id TEXT PRIMARY KEY,
            tieuDe TEXT NOT NULL,
            soTien REAL NOT NULL,
            ngayGiaoDich TEXT NOT NULL,
            loai INTEGER NOT NULL,
            iconCodePoint INTEGER NOT NULL,
            mauNenValue INTEGER NOT NULL,
            danhMuc TEXT NOT NULL,
            ghiChu TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE danh_muc (
            id TEXT PRIMARY KEY,
            tenDanhMuc TEXT NOT NULL,
            iconCodePoint INTEGER NOT NULL,
            mauSacValue INTEGER NOT NULL,
            loai INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE ngan_sach (
            id TEXT PRIMARY KEY,
            danhMuc TEXT NOT NULL,
            nhan TEXT,
            gioiHan REAL NOT NULL,
            daDung REAL NOT NULL,
            iconCodePoint INTEGER NOT NULL,
            mauSacValue INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE cau_hinh (
            khoa TEXT PRIMARY KEY,
            giaTri TEXT NOT NULL
          )
        ''');

        // Tài khoản mới: Khởi tạo danh mục & ngân sách mẫu
        for (var cat in DuLieuMau.danhSachDanhMuc) {
          await db.insert('danh_muc', cat.toMap());
        }
        for (var ns in DuLieuMau.danhSachNganSach) {
          await db.insert('ngan_sach', ns.toMap());
        }
      },
    );
  }

  static Future<void> datLaiDuLieuKichBanDemoMinh() async {
    if (kIsWeb) {
      await _luuGiaoDichWeb(DuLieuMau.danhSachGiaoDich);
      await _luuDanhMucWeb(DuLieuMau.danhSachDanhMuc);
      await _luuNganSachWeb(DuLieuMau.danhSachNganSach);
      return;
    }
    final db = await database;
    await db.delete('giao_dich');
    await db.delete('danh_muc');
    await db.delete('ngan_sach');

    for (var item in DuLieuMau.danhSachGiaoDich) {
      await db.insert('giao_dich', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    for (var cat in DuLieuMau.danhSachDanhMuc) {
      await db.insert('danh_muc', cat.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    for (var ns in DuLieuMau.danhSachNganSach) {
      await db.insert('ngan_sach', ns.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  // --- QUẢN LÝ CẤU HÌNH CÁ NHÂN TRONG CSDL RIÊNG ---
  static Future<void> luuCauHinh(String khoa, String giaTri) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyWeb('cfg_$khoa'), giaTri);
      return;
    }
    final db = await database;
    await db.insert(
      'cau_hinh',
      {'khoa': khoa, 'giaTri': giaTri},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<String?> layCauHinh(String khoa) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyWeb('cfg_$khoa'));
    }
    final db = await database;
    final maps = await db.query(
      'cau_hinh',
      where: 'khoa = ?',
      whereArgs: [khoa],
    );
    if (maps.isNotEmpty) {
      return maps.first['giaTri'] as String?;
    }
    return null;
  }

  static Future<void> xoaCauHinh(String khoa) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyWeb('cfg_$khoa'));
      return;
    }
    final db = await database;
    await db.delete('cau_hinh', where: 'khoa = ?', whereArgs: [khoa]);
  }

  // Cấu hình giao diện tối (Lưu dùng chung toàn app)
  static Future<void> luuGiaoDienToi(bool isDark) async {
    await luuCauHinhChung('giao_dien_toi', isDark ? '1' : '0');
  }

  static Future<bool> layGiaoDienToi() async {
    final val = await layCauHinhChung('giao_dien_toi');
    return val == '1';
  }

  // Cấu hình số dư ban đầu
  static Future<void> luuSoDuBanDau(double soTien) async {
    await luuCauHinh('so_du_ban_dau', soTien.toString());
  }

  static Future<double> laySoDuBanDau() async {
    final val = await layCauHinh('so_du_ban_dau');
    return double.tryParse(val ?? '0') ?? 0.0;
  }

  // Cấu hình tỷ lệ 6 hũ
  static Future<void> luuTyLeHu(List<double> tyLe) async {
    await luuCauHinh('ty_le_hu', jsonEncode(tyLe));
  }

  static Future<List<double>?> layTyLeHu() async {
    final val = await layCauHinh('ty_le_hu');
    if (val == null || val.isEmpty) return null;
    try {
      final List dynamicList = jsonDecode(val);
      return dynamicList.map((e) => (e as num).toDouble()).toList();
    } catch (_) {
      return null;
    }
  }

  // Người dùng hiện tại & Đăng nhập / Đăng xuất
  static Future<void> luuNguoiDungHienTai(String? email) async {
    if (email == null || email.trim().isEmpty) {
      await xoaCauHinhChung('nguoi_dung_hien_tai');
    } else {
      await luuCauHinhChung('nguoi_dung_hien_tai', email.trim().toLowerCase());
    }
  }

  static Future<String?> layNguoiDungHienTai() async {
    return await layCauHinhChung('nguoi_dung_hien_tai');
  }

  static Future<void> luuThongTinNguoiDung({
    required String email,
    String hoTen = 'HỨA TRÍ NGUYÊN',
  }) async {
    await luuNguoiDungHienTai(email);
    await luuCauHinhChung('da_dang_nhap', '1');
    await luuCauHinhChung('email_nguoi_dung', email);
    await luuCauHinhChung('ho_ten_nguoi_dung', hoTen);
    await luuCauHinh('email_nguoi_dung', email);
    await luuCauHinh('ho_ten_nguoi_dung', hoTen);
  }

  static Future<Map<String, String>> layThongTinNguoiDung() async {
    final bool daDangNhap = await kiemTraDangNhap();
    if (!daDangNhap) {
      return {
        'email': 'Chưa đăng nhập',
        'hoTen': 'Khách hàng',
      };
    }
    final email = await layCauHinhChung('email_nguoi_dung') ?? await layCauHinh('email_nguoi_dung');
    final hoTen = await layCauHinhChung('ho_ten_nguoi_dung') ?? await layCauHinh('ho_ten_nguoi_dung');
    return {
      'email': (email != null && email.isNotEmpty) ? email : 'Chưa đăng nhập',
      'hoTen': (hoTen != null && hoTen.isNotEmpty) ? hoTen : 'Khách hàng',
    };
  }

  static Future<bool> kiemTraDangNhap() async {
    final val = await layCauHinhChung('da_dang_nhap');
    return val == '1';
  }

  static Future<void> xoaDangXuat() async {
    await xoaCauHinhChung('nguoi_dung_hien_tai');
    await luuCauHinhChung('da_dang_nhap', '0');
    await xoaCauHinhChung('email_nguoi_dung');
    await xoaCauHinhChung('ho_ten_nguoi_dung');
    await xoaCauHinh('da_dang_nhap');
    await datNguoiDung(null);
  }

  // --- HỖ TRỢ XỬ LÝ WEB (Shared Preferences Backup) ---
  static Future<List<MoHinhGiaoDich>> _layGiaoDichWeb() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keyWeb('giao_dich'));
    if (str == null || str.isEmpty) {
      final initial = DuLieuMau.danhSachGiaoDich;
      await _luuGiaoDichWeb(initial);
      return initial;
    }
    final List dynamicList = jsonDecode(str);
    return dynamicList.map((m) => MoHinhGiaoDich.fromMap(Map<String, dynamic>.from(m))).toList();
  }

  static Future<void> _luuGiaoDichWeb(List<MoHinhGiaoDich> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(list.map((e) => e.toMap()).toList());
    await prefs.setString(_keyWeb('giao_dich'), jsonStr);
  }

  static Future<List<MoHinhDanhMuc>> _layDanhMucWeb() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keyWeb('danh_muc'));
    if (str == null || str.isEmpty) {
      final initial = DuLieuMau.danhSachDanhMuc;
      await _luuDanhMucWeb(initial);
      return initial;
    }
    final List dynamicList = jsonDecode(str);
    return dynamicList.map((m) => MoHinhDanhMuc.fromMap(Map<String, dynamic>.from(m))).toList();
  }

  static Future<void> _luuDanhMucWeb(List<MoHinhDanhMuc> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(list.map((e) => e.toMap()).toList());
    await prefs.setString(_keyWeb('danh_muc'), jsonStr);
  }

  static Future<List<MoHinhNganSach>> _layNganSachWeb() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keyWeb('ngan_sach'));
    if (str == null || str.isEmpty) {
      final initial = DuLieuMau.danhSachNganSach;
      await _luuNganSachWeb(initial);
      return initial;
    }
    final List dynamicList = jsonDecode(str);
    return dynamicList.map((m) => MoHinhNganSach.fromMap(Map<String, dynamic>.from(m))).toList();
  }

  static Future<void> _luuNganSachWeb(List<MoHinhNganSach> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(list.map((e) => e.toMap()).toList());
    await prefs.setString(_keyWeb('ngan_sach'), jsonStr);
  }

  // --- CRUD GIAO DỊCH ---
  static Future<List<MoHinhGiaoDich>> layTatCaGiaoDich() async {
    if (kIsWeb) return await _layGiaoDichWeb();
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'giao_dich',
      orderBy: 'ngayGiaoDich DESC',
    );
    return maps.map((map) => MoHinhGiaoDich.fromMap(map)).toList();
  }

  static Future<void> themGiaoDich(MoHinhGiaoDich item) async {
    if (kIsWeb) {
      final list = await _layGiaoDichWeb();
      list.insert(0, item);
      await _luuGiaoDichWeb(list);
      return;
    }
    final db = await database;
    await db.insert(
      'giao_dich',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> capNhatGiaoDich(MoHinhGiaoDich item) async {
    if (kIsWeb) {
      final list = await _layGiaoDichWeb();
      final idx = list.indexWhere((x) => x.id == item.id);
      if (idx != -1) {
        list[idx] = item;
        await _luuGiaoDichWeb(list);
      }
      return;
    }
    final db = await database;
    await db.update(
      'giao_dich',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  static Future<void> xoaGiaoDich(String id) async {
    if (kIsWeb) {
      final list = await _layGiaoDichWeb();
      list.removeWhere((x) => x.id == id);
      await _luuGiaoDichWeb(list);
      return;
    }
    final db = await database;
    await db.delete(
      'giao_dich',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- CRUD DANH MỤC ---
  static Future<List<MoHinhDanhMuc>> layTatCaDanhMuc() async {
    if (kIsWeb) return await _layDanhMucWeb();
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('danh_muc');
    return maps.map((map) => MoHinhDanhMuc.fromMap(map)).toList();
  }

  static Future<void> themDanhMuc(MoHinhDanhMuc item) async {
    if (kIsWeb) {
      final list = await _layDanhMucWeb();
      list.add(item);
      await _luuDanhMucWeb(list);
      return;
    }
    final db = await database;
    await db.insert(
      'danh_muc',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // --- CRUD NGÂN SÁCH ---
  static Future<List<MoHinhNganSach>> layTatCaNganSach() async {
    if (kIsWeb) return await _layNganSachWeb();
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('ngan_sach');
    return maps.map((map) => MoHinhNganSach.fromMap(map)).toList();
  }

  static Future<void> luuNganSach(MoHinhNganSach item) async {
    if (kIsWeb) {
      final list = await _layNganSachWeb();
      final idx = list.indexWhere((x) => x.danhMuc == item.danhMuc);
      if (idx != -1) {
        list[idx] = item;
      } else {
        list.add(item);
      }
      await _luuNganSachWeb(list);
      return;
    }
    final db = await database;
    await db.insert(
      'ngan_sach',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> xoaNganSach(String id) async {
    if (kIsWeb) {
      final list = await _layNganSachWeb();
      list.removeWhere((x) => x.id == id);
      await _luuNganSachWeb(list);
      return;
    }
    final db = await database;
    await db.delete(
      'ngan_sach',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
