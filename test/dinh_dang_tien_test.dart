import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quanlychitieu/thien_ich/dinh_dang_tien.dart';

void main() {
  group('DinhDangTienInputFormatter Tests', () {
    final formatter = DinhDangTienInputFormatter();

    test('Định dạng số chuẩn và phân cách hàng nghìn', () {
      var val = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '1000'),
      );
      expect(val.text, '1.000');

      val = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '100000'),
      );
      expect(val.text, '100.000');

      val = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '1000000'),
      );
      expect(val.text, '1.000.000');

      val = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '05000'),
      );
      expect(val.text, '5.000');
    });

    test('Xử lý an toàn phím gõ tiếng Việt / Telex / VNI', () {
      // Gõ chữ tiếng Việt (w, a, s, f, r, x) khi ô nhập trống
      var val = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: 'w',
          composing: TextRange(start: 0, end: 1),
        ),
      );
      expect(val.text, '');
      expect(val.composing, TextRange.empty);

      // Gõ chữ tiếng Việt khi đã có số '500.000'
      val = formatter.formatEditUpdate(
        const TextEditingValue(text: '500.000'),
        const TextEditingValue(
          text: '500.000s',
          composing: TextRange(start: 7, end: 8),
        ),
      );
      expect(val.text, '500.000');
      expect(val.composing, TextRange.empty);
    });

    test('Hỗ trợ chữ số fullwidth (０-９)', () {
      final val = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '５０００'),
      );
      expect(val.text, '5.000');
    });

    test('Giải mã số tiền từ chuỗi có ký tự tiếng Việt hoặc ký hiệu đ', () {
      expect(DinhDangTienInputFormatter.giaiMaSoTien('100.000'), 100000.0);
      expect(DinhDangTienInputFormatter.giaiMaSoTien('1.000.000 đ'), 1000000.0);
      expect(DinhDangTienInputFormatter.giaiMaSoTien('50.000đ'), 50000.0);
      expect(DinhDangTienInputFormatter.giaiMaSoTien('2.500.000 đồng'), 2500000.0);
      expect(DinhDangTienInputFormatter.giaiMaSoTien(''), isNull);
    });
  });
}
