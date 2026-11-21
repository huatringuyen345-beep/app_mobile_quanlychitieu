import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../dich_vu/quan_ly_trang_thai_app.dart';
import '../mo_hinh/mo_hinh_giao_dich.dart';
import '../thien_ich/dinh_dang_tien.dart';

class ManHinhThongKe extends StatefulWidget {
  const ManHinhThongKe({super.key});

  @override
  State<ManHinhThongKe> createState() => _ManHinhThongKeState();
}

class _ManHinhThongKeState extends State<ManHinhThongKe> {
  int _viTriTab = 0; // 0: Chi tiêu, 1: Thu nhập

  static const Color mauChiTieu = Color(0xFFE07852);
  static const Color mauThuNhap = Color(0xFF27AE60);

  static const List<Color> _bangMauDuPhong = [
    Color(0xFF3B82F6), // xanh dương
    Color(0xFF8B5CF6), // tím
    Color(0xFFEC4899), // hồng
    Color(0xFFF59E0B), // vàng cam
    Color(0xFF14B8A6), // xanh ngọc
    Color(0xFFEF4444), // đỏ
    Color(0xFF84CC16), // xanh chanh
    Color(0xFF06B6D4), // xanh lơ
    Color(0xFFF97316), // cam
    Color(0xFF6366F1), // chàm
  ];

