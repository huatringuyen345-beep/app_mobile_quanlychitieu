import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../mo_hinh/mo_hinh_thong_bao.dart';

class DichVuThongBao {
  static final DichVuThongBao _instance = DichVuThongBao._internal();
  factory DichVuThongBao() => _instance;
  DichVuThongBao._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _keyChoPhepThongBao = 'cho_phep_thong_bao';
  static const String _keyDanhSachLich = 'danh_sach_lich_nhac_nho';

  bool _daKhoiTao = false;
  bool get daKhoiTao => _daKhoiTao;

  /// Khởi tạo dịch vụ thông báo & múi giờ
  Future<void> khoiTao() async {
    if (_daKhoiTao) return;

    try {
      // 1. Khởi tạo múi giờ
      tz.initializeTimeZones();
      try {
        final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
        final String timeZoneName = timeZoneInfo.identifier;
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (e) {
        debugPrint('Không thiết lập được múi giờ địa phương: $e');
      }

      // 2. Cấu hình icon thông báo trên Android & iOS
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      );

      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint('Bấm vào thông báo: ${details.payload}');
        },
      );

      _daKhoiTao = true;

      // 3. Tự động khôi phục lịch nhắc nhở đã lưu
      await taiVaKhoiPhucLichNhacNho();
    } catch (e) {
      debugPrint('Lỗi khởi tạo DichVuThongBao: $e');
    }
  }

  /// Xin quyền hiển thị thông báo
  Future<bool> yeuCauQuyenThongBao() async {
    try {
      final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }

      final iosPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('Lỗi xin quyền thông báo: $e');
    }
    return true;
  }

  /// Thông tin cấu hình Notification Details chung
  NotificationDetails _layNotificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      'quan_ly_chi_tieu_channel',
      'Thông báo Nhắc nhở Chi tiêu',
      channelDescription: 'Kênh thông báo nhắc nhở ghi chép chi tiêu và hóa đơn',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  /// Hiển thị thông báo ngay lập tức (dùng để thử nghiệm)
  Future<void> hienThongBaoTucThoi({
    required String tieuDe,
    required String noiDung,
  }) async {
    await khoiTao();
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      await _notificationsPlugin.show(
        id: id,
        title: tieuDe,
        body: noiDung,
        notificationDetails: _layNotificationDetails(),
      );
    } catch (e) {
      debugPrint('Lỗi hiện thông báo tức thời: $e');
    }
  }

  /// Lên lịch thông báo theo `MoHinhLichNhacNho`
  Future<void> lapLichThongBao(MoHinhLichNhacNho nhacNho) async {
    await khoiTao();
    if (!nhacNho.kichHoat) return;

    final choPhep = await layChoPhepThongBao();
    if (!choPhep) return;

    try {
      if (nhacNho.loai == LoaiLichNhacNho.hangNgay) {
        final now = tz.TZDateTime.now(tz.local);
        var scheduledDate = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          nhacNho.gio,
          nhacNho.phut,
        );

        if (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }

        await _notificationsPlugin.zonedSchedule(
          id: nhacNho.id,
          title: nhacNho.tieuDe,
          body: nhacNho.noiDung,
          scheduledDate: scheduledDate,
          notificationDetails: _layNotificationDetails(),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } else if (nhacNho.loai == LoaiLichNhacNho.theoLich) {
        final date = nhacNho.ngayDatLich ?? DateTime.now();
        final scheduledDate = tz.TZDateTime(
          tz.local,
          date.year,
          date.month,
          date.day,
          nhacNho.gio,
          nhacNho.phut,
        );

        final now = tz.TZDateTime.now(tz.local);
        if (scheduledDate.isAfter(now)) {
          await _notificationsPlugin.zonedSchedule(
            id: nhacNho.id,
            title: nhacNho.tieuDe,
            body: nhacNho.noiDung,
            scheduledDate: scheduledDate,
            notificationDetails: _layNotificationDetails(),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        }
      }
    } catch (e) {
      debugPrint('Lỗi lên lịch thông báo ID ${nhacNho.id}: $e');
    }
  }

  /// Hủy 1 lịch thông báo theo ID
  Future<void> huyThongBao(int id) async {
    try {
      await _notificationsPlugin.cancel(id: id);
    } catch (e) {
      debugPrint('Lỗi hủy thông báo ID $id: $e');
    }
  }

  /// Hủy toàn bộ thông báo hệ thống
  Future<void> huyTatCaThongBao() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Lỗi hủy tất cả thông báo: $e');
    }
  }

  // ---------- QUẢN LÝ DỮ LIỆU LƯU TRỮ ----------

  Future<bool> layChoPhepThongBao() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyChoPhepThongBao) ?? true;
  }

  Future<void> luuChoPhepThongBao(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyChoPhepThongBao, value);
    if (!value) {
      await huyTatCaThongBao();
    } else {
      await taiVaKhoiPhucLichNhacNho();
    }
  }

  Future<List<MoHinhLichNhacNho>> layDanhSachNhacNho() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_keyDanhSachLich);
    if (jsonList == null || jsonList.isEmpty) {
      // Nếu chưa có, trả về danh sách lịch mặc định mẫu
      return _taoDanhSachMacDinh();
    }
    try {
      return jsonList
          .map((item) => MoHinhLichNhacNho.fromJson(item))
          .toList();
    } catch (e) {
      debugPrint('Lỗi đọc danh sách nhắc nhở: $e');
      return _taoDanhSachMacDinh();
    }
  }

  List<MoHinhLichNhacNho> _taoDanhSachMacDinh() {
    return [
      MoHinhLichNhacNho(
        id: 1001,
        tieuDe: 'Nhắc chép sổ chi tiêu',
        noiDung: 'Đừng quên ghi lại các khoản thu chi hôm nay bạn nhé!',
        loai: LoaiLichNhacNho.hangNgay,
        gio: 20,
        phut: 30,
        kichHoat: true,
      ),
      MoHinhLichNhacNho(
        id: 1002,
        tieuDe: 'Tổng kết chi tiêu tháng',
        noiDung: 'Xem lại tình hình tài chính và 6 hũ hằng tháng nào!',
        loai: LoaiLichNhacNho.theoLich,
        gio: 9,
        phut: 0,
        ngayDatLich: DateTime.now().add(const Duration(days: 7)),
        kichHoat: true,
      ),
    ];
  }

  Future<void> luuDanhSachNhacNho(List<MoHinhLichNhacNho> ds) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = ds.map((e) => e.toJson()).toList();
    await prefs.setStringList(_keyDanhSachLich, jsonList);
  }

  Future<void> themHoacCapNhatLich(MoHinhLichNhacNho item) async {
    final ds = await layDanhSachNhacNho();
    final idx = ds.indexWhere((e) => e.id == item.id);
    if (idx != -1) {
      ds[idx] = item;
    } else {
      ds.add(item);
    }
    await luuDanhSachNhacNho(ds);

    if (item.kichHoat) {
      await lapLichThongBao(item);
    } else {
      await huyThongBao(item.id);
    }
  }

  Future<void> batTatLich(int id, bool kichHoat) async {
    final ds = await layDanhSachNhacNho();
    final idx = ds.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final updated = ds[idx].copyWith(kichHoat: kichHoat);
      ds[idx] = updated;
      await luuDanhSachNhacNho(ds);
      if (kichHoat) {
        await lapLichThongBao(updated);
      } else {
        await huyThongBao(id);
      }
    }
  }

  Future<void> xoaLich(int id) async {
    final ds = await layDanhSachNhacNho();
    ds.removeWhere((e) => e.id == id);
    await luuDanhSachNhacNho(ds);
    await huyThongBao(id);
  }

  /// Đọc lại toàn bộ lịch và lập lịch lại với hệ thống
  Future<void> taiVaKhoiPhucLichNhacNho() async {
    final choPhep = await layChoPhepThongBao();
    if (!choPhep) return;

    final ds = await layDanhSachNhacNho();
    for (final item in ds) {
      if (item.kichHoat) {
        await lapLichThongBao(item);
      }
    }
  }
}
