import 'package:flutter/material.dart';
import '../dich_vu/quan_ly_trang_thai_app.dart';
import '../dich_vu/dich_vu_csdl.dart';
import '../dich_vu/dich_vu_firebase.dart';
import '../dich_vu/dich_vu_thong_bao.dart';
import '../mo_hinh/mo_hinh_giao_dich.dart';
import '../thien_ich/dinh_dang_tien.dart';
import '../thong_bao/man_hinh_cai_dat_thong_bao.dart';

class ManHinhCaiDat extends StatefulWidget {
  final VoidCallback? chuyenToiDanhMuc;
  final VoidCallback? chuyenToiNganSach;
  final VoidCallback? chuyenToiThongBao;
  final VoidCallback? dangXuat;

  final ValueChanged<bool>? khiDoiGiaoDienToi;
  final bool laGiaoDienToi;

  const ManHinhCaiDat({
    super.key,
    this.chuyenToiDanhMuc,
    this.chuyenToiNganSach,
    this.chuyenToiThongBao,
    this.dangXuat,
    this.khiDoiGiaoDienToi,
    this.laGiaoDienToi = false,
  });

  @override
  State<ManHinhCaiDat> createState() => _ManHinhCaiDatState();
}

class _ManHinhCaiDatState extends State<ManHinhCaiDat> {
  late bool _giaoDienToi;
  bool _vanTayBaoMat = true;
  bool _thongBao = true;

  String _hoTen = 'Khách hàng';
  String _email = 'Chưa đăng nhập';

  static const Color mauChinh = Color(0xFFE07852);

  @override
  void initState() {
    super.initState();
    _giaoDienToi = widget.laGiaoDienToi;
    _taiThongTinNguoiDung();
  }

