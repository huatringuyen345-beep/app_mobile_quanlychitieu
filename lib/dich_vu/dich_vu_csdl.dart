import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../mo_hinh/mo_hinh_giao_dich.dart';

class DichVuCSDL {
  // Mỗi tài khoản có CSDL riêng (khóa theo email) -> đăng nhập tài khoản khác
  // sẽ thấy dữ liệu trống (0đ), không dính dữ liệu của người trước.
  static String _nguoiDung = 'khach';

  static String get _keyGiaoDichWeb => 'csdl_giao_dich_$_nguoiDung';
  static String get _keyDanhMucWeb => 'csdl_danh_muc_$_nguoiDung';
  static String get _keyNganSachWeb => 'csdl_ngan_sach_$_nguoiDung';

  static Database? _database;

  /// Chuyển sang CSDL của người dùng [email]. Truyền null/rỗng = khách (đã đăng xuất).
  static Future<void> datNguoiDung(String? email) async {
    final String id = (email == null || email.trim().isEmpty)
        ? 'khach'
        : email.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    if (id == _nguoiDung && _database != null) return;
    _nguoiDung = id;
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _khoiTaoCSDL();
    return _database!;
  }

  static Future<Database> _khoiTaoCSDL() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'quanly_chitieu_$_nguoiDung.db');

    return await openDatabase(
      path,
      version: 1,
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
            gioiHan REAL NOT NULL,
            daDung REAL NOT NULL,
            iconCodePoint INTEGER NOT NULL,
            mauSacValue INTEGER NOT NULL
          )
        ''');

        // Tài khoản mới: KHÔNG chèn giao dịch mẫu -> mọi số liệu bắt đầu từ 0
        for (var cat in DuLieuMau.danhSachDanhMuc) {
          await db.insert('danh_muc', cat.toMap());
        }
        for (var ns in DuLieuMau.danhSachNganSach) {
          await db.insert('ngan_sach', ns.toMap());
        }
      },
    );
  }

  // --- CRUD GIAO DỊCH ---
  static Future<List<MoHinhGiaoDich>> layTatCaGiaoDich() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_keyGiaoDichWeb);
      if (str == null || str.isEmpty) {
        final initial = <MoHinhGiaoDich>[];
        await _luuGiaoDichWeb(initial);
        return initial;
      }
      final List dynamicList = jsonDecode(str);
      return dynamicList
          .map((m) => MoHinhGiaoDich.fromMap(Map<String, dynamic>.from(m)))
          .toList();
    } else {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'giao_dich',
        orderBy: 'ngayGiaoDich DESC',
      );
      return maps.map((map) => MoHinhGiaoDich.fromMap(map)).toList();
    }
  }

  static Future<void> _luuGiaoDichWeb(List<MoHinhGiaoDich> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(list.map((e) => e.toMap()).toList());
    await prefs.setString(_keyGiaoDichWeb, jsonStr);
  }

  static Future<void> themGiaoDich(MoHinhGiaoDich item) async {
    if (kIsWeb) {
      final list = await layTatCaGiaoDich();
      list.insert(0, item);
      await _luuGiaoDichWeb(list);
    } else {
      final db = await database;
      await db.insert(
        'giao_dich',
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  static Future<void> capNhatGiaoDich(MoHinhGiaoDich item) async {
    if (kIsWeb) {
      final list = await layTatCaGiaoDich();
      final idx = list.indexWhere((x) => x.id == item.id);
      if (idx != -1) {
        list[idx] = item;
        await _luuGiaoDichWeb(list);
      }
    } else {
      final db = await database;
      await db.update(
        'giao_dich',
        item.toMap(),
        where: 'id = ?',
        whereArgs: [item.id],
      );
    }
  }

  static Future<void> xoaGiaoDich(String id) async {
    if (kIsWeb) {
      final list = await layTatCaGiaoDich();
      list.removeWhere((x) => x.id == id);
      await _luuGiaoDichWeb(list);
    } else {
      final db = await database;
      await db.delete(
        'giao_dich',
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  // --- CRUD DANH MỤC ---
  static Future<List<MoHinhDanhMuc>> layTatCaDanhMuc() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_keyDanhMucWeb);
      if (str == null || str.isEmpty) {
        final initial = DuLieuMau.danhSachDanhMuc;
        await _luuDanhMucWeb(initial);
        return initial;
      }
      final List dynamicList = jsonDecode(str);
      return dynamicList
          .map((m) => MoHinhDanhMuc.fromMap(Map<String, dynamic>.from(m)))
          .toList();
    } else {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('danh_muc');
      return maps.map((map) => MoHinhDanhMuc.fromMap(map)).toList();
    }
  }

  static Future<void> _luuDanhMucWeb(List<MoHinhDanhMuc> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(list.map((e) => e.toMap()).toList());
    await prefs.setString(_keyDanhMucWeb, jsonStr);
  }

  static Future<void> themDanhMuc(MoHinhDanhMuc item) async {
    if (kIsWeb) {
      final list = await layTatCaDanhMuc();
      list.add(item);
      await _luuDanhMucWeb(list);
    } else {
      final db = await database;
      await db.insert(
        'danh_muc',
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // --- CRUD NGÂN SÁCH ---
  static Future<List<MoHinhNganSach>> layTatCaNganSach() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_keyNganSachWeb);
      if (str == null || str.isEmpty) {
        final initial = DuLieuMau.danhSachNganSach;
        await _luuNganSachWeb(initial);
        return initial;
      }
      final List dynamicList = jsonDecode(str);
      return dynamicList
          .map((m) => MoHinhNganSach.fromMap(Map<String, dynamic>.from(m)))
          .toList();
    } else {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('ngan_sach');
      return maps.map((map) => MoHinhNganSach.fromMap(map)).toList();
    }
  }

  static Future<void> _luuNganSachWeb(List<MoHinhNganSach> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(list.map((e) => e.toMap()).toList());
    await prefs.setString(_keyNganSachWeb, jsonStr);
  }

  static Future<void> luuNganSach(MoHinhNganSach item) async {
    if (kIsWeb) {
      final list = await layTatCaNganSach();
      final idx = list.indexWhere((x) => x.danhMuc == item.danhMuc);
      if (idx != -1) {
        list[idx] = item;
      } else {
        list.add(item);
      }
      await _luuNganSachWeb(list);
    } else {
      final db = await database;
      await db.insert(
        'ngan_sach',
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}