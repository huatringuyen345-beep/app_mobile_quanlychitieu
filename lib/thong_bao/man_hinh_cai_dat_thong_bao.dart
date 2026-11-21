import 'package:flutter/material.dart';
import '../dich_vu/dich_vu_thong_bao.dart';
import '../mo_hinh/mo_hinh_thong_bao.dart';

class ManHinhCaiDatThongBao extends StatefulWidget {
  const ManHinhCaiDatThongBao({super.key});

  @override
  State<ManHinhCaiDatThongBao> createState() => _ManHinhCaiDatThongBaoState();
}

class _ManHinhCaiDatThongBaoState extends State<ManHinhCaiDatThongBao> {
  static const Color mauChinh = Color(0xFFE07852);

  bool _choPhepThongBao = true;
  List<MoHinhLichNhacNho> _danhSachNhacNho = [];
  bool _dangTai = true;

  @override
  void initState() {
    super.initState();
    _taiDuLieu();
  }

  Future<void> _taiDuLieu() async {
    setState(() => _dangTai = true);
    final dichVu = DichVuThongBao();
    final choPhep = await dichVu.layChoPhepThongBao();
    final ds = await dichVu.layDanhSachNhacNho();
    if (mounted) {
      setState(() {
        _choPhepThongBao = choPhep;
        _danhSachNhacNho = ds;
        _dangTai = false;
      });
    }
  }

