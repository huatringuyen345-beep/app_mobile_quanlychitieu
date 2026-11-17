import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quanlychitieu/thong_ke/man_hinh_thong_ke.dart';

void main() {
  test('BieuDoTronPainter initializes and repaints correctly', () {
    final listData1 = [
      {'name': 'Ăn uống', 'amount': 100000.0, 'percent': 0.5, 'color': Colors.orange},
      {'name': 'Mua sắm', 'amount': 100000.0, 'percent': 0.5, 'color': Colors.blue},
    ];

    final listData2 = [
      {'name': 'Ăn uống', 'amount': 150000.0, 'percent': 0.75, 'color': Colors.orange},
      {'name': 'Mua sắm', 'amount': 50000.0, 'percent': 0.25, 'color': Colors.blue},
    ];

    final painter1 = BieuDoTronPainter(danhSach: listData1, isDark: false);
    final painter1Same = BieuDoTronPainter(danhSach: listData1, isDark: false);
    final painter2 = BieuDoTronPainter(danhSach: listData2, isDark: false);
    final painterDark = BieuDoTronPainter(danhSach: listData1, isDark: true);

    expect(painter1.shouldRepaint(painter1Same), false);
    expect(painter1.shouldRepaint(painter2), true);
    expect(painter1.shouldRepaint(painterDark), true);
  });

  test('BieuDoTronPainter handles empty data without errors', () {
    final painterEmpty = BieuDoTronPainter(danhSach: [], isDark: false);
    expect(painterEmpty.danhSach, isEmpty);
  });
}
