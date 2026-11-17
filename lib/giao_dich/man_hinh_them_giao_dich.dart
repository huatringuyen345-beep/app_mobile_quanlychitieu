import 'package:flutter/material.dart';
import '../dich_vu/quan_ly_trang_thai_app.dart';
import '../mo_hinh/mo_hinh_giao_dich.dart';
import '../thien_ich/dinh_dang_tien.dart';
import '../thien_ich/kiem_tra_dieu_kien.dart';

class ManHinhThemGiaoDich extends StatefulWidget {
  final VoidCallback? khiDaLuu;

  const ManHinhThemGiaoDich({
    super.key,
    this.khiDaLuu,
  });

  @override
  State<ManHinhThemGiaoDich> createState() => _ManHinhThemGiaoDichState();
}

class _ManHinhThemGiaoDichState extends State<ManHinhThemGiaoDich> {
  LoaiGiaoDich _loai = LoaiGiaoDich.chiTieu;
  final TextEditingController _soTienController = TextEditingController();
  final TextEditingController _tieuDeController = TextEditingController();
  final TextEditingController _ghiChuController = TextEditingController();
  MoHinhDanhMuc? _danhMucChon;
  DateTime _ngayChon = DateTime.now();

  static const Color mauChinh = Color(0xFFE07852);
  static const Color mauChiTieu = Color(0xFFE07852);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final quanLy = QuanLyTrangThaiScope.of(context);
    final danhMucKhaDung = quanLy.danhSachDanhMuc.where((c) => c.loai == _loai).toList();

    _danhMucChon ??= danhMucKhaDung.isNotEmpty ? danhMucKhaDung.first : null;

