import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quanlychitieu/mo_hinh/mo_hinh_giao_dich.dart';

void main() {
  test('Kiểm tra Serialization MoHinhGiaoDich', () {
    final tx = MoHinhGiaoDich(
      id: 'tx1',
      tieuDe: 'Ăn tối',
      soTien: 100000,
      ngayGiaoDich: DateTime(2026, 11, 2),
      loai: LoaiGiaoDich.chiTieu,
      icon: Icons.restaurant,
      mauNenIcon: Colors.orange,
      danhMuc: 'Ăn uống',
      ghiChu: 'Ăn lẩu',
    );

    final map = tx.toMap();
    expect(map['id'], 'tx1');
    expect(map['soTien'], 100000.0);
    expect(map['danhMuc'], 'Ăn uống');

    final txFromMap = MoHinhGiaoDich.fromMap(map);
    expect(txFromMap.id, tx.id);
    expect(txFromMap.tieuDe, tx.tieuDe);
    expect(txFromMap.soTien, tx.soTien);
    expect(txFromMap.loai, tx.loai);
    expect(txFromMap.danhMuc, tx.danhMuc);
  });

  test('Kiểm tra Serialization MoHinhDanhMuc', () {
    const cat = MoHinhDanhMuc(
      id: 'c1',
      tenDanhMuc: 'Mua sắm',
      icon: Icons.shopping_bag,
      mauSac: Colors.purple,
      loai: LoaiGiaoDich.chiTieu,
    );

    final map = cat.toMap();
    final catFromMap = MoHinhDanhMuc.fromMap(map);

    expect(catFromMap.id, cat.id);
    expect(catFromMap.tenDanhMuc, cat.tenDanhMuc);
    expect(catFromMap.loai, cat.loai);
  });
}
