import 'package:flutter/material.dart';
import 'cot_loi/giao_dien/giao_dien_app.dart';
import 'cot_loi/giao_dien/khung_nen_app.dart';
import 'dich_vu/dich_vu_luu_tru.dart';
import 'dich_vu/quan_ly_trang_thai_app.dart';
import 'mo_hinh/mo_hinh_giao_dich.dart';
import 'thanh_phan/thanh_dieu_huong_duoi.dart';
import 'khoi_dau/man_hinh_khoi_dau.dart';
import 'trang_chu/man_hinh_trang_chu.dart';
import 'giao_dich/man_hinh_danh_sach_giao_dich.dart';
import 'giao_dich/man_hinh_them_giao_dich.dart';
import 'giao_dich/man_hinh_chi_tiet_giao_dich.dart';
import 'thong_ke/man_hinh_thong_ke.dart';
import 'danh_muc/man_hinh_danh_muc.dart';
import 'ngan_sach/man_hinh_ngan_sach.dart';
import 'cai_dat/man_hinh_cai_dat.dart';
import 'log in/dang_ky.dart';
import 'log in/dang_nhap.dart';

void main() {
  runApp(const ExpenseApp());
}

typedef MyApp = ExpenseApp;

class ExpenseApp extends StatefulWidget {
  const ExpenseApp({super.key});

  @override
  State<ExpenseApp> createState() => _ExpenseAppState();
}

class _ExpenseAppState extends State<ExpenseApp> {
  final QuanLyTrangThaiApp _quanLyTrangThai = QuanLyTrangThaiApp();
  bool _daHoanThanhKhoiDau = false;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _taiCauHinhGiaoDien();
  }

  Future<void> _taiCauHinhGiaoDien() async {
    final isDark = await DichVuLuuTru.layGiaoDienToi();
    if (mounted) {
      setState(() {
        _isDarkMode = isDark;
      });
    }
  }

  void _doiGiaoDienToi(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return QuanLyTrangThaiScope(
      quanLyTrangThai: _quanLyTrangThai,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Quản lý chi tiêu',
        theme: GiaoDienApp.themeSang,
        darkTheme: GiaoDienApp.themeToi,
        themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: _daHoanThanhKhoiDau
            ? DieuHuongChinh(
                isDarkMode: _isDarkMode,
                onToggleDarkMode: _doiGiaoDienToi,
              )
            : ManHinhKhoiDau(
                thoiGianChoGiay: 10,
                khiHoanThanh: () {
                  setState(() {
                    _daHoanThanhKhoiDau = true;
                  });
                },
              ),
      ),
    );
  }
}

class DieuHuongChinh extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onToggleDarkMode;

  const DieuHuongChinh({
    super.key,
    required this.isDarkMode,
    required this.onToggleDarkMode,
  });

  @override
  State<DieuHuongChinh> createState() => _DieuHuongChinhState();
}

class _DieuHuongChinhState extends State<DieuHuongChinh> {
  int _viTriTab = 0;
  MoHinhGiaoDich? _giaoDichDuocChon;
  int _viTriManHinhDocLap = -1; // -1 la che do xem toan bo app

  final List<String> _tenCacManHinh = [
    '0. Màn hình khởi đầu (Loading 10s)',
    '1. Trang chủ (Trang chu)',
    '2. Danh sách giao dịch (Danh sach giao dich)',
    '3. Thêm giao dịch mới (Them giao dich)',
    '4. Chi tiết giao dịch (Chi tiet giao dich)',
    '5. Thống kê & Báo cáo (Thong ke)',
    '6. Quản lý danh mục (Danh muc)',
    '7. Ngân sách & Tiết kiệm (Ngan sach)',
    '8. Cài đặt & Tài khoản (Cai dat)',
    '9. Đăng ký tài khoản (Dang ky)',
    '10. Đăng nhập (Dang nhap)',
  ];

