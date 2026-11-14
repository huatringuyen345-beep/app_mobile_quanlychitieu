import 'package:flutter/material.dart';
import '../dich_vu/dich_vu_luu_tru.dart';

class ManHinhCaiDat extends StatefulWidget {
  final VoidCallback? chuyenToiDanhMuc;
  final VoidCallback? chuyenToiNganSach;
  final VoidCallback? dangXuat;

  final ValueChanged<bool>? khiDoiGiaoDienToi;
  final bool laGiaoDienToi;

  const ManHinhCaiDat({
    super.key,
    this.chuyenToiDanhMuc,
    this.chuyenToiNganSach,
    this.dangXuat,
    this.khiDoiGiaoDienToi,
    this.laGiaoDienToi = false,
  });

  @override
  State<ManHinhCaiDat> createState() => _ManHinhCaiDatState();
}

class _ManHinhCaiDatState extends State<ManHinhCaiDat> {
  late bool _giaoDienToi;
  bool _vanTayBaoMat = true;
  bool _thongBao = true;

  String _hoTen = 'HỨA TRÍ NGUYÊN';
  String _email = 'huatringuyen345@gmail.com';

  static const Color mauChinh = Color(0xFFE07852);

  @override
  void initState() {
    super.initState();
    _giaoDienToi = widget.laGiaoDienToi;
    _taiThongTinNguoiDung();
  }

  Future<void> _taiThongTinNguoiDung() async {
    final thongTin = await DichVuLuuTru.layThongTinNguoiDung();
    final isDark = await DichVuLuuTru.layGiaoDienToi();
    if (mounted) {
      setState(() {
        _hoTen = thongTin['hoTen'] ?? 'HỨA TRÍ NGUYÊN';
        _email = thongTin['email'] ?? 'huatringuyen345@gmail.com';
        _giaoDienToi = isDark;
      });
    }
  }

  void _hienHopThoaiXacNhanDangXuat() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          title: Text(
            'Đăng xuất',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: isDark ? Colors.white : const Color(0xFF1E232A),
            ),
          ),
          content: Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản không?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
              height: 1.4,
            ),
          ),
          actionsPadding: const EdgeInsets.all(20),
          actions: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Hủy',
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF1E232A),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(dialogContext);
                        await DichVuLuuTru.xoaDangXuat();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã đăng xuất thành công!'),
                              backgroundColor: mauChinh,
                            ),
                          );
                          if (widget.dangXuat != null) {
                            widget.dangXuat!();
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mauChinh,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Đăng xuất',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Cài đặt & Tài khoản'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin người dùng động
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE8EAE5)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFFFFF4E8),
                    child: Icon(Icons.person_rounded, size: 36, color: mauChinh),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _hoTen,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _email,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_outlined, color: mauChinh),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quản lý
            Text(
              'Quản lý dữ liệu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE8EAE5)),
              ),
              child: Column(
                children: [
                  _taoMucCaiDat(
                    icon: Icons.category_rounded,
                    mauIcon: Colors.orange,
                    tieuDe: 'Quản lý danh mục',
                    moTa: 'Tùy chỉnh danh mục thu chi',
                    onTap: widget.chuyenToiDanhMuc,
                    isDark: isDark,
                  ),
                  Divider(height: 1, indent: 56, endIndent: 16, color: isDark ? const Color(0xFF334155) : null),
                  _taoMucCaiDat(
                    icon: Icons.account_balance_wallet_rounded,
                    mauIcon: Colors.blue,
                    tieuDe: 'Quản lý ngân sách',
                    moTa: 'Đặt hạn mức chi tiêu hàng tháng',
                    onTap: widget.chuyenToiNganSach,
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tùy chọn ứng dụng
            Text(
              'Cài đặt ứng dụng',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE8EAE5)),
              ),
              child: Column(
                children: [
                  _taoMucCongTac(
                    icon: Icons.dark_mode_rounded,
                    mauIcon: Colors.indigo,
                    tieuDe: 'Giao diện tối',
                    giaTri: _giaoDienToi,
                    khiDoi: (val) async {
                      setState(() {
                        _giaoDienToi = val;
                      });
                      await DichVuLuuTru.luuGiaoDienToi(val);
                      if (widget.khiDoiGiaoDienToi != null) {
                        widget.khiDoiGiaoDienToi!(val);
                      }
                    },
                    isDark: isDark,
                  ),
                  Divider(height: 1, indent: 56, endIndent: 16, color: isDark ? const Color(0xFF334155) : null),
                  _taoMucCongTac(
                    icon: Icons.fingerprint_rounded,
                    mauIcon: Colors.teal,
                    tieuDe: 'Bảo mật vân tay',
                    giaTri: _vanTayBaoMat,
                    khiDoi: (val) {
                      setState(() {
                        _vanTayBaoMat = val;
                      });
                    },
                    isDark: isDark,
                  ),
                  Divider(height: 1, indent: 56, endIndent: 16, color: isDark ? const Color(0xFF334155) : null),
                  _taoMucCongTac(
                    icon: Icons.notifications_active_rounded,
                    mauIcon: Colors.amber,
                    tieuDe: 'Thông báo nhắc nhở',
                    giaTri: _thongBao,
                    khiDoi: (val) {
                      setState(() {
                        _thongBao = val;
                      });
                    },
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Hệ thống
            Text(
              'Hệ thống',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE8EAE5)),
              ),
              child: Column(
                children: [
                  _taoMucCaiDat(
                    icon: Icons.cloud_upload_rounded,
                    mauIcon: Colors.cyan,
                    tieuDe: 'Sao lưu & Phục hồi',
                    moTa: 'Đồng bộ dữ liệu lên đám mây',
                    onTap: () {},
                    isDark: isDark,
                  ),
                  Divider(height: 1, indent: 56, endIndent: 16, color: isDark ? const Color(0xFF334155) : null),
                  _taoMucCaiDat(
                    icon: Icons.info_outline_rounded,
                    mauIcon: Colors.purple,
                    tieuDe: 'Thông tin ứng dụng',
                    moTa: 'Phiên bản 1.0.0',
                    onTap: () {},
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Nút đăng xuất
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _hienHopThoaiXacNhanDangXuat,
                icon: const Icon(Icons.logout_rounded, color: mauChinh),
                label: const Text(
                  'Đăng xuất',
                  style: TextStyle(
                    color: mauChinh,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF3B1D15) : const Color(0xFFFFF4E8),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _taoMucCaiDat({
    required IconData icon,
    required Color mauIcon,
    required String tieuDe,
    String? moTa,
    VoidCallback? onTap,
    bool isDark = false,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: mauIcon.withValues(alpha: 0.15),
        child: Icon(icon, color: mauIcon, size: 22),
      ),
      title: Text(
        tieuDe,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: moTa != null
          ? Text(
              moTa,
              style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : Colors.grey),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _taoMucCongTac({
    required IconData icon,
    required Color mauIcon,
    required String tieuDe,
    required bool giaTri,
    required ValueChanged<bool> khiDoi,
    bool isDark = false,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: mauIcon.withValues(alpha: 0.15),
        child: Icon(icon, color: mauIcon, size: 22),
      ),
      title: Text(
        tieuDe,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      trailing: Switch(
        value: giaTri,
        activeThumbColor: mauChinh,
        onChanged: khiDoi,
      ),
    );
  }
}
