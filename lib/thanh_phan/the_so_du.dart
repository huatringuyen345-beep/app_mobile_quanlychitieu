import 'package:flutter/material.dart';

class TheSoDu extends StatelessWidget {
  final double tongSoDu;
  final double tongThuNhap;
  final double tongChiTieu;

  const TheSoDu({
    super.key,
    this.tongSoDu = 5250000,
    this.tongThuNhap = 8000000,
    this.tongChiTieu = 2750000,
  });

  static const Color mauChinh = Color(0xFFE07852);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: mauChinh,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: mauChinh.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng số dư',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Ví chính',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${tongSoDu.toInt()} đ',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _taoChiTietSoDu(
                  'Thu nhập',
                  '${tongThuNhap.toInt()} đ',
                  Icons.arrow_downward_rounded,
                  Colors.greenAccent,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: Colors.white24,
              ),
              Expanded(
                child: _taoChiTietSoDu(
                  'Chi tiêu',
                  '${tongChiTieu.toInt()} đ',
                  Icons.arrow_upward_rounded,
                  const Color(0xFFFFCCBC),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _taoChiTietSoDu(String nhan, String soTien, IconData icon, Color mauIcon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 10,
              backgroundColor: mauIcon.withValues(alpha: 0.2),
              child: Icon(icon, size: 12, color: mauIcon),
            ),
            const SizedBox(width: 6),
            Text(
              nhan,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          soTien,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
