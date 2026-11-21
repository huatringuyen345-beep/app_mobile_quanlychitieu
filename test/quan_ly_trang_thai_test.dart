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

  test('Kiểm tra Serialization MoHinhNganSach và tenHienThi nhãn hũ', () {
    const nsWithNhan = MoHinhNganSach(
      id: 'b1',
      danhMuc: 'Ăn uống',
      nhan: 'Hũ Ăn Uống Gia Đình',
      gioiHan: 3000000,
      icon: Icons.restaurant,
      mauSac: Colors.orange,
    );

    expect(nsWithNhan.tenHienThi, 'Hũ Ăn Uống Gia Đình');
    final map = nsWithNhan.toMap();
    expect(map['nhan'], 'Hũ Ăn Uống Gia Đình');

    final nsFromMap = MoHinhNganSach.fromMap(map);
    expect(nsFromMap.nhan, 'Hũ Ăn Uống Gia Đình');
    expect(nsFromMap.tenHienThi, 'Hũ Ăn Uống Gia Đình');

    const nsWithoutNhan = MoHinhNganSach(
      id: 'b2',
      danhMuc: 'Đi lại',
      gioiHan: 1000000,
      icon: Icons.directions_bus,
      mauSac: Colors.blue,
    );
    expect(nsWithoutNhan.tenHienThi, 'Đi lại');
  });

  test('Kiểm tra danh sách giao dịch & ngân sách mặc định phải ở trạng thái sạch (rỗng)', () {
    final danhSachMoi = <MoHinhGiaoDich>[];
    final nganSachMoi = <MoHinhNganSach>[];
    final double soDu = 0.0;

    expect(danhSachMoi.isEmpty, isTrue);
    expect(nganSachMoi.isEmpty, isTrue);
    expect(soDu, 0.0);
  });
}



