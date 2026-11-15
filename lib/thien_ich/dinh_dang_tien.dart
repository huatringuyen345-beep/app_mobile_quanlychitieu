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
      );
    }

    // Chỉ giữ lại chữ số
    final rawDigits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (rawDigits.isEmpty) {
      // Gõ ký tự không phải số -> giữ nguyên giá trị cũ (tránh lỗi selection)
      return oldValue;
    }

    // Loại bỏ các chữ số 0 thừa ở đầu (leading zeros)
    String cleanDigits = rawDigits.replaceFirst(RegExp(r'^0+'), '');
    if (cleanDigits.isEmpty) {
      cleanDigits = '0';
    }

    // Tự động phân cách hàng nghìn bằng dấu chấm (.)
    final buffer = StringBuffer();
    for (int i = 0; i < cleanDigits.length; i++) {
      if (i > 0 && (cleanDigits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(cleanDigits[i]);
    }

    // Giới hạn 12 chữ số (tránh gõ "000" liên tục làm tràn số)
    if (cleanDigits.length > 12) {
      return oldValue;
    }

    final formattedText = buffer.toString();
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }

  static double? giaiMaSoTien(String text) {
    final rawDigits = text.replaceAll('.', '').replaceAll(',', '').trim();
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