  @override
  void didUpdateWidget(covariant ManHinhCaiDat oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.laGiaoDienToi != widget.laGiaoDienToi) {
      setState(() {
        _giaoDienToi = widget.laGiaoDienToi;
      });
    }
  }

  Future<void> _taiThongTinNguoiDung() async {
    final thongTin = await DichVuCSDL.layThongTinNguoiDung();
    final isDark = await DichVuCSDL.layGiaoDienToi();
    final isNotify = await DichVuThongBao().layChoPhepThongBao();
    if (mounted) {
      setState(() {
        _hoTen = thongTin['hoTen'] ?? 'Khách hàng';
        _email = thongTin['email'] ?? 'Chưa đăng nhập';
        _giaoDienToi = isDark;
        _thongBao = isNotify;
      });
    }
  }

  Future<void> _ghiDuLieuPhucHoiVaoCSDL(Map<String, dynamic> data) async {
    if (data['so_du_ban_dau'] != null) {
      final val = double.tryParse(data['so_du_ban_dau'].toString());
      if (val != null) {
        await DichVuCSDL.luuSoDuBanDau(val);
      }
    }

    if (data['danh_muc'] is List) {
      for (final item in (data['danh_muc'] as List)) {
        if (item is Map) {
          final dm = MoHinhDanhMuc.fromMap(Map<String, dynamic>.from(item));
          await DichVuCSDL.themDanhMuc(dm);
        }
      }
    }

    if (data['ngan_sach'] is List) {
      for (final item in (data['ngan_sach'] as List)) {
        if (item is Map) {
          final ns = MoHinhNganSach.fromMap(Map<String, dynamic>.from(item));
          await DichVuCSDL.luuNganSach(ns);
        }
      }
    }

    if (data['giao_dich'] is List) {
      for (final item in (data['giao_dich'] as List)) {
        if (item is Map) {
          final gd = MoHinhGiaoDich.fromMap(Map<String, dynamic>.from(item));
          await DichVuCSDL.themGiaoDich(gd);
        }
      }
    }
  }

  void _hienHopThoaiSaoLuuPhucHoi(BuildContext context, bool isDark) {
    final messenger = ScaffoldMessenger.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sao lưu & Phục hồi Firebase',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E232A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tài khoản: $_email',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(sheetContext);
                    if (_email == 'Chưa đăng nhập' || _email.trim().isEmpty) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content:
                          Text('Bạn cần đăng nhập để sao lưu lên Firebase!'),
                        ),
                      );
                      return;
                    }

                    final soDuBanDau = await DichVuCSDL.laySoDuBanDau();
                    final giaoDich = await DichVuCSDL.layTatCaGiaoDich();
                    final nganSach = await DichVuCSDL.layTatCaNganSach();
                    final danhMuc = await DichVuCSDL.layTatCaDanhMuc();

                    final goiDuLieu = <String, dynamic>{
                      'so_du_ban_dau': soDuBanDau,
                      'giao_dich': giaoDich.map((e) => e.toMap()).toList(),
                      'ngan_sach': nganSach.map((e) => e.toMap()).toList(),
                      'danh_muc': danhMuc.map((e) => e.toMap()).toList(),
                    };

                    final kq = await DichVuFirebase.saoLuuToanBoDuLieu(
                      email: _email,
                      goiDuLieu: goiDuLieu,
                    );

                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(kq.thongBao),
                        backgroundColor:
                        kq.thanhCong ? mauChinh : Colors.redAccent,
                      ),
                    );
                  },
                  icon: const Icon(Icons.cloud_upload_rounded,
                      color: Colors.white),
                  label: const Text(
                    'Sao lưu toàn bộ lên Firebase',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mauChinh,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(sheetContext);
                    if (_email == 'Chưa đăng nhập' || _email.trim().isEmpty) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Bạn cần đăng nhập để phục hồi từ Firebase!'),
                        ),
                      );
                      return;
                    }

                    final kq = await DichVuFirebase.phucHoiToanBoDuLieu(_email);
                    if (!kq.thanhCong || kq.duLieu == null) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(kq.thongBao),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    final data = Map<String, dynamic>.from(kq.duLieu as Map);
                    await _ghiDuLieuPhucHoiVaoCSDL(data);

                    if (mounted) {
                      await _taiThongTinNguoiDung();
                      setState(() {});
                    }

                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          '${kq.thongBao} Hãy mở lại màn hình hoặc khởi động lại app để cập nhật đầy đủ dữ liệu.',
                        ),
                        backgroundColor: mauChinh,
                      ),
                    );
                  },
                  icon: const Icon(Icons.cloud_download_rounded,
                      color: mauChinh),
                  label: const Text(
                    'Phục hồi dữ liệu từ Firebase',
                    style:
                    TextStyle(color: mauChinh, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: mauChinh),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _hienHopThoaiSoDuBanDau(BuildContext context, bool isDark) {
    final quanLy = QuanLyTrangThaiScope.of(context);
    final controller = TextEditingController(
      text: DinhDangTienInputFormatter.dinhDang(quanLy.soDuBanDau),
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          title: Text(
            'Quản lý số dư ban đầu',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: isDark ? Colors.white : const Color(0xFF1E232A),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Nhập số tiền vốn ban đầu của bạn trước khi ghi chép thu chi:',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: false, signed: false),
                inputFormatters: [DinhDangTienInputFormatter()],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  labelText: 'Số dư ban đầu (VNĐ)',
                  labelStyle: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF7F8F4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.all(20),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFF1F5F9),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      'Hủy',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1E232A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final double? val =
                      DinhDangTienInputFormatter.giaiMaSoTien(
                          controller.text);
                      if (val != null) {
                        await quanLy.capNhatSoDuBanDau(val);
                      }
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                            Text('Đã cập nhật số dư ban đầu thành công!'),
                            backgroundColor: mauChinh,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mauChinh,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      'Lưu',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _hienHopThoaiXacNhanMatKhau({
    required BuildContext context,
    required bool isDark,
    required String tieuDe,
    required VoidCallback khiNhapDung,
  }) {
    final controller = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              title: Row(
                children: [
                  const Icon(Icons.lock_outline_rounded, color: mauChinh),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Xác nhận mật khẩu',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isDark ? Colors.white : const Color(0xFF1E232A),
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nhập mật khẩu (pass: ****) để thực hiện "$tieuDe":',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    autofocus: true,
                    style: TextStyle(
                      fontSize: 18,
                      letterSpacing: 4,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu (4 số)',
                      labelStyle: TextStyle(
                          color: isDark ? const Color(0xFF94A3B8) : Colors.grey),
                      errorText: errorText,
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF7F8F4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.all(20),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFF1F5F9),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          'Hủy',
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF1E232A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (controller.text == '0000') {
                            Navigator.pop(dialogContext);
                            khiNhapDung();
                          } else {
                            setDialogState(() {
                              errorText = 'Mật khẩu không đúng!';
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mauChinh,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text(
                          'Xác nhận',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _hienThongTinUngDung(BuildContext context, bool isDark) {
    final quanLy = QuanLyTrangThaiScope.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E8),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    size: 40, color: mauChinh),
              ),
              const SizedBox(height: 12),
              Text(
                'Quản lý Chi tiêu',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E232A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Phiên bản 1.0.0 (SQLite & Firebase)',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Ứng dụng quản lý tài chính cá nhân thông minh, tích hợp Quy tắc 6 Hũ tài chính, tự động tính toán số dư và đồng bộ thời gian thực.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 24),
              Divider(color: isDark ? const Color(0xFF334155) : null),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tính năng Hệ thống (Nhập pass: 0000)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _taoMucCaiDat(
                icon: Icons.play_circle_fill_rounded,
                mauIcon: Colors.purple,
                tieuDe: 'Nạp kịch bản Demo (Minh NVKD)',
                moTa: 'Nạp dữ liệu mẫu Lương 16,2Tr, 6 Hũ & Giao dịch',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _hienHopThoaiXacNhanMatKhau(
                    context: context,
                    isDark: isDark,
                    tieuDe: 'Nạp kịch bản Demo',
                    khiNhapDung: () async {
                      await quanLy.datLaiDuLieuKichBanDemoMinh();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Đã nạp thành công dữ liệu kịch bản Demo (Minh NVKD)!'),
                            backgroundColor: mauChinh,
                          ),
                        );
                      }
                    },
                  );
                },
                isDark: isDark,
              ),
              const SizedBox(height: 4),
              _taoMucCaiDat(
                icon: Icons.delete_sweep_rounded,
                mauIcon: Colors.redAccent,
                tieuDe: 'Đặt lại toàn bộ dữ liệu (Reset về 0)',
                moTa: 'Xóa sạch giao dịch, ngân sách & số dư',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _hienHopThoaiXacNhanMatKhau(
                    context: context,
                    isDark: isDark,
                    tieuDe: 'Đặt lại toàn bộ dữ liệu (Reset về 0)',
                    khiNhapDung: () => _hienHopThoaiXacNhanReset(context, isDark),
                  );
                },
                isDark: isDark,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _hienHopThoaiXacNhanReset(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          title: Text(
            'Đặt lại toàn bộ dữ liệu',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: isDark ? Colors.white : const Color(0xFF1E232A),
            ),
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa toàn bộ giao dịch, ngân sách và đưa số dư về 0đ không?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
              height: 1.4,
            ),
          ),
          actionsPadding: const EdgeInsets.all(20),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFF1F5F9),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      'Hủy',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1E232A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(dialogContext);
                      await QuanLyTrangThaiScope.of(context).xoaToanBoDuLieu();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Đã xóa toàn bộ dữ liệu và reset về 0đ thành công!'),
                            backgroundColor: mauChinh,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      'Đặt lại (0đ)',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _hienHopThoaiXacNhanDangXuat() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          title: Text(
            'Đăng xuất',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: isDark ? Colors.white : const Color(0xFF1E232A),
            ),
          ),
          content: Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản không?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
              height: 1.4,
            ),
          ),
          actionsPadding: const EdgeInsets.all(20),
          actions: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFF1F5F9),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Hủy',
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF1E232A),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(dialogContext);
                        await DichVuCSDL.xoaDangXuat();
                        if (mounted) {
                          await QuanLyTrangThaiScope.of(context).dangXuat();
                        }
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã đăng xuất thành công!'),
                              backgroundColor: mauChinh,
                            ),
                          );
                          if (widget.dangXuat != null) {
                            widget.dangXuat!();
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mauChinh,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Đăng xuất',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final quanLy = QuanLyTrangThaiScope.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Cài đặt & Tài khoản',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E232A),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : const Color(0xFF1E232A),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE8EAE5)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFFFFF4E8),
                    child:
                    Icon(Icons.person_rounded, size: 36, color: mauChinh),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _hoTen,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _email,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_outlined, color: mauChinh),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Quản lý dữ liệu & Số dư',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE8EAE5)),
              ),
              child: Column(
                children: [
                  _taoMucCaiDat(
                    icon: Icons.monetization_on_rounded,
                    mauIcon: Colors.green,
                    tieuDe: 'Quản lý số dư ban đầu',
                    moTa:
                    'Hiện tại: ${DinhDangTienInputFormatter.dinhDang(quanLy.soDuBanDau)}',
                    onTap: () => _hienHopThoaiSoDuBanDau(context, isDark),
                    isDark: isDark,
                  ),
                  Divider(
                      height: 1,
                      indent: 56,
                      endIndent: 16,
                      color: isDark ? const Color(0xFF334155) : null),
                  _taoMucCaiDat(
                    icon: Icons.category_rounded,
                    mauIcon: Colors.orange,
                    tieuDe: 'Quản lý danh mục',
                    moTa: 'Tùy chỉnh danh mục thu chi',
                    onTap: widget.chuyenToiDanhMuc,
                    isDark: isDark,
                  ),
                  Divider(
                      height: 1,
                      indent: 56,
                      endIndent: 16,
                      color: isDark ? const Color(0xFF334155) : null),
                  _taoMucCaiDat(
                    icon: Icons.account_balance_wallet_rounded,
                    mauIcon: Colors.blue,
                    tieuDe: 'Quản lý ngân sách',
                    moTa: 'Đặt hạn mức chi tiêu hàng tháng',
                    onTap: widget.chuyenToiNganSach,
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Cài đặt ứng dụng',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE8EAE5)),
              ),
              child: Column(
                children: [
                  _taoMucCongTac(
                    icon: Icons.dark_mode_rounded,
                    mauIcon: Colors.indigo,
                    tieuDe: 'Giao diện tối',
                    giaTri: _giaoDienToi,
                    khiDoi: (val) async {
                      setState(() {
                        _giaoDienToi = val;
                      });
                      await DichVuCSDL.luuGiaoDienToi(val);
                      if (widget.khiDoiGiaoDienToi != null) {
                        widget.khiDoiGiaoDienToi!(val);
                      }
                    },
                    isDark: isDark,
                  ),
                  Divider(
                      height: 1,
                      indent: 56,
                      endIndent: 16,
                      color: isDark ? const Color(0xFF334155) : null),
                  _taoMucCongTac(
                    icon: Icons.fingerprint_rounded,
                    mauIcon: Colors.teal,
                    tieuDe: 'Bảo mật vân tay',
                    giaTri: _vanTayBaoMat,
                    khiDoi: (val) {
                      setState(() {
                        _vanTayBaoMat = val;
                      });
                    },
                    isDark: isDark,
                  ),
                  Divider(
                      height: 1,
                      indent: 56,
                      endIndent: 16,
                      color: isDark ? const Color(0xFF334155) : null),
                  _taoMucCaiDat(
                    icon: Icons.notifications_active_rounded,
                    mauIcon: Colors.amber,
                    tieuDe: 'Thông báo & Lịch nhắc nhở',
                    moTa: _thongBao
                        ? 'Đang bật • Đặt thời gian & lịch nhắc nhở'
                        : 'Đã tắt thông báo nhắc nhở',
                    onTap: () {
                      if (widget.chuyenToiThongBao != null) {
                        widget.chuyenToiThongBao!();
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ManHinhCaiDatThongBao()),
                        ).then((_) => _taiThongTinNguoiDung());
                      }
                    },
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Hệ thống',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE8EAE5)),
              ),
              child: Column(
                children: [
                  _taoMucCaiDat(
                    icon: Icons.cloud_upload_rounded,
                    mauIcon: Colors.cyan,
                    tieuDe: 'Sao lưu & Phục hồi (Firebase)',
                    moTa: 'Sao lưu & phục hồi dữ liệu trên Firebase',
                    onTap: () => _hienHopThoaiSaoLuuPhucHoi(context, isDark),
                    isDark: isDark,
                  ),
                  Divider(
                      height: 1,
                      indent: 56,
                      endIndent: 16,
                      color: isDark ? const Color(0xFF334155) : null),
                  _taoMucCaiDat(
                    icon: Icons.info_outline_rounded,
                    mauIcon: Colors.purple,
                    tieuDe: 'Thông tin ứng dụng',
                    moTa: 'Phiên bản 1.0.0 (SQLite & Firebase)',
                    onTap: () => _hienThongTinUngDung(context, isDark),
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _hienHopThoaiXacNhanDangXuat,
                icon: const Icon(Icons.logout_rounded, color: mauChinh),
                label: const Text(
                  'Đăng xuất',
                  style: TextStyle(
                    color: mauChinh,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  isDark ? const Color(0xFF3B1D15) : const Color(0xFFFFF4E8),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _taoMucCaiDat({
    required IconData icon,
    required Color mauIcon,
    required String tieuDe,
    String? moTa,
    VoidCallback? onTap,
    bool isDark = false,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: mauIcon.withValues(alpha: 0.15),
        child: Icon(icon, color: mauIcon, size: 22),
      ),
      title: Text(
        tieuDe,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: moTa != null
          ? Text(
        moTa,
        style: TextStyle(
            fontSize: 12,
            color: isDark ? const Color(0xFF94A3B8) : Colors.grey),
      )
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _taoMucCongTac({
    required IconData icon,
    required Color mauIcon,
    required String tieuDe,
    required bool giaTri,
    required ValueChanged<bool> khiDoi,
    bool isDark = false,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: mauIcon.withValues(alpha: 0.15),
        child: Icon(icon, color: mauIcon, size: 22),
      ),
      title: Text(
        tieuDe,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      trailing: Switch(
        value: giaTri,
        activeThumbColor: mauChinh,
        onChanged: khiDoi,
      ),
    );
  }
}