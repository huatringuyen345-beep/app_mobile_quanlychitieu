import 'package:flutter/material.dart';
import '../mo_hinh/mo_hinh_giao_dich.dart';
import 'dich_vu_csdl.dart';
import 'dich_vu_luu_tru.dart';
import 'dich_vu_firebase.dart';

class QuanLyTrangThaiApp extends ChangeNotifier {
  List<MoHinhGiaoDich> _danhSachGiaoDich = [];
  List<MoHinhDanhMuc> _danhSachDanhMuc = [];
  List<MoHinhNganSach> _danhSachNganSach = [];
  bool _dangTai = true;

  List<MoHinhGiaoDich> get danhSachGiaoDich => List.unmodifiable(_danhSachGiaoDich);
  List<MoHinhDanhMuc> get danhSachDanhMuc => List.unmodifiable(_danhSachDanhMuc);
  List<MoHinhNganSach> get danhSachNganSach => List.unmodifiable(_danhSachNganSach);
  bool get dangTai => _dangTai;

  double get tongThuNhap {
    return _danhSachGiaoDich
        .where((tx) => tx.laThuNhap)
        .fold(0.0, (sum, item) => sum + item.soTien);
  }

  double get tongChiTieu {
    return _danhSachGiaoDich
        .where((tx) => !tx.laThuNhap)
        .fold(0.0, (sum, item) => sum + item.soTien);
  }

  double get tongSoDu => tongThuNhap - tongChiTieu;

  QuanLyTrangThaiApp() {
    _khoiTao();
  }

  Future<void> _khoiTao() async {
    // Mở đúng CSDL của tài khoản đang đăng nhập lần trước (nếu có)
    await DichVuCSDL.datNguoiDung(await DichVuLuuTru.layNguoiDungHienTai());
    await taiDuLieuTuCSDL();
  }

  /// Gọi khi đăng nhập / đăng ký: chuyển sang dữ liệu riêng của [email].
  Future<void> chuyenNguoiDung(String? email) async {
    final String? e = (email == null || email.trim().isEmpty)
        ? null
        : email.trim().toLowerCase();
    // Xóa sạch dữ liệu trên màn hình ngay lập tức -> mọi số về 0
    _danhSachGiaoDich = [];
    _danhSachDanhMuc = [];
    _danhSachNganSach = [];
    notifyListeners();
    await DichVuLuuTru.luuNguoiDungHienTai(e);
    await DichVuCSDL.datNguoiDung(e);
    await taiDuLieuTuCSDL();
  }

  /// Gọi khi đăng xuất: về trạng thái khách, dữ liệu người trước biến mất khỏi app.
  Future<void> dangXuat() => chuyenNguoiDung(null);

  Future<void> taiDuLieuTuCSDL() async {
    _dangTai = true;
    notifyListeners();

    try {
      _danhSachGiaoDich = await DichVuCSDL.layTatCaGiaoDich();
      _danhSachDanhMuc = await DichVuCSDL.layTatCaDanhMuc();
      _danhSachNganSach = await DichVuCSDL.layTatCaNganSach();

      if (_danhSachDanhMuc.isEmpty) {
        _danhSachDanhMuc = List.from(DuLieuMau.danhSachDanhMuc);
        for (var c in _danhSachDanhMuc) {
          await DichVuCSDL.themDanhMuc(c);
        }
      }

      if (_danhSachNganSach.isEmpty) {
        _danhSachNganSach = List.from(DuLieuMau.danhSachNganSach);
        for (var ns in _danhSachNganSach) {
          await DichVuCSDL.luuNganSach(ns);
        }
      }

      _capNhatDaDungChoNganSach();
    } catch (e) {
      debugPrint('Lỗi tải CSDL: $e');
    } finally {
      _dangTai = false;
      notifyListeners();
    }
  }

  void _capNhatDaDungChoNganSach() {
    final Map<String, double> tongChiTheoDanhMuc = {};
    for (var tx in _danhSachGiaoDich) {
      if (!tx.laThuNhap) {
        tongChiTheoDanhMuc[tx.danhMuc] =
            (tongChiTheoDanhMuc[tx.danhMuc] ?? 0.0) + tx.soTien;
      }
    }

    _danhSachNganSach = _danhSachNganSach.map((ns) {
      final daDungMoi = tongChiTheoDanhMuc[ns.danhMuc] ?? 0.0;
      return ns.copyWith(daDung: daDungMoi);
    }).toList();
  }

  Future<void> themGiaoDich(MoHinhGiaoDich tx) async {
    await DichVuCSDL.themGiaoDich(tx);
    await DichVuFirebase.dongBoGiaoDich(tx);
    _danhSachGiaoDich.insert(0, tx);
    _capNhatDaDungChoNganSach();
    notifyListeners();
  }

  Future<void> capNhatGiaoDich(MoHinhGiaoDich tx) async {
    await DichVuCSDL.capNhatGiaoDich(tx);
    await DichVuFirebase.dongBoGiaoDich(tx);
    final idx = _danhSachGiaoDich.indexWhere((item) => item.id == tx.id);
    if (idx != -1) {
      _danhSachGiaoDich[idx] = tx;
      _capNhatDaDungChoNganSach();
      notifyListeners();
    }
  }

  Future<void> xoaGiaoDich(String id) async {
    await DichVuCSDL.xoaGiaoDich(id);
    await DichVuFirebase.xoaGiaoDich(id);
    _danhSachGiaoDich.removeWhere((item) => item.id == id);
    _capNhatDaDungChoNganSach();
    notifyListeners();
  }

  Future<void> themDanhMuc(MoHinhDanhMuc cat) async {
    await DichVuCSDL.themDanhMuc(cat);
    await DichVuFirebase.dongBoDanhMuc(cat);
    _danhSachDanhMuc.add(cat);
    notifyListeners();
  }

  Future<void> luuNganSach(MoHinhNganSach ns) async {
    await DichVuCSDL.luuNganSach(ns);
    await DichVuFirebase.dongBoNganSach(ns);
    final idx = _danhSachNganSach.indexWhere((item) => item.danhMuc == ns.danhMuc);
    if (idx != -1) {
      _danhSachNganSach[idx] = ns;
    } else {
      _danhSachNganSach.add(ns);
    }
    _capNhatDaDungChoNganSach();
    notifyListeners();
  }
}

class QuanLyTrangThaiScope extends InheritedNotifier<QuanLyTrangThaiApp> {
  const QuanLyTrangThaiScope({
    super.key,
    required QuanLyTrangThaiApp quanLyTrangThai,
    required super.child,
  }) : super(notifier: quanLyTrangThai);

  static QuanLyTrangThaiApp of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<QuanLyTrangThaiScope>();
    assert(scope != null, 'Không tìm thấy QuanLyTrangThaiScope trong Context');
    return scope!.notifier!;
  }
}