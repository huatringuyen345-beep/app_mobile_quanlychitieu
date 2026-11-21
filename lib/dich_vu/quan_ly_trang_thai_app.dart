import 'package:flutter/material.dart';
import '../mo_hinh/mo_hinh_giao_dich.dart';
import 'dich_vu_csdl.dart';
import 'dich_vu_firebase.dart';

class QuanLyTrangThaiApp extends ChangeNotifier {
  List<MoHinhGiaoDich> _danhSachGiaoDich = [];
  List<MoHinhDanhMuc> _danhSachDanhMuc = [];
  List<MoHinhNganSach> _danhSachNganSach = [];
  double _soDuBanDau = 0.0;
  bool _dangTai = true;

  List<MoHinhGiaoDich> get danhSachGiaoDich => List.unmodifiable(_danhSachGiaoDich);
  List<MoHinhDanhMuc> get danhSachDanhMuc => List.unmodifiable(_danhSachDanhMuc);
  List<MoHinhNganSach> get danhSachNganSach => List.unmodifiable(_danhSachNganSach);
  double get soDuBanDau => _soDuBanDau;
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

  /// Tổng số dư = Số dư ban đầu + Tổng thu nhập - Tổng chi tiêu
  double get tongSoDu => _soDuBanDau + tongThuNhap - tongChiTieu;

  QuanLyTrangThaiApp() {
    _khoiTao();
  }

  Future<void> _khoiTao() async {
    final emailHienTai = await DichVuCSDL.layNguoiDungHienTai();
    await DichVuCSDL.datNguoiDung(emailHienTai);
    await DichVuFirebase.datNguoiDung(emailHienTai);
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
    _soDuBanDau = 0.0;
    notifyListeners();
    await DichVuCSDL.luuNguoiDungHienTai(e);
    await DichVuCSDL.datNguoiDung(e);
    await DichVuFirebase.datNguoiDung(e);
    await taiDuLieuTuCSDL();
  }

  /// Làm sạch toàn bộ dữ liệu hiện tại về 0 (Xóa sạch bộ nhớ & CSDL)
  Future<void> xoaToanBoDuLieu() async {
    await DichVuCSDL.xoaToanBoDuLieu();
    _danhSachGiaoDich = [];
    _danhSachDanhMuc = [];
    _danhSachNganSach = [];
    _soDuBanDau = 0.0;
    notifyListeners();
  }

  /// Gọi khi đăng xuất: làm sạch bộ nhớ và CSDL, về trạng thái 0đ.
  Future<void> dangXuat() async {
    await xoaToanBoDuLieu();
    await chuyenNguoiDung(null);
  }

  /// Khôi phục nạp lại dữ liệu kịch bản Demo nhân vật Minh
  Future<void> datLaiDuLieuKichBanDemoMinh() async {
    await DichVuCSDL.datLaiDuLieuKichBanDemoMinh();
    await taiDuLieuTuCSDL();
  }

  Future<void> taiDuLieuTuCSDL() async {
    _dangTai = true;
    notifyListeners();
    for (final g in _danhSachGiaoDich) { await DichVuFirebase.dongBoGiaoDich(g); }
    for (final c in _danhSachDanhMuc) { await DichVuFirebase.dongBoDanhMuc(c); }
    for (final n in _danhSachNganSach) { await DichVuFirebase.dongBoNganSach(n); }
    try {
      _danhSachGiaoDich = await DichVuCSDL.layTatCaGiaoDich();
      _danhSachDanhMuc = await DichVuCSDL.layTatCaDanhMuc();
      _danhSachNganSach = await DichVuCSDL.layTatCaNganSach();
      _soDuBanDau = await DichVuCSDL.laySoDuBanDau();

      if (_danhSachDanhMuc.isEmpty) {
        _danhSachDanhMuc = List.from(DuLieuMau.danhSachDanhMuc);
        for (var c in _danhSachDanhMuc) {
          await DichVuCSDL.themDanhMuc(c);
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

  Future<void> capNhatSoDuBanDau(double soTien) async {
    _soDuBanDau = soTien;
    await DichVuFirebase.datSoDuBanDau(soTien);
    notifyListeners();
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

    DichVuFirebase.phatCapNhatNganSach(_danhSachNganSach);
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
    final idx = _danhSachNganSach.indexWhere((item) => item.id == ns.id || item.danhMuc == ns.danhMuc);
    if (idx != -1) {
      _danhSachNganSach[idx] = ns;
    } else {
      _danhSachNganSach.add(ns);
    }
    _capNhatDaDungChoNganSach();
    notifyListeners();
  }

  Future<void> xoaNganSach(String id) async {
    await DichVuCSDL.xoaNganSach(id);
    _danhSachNganSach.removeWhere((item) => item.id == id);
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
