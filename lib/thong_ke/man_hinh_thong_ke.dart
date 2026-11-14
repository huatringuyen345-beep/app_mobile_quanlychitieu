import 'package:flutter/material.dart';
import '../dich_vu/quan_ly_trang_thai_app.dart';
import '../mo_hinh/mo_hinh_giao_dich.dart';

class ManHinhThongKe extends StatefulWidget {
  const ManHinhThongKe({super.key});

  @override
  State<ManHinhThongKe> createState() => _ManHinhThongKeState();
}

class _ManHinhThongKeState extends State<ManHinhThongKe> {
  int _viTriTab = 0; // 0: Chi tiêu, 1: Thu nhập

  static const Color mauChiTieu = Color(0xFFE07852);
  static const Color mauThuNhap = Color(0xFF27AE60);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final quanLy = QuanLyTrangThaiScope.of(context);
    final isChiTieu = _viTriTab == 0;

    final danhSachPhuHop = quanLy.danhSachGiaoDich
        .where((tx) => isChiTieu ? !tx.laThuNhap : tx.laThuNhap)
        .toList();

    final double tongTien = isChiTieu ? quanLy.tongChiTieu : quanLy.tongThuNhap;

    // Gom nhóm theo danh mục
    final Map<String, double> tongTheoDanhMuc = {};
    for (var tx in danhSachPhuHop) {
      tongTheoDanhMuc[tx.danhMuc] = (tongTheoDanhMuc[tx.danhMuc] ?? 0.0) + tx.soTien;
    }

    final List<Map<String, dynamic>> phanTichDanhMuc = [];
    tongTheoDanhMuc.forEach((tenCat, amount) {
      final catMatch = quanLy.danhSachDanhMuc.firstWhere(
        (c) => c.tenDanhMuc == tenCat,
        orElse: () => MoHinhDanhMuc(
          id: 'def',
          tenDanhMuc: tenCat,
          icon: Icons.category_rounded,
          mauSac: Colors.blue,
          loai: isChiTieu ? LoaiGiaoDich.chiTieu : LoaiGiaoDich.thuNhap,
        ),
      );

      final double percent = tongTien > 0 ? (amount / tongTien) : 0.0;
      phanTichDanhMuc.add({
        'name': tenCat,
        'amount': amount,
        'percent': percent,
        'color': catMatch.mauSac,
        'icon': catMatch.icon,
      });
    });

    phanTichDanhMuc.sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Thống kê chi tiêu',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E232A),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thẻ chọn kỳ
            Container(
              padding: const EdgeInsets.all(6),
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
                    child: _taoNutTab(0, 'Tổng Chi Tiêu', mauChiTieu, isDark),
                  ),
                  Expanded(
                    child: _taoNutTab(1, 'Tổng Thu Nhập', mauThuNhap, isDark),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tổng quan
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
                children: [
                  Text(
                    _viTriTab == 0 ? 'Tổng chi tiêu tháng này' : 'Tổng thu nhập tháng này',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${tongTien.toInt()} đ',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _viTriTab == 0 ? mauChiTieu : mauThuNhap,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: isDark ? const Color(0xFF334155) : Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _taoChiSoTongQuan('Mức trung bình/ngày', '${(tongTien / 30).toInt()} đ', isDark: isDark),
                      Container(
                        width: 1,
                        height: 30,
                        color: isDark ? const Color(0xFF334155) : Colors.grey.shade300,
                      ),
                      _taoChiSoTongQuan('Tổng số giao dịch', '${danhSachPhuHop.length} giao dịch', laTichCuc: true, isDark: isDark),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Biểu đồ cột
            Text(
              'Biểu đồ theo tuần',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E232A),
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.88) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE8EAE5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _taoCot('T2', 0.4, isDark: isDark),
                  _taoCot('T3', 0.7, isDark: isDark),
                  _taoCot('T4', 0.3, isDark: isDark),
                  _taoCot('T5', 0.9, laCaoNhat: true, isDark: isDark),
                  _taoCot('T6', 0.5, isDark: isDark),
                  _taoCot('T7', 0.8, isDark: isDark),
                  _taoCot('CN', 0.2, isDark: isDark),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Phân tích theo danh mục
            Text(
              'Phân tích theo danh mục',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E232A),
              ),
            ),
            const SizedBox(height: 16),

            if (phanTichDanhMuc.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.88) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    'Chưa có dữ liệu thống kê',
                    style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : Colors.grey),
                  ),
                ),
              )
            else
              ...phanTichDanhMuc.map((item) {
                final double percent = item['percent'] as double;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.88) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE8EAE5),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: (item['color'] as Color).withValues(alpha: 0.15),
                            child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            item['name'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isDark ? Colors.white : const Color(0xFF1E232A),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${(item['amount'] as double).toInt()} đ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isDark ? Colors.white : const Color(0xFF1E232A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: percent.clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF0F1EE),
                          color: item['color'] as Color,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${(percent * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _taoNutTab(int index, String tieuDe, Color mauKichHoat, bool isDark) {
    final bool dangChon = _viTriTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _viTriTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: dangChon ? mauKichHoat : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            tieuDe,
            style: TextStyle(
              color: dangChon
                  ? Colors.white
                  : (isDark ? const Color(0xFF94A3B8) : Colors.black87),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _taoChiSoTongQuan(String tieuDe, String giaTri, {bool laTichCuc = false, bool isDark = false}) {
    return Column(
      children: [
        Text(
          tieuDe,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          giaTri,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: laTichCuc
                ? mauThuNhap
                : (isDark ? Colors.white : Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _taoCot(String ngay, double tyLeChieuCao, {bool laCaoNhat = false, bool isDark = false}) {
    final color = laCaoNhat
        ? (_viTriTab == 0 ? mauChiTieu : mauThuNhap)
        : (isDark ? const Color(0xFF334155) : const Color(0xFFD3D8D0));
    return Column(
      children: [
        Container(
          height: 120 * tyLeChieuCao,
          width: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          ngay,
          style: TextStyle(
            fontSize: 12,
            fontWeight: laCaoNhat ? FontWeight.bold : FontWeight.normal,
            color: laCaoNhat
                ? (isDark ? Colors.white : Colors.black)
                : (isDark ? const Color(0xFF94A3B8) : Colors.grey),
          ),
        ),
      ],
    );
  }
}
