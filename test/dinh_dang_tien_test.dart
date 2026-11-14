import 'package:flutter_test/flutter_test.dart';
import 'package:quanlychitieu/thien_ich/dinh_dang_tien.dart';

void main() {
  test('DinhDangTienInputFormatter format test', () {
    final formatter = DinhDangTienInputFormatter();

    // Nhập 1000 -> 1.000
    var val = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '1000'),
    );
    expect(val.text, '1.000');

    // Nhập 100000 -> 100.000
    val = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '100000'),
    );
    expect(val.text, '100.000');

    // Nhập 1000000 -> 1.000.000
    val = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '1000000'),
    );
    expect(val.text, '1.000.000');

    // Nhập 0 -> 0
    val = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '0'),
    );
    expect(val.text, '0');

    // Nhập 000 -> 0 (không có dấu chấm)
    val = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '000'),
    );
    expect(val.text, '0');

    // Nhập 0000 -> 0 (không có dấu chấm)
    val = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '0000'),
    );
    expect(val.text, '0');

    // Nhập 05000 -> 5.000
    val = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '05000'),
    );
    expect(val.text, '5.000');

    // Giải mã số tiền
    expect(DinhDangTienInputFormatter.giaiMaSoTien('100.000'), 100000.0);
    expect(DinhDangTienInputFormatter.giaiMaSoTien('1.000.000'), 1000000.0);
  });
}
