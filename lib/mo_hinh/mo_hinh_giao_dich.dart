import 'package:flutter/material.dart';

enum LoaiGiaoDich { thuNhap, chiTieu }

class MoHinhGiaoDich {
  final String id;
  final String tieuDe;
  final double soTien;
  final DateTime ngayGiaoDich;
  final LoaiGiaoDich loai;
  final IconData icon;
  final Color mauNenIcon;
  final String danhMuc;
  final String ghiChu;

  const MoHinhGiaoDich({
    required this.id,
    required this.tieuDe,
    required this.soTien,
    required this.ngayGiaoDich,
    required this.loai,
    required this.icon,
    required this.mauNenIcon,
    required this.danhMuc,
    this.ghiChu = '',
  });

  bool get laThuNhap => loai == LoaiGiaoDich.thuNhap;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tieuDe': tieuDe,
      'soTien': soTien,
      'ngayGiaoDich': ngayGiaoDich.toIso8601String(),
      'loai': loai.index,
      'iconCodePoint': icon.codePoint,
      'mauNenValue': mauNenIcon.toARGB32(),
      'danhMuc': danhMuc,
      'ghiChu': ghiChu,
    };
  }

  factory MoHinhGiaoDich.fromMap(Map<String, dynamic> map) {
    final int codePoint = map['iconCodePoint'] as int;
    return MoHinhGiaoDich(
      id: map['id'],
      tieuDe: map['tieuDe'],
      soTien: (map['soTien'] as num).toDouble(),
      ngayGiaoDich: DateTime.parse(map['ngayGiaoDich']),
      loai: LoaiGiaoDich.values[map['loai'] as int],
      // ignore: non_const_argument_for_const_parameter
      icon: IconData(codePoint, fontFamily: 'MaterialIcons'),
      mauNenIcon: Color(map['mauNenValue'] as int),
      danhMuc: map['danhMuc'],
      ghiChu: map['ghiChu'] ?? '',
    );
  }
}

class MoHinhDanhMuc {
  final String id;
  final String tenDanhMuc;
  final IconData icon;
  final Color mauSac;
  final LoaiGiaoDich loai;

  const MoHinhDanhMuc({
    required this.id,
    required this.tenDanhMuc,
    required this.icon,
    required this.mauSac,
    required this.loai,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tenDanhMuc': tenDanhMuc,
      'iconCodePoint': icon.codePoint,
      'mauSacValue': mauSac.toARGB32(),
      'loai': loai.index,
    };
  }

  factory MoHinhDanhMuc.fromMap(Map<String, dynamic> map) {
    final int codePoint = map['iconCodePoint'] as int;
    return MoHinhDanhMuc(
      id: map['id'],
      tenDanhMuc: map['tenDanhMuc'],
      // ignore: non_const_argument_for_const_parameter
      icon: IconData(codePoint, fontFamily: 'MaterialIcons'),
      mauSac: Color(map['mauSacValue'] as int),
      loai: LoaiGiaoDich.values[map['loai'] as int],
    );
  }
}

class MoHinhNganSach {
  final String id;
  final String danhMuc;
  final String nhan;
  final double gioiHan;
  final double daDung;
  final IconData icon;
  final Color mauSac;

  const MoHinhNganSach({
    required this.id,
    required this.danhMuc,
    this.nhan = '',
    required this.gioiHan,
    this.daDung = 0.0,
    required this.icon,
    required this.mauSac,
  });

  String get tenHienThi => nhan.trim().isNotEmpty ? nhan.trim() : danhMuc;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'danhMuc': danhMuc,
      'nhan': nhan,
      'gioiHan': gioiHan,
      'daDung': daDung,
      'iconCodePoint': icon.codePoint,
      'mauSacValue': mauSac.toARGB32(),
    };
  }

  factory MoHinhNganSach.fromMap(Map<String, dynamic> map) {
    final int codePoint = map['iconCodePoint'] as int;
    return MoHinhNganSach(
      id: map['id'],
      danhMuc: map['danhMuc'],
      nhan: map['nhan'] ?? '',
      gioiHan: (map['gioiHan'] as num).toDouble(),
      daDung: (map['daDung'] as num?)?.toDouble() ?? 0.0,
      // ignore: non_const_argument_for_const_parameter
      icon: IconData(codePoint, fontFamily: 'MaterialIcons'),
      mauSac: Color(map['mauSacValue'] as int),
    );
  }

  MoHinhNganSach copyWith({
    String? id,
    String? danhMuc,
    String? nhan,
    double? gioiHan,
    double? daDung,
    IconData? icon,
    Color? mauSac,
  }) {
    return MoHinhNganSach(
      id: id ?? this.id,
      danhMuc: danhMuc ?? this.danhMuc,
      nhan: nhan ?? this.nhan,
      gioiHan: gioiHan ?? this.gioiHan,
      daDung: daDung ?? this.daDung,
      icon: icon ?? this.icon,
      mauSac: mauSac ?? this.mauSac,
    );
  }
}

