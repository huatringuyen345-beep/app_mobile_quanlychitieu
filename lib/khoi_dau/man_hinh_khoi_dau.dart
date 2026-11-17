import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' hide Image, LinearGradient, RadialGradient;
import '../cot_loi/giao_dien/khung_nen_app.dart';

class ManHinhKhoiDau extends StatefulWidget {
  final VoidCallback khiHoanThanh;
  final int thoiGianChoGiay;

  const ManHinhKhoiDau({
    super.key,
    required this.khiHoanThanh,
    this.thoiGianChoGiay = 10,
  });

  @override
  State<ManHinhKhoiDau> createState() => _ManHinhKhoiDauState();
}

class _ManHinhKhoiDauState extends State<ManHinhKhoiDau> with TickerProviderStateMixin {
  late final AnimationController _tienTrinhCtrl; // thanh đầy dần 0 -> 1
  late final AnimationController _dongXuCtrl; // vòng lặp cho đồng xu bay

  static const Color mauCamVang = Color(0xFFE07852);
  static const Color mauRgbRive = Color(0xFF00C9FF);

  // Kích thước thanh & đồng xu
  static const double _beRongThanh = 280;
  static const double _beCaoThanh = 20;
  static const double _kichThuocXu = 12; // xu nhỏ hơn nữa

  // Xu bay từ nhiều hướng: góc (độ, 0 = từ bên phải, 90 = từ trên, 180 = từ bên trái)
  static const List<double> _gocBay = [20, 50, 80, 110, 140, 165, 35, 95];
  // Khoảng cách xuất phát so với điểm đích (px)
  static const List<double> _khoangCach = [110, 95, 85, 90, 105, 115, 75, 70];
  // Độ lệch điểm rơi so với đầu thanh (px)
  static const List<double> _lechX = [0, -24, -48, -12, -36, -6, -60, -18];

  static const int _soXu = 8;

  bool _daHoanThanh = false;