    final bool chuacoThuNhap = _loai == LoaiGiaoDich.chiTieu && quanLy.tongThuNhap <= 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Thêm giao dịch mới',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E232A),
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nút chuyển Chi tiêu / Thu nhập
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.9) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE8EAE5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _taoNutLoai(
                      loai: LoaiGiaoDich.chiTieu,
                      nhan: 'Chi tiêu',
                      mauKichHoat: mauChiTieu,
                      isDark: isDark,
                      quanLy: quanLy,
                    ),
                  ),
                  Expanded(
                    child: _taoNutLoai(
                      loai: LoaiGiaoDich.thuNhap,
                      nhan: 'Thu nhập',
                      mauKichHoat: const Color(0xFF27AE60),
                      isDark: isDark,
                      quanLy: quanLy,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Cảnh báo khi chưa có thu nhập mà chọn Chi tiêu
            if (chuacoThuNhap)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.shade900.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.shade700, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Bạn chưa có thu nhập nào. Vui lòng nhập thu nhập vào trước mới được chi tiêu!',
                        style: TextStyle(
                          color: isDark ? Colors.amber.shade200 : Colors.amber.shade900,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Nhập số tiền
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.88) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE8EAE5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Số tiền',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        _loai == LoaiGiaoDich.thuNhap ? '+' : '-',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _loai == LoaiGiaoDich.thuNhap
                              ? const Color(0xFF27AE60)
                              : mauChiTieu,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _soTienController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: false,
                            signed: false,
                          ),
                          inputFormatters: [DinhDangTienInputFormatter()],
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '0',
                            hintStyle: TextStyle(
                              color: isDark ? const Color(0xFF64748B) : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'đ',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tiêu đề
            _taoONhap(
              controller: _tieuDeController,
              nhan: 'Tên giao dịch / Nội dung',
              goiY: 'Ví dụ: Ăn trưa, Mua quần áo...',
              icon: Icons.edit_note_rounded,
              isDark: isDark,
            ),

            const SizedBox(height: 20),

            // Chọn danh mục
            Text(
              'Danh mục',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E232A),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: danhMucKhaDung.length,
                itemBuilder: (context, index) {
                  final cat = danhMucKhaDung[index];
                  final dangChon = _danhMucChon?.id == cat.id;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _danhMucChon = cat;
                      });
                    },
                    child: Container(
                      width: 75,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: dangChon
                            ? cat.mauSac
                            : (isDark ? const Color(0xFF1E293B).withValues(alpha: 0.88) : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: dangChon
                              ? cat.mauSac
                              : (isDark ? const Color(0xFF334155) : const Color(0xFFE8EAE5)),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            cat.icon,
                            color: dangChon ? Colors.white : cat.mauSac,
                            size: 26,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            cat.tenDanhMuc,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: dangChon
                                  ? Colors.white
                                  : (isDark ? Colors.white : Colors.black87),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Chọn ngày
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _ngayChon,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  setState(() {
                    _ngayChon = picked;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.88) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE8EAE5),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, color: mauChinh),
                    const SizedBox(width: 12),
                    Text(
                      'Ngày: ${_ngayChon.day}/${_ngayChon.month}/${_ngayChon.year}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Ghi chú
            _taoONhap(
              controller: _ghiChuController,
              nhan: 'Ghi chú thêm',
              goiY: 'Nhập chi tiết ghi chú...',
              icon: Icons.notes_rounded,
              soDong: 2,
              isDark: isDark,
            ),

            const SizedBox(height: 32),

            // Nút lưu
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () async {
                  final double? soTien = DinhDangTienInputFormatter.giaiMaSoTien(_soTienController.text);
                  final String tieuDe = _tieuDeController.text.trim().isNotEmpty
                      ? _tieuDeController.text.trim()
                      : (_danhMucChon?.tenDanhMuc ?? 'Giao dịch');

                  // Kiểm tra toàn bộ điều kiện logic trước khi lưu
                  final ketQua = KiemTraDieuKien.kiemTraGiaoDichTongHop(
                    laChiTieu: _loai == LoaiGiaoDich.chiTieu,
                    soTien: soTien,
                    tieuDe: tieuDe,
                    ngayGiaoDich: _ngayChon,
                    tongThuNhap: quanLy.tongThuNhap,
                    tongSoDu: quanLy.tongSoDu,
                  );

                  if (!ketQua.hopLe) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ketQua.thongBao),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }

                  final newTx = MoHinhGiaoDich(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    tieuDe: tieuDe,
                    soTien: soTien!,
                    ngayGiaoDich: _ngayChon,
                    loai: _loai,
                    icon: _danhMucChon?.icon ?? Icons.receipt_long_rounded,
                    mauNenIcon: _danhMucChon?.mauSac.withValues(alpha: 0.2) ?? const Color(0xFFFFE7D9),
                    danhMuc: _danhMucChon?.tenDanhMuc ?? 'Khác',
                    ghiChu: _ghiChuController.text.trim(),
                  );

                  await quanLy.themGiaoDich(newTx);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã lưu giao dịch thành công!')),
                    );
                    if (widget.khiDaLuu != null) {
                      widget.khiDaLuu!();
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _loai == LoaiGiaoDich.thuNhap ? const Color(0xFF27AE60) : mauChiTieu,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Lưu giao dịch',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _taoNutLoai({
    required LoaiGiaoDich loai,
    required String nhan,
    required Color mauKichHoat,
    bool isDark = false,
    required QuanLyTrangThaiApp quanLy,
  }) {
    final bool dangChon = _loai == loai;
    return GestureDetector(
      onTap: () {
        setState(() {
          _loai = loai;
          final danhMucKhaDung = quanLy.danhSachDanhMuc.where((c) => c.loai == _loai).toList();
          _danhMucChon = danhMucKhaDung.isNotEmpty ? danhMucKhaDung.first : null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: dangChon ? mauKichHoat : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            nhan,
            style: TextStyle(
              color: dangChon
                  ? Colors.white
                  : (isDark ? const Color(0xFF94A3B8) : Colors.black87),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _taoONhap({
    required TextEditingController controller,
    required String nhan,
    required String goiY,
    required IconData icon,
    int soDong = 1,
    bool isDark = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nhan,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E232A),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: soDong,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: goiY,
            hintStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : Colors.grey),
            prefixIcon: Icon(icon, color: mauChinh),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.88) : Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE8EAE5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: mauChinh, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
