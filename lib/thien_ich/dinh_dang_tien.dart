import 'package:flutter/services.dart';

class DinhDangTienInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
        composing: TextRange.empty,
      );
    }

    // 1. Chuẩn hóa chữ số fullwidth (０-９ -> 0-9)
    final textNormalized = newValue.text.replaceAllMapped(
      RegExp(r'[\uFF10-\uFF19]'),
      (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) - 0xFF10 + 0x30),
    );

    // 2. Chỉ giữ lại các chữ số 0-9
    final rawDigits = textNormalized.replaceAll(RegExp(r'[^\d]'), '');
    if (rawDigits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
        composing: TextRange.empty,
      );
    }

    // 3. Loại bỏ các chữ số 0 thừa ở đầu (leading zeros)
    String cleanDigits = rawDigits.replaceFirst(RegExp(r'^0+'), '');
    if (cleanDigits.isEmpty) {
      cleanDigits = '0';
    }

    // 4. Giới hạn tối đa 12 chữ số
    if (cleanDigits.length > 12) {
      cleanDigits = cleanDigits.substring(0, 12);
    }

    // 5. Phân cách hàng nghìn bằng dấu chấm (.)
    final buffer = StringBuffer();
    for (int i = 0; i < cleanDigits.length; i++) {
      if (i > 0 && (cleanDigits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(cleanDigits[i]);
    }

    final formattedText = buffer.toString();
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
      composing: TextRange.empty,
    );
  }

  static double? giaiMaSoTien(String text) {
    if (text.isEmpty) return null;
    final textNormalized = text.replaceAllMapped(
      RegExp(r'[\uFF10-\uFF19]'),
      (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) - 0xFF10 + 0x30),
    );
    final rawDigits = textNormalized.replaceAll(RegExp(r'[^\d]'), '');
    if (rawDigits.isEmpty) return null;
    return double.tryParse(rawDigits);
  }

  static String dinhDang(double amount) {
    final int intAmount = amount.toInt();
    final String str = intAmount.abs().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return '${amount < 0 ? '-' : ''}${buffer.toString()} đ';
  }
}
