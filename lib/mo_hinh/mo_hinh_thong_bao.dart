import 'dart:convert';

enum LoaiLichNhacNho {
  hangNgay, // Nhắc nhở theo giờ cố định hàng ngày
  theoLich, // Nhắc nhở theo ngày và giờ cụ thể trên lịch
}

class MoHinhLichNhacNho {
  final int id;
  final String tieuDe;
  final String noiDung;
  final LoaiLichNhacNho loai;
  final int gio; // 0..23
  final int phut; // 0..59
  final DateTime? ngayDatLich; // Dành cho loại theoLich
  final bool kichHoat;
  final DateTime ngayTao;

  MoHinhLichNhacNho({
    required this.id,
    required this.tieuDe,
    required this.noiDung,
    required this.loai,
    required this.gio,
    required this.phut,
    this.ngayDatLich,
    this.kichHoat = true,
    DateTime? ngayTao,
  }) : ngayTao = ngayTao ?? DateTime.now();

  String get hienThiLoai {
    switch (loai) {
      case LoaiLichNhacNho.hangNgay:
        return 'Hàng ngày';
      case LoaiLichNhacNho.theoLich:
        return 'Theo lịch';
    }
  }

  String get hienThiThoiGian {
    final gioStr = gio.toString().padLeft(2, '0');
    final phutStr = phut.toString().padLeft(2, '0');
    if (loai == LoaiLichNhacNho.theoLich && ngayDatLich != null) {
      final ngayStr = ngayDatLich!.day.toString().padLeft(2, '0');
      final thangStr = ngayDatLich!.month.toString().padLeft(2, '0');
      final namStr = ngayDatLich!.year.toString();
      return '$gioStr:$phutStr - $ngayStr/$thangStr/$namStr';
    }
    return '$gioStr:$phutStr hàng ngày';
  }

  MoHinhLichNhacNho copyWith({
    int? id,
    String? tieuDe,
    String? noiDung,
    LoaiLichNhacNho? loai,
    int? gio,
    int? phut,
    DateTime? ngayDatLich,
    bool? kichHoat,
    DateTime? ngayTao,
  }) {
    return MoHinhLichNhacNho(
      id: id ?? this.id,
      tieuDe: tieuDe ?? this.tieuDe,
      noiDung: noiDung ?? this.noiDung,
      loai: loai ?? this.loai,
      gio: gio ?? this.gio,
      phut: phut ?? this.phut,
      ngayDatLich: ngayDatLich ?? this.ngayDatLich,
      kichHoat: kichHoat ?? this.kichHoat,
      ngayTao: ngayTao ?? this.ngayTao,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tieuDe': tieuDe,
      'noiDung': noiDung,
      'loai': loai.name,
      'gio': gio,
      'phut': phut,
      'ngayDatLich': ngayDatLich?.toIso8601String(),
      'kichHoat': kichHoat,
      'ngayTao': ngayTao.toIso8601String(),
    };
  }

  factory MoHinhLichNhacNho.fromMap(Map<String, dynamic> map) {
    return MoHinhLichNhacNho(
      id: map['id'] as int,
      tieuDe: map['tieuDe'] as String? ?? '',
      noiDung: map['noiDung'] as String? ?? '',
      loai: map['loai'] == 'theoLich'
          ? LoaiLichNhacNho.theoLich
          : LoaiLichNhacNho.hangNgay,
      gio: map['gio'] as int? ?? 20,
      phut: map['phut'] as int? ?? 0,
      ngayDatLich: map['ngayDatLich'] != null
          ? DateTime.tryParse(map['ngayDatLich'] as String)
          : null,
      kichHoat: map['kichHoat'] as bool? ?? true,
      ngayTao: map['ngayTao'] != null
          ? DateTime.tryParse(map['ngayTao'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory MoHinhLichNhacNho.fromJson(String source) =>
      MoHinhLichNhacNho.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
