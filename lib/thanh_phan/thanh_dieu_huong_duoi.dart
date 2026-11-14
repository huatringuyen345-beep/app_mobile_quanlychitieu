import 'package:flutter/material.dart';

class ThanhDieuHuongDuoi extends StatelessWidget {
  final int viTriHienTai;
  final ValueChanged<int> khiChon;

  const ThanhDieuHuongDuoi({
    super.key,
    required this.viTriHienTai,
    required this.khiChon,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    const Color mauChinh = Color(0xFFE07852);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.95) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _taoNutMuc(0, Icons.home_rounded, 'Trang chủ', mauChinh, isDark),
              _taoNutMuc(1, Icons.receipt_long_rounded, 'Giao dịch', mauChinh, isDark),
              _taoNutCongTo(mauChinh),
              _taoNutMuc(3, Icons.bar_chart_rounded, 'Thống kê', mauChinh, isDark),
              _taoNutMuc(4, Icons.person_rounded, 'Cài đặt', mauChinh, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _taoNutMuc(int index, IconData icon, String nhan, Color mauChinh, bool isDark) {
    final bool dangChon = viTriHienTai == index;
    final Color mauChuaChon = isDark ? const Color(0xFF94A3B8) : Colors.grey;

    return InkWell(
      onTap: () => khiChon(index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: dangChon ? mauChinh : mauChuaChon,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              nhan,
              style: TextStyle(
                fontSize: 11,
                fontWeight: dangChon ? FontWeight.bold : FontWeight.normal,
                color: dangChon ? mauChinh : mauChuaChon,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _taoNutCongTo(Color mauChinh) {
    return GestureDetector(
      onTap: () => khiChon(2),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: mauChinh,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: mauChinh.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
