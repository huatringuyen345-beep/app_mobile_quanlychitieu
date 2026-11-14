import 'package:flutter/material.dart';
import '../dich_vu/quan_ly_trang_thai_app.dart';
import '../mo_hinh/mo_hinh_giao_dich.dart';

class ManHinhChiTietGiaoDich extends StatelessWidget {
  final MoHinhGiaoDich giaoDich;
  final VoidCallback? khiQuayLai;

  const ManHinhChiTietGiaoDich({
    super.key,
    required this.giaoDich,
    this.khiQuayLai,
  });

  static const Color mauChinh = Color(0xFFE07852);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final quanLy = QuanLyTrangThaiScope.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Chi tiết giao dịch',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E232A),
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : const Color(0xFF1E232A),
          ),
          onPressed: () {
            if (khiQuayLai != null) {
              khiQuayLai!();
            } else {
              Navigator.maybePop(context);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (dialogCtx) => AlertDialog(
                  backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  title: Text(
                    'Xóa giao dịch',
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  ),
                  content: Text(
                    'Bạn có chắc chắn muốn xóa giao dịch "${giaoDich.tieuDe}" khỏi CSDL?',
                    style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : Colors.black87),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogCtx, false),
                      child: const Text('Hủy'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(dialogCtx, true),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      child: const Text('Xóa', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await quanLy.xoaGiaoDich(giaoDich.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xóa giao dịch khỏi CSDL!')),
                  );
                  if (khiQuayLai != null) {
                    khiQuayLai!();
                  } else {
                    Navigator.maybePop(context);
                  }
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Thẻ hóa đơn
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.88) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE8EAE5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: giaoDich.mauNenIcon,
                    child: Icon(giaoDich.icon, size: 36, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    giaoDich.tieuDe,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E232A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: mauChinh.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      giaoDich.danhMuc,
                      style: const TextStyle(
                        color: mauChinh,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '${giaoDich.laThuNhap ? '+' : '-'}${giaoDich.soTien.toInt()} đ',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: giaoDich.laThuNhap
                          ? const Color(0xFF27AE60)
                          : const Color(0xFFE07852),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Divider(color: isDark ? const Color(0xFF334155) : Colors.grey.shade300),
                  const SizedBox(height: 16),
                  _taoDongChiTiet('Loại giao dịch', giaoDich.laThuNhap ? 'Thu nhập' : 'Chi tiêu', isDark),
                  const SizedBox(height: 12),
                  _taoDongChiTiet('Thời gian', '${giaoDich.ngayGiaoDich.day}/${giaoDich.ngayGiaoDich.month}/${giaoDich.ngayGiaoDich.year}', isDark),
                  const SizedBox(height: 12),
                  _taoDongChiTiet('Trạng thái', 'Thành công', isDark, laTrangThai: true),
                  if (giaoDich.ghiChu.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _taoDongChiTiet('Ghi chú', giaoDich.ghiChu, isDark),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _taoDongChiTiet(String nhan, String giaTri, bool isDark, {bool laTrangThai = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          nhan,
          style: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
            fontSize: 14,
          ),
        ),
        if (laTrangThai)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, size: 14, color: Colors.green.shade700),
                const SizedBox(width: 4),
                Text(
                  giaTri,
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          )
        else
          Text(
            giaTri,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
      ],
    );
  }
}
