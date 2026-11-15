import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dich_vu/dich_vu_luu_tru.dart';
import '../dich_vu/quan_ly_trang_thai_app.dart';
import '../mo_hinh/mo_hinh_giao_dich.dart';
import '../thanh_phan/the_so_du.dart';
import '../thien_ich/dinh_dang_tien.dart';

// ============================================================
// TRANG CHỦ (đã gộp "Chia lương sáu hũ")
//  - Header chào + thẻ số dư + giao dịch nhanh
//  - 6 hũ: tổng thu nhập chia theo tỷ lệ, chi tiêu làm nước tụt
//  - Giao dịch gần đây
// ============================================================

class _CauHinhHu {
  final String ten;
  final double tyLe;
  final IconData icon;
  final Color mau;
  const _CauHinhHu(this.ten, this.tyLe, this.icon, this.mau);
}

const List<_CauHinhHu> _cacHu = [
  _CauHinhHu('Thiết yếu', 0.55, Icons.home_rounded, Color(0xFFFF8A4C)),
  _CauHinhHu('Tự do tài chính', 0.10, Icons.trending_up_rounded, Color(0xFF9B7BFF)),
  _CauHinhHu('Giáo dục', 0.10, Icons.school_rounded, Color(0xFF4FC3F7)),
  _CauHinhHu('Tiết kiệm dài hạn', 0.10, Icons.savings_rounded, Color(0xFF4ADE80)),
  _CauHinhHu('Hưởng thụ', 0.10, Icons.celebration_rounded, Color(0xFFF472B6)),
  _CauHinhHu('Cho đi', 0.05, Icons.volunteer_activism_rounded, Color(0xFFFACC15)),
];

// Danh mục chi tiêu -> hũ nào. Danh mục trùng tên hũ thì vào đúng hũ đó.
int _chiSoHuCuaDanhMuc(String danhMuc) {
  for (var i = 0; i < _cacHu.length; i++) {
    if (_cacHu[i].ten == danhMuc) return i;
  }
  switch (danhMuc) {
    case 'Ăn uống':
    case 'Đi lại':
    case 'Hóa đơn':
    case 'Nhà ở':
      return 0;
    case 'Đầu tư':
      return 1;
    case 'Học tập':
      return 2;
    case 'Tiết kiệm':
      return 3;
    case 'Mua sắm':
    case 'Giải trí':
      return 4;
    case 'Từ thiện':
      return 5;
    default:
      return 0;
  }
}

class _KetQuaChi {
  final double soTien;
  final String noiDung;
  const _KetQuaChi(this.soTien, this.noiDung);
}

class ManHinhTrangChu extends StatefulWidget {
  final VoidCallback? chuyenToiDanhSachGiaoDich;
  final VoidCallback? chuyenToiThemGiaoDich;
  final Function(MoHinhGiaoDich)? chonGiaoDich;

  const ManHinhTrangChu({
    super.key,
    this.chuyenToiDanhSachGiaoDich,
    this.chuyenToiThemGiaoDich,
    this.chonGiaoDich,
  });

  @override
  State<ManHinhTrangChu> createState() => _ManHinhTrangChuState();
}

// Giữ tên cũ để code nào còn gọi ManHinhSauHu vẫn chạy
typedef ManHinhSauHu = ManHinhTrangChu;