  @override
  Widget build(BuildContext context) {
    Widget noiDung;

    if (_viTriManHinhDocLap != -1) {
      noiDung = _taoManHinhDocLap(_viTriManHinhDocLap);
    } else {
      switch (_viTriTab) {
        case 0:
          noiDung = ManHinhTrangChu(
        //noiDung = ManHinhSauHu(
            chuyenToiDanhSachGiaoDich: () {
              setState(() {
                _viTriTab = 1;
              });
            },
            chuyenToiThemGiaoDich: () {
              setState(() {
                _viTriTab = 2;
              });
            },
            chonGiaoDich: (tx) {
              setState(() {
                _giaoDichDuocChon = tx;
                _viTriManHinhDocLap = 4;
              });
            },
          );
          break;
        case 1:
          noiDung = ManHinhDanhSachGiaoDich(
            chonGiaoDich: (tx) {
              setState(() {
                _giaoDichDuocChon = tx;
                _viTriManHinhDocLap = 4;
              });
            },
          );
          break;
        case 2:
          noiDung = ManHinhThemGiaoDich(
            khiDaLuu: () {
              setState(() {
                _viTriTab = 0;
              });
            },
          );
          break;
        case 3:
          noiDung = const ManHinhThongKe();
          break;
        case 4:
          noiDung = ManHinhCaiDat(
            laGiaoDienToi: widget.isDarkMode,
            khiDoiGiaoDienToi: widget.onToggleDarkMode,
            chuyenToiDanhMuc: () {
              setState(() {
                _viTriManHinhDocLap = 6;
              });
            },
            chuyenToiNganSach: () {
              setState(() {
                _viTriManHinhDocLap = 7;
              });
            },
            dangXuat: () {
              setState(() {
                _viTriManHinhDocLap = 10; // Chuyển sang màn hình Đăng nhập
              });
            },
          );
          break;
        default:
          noiDung = const ManHinhTrangChu();
      }
    }

    return KhungNenApp(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          toolbarHeight: 46,
          backgroundColor: const Color(0xFFE07852),
          foregroundColor: Colors.white,
          title: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _viTriManHinhDocLap,
              dropdownColor: const Color(0xFFB8532F),
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.white),
              items: [
                const DropdownMenuItem<int>(
                  value: -1,
                  child: Text('📱 Chế độ Xem Toàn Bộ App'),
                ),
                ...List.generate(_tenCacManHinh.length, (index) {
                  return DropdownMenuItem<int>(
                    value: index,
                    child: Text('🖼️ ${_tenCacManHinh[index]}'),
                  );
                }),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _viTriManHinhDocLap = value;
                  });
                }
              },
            ),
          ),
          actions: [
            if (_viTriManHinhDocLap != -1)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _viTriManHinhDocLap = -1;
                  });
                },
                icon: const Icon(Icons.arrow_back_rounded, size: 16, color: Colors.white),
                label: const Text('Quay lại', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
          ],
        ),
        body: noiDung,
        bottomNavigationBar: _viTriManHinhDocLap == -1
            ? ThanhDieuHuongDuoi(
                viTriHienTai: _viTriTab,
                khiChon: (index) {
                  setState(() {
                    _viTriTab = index;
                  });
                },
              )
            : null,
      ),
    );
  }

  Widget _taoManHinhDocLap(int index) {
    switch (index) {
      case 0:
        return ManHinhKhoiDau(
        //return ManHinhSauHu(
          thoiGianChoGiay: 10,
          khiHoanThanh: () => setState(() => _viTriManHinhDocLap = -1),
        );
      case 1:
        return ManHinhTrangChu(
          chuyenToiDanhSachGiaoDich: () => setState(() => _viTriManHinhDocLap = 2),
          chuyenToiThemGiaoDich: () => setState(() => _viTriManHinhDocLap = 3),
          chonGiaoDich: (tx) => setState(() {
            _giaoDichDuocChon = tx;
            _viTriManHinhDocLap = 4;
          }),
        );
      case 2:
        return ManHinhDanhSachGiaoDich(
          chonGiaoDich: (tx) => setState(() {
            _giaoDichDuocChon = tx;
            _viTriManHinhDocLap = 4;
          }),
        );
      case 3:
        return ManHinhThemGiaoDich(
          khiDaLuu: () => setState(() => _viTriManHinhDocLap = 1),
        );
      case 4:
        return ManHinhChiTietGiaoDich(
          giaoDich: _giaoDichDuocChon ?? DuLieuMau.danhSachGiaoDich.first,
          khiQuayLai: () => setState(() => _viTriManHinhDocLap = 1),
        );
      case 5:
        return const ManHinhThongKe();
      case 6:
        return const ManHinhDanhMuc();
      case 7:
        return const ManHinhNganSach();
      case 8:
        return ManHinhCaiDat(
          laGiaoDienToi: widget.isDarkMode,
          khiDoiGiaoDienToi: widget.onToggleDarkMode,
          chuyenToiDanhMuc: () => setState(() => _viTriManHinhDocLap = 6),
          chuyenToiNganSach: () => setState(() => _viTriManHinhDocLap = 7),
          dangXuat: () => setState(() => _viTriManHinhDocLap = 10),
        );
      case 9:
        return ManHinhDangKy(
          chuyenToiDangNhap: () => setState(() => _viTriManHinhDocLap = 10),
          khiDangKyThanhCong: () => setState(() => _viTriManHinhDocLap = -1),
        );
      case 10:
        return ManHinhDangNhap(
          chuyenToiDangKy: () => setState(() => _viTriManHinhDocLap = 9),
          khiDangNhapThanhCong: () => setState(() => _viTriManHinhDocLap = -1),
        );
      default:
        return const ManHinhTrangChu();
    }
  }
}
