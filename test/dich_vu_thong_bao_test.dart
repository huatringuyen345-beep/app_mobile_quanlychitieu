import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quanlychitieu/dich_vu/dich_vu_thong_bao.dart';
import 'package:quanlychitieu/mo_hinh/mo_hinh_thong_bao.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DichVuThongBao Tests', () {
    test('Lấy và lưu cấu hình cho phép thông báo', () async {
      final dichVu = DichVuThongBao();
      
      // Mặc định là true
      final defaultChoPhep = await dichVu.layChoPhepThongBao();
      expect(defaultChoPhep, isTrue);

      // Cập nhật sang false
      await dichVu.luuChoPhepThongBao(false);
      final updatedChoPhep = await dichVu.layChoPhepThongBao();
      expect(updatedChoPhep, isFalse);
    });

    test('Lưu, sửa và xóa danh sách lịch nhắc nhở trong SharedPreferences', () async {
      final dichVu = DichVuThongBao();

      final item1 = MoHinhLichNhacNho(
        id: 2001,
        tieuDe: 'Nhắc chép sổ',
        noiDung: 'Mỗi tối lúc 21h',
        loai: LoaiLichNhacNho.hangNgay,
        gio: 21,
        phut: 0,
      );

      final item2 = MoHinhLichNhacNho(
        id: 2002,
        tieuDe: 'Đóng tiền điện',
        noiDung: 'Tiền điện tháng 12',
        loai: LoaiLichNhacNho.theoLich,
        gio: 10,
        phut: 30,
        ngayDatLich: DateTime(2026, 12, 20),
      );

      // Lưu danh sách
      await dichVu.luuDanhSachNhacNho([item1, item2]);
      var ds = await dichVu.layDanhSachNhacNho();
      expect(ds.length, equals(2));
      expect(ds.first.tieuDe, equals('Nhắc chép sổ'));

      // Thêm / Cập nhật
      final item1Updated = item1.copyWith(tieuDe: 'Nhắc chép sổ chi tiêu hàng ngày');
      await dichVu.themHoacCapNhatLich(item1Updated);
      ds = await dichVu.layDanhSachNhacNho();
      expect(ds.first.tieuDe, equals('Nhắc chép sổ chi tiêu hàng ngày'));

      // Xóa item
      await dichVu.xoaLich(2002);
      ds = await dichVu.layDanhSachNhacNho();
      expect(ds.length, equals(1));
      expect(ds.first.id, equals(2001));
    });
  });
}
