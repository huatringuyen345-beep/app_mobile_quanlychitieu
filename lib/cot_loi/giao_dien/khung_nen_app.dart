import 'package:flutter/material.dart';

class KhungNenApp extends StatelessWidget {
  final Widget child;

  const KhungNenApp({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bool laGiaoDienToi = Theme.of(context).brightness == Brightness.dark;
    final String tenAnhNen = laGiaoDienToi
        ? 'lib/images/background-toi .png'
        : 'lib/images/background-sang.jpg';

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            tenAnhNen,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback nếu tên file không có khoảng trắng
              return Image.asset(
                laGiaoDienToi
                    ? 'lib/images/background-toi.png'
                    : 'lib/images/background-sang.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: laGiaoDienToi ? const Color(0xFF0F172A) : const Color(0xFFF7F8F4),
                  );
                },
              );
            },
          ),
        ),
        Positioned.fill(
          child: child,
        ),
      ],
    );
  }
}