class DuLieuMau {
  static final List<MoHinhGiaoDich> danhSachGiaoDich = [
    MoHinhGiaoDich(
      id: '1',
      tieuDe: 'Ăn uống sáng & trưa',
      soTien: 45000,
      ngayGiaoDich: DateTime.now(),
      loai: LoaiGiaoDich.chiTieu,
      icon: Icons.restaurant_rounded,
      mauNenIcon: const Color(0xFFFFE7D9),
      danhMuc: 'Ăn uống',
      ghiChu: 'Phở bò & Cà phê sáng',
    ),
    MoHinhGiaoDich(
      id: '2',
      tieuDe: 'Vé xe bus & Grab',
      soTien: 15000,
      ngayGiaoDich: DateTime.now(),
      loai: LoaiGiaoDich.chiTieu,
      icon: Icons.directions_bus_rounded,
      mauNenIcon: const Color(0xFFDDEBFF),
      danhMuc: 'Đi lại',
      ghiChu: 'Di chuyển đi làm',
    ),
    MoHinhGiaoDich(
      id: '3',
      tieuDe: 'Nhận lương tháng',
      soTien: 8000000,
      ngayGiaoDich: DateTime.now().subtract(const Duration(days: 1)),
      loai: LoaiGiaoDich.thuNhap,
      icon: Icons.account_balance_wallet_rounded,
      mauNenIcon: const Color(0xFFFFF4E8),
      danhMuc: 'Lương',
      ghiChu: 'Lương công ty hàng tháng',
    ),
    MoHinhGiaoDich(
      id: '4',
      tieuDe: 'Mua sắm siêu thị',
      soTien: 350000,
      ngayGiaoDich: DateTime.now().subtract(const Duration(days: 2)),
      loai: LoaiGiaoDich.chiTieu,
      icon: Icons.shopping_bag_rounded,
      mauNenIcon: const Color(0xFFFFF0D9),
      danhMuc: 'Mua sắm',
      ghiChu: 'Rau củ, hoa quả và đồ dùng nhà bếp',
    ),
    MoHinhGiaoDich(
      id: '5',
      tieuDe: 'Thưởng dự án',
      soTien: 1500000,
      ngayGiaoDich: DateTime.now().subtract(const Duration(days: 3)),
      loai: LoaiGiaoDich.thuNhap,
      icon: Icons.card_giftcard_rounded,
      mauNenIcon: const Color(0xFFE2F3DD),
      danhMuc: 'Thưởng',
      ghiChu: 'Thưởng hoàn thành KPI quý',
    ),
    MoHinhGiaoDich(
      id: '6',
      tieuDe: 'Tiền điện nước',
      soTien: 420000,
      ngayGiaoDich: DateTime.now().subtract(const Duration(days: 4)),
      loai: LoaiGiaoDich.chiTieu,
      icon: Icons.bolt_rounded,
      mauNenIcon: const Color(0xFFFFF3CD),
      danhMuc: 'Hóa đơn',
      ghiChu: 'Hóa đơn điện tháng này',
    ),
  ];

  static final List<MoHinhDanhMuc> danhSachDanhMuc = [
    const MoHinhDanhMuc(
      id: 'c1',
      tenDanhMuc: 'Ăn uống',
      icon: Icons.restaurant_rounded,
      mauSac: Color(0xFFE07852),
      loai: LoaiGiaoDich.chiTieu,
    ),
    const MoHinhDanhMuc(
      id: 'c2',
      tenDanhMuc: 'Đi lại',
      icon: Icons.directions_bus_rounded,
      mauSac: Color(0xFF4A90E2),
      loai: LoaiGiaoDich.chiTieu,
    ),
    const MoHinhDanhMuc(
      id: 'c3',
      tenDanhMuc: 'Mua sắm',
      icon: Icons.shopping_bag_rounded,
      mauSac: Color(0xFFE67E22),
      loai: LoaiGiaoDich.chiTieu,
    ),
    const MoHinhDanhMuc(
      id: 'c4',
      tenDanhMuc: 'Hóa đơn',
      icon: Icons.receipt_long_rounded,
      mauSac: Color(0xFF9B59B6),
      loai: LoaiGiaoDich.chiTieu,
    ),
    const MoHinhDanhMuc(
      id: 'c5',
      tenDanhMuc: 'Giải trí',
      icon: Icons.sports_esports_rounded,
      mauSac: Color(0xFF1ABC9C),
      loai: LoaiGiaoDich.chiTieu,
    ),
    const MoHinhDanhMuc(
      id: 'c6',
      tenDanhMuc: 'Lương',
      icon: Icons.account_balance_wallet_rounded,
      mauSac: Color(0xFFE07852),
      loai: LoaiGiaoDich.thuNhap,
    ),
    const MoHinhDanhMuc(
      id: 'c7',
      tenDanhMuc: 'Thưởng',
      icon: Icons.card_giftcard_rounded,
      mauSac: Color(0xFF27AE60),
      loai: LoaiGiaoDich.thuNhap,
    ),
    const MoHinhDanhMuc(
      id: 'c8',
      tenDanhMuc: 'Đầu tư',
      icon: Icons.trending_up_rounded,
      mauSac: Color(0xFF2980B9),
      loai: LoaiGiaoDich.thuNhap,
    ),
  ];

  static final List<MoHinhNganSach> danhSachNganSach = [
    const MoHinhNganSach(
      id: 'b1',
      danhMuc: 'Ăn uống',
      gioiHan: 3000000,
      daDung: 1250000,
      icon: Icons.restaurant_rounded,
      mauSac: Colors.orange,
    ),
    const MoHinhNganSach(
      id: 'b2',
      danhMuc: 'Đi lại',
      gioiHan: 1000000,
      daDung: 450000,
      icon: Icons.directions_bus_rounded,
      mauSac: Colors.blue,
    ),
    const MoHinhNganSach(
      id: 'b3',
      danhMuc: 'Mua sắm',
      gioiHan: 1500000,
      daDung: 630000,
      icon: Icons.shopping_bag_rounded,
      mauSac: Colors.purple,
    ),
  ];
}