class _ManHinhTrangChuState extends State<ManHinhTrangChu>
    with TickerProviderStateMixin {
  static const Color mauChinh = Color(0xFFE07852);

  List<double> _tyLe = [for (final h in _cacHu) h.tyLe];

  late final AnimationController _song;
  late final AnimationController _vao;

  @override
  void initState() {
    super.initState();
    _song = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
    _vao = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3200))
      ..forward();
    _taiTyLe();
  }

  // ---------- Lưu / tải tỷ lệ (riêng từng tài khoản) ----------
  Future<String> _khoaTyLe() async {
    final email = await DichVuLuuTru.layNguoiDungHienTai();
    return 'ty_le_hu_${(email ?? 'khach').toLowerCase()}';
  }

  Future<void> _taiTyLe() async {
    final prefs = await SharedPreferences.getInstance();
    final ds = prefs.getStringList(await _khoaTyLe());
    if (ds == null || ds.length != _cacHu.length) return;
    final v = ds.map((e) => double.tryParse(e) ?? 0).toList();
    if ((v.fold<double>(0, (a, b) => a + b) - 1).abs() > 0.001) return;
    if (mounted) setState(() => _tyLe = v);
  }

  Future<void> _luuTyLe(List<double> v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        await _khoaTyLe(), v.map((e) => e.toString()).toList());
  }

  Future<void> _moBangTyLe(double tongThu) async {
    final kq = await showModalBottomSheet<List<double>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => _BangTyLe(tyLeBanDau: _tyLe, tongThu: tongThu),
    );
    if (kq == null || !mounted) return;
    setState(() => _tyLe = kq);
    await _luuTyLe(kq);
  }

  @override
  void dispose() {
    _song.dispose();
    _vao.dispose();
    super.dispose();
  }

  double _heSoVao(int i) {
    final x = ((_vao.value - i * 0.1) / 0.5).clamp(0.0, 1.0);
    return Curves.easeOutCubic.transform(x);
  }

  Future<void> _moBangGhiChi(
      int i, double soDuHu, QuanLyTrangThaiApp quanLy) async {
    final hu = _cacHu[i];
    final kq = await showModalBottomSheet<_KetQuaChi>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => _BangGhiChi(hu: hu, soDu: soDuHu),
    );
    if (kq == null) return;

    final tx = MoHinhGiaoDich(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      tieuDe: kq.noiDung.isEmpty ? 'Chi từ hũ ${hu.ten}' : kq.noiDung,
      soTien: kq.soTien,
      ngayGiaoDich: DateTime.now(),
      loai: LoaiGiaoDich.chiTieu,
      icon: hu.icon,
      mauNenIcon: hu.mau.withValues(alpha: 0.25),
      danhMuc: hu.ten,
    );
    try {
      await quanLy.themGiaoDich(tx);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Không lưu được giao dịch: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final quanLy = QuanLyTrangThaiScope.of(context);

    final double tongThu = quanLy.tongThuNhap;
    final List<double> chi = List.filled(_cacHu.length, 0);
    for (final tx in quanLy.danhSachGiaoDich) {
      if (!tx.laThuNhap) chi[_chiSoHuCuaDanhMuc(tx.danhMuc)] += tx.soTien;
    }
    final List<double> soDuDich = [
      for (var i = 0; i < _cacHu.length; i++) tongThu * _tyLe[i] - chi[i],
    ];
    final recent = quanLy.danhSachGiaoDich.take(5).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- Header ----------
              Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFFFFF4E8),
                    child: Icon(Icons.pets_rounded, color: mauChinh, size: 28),
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

              // ---------- Thẻ số dư ----------
              TheSoDu(
                tongSoDu: quanLy.tongSoDu,
                tongThuNhap: quanLy.tongThuNhap,
                tongChiTieu: quanLy.tongChiTieu,
              ),

              const SizedBox(height: 24),
              // ---------- 6 hũ ----------
              Row(
                children: [
                  Expanded(child: _tieuDe('6 hũ tài chính', isDark)),
                  IconButton(
                    tooltip: 'Chỉnh tỷ lệ chia hũ',
                    onPressed: () => _moBangTyLe(tongThu),
                    icon: const Icon(Icons.tune_rounded, color: mauChinh),
                  ),
                  IconButton(
                    tooltip: 'Chia lại',
                    onPressed: () => _vao.forward(from: 0),
                    icon: const Icon(Icons.replay_rounded, color: mauChinh),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AnimatedBuilder(
                animation: _vao,
                builder: (context, _) {
                  return Column(
                    children: [
                      for (var r = 0; r < 3; r++) ...[
                        Row(
                          children: [
                            Expanded(
                                child: _theHu(r * 2, isDark, tongThu,
                                    soDuDich[r * 2], quanLy)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _theHu(r * 2 + 1, isDark, tongThu,
                                    soDuDich[r * 2 + 1], quanLy)),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  );
                },
              ),

              const SizedBox(height: 10),

              // ---------- Giao dịch gần đây ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _tieuDe('Giao dịch gần đây', isDark),
                  TextButton(
                    onPressed: widget.chuyenToiDanhSachGiaoDich,
                    child: const Text('Xem tất cả',
                        style: TextStyle(
                            color: mauChinh, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              if (recent.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text('Chưa có giao dịch nào',
                      style: TextStyle(
                          color: isDark ? const Color(0xFF94A3B8) : Colors.grey)),
                ),
              for (final tx in recent)
                _hienDan(
                  key: ValueKey(tx.id),
                  child: _mucGiaoDich(tx, isDark),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tieuDe(String text, bool isDark) => Text(
    text,
    style: TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.bold,
      color: isDark ? Colors.white : Colors.black87,
    ),
  );

  BoxDecoration _kieuCard(bool isDark) => BoxDecoration(
    color: isDark
        ? const Color(0xFF1E293B).withValues(alpha: 0.85)
        : Colors.white.withValues(alpha: 0.92),
    borderRadius: BorderRadius.circular(22),
    border: Border.all(
      color: isDark ? const Color(0xFF334155) : const Color(0xFFF0F1EE),
    ),
  );

  Widget _taoNutThaoTac({
    required IconData icon,
    required String tieuDe,
    required Color mauSac,
    bool isDark = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.85)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE8EAE5)),
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

  Widget _theHu(int i, bool isDark, double tongThu, double soDuDich,
      QuanLyTrangThaiApp quanLy) {
    final hu = _cacHu[i];
    final double phanBo = tongThu * _tyLe[i];

    return GestureDetector(
      onTap: () => _moBangGhiChi(i, soDuDich, quanLy),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
        decoration: _kieuCard(isDark),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(end: soDuDich),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOutCubic,
          builder: (context, v, _) {
            final double hien = v * _heSoVao(i);
            final double fill = phanBo <= 0 ? 0 : (hien / phanBo).clamp(0.0, 1.0);
            final bool am = v < 0;
            return Column(
              children: [
                Row(
                  children: [
                    Icon(hu.icon, color: hu.mau, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        hu.ten,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 70,
                  height: 90,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _HuPainter(
                            fill: fill,
                            mau: hu.mau,
                            song: _song,
                            isDark: isDark,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: Text(
                          '${(_tyLe[i] * 100).round()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    DinhDangTienInputFormatter.dinhDang(hien.roundToDouble()),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: am
                          ? Colors.redAccent
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Phân bổ ${DinhDangTienInputFormatter.dinhDang(phanBo.roundToDouble())}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _hienDan({required Key key, required Widget child}) {
    return TweenAnimationBuilder<double>(
      key: key,
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
      builder: (context, v, c) => ClipRect(
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: v,
          child: Opacity(
            opacity: v,
            child: Transform.translate(offset: Offset(0, (v - 1) * 20), child: c),
          ),
        ),
      ),
      child: child,
    );
  }

  Widget _mucGiaoDich(MoHinhGiaoDich tx, bool isDark) {
    final bool thu = tx.laThuNhap;
    final hu = thu ? null : _cacHu[_chiSoHuCuaDanhMuc(tx.danhMuc)];
    final Color mau = hu?.mau ?? const Color(0xFF27AE60);
    final d = tx.ngayGiaoDich;
    final ngay =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: () => widget.chonGiaoDich?.call(tx),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: _kieuCard(isDark),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: mau.withValues(alpha: 0.2),
              child: Icon(hu?.icon ?? tx.icon, color: mau),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.tieuDe,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: mau.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          thu ? 'Chia vào 6 hũ' : 'Hũ ${hu!.ten}',
                          style: TextStyle(
                              color: mau,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(ngay,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${thu ? '+' : '-'}${DinhDangTienInputFormatter.dinhDang(tx.soTien)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: thu ? const Color(0xFF27AE60) : mauChinh,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// VẼ HŨ + SÓNG NƯỚC
// ============================================================
class _HuPainter extends CustomPainter {
  final double fill;
  final Color mau;
  final Animation<double> song;
  final bool isDark;

  _HuPainter({
    required this.fill,
    required this.mau,
    required this.song,
    required this.isDark,
  }) : super(repaint: song);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    final body = RRect.fromLTRBR(
        w * 0.06, h * 0.2, w * 0.94, h, const Radius.circular(20));
    final neck = RRect.fromLTRBR(
        w * 0.24, h * 0.09, w * 0.76, h * 0.26, const Radius.circular(4));
    final lid = RRect.fromLTRBR(
        w * 0.18, 0, w * 0.82, h * 0.11, const Radius.circular(6));

    final jar = Path.combine(
      PathOperation.union,
      Path()..addRRect(body),
      Path()..addRRect(neck),
    );

    canvas.drawPath(
      jar,
      Paint()
        ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
    );

    if (fill > 0.001) {
      final top = body.top + (body.bottom - body.top) * (1 - fill);
      final phase = song.value * 2 * math.pi;
      final water = Path()..moveTo(0, h);
      water.lineTo(0, top);
      for (double x = 0; x <= w; x += 2) {
        final y = top + math.sin((x / w) * 2 * math.pi + phase) * 2.6;
        water.lineTo(x, y);
      }
      water.lineTo(w, h);
      water.close();

      canvas.save();
      canvas.clipPath(jar);
      canvas.drawPath(
        water,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [mau.withValues(alpha: 0.85), mau],
          ).createShader(Rect.fromLTWH(0, top, w, h - top)),
      );
      canvas.restore();
    }

    final vien = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = (isDark ? Colors.white : Colors.black54).withValues(alpha: 0.4);
    canvas.drawPath(jar, vien);
    canvas.drawRRect(lid, Paint()..color = mau.withValues(alpha: 0.9));
  }

  @override
  bool shouldRepaint(covariant _HuPainter old) =>
      old.fill != fill || old.mau != mau || old.isDark != isDark;
}

// ============================================================
// BOTTOM SHEET GHI CHI TIÊU (kèm validate + rung)
// ============================================================
class _BangGhiChi extends StatefulWidget {
  final _CauHinhHu hu;
  final double soDu;
  const _BangGhiChi({required this.hu, required this.soDu});

  @override
  State<_BangGhiChi> createState() => _BangGhiChiState();
}

class _BangGhiChiState extends State<_BangGhiChi>
    with SingleTickerProviderStateMixin {
  final TextEditingController _ctl = TextEditingController();
  final TextEditingController _noiDung = TextEditingController();
  late final AnimationController _rung;
  bool _vuot = false;

  double get _toiDa => math.max(0, widget.soDu).roundToDouble();
  double get _soTien => DinhDangTienInputFormatter.giaiMaSoTien(_ctl.text) ?? 0;

  @override
  void initState() {
    super.initState();
    _rung = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 420));
    _ctl.addListener(_khiDoi);
  }

  void _khiDoi() {
    final vuot = _soTien > _toiDa;
    if (vuot && !_vuot) _rung.forward(from: 0);
    setState(() => _vuot = vuot);
  }

  @override
  void dispose() {
    _ctl.dispose();
    _noiDung.dispose();
    _rung.dispose();
    super.dispose();
  }

  void _chonNhanh(int v) {
    final text =
    DinhDangTienInputFormatter.dinhDang(v.toDouble()).replaceAll(' đ', '');
    _ctl.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hu = widget.hu;
    final bool hopLe = _soTien > 0 && !_vuot;
    const Color nen = Color(0xFF1B2233);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
        decoration: const BoxDecoration(
          color: nen,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Icon(hu.icon, color: hu.mau),
                    const SizedBox(width: 8),
                    Text('Ghi chi tiêu • ${hu.ten}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Số dư hiện tại: ${DinhDangTienInputFormatter.dinhDang(widget.soDu.roundToDouble())}',
                  style: const TextStyle(color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final v in [50000, 100000, 200000, 500000])
                      ActionChip(
                        label: Text('${v ~/ 1000}k'),
                        backgroundColor: Colors.white10,
                        labelStyle: const TextStyle(color: Colors.white),
                        side: BorderSide(color: hu.mau.withValues(alpha: 0.5)),
                        onPressed: () => _chonNhanh(v),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                AnimatedBuilder(
                  animation: _rung,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(
                      math.sin(_rung.value * math.pi * 6) * 10 * (1 - _rung.value),
                      0,
                    ),
                    child: child,
                  ),
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _vuot ? Colors.redAccent : Colors.white24,
                        width: _vuot ? 1.6 : 1,
                      ),
                    ),
                    child: TextField(
                      controller: _ctl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [DinhDangTienInputFormatter()],
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: _vuot ? Colors.redAccent : Colors.white,
                      ),
                      decoration: const InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(color: Colors.white24),
                        suffixText: 'đ',
                        suffixStyle:
                        TextStyle(color: Colors.white54, fontSize: 18),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: _vuot
                      ? Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4),
                    child: Text(
                      'Chỉ còn tối đa ${DinhDangTienInputFormatter.dinhDang(_toiDa)} trong hũ này',
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 13),
                    ),
                  )
                      : const SizedBox(width: double.infinity),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noiDung,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Nội dung chi (không bắt buộc)',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white10,
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: hopLe
                        ? () => Navigator.pop(
                        context, _KetQuaChi(_soTien, _noiDung.text.trim()))
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: hu.mau,
                      foregroundColor: Colors.black87,
                      disabledBackgroundColor: hu.mau.withValues(alpha: 0.25),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Ghi chi tiêu',
                        style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// BẢNG CHỈNH TỶ LỆ CHIA HŨ
// ============================================================
class _BangTyLe extends StatefulWidget {
  final List<double> tyLeBanDau;
  final double tongThu;
  const _BangTyLe({required this.tyLeBanDau, required this.tongThu});

  @override
  State<_BangTyLe> createState() => _BangTyLeState();
}

class _BangTyLeState extends State<_BangTyLe> {
  late List<int> _p;

  @override
  void initState() {
    super.initState();
    _p = _lamTron(widget.tyLeBanDau.map((e) => e * 100).toList(), 100);
  }

  static List<int> _lamTron(List<double> v, int tong) {
    final nen = v.map((e) => e.floor()).toList();
    var thieu = tong - nen.fold<int>(0, (a, b) => a + b);
    final idx = List.generate(v.length, (i) => i)
      ..sort((a, b) => (v[b] - nen[b]).compareTo(v[a] - nen[a]));
    for (var k = 0; thieu > 0 && v.isNotEmpty; k++, thieu--) {
      nen[idx[k % idx.length]]++;
    }
    return nen;
  }

  void _doi(int i, int moi) {
    moi = moi.clamp(0, 100);
    final cu = _p[i];
    if (moi == cu) return;
    final conLai = 100 - moi;
    final khac = [for (var j = 0; j < _p.length; j++) if (j != i) j];
    final tongKhacCu = 100 - cu;

    final List<double> thuc;
    if (tongKhacCu == 0) {
      thuc = [for (final _ in khac) conLai / khac.length];
    } else {
      thuc = [for (final j in khac) _p[j] * conLai / tongKhacCu];
    }
    final nguyen = _lamTron(thuc, conLai);

    setState(() {
      _p[i] = moi;
      for (var k = 0; k < khac.length; k++) {
        _p[khac[k]] = nguyen[k];
      }
    });
  }

  void _macDinh() => setState(() {
    _p = _lamTron([for (final h in _cacHu) h.tyLe * 100], 100);
  });

  @override
  Widget build(BuildContext context) {
    const Color nen = Color(0xFF1B2233);
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 20),
      decoration: const BoxDecoration(
        color: nen,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: Text('Tỷ lệ chia hũ',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Tổng 100%',
                        style: TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                  'Kéo một hũ, các hũ còn lại tự co giãn để tổng luôn 100%.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              const SizedBox(height: 8),
              for (var i = 0; i < _cacHu.length; i++) _dong(i),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _macDinh,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Mặc định'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(
                          context, [for (final e in _p) e / 100.0]),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE07852),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Áp dụng',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dong(int i) {
    final hu = _cacHu[i];
    final tien = widget.tongThu * _p[i] / 100;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          Row(
            children: [
              Icon(hu.icon, color: hu.mau, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(hu.ten,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ),
              Text(
                '${_p[i]}%  •  ${DinhDangTienInputFormatter.dinhDang(tien.roundToDouble())}',
                style: TextStyle(
                    color: hu.mau, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: hu.mau,
              inactiveTrackColor: Colors.white12,
              thumbColor: hu.mau,
              overlayColor: hu.mau.withValues(alpha: 0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: _p[i].toDouble(),
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: (v) => _doi(i, v.round()),
            ),
          ),
        ],
      ),
    );
  }
}