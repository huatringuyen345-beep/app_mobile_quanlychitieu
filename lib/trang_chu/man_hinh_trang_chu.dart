import 'package:flutter/material.dart';
import '../dich_vu/quan_ly_trang_thai_app.dart';
import '../mo_hinh/mo_hinh_giao_dich.dart';
import '../thanh_phan/the_so_du.dart';

class ManHinhTrangChu extends StatelessWidget {
  final VoidCallback? chuyenToiDanhSachGiaoDich;
  final VoidCallback? chuyenToiThemGiaoDich;
  final Function(MoHinhGiaoDich)? chonGiaoDich;

  const ManHinhTrangChu({
    super.key,
    this.chuyenToiDanhSachGiaoDich,
    this.chuyenToiThemGiaoDich,
    this.chonGiaoDich,
  });

  static const Color mauChinh = Color(0xFFE07852);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final quanLy = QuanLyTrangThaiScope.of(context);
    final danhSachGanDay = quanLy.danhSachGiaoDich.take(5).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFFFFF4E8),
                    child: Icon(
                      Icons.pets_rounded,
                      color: mauChinh,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xin chào bạn!',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Quản lý chi tiêu',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Không có thông báo mới')),
                      );
                    },
                    icon: Icon(
                      Icons.notifications_none_rounded,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Thẻ số dư động từ CSDL Realtime
              TheSoDu(
                tongSoDu: quanLy.tongSoDu,
                tongThuNhap: quanLy.tongThuNhap,
                tongChiTieu: quanLy.tongChiTieu,
              ),

              const SizedBox(height: 28),

              // Giao dịch nhanh
              Text(
                'Giao dịch nhanh',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: chuyenToiThemGiaoDich,
                      child: _taoNutThaoTac(
                        icon: Icons.add_circle_outline_rounded,
                        tieuDe: 'Thêm thu',
                        mauSac: const Color(0xFF27AE60),
                        isDark: isDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: chuyenToiThemGiaoDich,
                      child: _taoNutThaoTac(
                        icon: Icons.remove_circle_outline_rounded,
                        tieuDe: 'Thêm chi',
                        mauSac: const Color(0xFFE07852),
                        isDark: isDark,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Giao dịch gần đây
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Giao dịch gần đây',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: chuyenToiDanhSachGiaoDich,
                    child: const Text(
                      'Xem tất cả',
                      style: TextStyle(color: mauChinh, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              if (danhSachGanDay.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(
                      'Chưa có giao dịch nào',
                      style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : Colors.grey),
                    ),
                  ),
                )
              else
                ...danhSachGanDay.map((item) {
                  return _taoMucGiaoDich(context, item, isDark);
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _taoNutThaoTac({
    required IconData icon,
    required String tieuDe,
    required Color mauSac,
    bool isDark = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE8EAE5)),
      ),
      child: Column(
        children: [
          Icon(icon, color: mauSac, size: 30),
          const SizedBox(height: 8),
          Text(
            tieuDe,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _taoMucGiaoDich(BuildContext context, MoHinhGiaoDich item, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFF0F1EE)),
      ),
      child: InkWell(
        onTap: () {
          if (chonGiaoDich != null) {
            chonGiaoDich!(item);
          }
        },
        child: Row(
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor: item.mauNenIcon,
              child: Icon(item.icon, color: Colors.black87),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.tieuDe,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${item.danhMuc} • ${item.ngayGiaoDich.day}/${item.ngayGiaoDich.month}/${item.ngayGiaoDich.year}',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${item.laThuNhap ? '+' : '-'}${item.soTien.toInt()} đ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: item.laThuNhap
                    ? const Color(0xFF27AE60)
                    : const Color(0xFFE07852),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