  Future<void> _doiChoPhepThongBao(bool value) async {
    setState(() => _choPhepThongBao = value);
    await DichVuThongBao().luuChoPhepThongBao(value);
    if (value) {
      final granted = await DichVuThongBao().yeuCauQuyenThongBao();
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng cấp quyền thông báo trong cài đặt thiết bị'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _guiThongBaoThu() async {
    final dichVu = DichVuThongBao();
    final granted = await dichVu.yeuCauQuyenThongBao();
    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ứng dụng chưa có quyền thông báo'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    await dichVu.hienThongBaoTucThoi(
      tieuDe: 'Thông báo thử nghiệm 🔔',
      noiDung: 'Ứng dụng Quản lý chi tiêu đang hoạt động tốt trên thiết bị của bạn!',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã gửi thông báo thử nghiệm! Kiểm tra thanh thông báo hệ thống.'),
          backgroundColor: mauChinh,
        ),
      );
    }
  }

  Future<void> _xoaLich(int id) async {
    await DichVuThongBao().xoaLich(id);
    await _taiDuLieu();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa lịch nhắc nhở')),
      );
    }
  }

  Future<void> _batTatLich(int id, bool val) async {
    await DichVuThongBao().batTatLich(id, val);
    await _taiDuLieu();
  }

  Future<void> _moHopThoaiThemSuLich({MoHinhLichNhacNho? banDau}) async {
    final kq = await showModalBottomSheet<MoHinhLichNhacNho>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BangSoanThaoLich(banDau: banDau),
    );

    if (kq != null) {
      await DichVuThongBao().themHoacCapNhatLich(kq);
      await _taiDuLieu();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(banDau != null
                ? 'Đã cập nhật lịch nhắc nhở'
                : 'Đã thêm lịch nhắc nhở mới'),
            backgroundColor: mauChinh,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Cài đặt & Lịch thông báo',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E232A),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : const Color(0xFF1E232A),
        ),
      ),
      body: _dangTai
          ? const Center(child: CircularProgressIndicator(color: mauChinh))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Thẻ Bật/Tắt Tổng Thông báo ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE8EAE5),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.amber.withValues(alpha: 0.15),
                              child: const Icon(Icons.notifications_active_rounded,
                                  color: Colors.amber),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Cho phép thông báo',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Bật để nhận thông báo nhắc nhở chi tiêu',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _choPhepThongBao,
                              activeThumbColor: mauChinh,
                              onChanged: _doiChoPhepThongBao,
                            ),
                          ],
                        ),
                        if (_choPhepThongBao) ...[
                          const Divider(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _guiThongBaoThu,
                              icon: const Icon(Icons.send_rounded, size: 18),
                              label: const Text('Thử gửi thông báo ngay'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: mauChinh,
                                side: const BorderSide(color: mauChinh),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- Header Lịch Nhắc Nhở ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Danh sách nhắc nhở',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _choPhepThongBao
                            ? () => _moHopThoaiThemSuLich()
                            : null,
                        icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                        label: const Text('Thêm mới', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mauChinh,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // --- Danh sách Lịch ---
                  if (_danhSachNhacNho.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE8EAE5),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.alarm_off_rounded,
                              size: 48, color: isDark ? Colors.white38 : Colors.grey),
                          const SizedBox(height: 12),
                          Text(
                            'Chưa có lịch nhắc nhở nào',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Hãy bấm "Thêm mới" để tạo nhắc nhở ghi sổ chi tiêu hoặc hóa đơn!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _danhSachNhacNho.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _danhSachNhacNho[index];
                        return _theLichNhacNho(item, isDark);
                      },
                    ),
                ],
              ),
            ),
    );
  }

  Widget _theLichNhacNho(MoHinhLichNhacNho item, bool isDark) {
    final isHangNgay = item.loai == LoaiLichNhacNho.hangNgay;
    final mauIcon = isHangNgay ? Colors.blue : Colors.purple;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE8EAE5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: mauIcon.withValues(alpha: 0.15),
            child: Icon(
              isHangNgay ? Icons.access_time_filled_rounded : Icons.calendar_month_rounded,
              color: mauIcon,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: mauIcon.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.hienThiLoai,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: mauIcon,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.hienThiThoiGian,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: mauChinh,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.tieuDe,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                if (item.noiDung.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.noiDung,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey[700],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    InkWell(
                      onTap: () => _moHopThoaiThemSuLich(banDau: item),
                      child: Row(
                        children: const [
                          Icon(Icons.edit_rounded, size: 14, color: Colors.blue),
                          SizedBox(width: 4),
                          Text('Sửa', style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () => _xoaLich(item.id),
                      child: Row(
                        children: const [
                          Icon(Icons.delete_outline_rounded, size: 14, color: Colors.redAccent),
                          SizedBox(width: 4),
                          Text('Xóa', style: TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: item.kichHoat && _choPhepThongBao,
            activeThumbColor: mauChinh,
            onChanged: _choPhepThongBao
                ? (val) => _batTatLich(item.id, val)
                : null,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BANG SOẠN THẢO / THÊM / SỬA LỊCH NHẮC NHỞ
// ============================================================
class _BangSoanThaoLich extends StatefulWidget {
  final MoHinhLichNhacNho? banDau;
  const _BangSoanThaoLich({this.banDau});

  @override
  State<_BangSoanThaoLich> createState() => _BangSoanThaoLichState();
}

class _BangSoanThaoLichState extends State<_BangSoanThaoLich> {
  late LoaiLichNhacNho _loai;
  late TimeOfDay _gioSelected;
  late DateTime _ngaySelected;
  late TextEditingController _ctlTieuDe;
  late TextEditingController _ctlNoiDung;

  static const Color mauChinh = Color(0xFFE07852);

  @override
  void initState() {
    super.initState();
    final item = widget.banDau;
    if (item != null) {
      _loai = item.loai;
      _gioSelected = TimeOfDay(hour: item.gio, minute: item.phut);
      _ngaySelected = item.ngayDatLich ?? DateTime.now();
      _ctlTieuDe = TextEditingController(text: item.tieuDe);
      _ctlNoiDung = TextEditingController(text: item.noiDung);
    } else {
      _loai = LoaiLichNhacNho.hangNgay;
      _gioSelected = const TimeOfDay(hour: 20, minute: 30);
      _ngaySelected = DateTime.now().add(const Duration(days: 1));
      _ctlTieuDe = TextEditingController(text: 'Nhắc chép sổ chi tiêu');
      _ctlNoiDung = TextEditingController(text: 'Hãy ghi lại thu chi hôm nay nhé!');
    }
  }

  @override
  void dispose() {
    _ctlTieuDe.dispose();
    _ctlNoiDung.dispose();
    super.dispose();
  }

  Future<void> _chonGio() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _gioSelected,
    );
    if (picked != null) {
      setState(() => _gioSelected = picked);
    }
  }

  Future<void> _chonNgay() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _ngaySelected,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() => _ngaySelected = picked);
    }
  }

  void _luu() {
    final tieuDe = _ctlTieuDe.text.trim();
    if (tieuDe.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tiêu đề nhắc nhở')),
      );
      return;
    }

    final id = widget.banDau?.id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final itemMoi = MoHinhLichNhacNho(
      id: id,
      tieuDe: tieuDe,
      noiDung: _ctlNoiDung.text.trim(),
      loai: _loai,
      gio: _gioSelected.hour,
      phut: _gioSelected.minute,
      ngayDatLich: _loai == LoaiLichNhacNho.theoLich ? _ngaySelected : null,
      kichHoat: widget.banDau?.kichHoat ?? true,
    );

    Navigator.pop(context, itemMoi);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gioStr = _gioSelected.hour.toString().padLeft(2, '0');
    final phutStr = _gioSelected.minute.toString().padLeft(2, '0');
    final ngayStr = '${_ngaySelected.day.toString().padLeft(2, '0')}/${_ngaySelected.month.toString().padLeft(2, '0')}/${_ngaySelected.year}';

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.banDau == null
                      ? 'Thêm lịch nhắc nhở'
                      : 'Chỉnh sửa lịch nhắc nhở',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // Chọn loại nhắc nhở
                Text('Hình thức nhắc nhở',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black54)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        avatar: Icon(Icons.access_time_filled_rounded,
                            size: 16,
                            color: _loai == LoaiLichNhacNho.hangNgay
                                ? Colors.white
                                : mauChinh),
                        label: const Text('Theo giờ hàng ngày'),
                        selected: _loai == LoaiLichNhacNho.hangNgay,
                        selectedColor: mauChinh,
                        labelStyle: TextStyle(
                          color: _loai == LoaiLichNhacNho.hangNgay
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          if (val) setState(() => _loai = LoaiLichNhacNho.hangNgay);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        avatar: Icon(Icons.calendar_month_rounded,
                            size: 16,
                            color: _loai == LoaiLichNhacNho.theoLich
                                ? Colors.white
                                : mauChinh),
                        label: const Text('Theo lịch ngày & giờ'),
                        selected: _loai == LoaiLichNhacNho.theoLich,
                        selectedColor: mauChinh,
                        labelStyle: TextStyle(
                          color: _loai == LoaiLichNhacNho.theoLich
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          if (val) setState(() => _loai = LoaiLichNhacNho.theoLich);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Bộ chọn Thời gian & Ngày
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _chonGio,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time_rounded, color: mauChinh),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Giờ nhận', style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.grey[600])),
                                  Text('$gioStr:$phutStr', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_loai == LoaiLichNhacNho.theoLich) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: _chonNgay,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, color: mauChinh),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Ngày nhận', style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.grey[600])),
                                    Text(ngayStr, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 16),

                // Tiêu đề & Nội dung
                TextField(
                  controller: _ctlTieuDe,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Tiêu đề nhắc nhở',
                    hintText: 'VD: Nhắc chép chi tiêu, Đóng tiền nhà...',
                    labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _ctlNoiDung,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Nội dung chi tiết (Không bắt buộc)',
                    hintText: 'VD: Hãy mở app để ghi chép lại thu chi nhé!',
                    labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Nút Lưu
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _luu,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mauChinh,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Lưu lịch nhắc nhở',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