  @override
  void initState() {
    super.initState();

    _tienTrinhCtrl = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.thoiGianChoGiay),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed && !_daHoanThanh) {
        _daHoanThanh = true;
        widget.khiHoanThanh();
      }
    });

    _dongXuCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _tienTrinhCtrl.forward();
  }

  @override
  void dispose() {
    _tienTrinhCtrl.dispose();
    _dongXuCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool laGiaoDienToi = Theme.of(context).brightness == Brightness.dark;

    return KhungNenApp(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              // Nội dung chính giữa cuộn an toàn chống lỗi tràn Pixel
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Khung chứa Logo Image
                      Container(
                        width: 135,
                        height: 135,
                        decoration: BoxDecoration(
                          color: laGiaoDienToi ? const Color(0xFF1E293B) : const Color(0xFFFFF4E8),
                          borderRadius: BorderRadius.circular(28),
                          border: laGiaoDienToi
                              ? Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5), width: 1.5)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: laGiaoDienToi
                                  ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
                                  : mauCamVang.withValues(alpha: 0.18),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Image.asset(
                            'lib/images/logo.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.account_balance_wallet_rounded,
                                size: 60,
                                color: laGiaoDienToi ? const Color(0xFFF59E0B) : mauCamVang,
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Tên ứng dụng
                      Text(
                        'Quản lý Chi tiêu',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: laGiaoDienToi ? Colors.white : const Color(0xFF1E232A),
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Khẩu hiệu
                      Text(
                        'Quản lý tài chính cá nhân\nthông minh & hiệu quả',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: laGiaoDienToi ? const Color(0xFF94A3B8) : Colors.grey,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Hoạt ảnh Rive Loading
                      SizedBox(
                        width: 180,
                        height: 140,
                        child: RiveAnimation.asset(
                          'lib/hoat-anh/loading-ride.riv',
                          fit: BoxFit.contain,
                          onInit: (artboard) {
                            var controller = StateMachineController.fromArtboard(
                              artboard,
                              'State Machine 1',
                            );
                            if (controller != null) {
                              artboard.addController(controller);
                            } else {
                              for (var animation in artboard.animations) {
                                artboard.addController(SimpleAnimation(animation.name));
                              }
                            }
                          },
                          placeHolder: const Center(
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                color: mauRgbRive,
                                strokeWidth: 2.8,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Thanh tiến trình + tiền xu bay vào thanh
                      _taoThanhTienTrinhXu(laGiaoDienToi),
                    ],
                  ),
                ),
              ),
              // Footer
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Phiên bản 1.0.0 • Made with Flutter',
                    style: TextStyle(
                      fontSize: 12,
                      color: laGiaoDienToi ? const Color(0xFF64748B) : Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _taoThanhTienTrinhXu(bool laGiaoDienToi) {
    return SizedBox(
      width: _beRongThanh,
      height: _beCaoThanh,
      child: AnimatedBuilder(
        animation: Listenable.merge([_tienTrinhCtrl, _dongXuCtrl]),
        builder: (context, _) {
          final double tienTrinh = _tienTrinhCtrl.value;
          final double xDauThanh = tienTrinh * _beRongThanh;
          final bool daDay = tienTrinh >= 1.0;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Thanh nền
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: _beRongThanh,
                  height: _beCaoThanh,
                  decoration: BoxDecoration(
                    color: laGiaoDienToi ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(_beCaoThanh),
                    border: Border.all(
                      color: laGiaoDienToi ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                    ),
                  ),
                ),
              ),

              // Phần thanh đã đầy (gradient vàng -> xanh dương)
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: math.max(_beCaoThanh, xDauThanh),
                  height: _beCaoThanh,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_beCaoThanh),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFC107), Color(0xFF38BDF8), Color(0xFF0284C7)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF38BDF8).withValues(alpha: daDay ? 0.6 : 0.35),
                        blurRadius: daDay ? 16 : 10,
                      ),
                    ],
                  ),
                ),
              ),

              // Các đồng xu bay vào thanh từ nhiều hướng
              if (!daDay)
                for (int i = 0; i < _soXu; i++) _taoDongXu(i, xDauThanh),
            ],
          );
        },
      ),
    );
  }

  Widget _taoDongXu(int i, double xDauThanh) {
    // Mỗi xu có pha lệch nhau để bay liên tục
    final double t = (_dongXuCtrl.value + i / _soXu) % 1.0;

    // Bay nhanh dần về phía thanh
    final double bay = Curves.easeIn.transform(t);

    // Điểm đích: gần đầu thanh, giữa chiều cao thanh
    final double xDich = (xDauThanh + _lechX[i]).clamp(_kichThuocXu / 2, _beRongThanh - _kichThuocXu / 2);
    final double yDich = _beCaoThanh / 2;

    // Điểm xuất phát theo góc & khoảng cách (chỉ từ nửa trên + hai bên)
    final double rad = _gocBay[i] * math.pi / 180;
    final double xBatDau = xDich + math.cos(rad) * _khoangCach[i] * 1.3;
    final double yBatDau = yDich - math.sin(rad) * _khoangCach[i];

    final double x = xBatDau + (xDich - xBatDau) * bay;
    final double y = yBatDau + (yDich - yBatDau) * bay;

    // 25% cuối: thu nhỏ + mờ dần như chui vào thanh
    final double giaiDoanCuoi = ((t - 0.75) / 0.25).clamp(0.0, 1.0);
    final double scale = 1.0 - 0.6 * giaiDoanCuoi;
    final double opacity = (t < 0.1 ? t / 0.1 : 1.0) * (1.0 - giaiDoanCuoi);

    // Xu xoay lật như đồng xu thật
    final double goc = t * 2 * math.pi * 2;

    // Xen kẽ màu vàng / xanh dương
    final bool laXuVang = i % 2 == 0;

    return Positioned(
      left: x - _kichThuocXu / 2,
      top: y - _kichThuocXu / 2,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: scale,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002)
              ..rotateY(goc),
            child: _DongXu(kichThuoc: _kichThuocXu, laXuVang: laXuVang),
          ),
        ),
      ),
    );
  }
}

class _DongXu extends StatelessWidget {
  final double kichThuoc;
  final bool laXuVang;

  const _DongXu({required this.kichThuoc, required this.laXuVang});

  @override
  Widget build(BuildContext context) {
    final List<Color> mauNen = laXuVang
        ? const [Color(0xFFFFE082), Color(0xFFFFB300)]
        : const [Color(0xFF7DD3FC), Color(0xFF0284C7)];
    final Color mauVien = laXuVang ? const Color(0xFFB45309) : const Color(0xFF075985);

    return Container(
      width: kichThuoc,
      height: kichThuoc,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: mauNen,
        ),
        border: Border.all(color: mauVien, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: mauNen.last.withValues(alpha: 0.5),
            blurRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Text(
          '₫',
          style: TextStyle(
            fontSize: kichThuoc * 0.55,
            fontWeight: FontWeight.w900,
            color: mauVien,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