  void _lamMauKhacNhau(List<Map<String, dynamic>> ds) {
    final Set<int> daDung = {};
    for (int i = 0; i < ds.length; i++) {
      Color mau = ds[i]['color'] as Color;

      if (daDung.contains(mau.toARGB32())) {
        Color? mauMoi;
        for (final c in _bangMauDuPhong) {
          if (!daDung.contains(c.toARGB32())) {
            mauMoi = c;
            break;
          }
        }
        mauMoi ??= HSVColor.fromAHSV(1, (i * 47.0) % 360, 0.65, 0.9).toColor();
        mau = mauMoi;
        ds[i]['color'] = mau;
      }
      daDung.add(mau.toARGB32());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final quanLy = QuanLyTrangThaiScope.of(context);
    final isChiTieu = _viTriTab == 0;

    final danhSachPhuHop = quanLy.danhSachGiaoDich
        .where((tx) => isChiTieu ? !tx.laThuNhap : tx.laThuNhap)
        .toList();

    final double tongTien = isChiTieu ? quanLy.tongChiTieu : quanLy.tongThuNhap;
    final double tongThu = quanLy.tongThuNhap;
    final double tongChi = quanLy.tongChiTieu;
    final double soDuConLai = quanLy.tongSoDu;

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
    _lamMauKhacNhau(phanTichDanhMuc);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Báo cáo thống kê & Biểu đồ',
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
            // Thẻ chuyển tab Tổng Chi / Tổng Thu
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

            // Thẻ tổng quan 3 chỉ số: Tổng Thu, Tổng Chi & Số Dư Còn Lại
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
                  const SizedBox(height: 6),
                  Text(
                    DinhDangTienInputFormatter.dinhDang(tongTien),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _viTriTab == 0 ? mauChiTieu : mauThuNhap,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: isDark ? const Color(0xFF334155) : Colors.grey.shade300),
                  const SizedBox(height: 12),
                  // Row 3 chỉ số: Tổng Thu | Tổng Chi | Số Dư Còn Lại
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _taoChiSoTongQuan('Tổng Thu', DinhDangTienInputFormatter.dinhDang(tongThu), mau: mauThuNhap, isDark: isDark),
                      Container(width: 1, height: 32, color: isDark ? const Color(0xFF334155) : Colors.grey.shade300),
                      _taoChiSoTongQuan('Tổng Chi', DinhDangTienInputFormatter.dinhDang(tongChi), mau: mauChiTieu, isDark: isDark),
                      Container(width: 1, height: 32, color: isDark ? const Color(0xFF334155) : Colors.grey.shade300),
                      _taoChiSoTongQuan('Số dư còn lại', DinhDangTienInputFormatter.dinhDang(soDuConLai), mau: soDuConLai >= 0 ? Colors.blue : Colors.red, isDark: isDark),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tiêu đề biểu đồ
            Text(
              'Biểu đồ tỷ lệ chi tiêu (LayoutBuilder)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E232A),
              ),
            ),
            const SizedBox(height: 16),

            // Dựng Biểu đồ cơ cấu theo LayoutBuilder linh hoạt kích thước
            LayoutBuilder(
              builder: (context, constraints) {
                final double chartDimension = math.min(constraints.maxWidth * 0.65, 220.0);

                return Container(
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
                      SizedBox(
                        height: chartDimension,
                        width: chartDimension,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            TweenAnimationBuilder<double>(
                              key: ValueKey('$isChiTieu-${phanTichDanhMuc.length}-$tongTien'),
                              tween: Tween<double>(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 900),
                              curve: Curves.easeOutCubic,
                              builder: (context, progress, _) {
                                return CustomPaint(
                                  size: Size(chartDimension, chartDimension),
                                  painter: BieuDoTronPainter(
                                    danhSach: phanTichDanhMuc,
                                    isDark: isDark,
                                    progress: progress,
                                  ),
                                );
                              },
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isChiTieu ? 'Tổng Chi' : 'Tổng Thu',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      DinhDangTienInputFormatter.dinhDang(tongTien),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : const Color(0xFF1E232A),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (phanTichDanhMuc.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: phanTichDanhMuc.map((item) {
                            final double percent = (item['percent'] as double) * 100;
                            final Color color = item['color'] as Color;
                            final String name = item['name'] as String;
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$name (${percent.toStringAsFixed(1)}%)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Phân tích danh mục chi tiết với LayoutBuilder cho thanh tiến trình
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
                            DinhDangTienInputFormatter.dinhDang(item['amount'] as double),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isDark ? Colors.white : const Color(0xFF1E232A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LayoutBuilder(
                        builder: (context, barConstraints) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: TweenAnimationBuilder<double>(
                              key: ValueKey('${item['name']}-$isChiTieu'),
                              tween: Tween<double>(begin: 0.0, end: percent.clamp(0.0, 1.0)),
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, _) => LinearProgressIndicator(
                                value: value,
                                minHeight: 8,
                                backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF0F1EE),
                                color: item['color'] as Color,
                              ),
                            ),
                          );
                        },
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

  Widget _taoChiSoTongQuan(String tieuDe, String giaTri, {required Color mau, bool isDark = false}) {
    return Column(
      children: [
        Text(
          tieuDe,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            giaTri,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: mau,
            ),
          ),
        ),
      ],
    );
  }
}

class BieuDoTronPainter extends CustomPainter {
  final List<Map<String, dynamic>> danhSach;
  final bool isDark;
  final double progress;

  BieuDoTronPainter({
    required this.danhSach,
    required this.isDark,
    this.progress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = radius * 0.32;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final paintEmpty = Paint()
      ..color = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final double totalAmount =
    danhSach.fold<double>(0.0, (sum, item) => sum + (item['amount'] as double));

    canvas.drawArc(rect, 0, 2 * math.pi, false, paintEmpty);

    if (danhSach.isEmpty || totalAmount <= 0) return;

    final double maxAngle = progress * 2 * math.pi;
    double startAngle = -math.pi / 2;
    double consumed = 0.0;
    final int count = danhSach.length;

    for (int i = 0; i < count; i++) {
      final item = danhSach[i];
      final double amount = item['amount'] as double;
      final double sweepAngle = (amount / totalAmount) * 2 * math.pi;

      final double visibleSweep = math.min(sweepAngle, maxAngle - consumed);
      if (visibleSweep <= 0) break;

      final double gap = count > 1 ? 0.04 : 0.0;
      final double actualSweep = math.max(0.001, visibleSweep - gap);

      final paintSlice = Paint()
        ..color = item['color'] as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle + (gap / 2), actualSweep, false, paintSlice);

      startAngle += sweepAngle;
      consumed += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant BieuDoTronPainter oldDelegate) {
    return oldDelegate.danhSach != danhSach ||
        oldDelegate.isDark != isDark ||
        oldDelegate.progress != progress;
  }
}
