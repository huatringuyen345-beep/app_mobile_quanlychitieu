import 'package:flutter_test/flutter_test.dart';
import 'package:quanlychitieu/mo_hinh/mo_hinh_thong_bao.dart';

void main() {
  group('MoHinhLichNhacNho Tests', () {
    test('Khởi tạo lịch hàng ngày hợp lệ', () {
      final item = MoHinhLichNhacNho(
        id: 1,
        tieuDe: 'Nhắc chép sổ chi tiêu',
        noiDung: 'Ghi chép thu chi',
        loai: LoaiLichNhacNho.hangNgay,
        gio: 20,
        phut: 30,
      );

      expect(item.id, equals(1));
      expect(item.loai, equals(LoaiLichNhacNho.hangNgay));
      expect(item.hienThiLoai, equals('Hàng ngày'));
      expect(item.hienThiThoiGian, equals('20:30 hàng ngày'));
      expect(item.kichHoat, isTrue);
    });

    test('Khởi tạo lịch theo lịch ngày cụ thể hợp lệ', () {
      final date = DateTime(2026, 12, 25, 9, 15);
      final item = MoHinhLichNhacNho(
        id: 2,
        tieuDe: 'Đóng tiền điện',
        noiDung: 'Thanh toán hóa đơn điện tháng 12',
        loai: LoaiLichNhacNho.theoLich,
        gio: 9,
        phut: 15,
        ngayDatLich: date,
      );

      expect(item.id, equals(2));
      expect(item.loai, equals(LoaiLichNhacNho.theoLich));
      expect(item.hienThiLoai, equals('Theo lịch'));
      expect(item.hienThiThoiGian, equals('09:15 - 25/12/2026'));
    });

    test('Chuyển đổi Map và JSON hoạt động chính xác', () {
      final date = DateTime(2026, 11, 30);
      final item = MoHinhLichNhacNho(
        id: 100,
        tieuDe: 'Nhắc tiết kiệm',
        noiDung: 'Chuyển tiền vào hũ tiết kiệm',
        loai: LoaiLichNhacNho.theoLich,
        gio: 8,
        phut: 0,
        ngayDatLich: date,
        kichHoat: false,
      );

      final map = item.toMap();
      final fromMapItem = MoHinhLichNhacNho.fromMap(map);

      expect(fromMapItem.id, equals(100));
      expect(fromMapItem.tieuDe, equals('Nhắc tiết kiệm'));
      expect(fromMapItem.loai, equals(LoaiLichNhacNho.theoLich));
      expect(fromMapItem.gio, equals(8));
      expect(fromMapItem.phut, equals(0));
      expect(fromMapItem.kichHoat, isFalse);

      final jsonStr = item.toJson();
      final fromJsonItem = MoHinhLichNhacNho.fromJson(jsonStr);
      expect(fromJsonItem.id, equals(100));
      expect(fromJsonItem.tieuDe, equals('Nhắc tiết kiệm'));
    });

    test('Phương thức copyWith tạo đối tượng mới đúng thuộc tính', () {
      final original = MoHinhLichNhacNho(
        id: 5,
        tieuDe: 'Nhắc nhở cũ',
        noiDung: 'Nội dung cũ',
        loai: LoaiLichNhacNho.hangNgay,
        gio: 19,
        phut: 0,
        kichHoat: true,
      );

      final updated = original.copyWith(
        tieuDe: 'Nhắc nhở mới',
        gio: 21,
        kichHoat: false,
      );

      expect(updated.id, equals(5));
      expect(updated.tieuDe, equals('Nhắc nhở mới'));
      expect(updated.noiDung, equals('Nội dung cũ'));
      expect(updated.gio, equals(21));
      expect(updated.phut, equals(0));
      expect(updated.kichHoat, isFalse);
    });
  });
}
