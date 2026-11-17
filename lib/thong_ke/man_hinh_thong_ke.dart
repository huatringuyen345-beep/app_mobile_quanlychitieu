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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _taoChiSoTongQuan('Mức trung bình/ngày', DinhDangTienInputFormatter.dinhDang(tongTien / 30), isDark: isDark),
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

            // Biểu đồ tròn
            Text(
              'Biểu đồ cơ cấu theo danh mục',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E232A),
              ),
            ),
            const SizedBox(height: 16),

            _taoBieuDoTronContainer(
              phanTichDanhMuc: phanTichDanhMuc,
              tongTien: tongTien,
              isDark: isDark,
              isChiTieu: isChiTieu,
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
                      ClipRRect(
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

  Widget _taoBieuDoTronContainer({
    required List<Map<String, dynamic>> phanTichDanhMuc,
    required double tongTien,
    required bool isDark,
    required bool isChiTieu,
  }) {
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
            height: 200,
            width: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  // key đổi => hoạt ảnh chạy lại khi đổi tab hoặc dữ liệu thay đổi
                  key: ValueKey('$isChiTieu-${phanTichDanhMuc.length}-$tongTien'),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, progress, _) {
                    return CustomPaint(
                      size: const Size(200, 200),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
  }
}

class BieuDoTronPainter extends CustomPainter {
  final List<Map<String, dynamic>> danhSach;
  final bool isDark;
  final double progress; // 0.0 -> 1.0

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

    // Vòng nền (luôn vẽ, để thấy vòng được "lấp đầy" dần)
    canvas.drawArc(rect, 0, 2 * math.pi, false, paintEmpty);

    if (danhSach.isEmpty || totalAmount <= 0) return;

    final double maxAngle = progress * 2 * math.pi; // góc tối đa được vẽ
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