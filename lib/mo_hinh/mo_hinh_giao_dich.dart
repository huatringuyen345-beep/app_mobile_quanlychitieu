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
    // --- Thu nhập ---
    MoHinhGiaoDich(
      id: 'tx_1',
      tieuDe: 'Lương tháng',
      soTien: 15000000,
      ngayGiaoDich: DateTime.now(),
      loai: LoaiGiaoDich.thuNhap,
      icon: Icons.account_balance_wallet_rounded,
      mauNenIcon: const Color(0xFFE8F5E9),
      danhMuc: 'Lương',
      ghiChu: 'Lương nhân viên kinh doanh',
    ),
    MoHinhGiaoDich(
      id: 'tx_2',
      tieuDe: 'Thưởng khóa này',
      soTien: 1200000,
      ngayGiaoDich: DateTime.now(),
      loai: LoaiGiaoDich.thuNhap,
      icon: Icons.card_giftcard_rounded,
      mauNenIcon: const Color(0xFFFFF3E0),
      danhMuc: 'Thưởng',
      ghiChu: 'Thưởng chỉ tiêu bán hàng',
    ),

    // --- Chi tiêu & Trích hũ ---
    MoHinhGiaoDich(
      id: 'tx_3',
      tieuDe: 'Trích quỹ mua xe',
      soTien: 8000000,
      ngayGiaoDich: DateTime.now(),
      loai: LoaiGiaoDich.chiTieu,
      icon: Icons.savings_rounded,
      mauNenIcon: const Color(0xFFF3E8FF),
      danhMuc: 'Tiết kiệm',
      ghiChu: 'Mục tiêu mua xe cuối tháng',
    ),
    MoHinhGiaoDich(
      id: 'tx_4',
      tieuDe: 'Quỹ đầu tư tháng này',
      soTien: 2500000,
      ngayGiaoDich: DateTime.now(),
      loai: LoaiGiaoDich.chiTieu,
      icon: Icons.trending_up_rounded,
      mauNenIcon: const Color(0xFFE0F2FE),
      danhMuc: 'Đầu tư',
      ghiChu: 'Hũ đầu tư tài chính',
    ),
    MoHinhGiaoDich(
      id: 'tx_5',
      tieuDe: 'Tiền nhà',
      soTien: 3000000,
      ngayGiaoDich: DateTime.now().subtract(const Duration(days: 1)),
      loai: LoaiGiaoDich.chiTieu,
      icon: Icons.home_rounded,
      mauNenIcon: const Color(0xFFFFE7D9),
      danhMuc: 'Thiết yếu',
      ghiChu: 'Thanh toán tiền nhà đầu tháng',
    ),
    MoHinhGiaoDich(
      id: 'tx_6',
      tieuDe: 'Cơm trưa',
      soTien: 45000,
      ngayGiaoDich: DateTime.now(),
      loai: LoaiGiaoDich.chiTieu,
      icon: Icons.restaurant_rounded,
      mauNenIcon: const Color(0xFFFFE7D9),
      danhMuc: 'Ăn uống',
      ghiChu: 'Cơm văn phòng',
    ),
    MoHinhGiaoDich(
      id: 'tx_7',
      tieuDe: 'Cà phê trước họp',
      soTien: 35000,
      ngayGiaoDich: DateTime.now(),
      loai: LoaiGiaoDich.chiTieu,
      icon: Icons.coffee_rounded,
      mauNenIcon: const Color(0xFFFFE7D9),
      danhMuc: 'Ăn uống',
      ghiChu: 'Cà phê họp nhóm',
    ),
    MoHinhGiaoDich(
      id: 'tx_8',
      tieuDe: 'Grab đi gặp khách',
      soTien: 68000,
      ngayGiaoDich: DateTime.now(),
      loai: LoaiGiaoDich.chiTieu,
      icon: Icons.directions_bus_rounded,
      mauNenIcon: const Color(0xFFDDEBFF),
      danhMuc: 'Đi lại',
      ghiChu: 'Di chuyển gặp đối tác',
    ),
    MoHinhGiaoDich(
      id: 'tx_9',
      tieuDe: 'Khóa học online',
      soTien: 480000,
      ngayGiaoDich: DateTime.now().subtract(const Duration(days: 2)),
      loai: LoaiGiaoDich.chiTieu,
      icon: Icons.school_rounded,
      mauNenIcon: const Color(0xFFCCFBF1),
      danhMuc: 'Giáo dục',
      ghiChu: 'Khóa kỹ năng bán hàng',
    ),
    MoHinhGiaoDich(
      id: 'tx_10',
      tieuDe: 'Mừng cưới đồng nghiệp',
      soTien: 500000,
      ngayGiaoDich: DateTime.now().subtract(const Duration(days: 3)),
      loai: LoaiGiaoDich.chiTieu,
      icon: Icons.favorite_rounded,
      mauNenIcon: const Color(0xFFFCE7F3),
      danhMuc: 'Cho đi',
      ghiChu: 'Thiệp mừng cưới',
    ),
    MoHinhGiaoDich(
      id: 'tx_11',
      tieuDe: 'Xem phim cuối tuần',
      soTien: 150000,
      ngayGiaoDich: DateTime.now().subtract(const Duration(days: 4)),
      loai: LoaiGiaoDich.chiTieu,
      icon: Icons.movie_rounded,
      mauNenIcon: const Color(0xFFFEF3C7),
      danhMuc: 'Giải trí',
      ghiChu: 'Vé xem phim CGV',
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
      tenDanhMuc: 'Thiết yếu',
      icon: Icons.home_rounded,
      mauSac: Color(0xFFE67E22),
      loai: LoaiGiaoDich.chiTieu,
    ),
    const MoHinhDanhMuc(
      id: 'c4',
      tenDanhMuc: 'Giáo dục',
      icon: Icons.school_rounded,
      mauSac: Color(0xFF14B8A6),
      loai: LoaiGiaoDich.chiTieu,
    ),
    const MoHinhDanhMuc(
      id: 'c5',
      tenDanhMuc: 'Tiết kiệm',
      icon: Icons.savings_rounded,
      mauSac: Color(0xFF8B5CF6),
      loai: LoaiGiaoDich.chiTieu,
    ),
    const MoHinhDanhMuc(
      id: 'c6',
      tenDanhMuc: 'Đầu tư',
      icon: Icons.trending_up_rounded,
      mauSac: Color(0xFF3B82F6),
      loai: LoaiGiaoDich.chiTieu,
    ),
    const MoHinhDanhMuc(
      id: 'c7',
      tenDanhMuc: 'Cho đi',
      icon: Icons.favorite_rounded,
      mauSac: Color(0xFFEC4899),
      loai: LoaiGiaoDich.chiTieu,
    ),
    const MoHinhDanhMuc(
      id: 'c8',
      tenDanhMuc: 'Giải trí',
      icon: Icons.sports_esports_rounded,
      mauSac: Color(0xFFF59E0B),
      loai: LoaiGiaoDich.chiTieu,
    ),
    const MoHinhDanhMuc(
      id: 'c9',
      tenDanhMuc: 'Lương',
      icon: Icons.account_balance_wallet_rounded,
      mauSac: Color(0xFF27AE60),
      loai: LoaiGiaoDich.thuNhap,
    ),
    const MoHinhDanhMuc(
      id: 'c10',
      tenDanhMuc: 'Thưởng',
      icon: Icons.card_giftcard_rounded,
      mauSac: Color(0xFFE07852),
      loai: LoaiGiaoDich.thuNhap,
    ),
  ];

  static final List<MoHinhNganSach> danhSachNganSach = [
    const MoHinhNganSach(
      id: 'b1',
      danhMuc: 'Tiết kiệm',
      nhan: '🏖️ Hũ Tiết Kiệm (mua xe)',
      gioiHan: 8000000,
      daDung: 8000000,
      icon: Icons.savings_rounded,
      mauSac: Color(0xFF8B5CF6),
    ),
    const MoHinhNganSach(
      id: 'b2',
      danhMuc: 'Đầu tư',
      nhan: '📈 Hũ Đầu Tư',
      gioiHan: 2500000,
      daDung: 2500000,
      icon: Icons.trending_up_rounded,
      mauSac: Color(0xFF3B82F6),
    ),
    const MoHinhNganSach(
      id: 'b3',
      danhMuc: 'Thiết yếu',
      nhan: '🍚 Hũ Thiết Yếu',
      gioiHan: 3500000,
      daDung: 3000000,
      icon: Icons.home_rounded,
      mauSac: Color(0xFFE07852),
    ),
    const MoHinhNganSach(
      id: 'b4',
      danhMuc: 'Giáo dục',
      nhan: '🎓 Hũ Giáo Dục',
      gioiHan: 500000,
      daDung: 480000,
      icon: Icons.school_rounded,
      mauSac: Color(0xFF14B8A6),
    ),
    const MoHinhNganSach(
      id: 'b5',
      danhMuc: 'Giải trí',
      nhan: '🍿 Hũ Hưởng Thụ',
      gioiHan: 1000000,
      daDung: 150000,
      icon: Icons.movie_rounded,
      mauSac: Color(0xFFF59E0B),
    ),
    const MoHinhNganSach(
      id: 'b6',
      danhMuc: 'Cho đi',
      nhan: '🎁 Hũ Cho Đi',
      gioiHan: 700000,
      daDung: 500000,
      icon: Icons.favorite_rounded,
      mauSac: Color(0xFFEC4899),
    ),
  ];
}

