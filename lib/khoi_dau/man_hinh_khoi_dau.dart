import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' hide Image, LinearGradient;
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

class _ManHinhKhoiDauState extends State<ManHinhKhoiDau> {
  Timer? _timer;
  double _tienTrinh = 0.0;

  static const Color mauCamVang = Color(0xFFE07852);
  static const Color mauRgbRive = Color(0xFF00C9FF);

  @override
  void initState() {
    super.initState();

    final int tongThoiGianMs = widget.thoiGianChoGiay * 1000;
    int msDaQua = 0;

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      msDaQua += 100;
      if (mounted) {
        setState(() {
          _tienTrinh = msDaQua / tongThoiGianMs;
        });
      }

      if (msDaQua >= tongThoiGianMs) {
        _timer?.cancel();
        widget.khiHoanThanh();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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

                      // Hoạt ảnh Rive Loading cyan RGB chuẩn
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

                      const SizedBox(height: 8),

                      // Chữ đếm tiến trình màu Cyan RGB phát sáng
                      Text(
                        'Đang tải ứng dụng... ${(_tienTrinh * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 13,
                          color: laGiaoDienToi ? const Color(0xFF00E5FF) : const Color(0xFF0083B0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
}
