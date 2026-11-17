import 'package:flutter/material.dart';
import '../dich_vu/quan_ly_trang_thai_app.dart';
import '../mo_hinh/mo_hinh_giao_dich.dart';
import '../thien_ich/dinh_dang_tien.dart';

class ManHinhNganSach extends StatefulWidget {
  const ManHinhNganSach({super.key});

  @override
  State<ManHinhNganSach> createState() => _ManHinhNganSachState();
}

class _ManHinhNganSachState extends State<ManHinhNganSach> {
  static const Color mauChinh = Color(0xFFE07852);

  static const List<String> danhSachGoiYNhan = [
    '🍚 Hũ Thiết Yếu',
    '🎓 Hũ Giáo Dục',
    '🏖️ Hũ Tiết Kiệm',
    '🍿 Hũ Hưởng Thụ',
    '📈 Hũ Đầu Tư',
    '🎁 Hũ Cho Đi',
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final quanLy = QuanLyTrangThaiScope.of(context);
    final danhSachNganSach = quanLy.danhSachNganSach;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Ngân sách & Hũ tài chính',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E232A),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: danhSachNganSach.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.savings_outlined,
                    size: 64,
                    color: isDark ? const Color(0xFF475569) : Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Chưa thiết lập hũ tài chính nào',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: danhSachNganSach.length,
              itemBuilder: (context, index) {
                final item = danhSachNganSach[index];
                final double tyLe = item.gioiHan > 0 ? (item.daDung / item.gioiHan) : 0.0;
                final bool coNhanRieng = item.nhan.trim().isNotEmpty;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.88) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE8EAE5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: item.mauSac.withValues(alpha: 0.15),
                            child: Icon(item.icon, color: item.mauSac),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.tenHienThi,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isDark ? Colors.white : const Color(0xFF1E232A),
                                  ),
                                ),
                                if (coNhanRieng) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Danh mục: ${item.danhMuc}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Text(
                            '${(tyLe * 100).toInt()}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: tyLe > 0.9 ? Colors.red : mauChinh,
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _hienHopThoaiSoNganSach(
                              context,
                              quanLy,
                              isDark,
                              nganSachSua: item,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                              color: Colors.redAccent,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _xacNhanXoaNganSach(
                              context,
                              quanLy,
                              item,
                              isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: tyLe.clamp(0.0, 1.0),
                          minHeight: 10,
                          backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF0F1EE),
                          color: tyLe > 0.9 ? Colors.red : mauChinh,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Đã dùng: ${DinhDangTienInputFormatter.dinhDang(item.daDung)}',
                            style: TextStyle(
                              color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Hạn mức: ${DinhDangTienInputFormatter.dinhDang(item.gioiHan)}',
                            style: TextStyle(
                              color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _hienHopThoaiSoNganSach(context, quanLy, isDark),
        backgroundColor: mauChinh,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Thêm hũ mới',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  void _hienHopThoaiSoNganSach(
    BuildContext context,
    QuanLyTrangThaiApp quanLy,
    bool isDark, {
    MoHinhNganSach? nganSachSua,
  }) {
    final bool isEdit = nganSachSua != null;
    final TextEditingController nhanController = TextEditingController(
      text: nganSachSua?.nhan ?? '',
    );
    final TextEditingController hanMucController = TextEditingController(
      text: isEdit ? DinhDangTienInputFormatter.dinhDang(nganSachSua.gioiHan) : '',
    );

    final danhMucChiTieu = quanLy.danhSachDanhMuc
        .where((c) => c.loai == LoaiGiaoDich.chiTieu)
        .toList();

    MoHinhDanhMuc danhMucChon = isEdit
        ? danhMucChiTieu.firstWhere(
            (c) => c.tenDanhMuc == nganSachSua.danhMuc,
            orElse: () => danhMucChiTieu.isNotEmpty ? danhMucChiTieu.first : quanLy.danhSachDanhMuc.first,
          )
        : (danhMucChiTieu.isNotEmpty ? danhMucChiTieu.first : quanLy.danhSachDanhMuc.first);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 24,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEdit ? 'Cài đặt nhãn & hạn mức hũ' : 'Thiết lập hũ tài chính mới',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Chọn danh mục
                    DropdownButtonFormField<MoHinhDanhMuc>(
                      initialValue: danhMucChon,
                      dropdownColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        labelText: 'Chọn danh mục liên kết',
                        labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : Colors.grey),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F8F4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: danhMucChiTieu.map((cat) {
                        return DropdownMenuItem<MoHinhDanhMuc>(
                          value: cat,
                          child: Text(cat.tenDanhMuc),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => danhMucChon = val);
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // Nhập nhãn tùy chỉnh
                    TextField(
                      controller: nhanController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        labelText: 'Nhãn cho hũ / Tên hũ (Tùy chọn)',
                        labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : Colors.grey),
                        hintText: 'Ví dụ: Hũ ăn uống gia đình, Hũ tiết kiệm...',
                        hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : Colors.grey.shade400),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F8F4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Chips gợi ý nhãn 6 Hũ Tài Chính
                    Text(
                      'Gợi ý nhãn nhanh (Quy tắc 6 Hũ):',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: danhSachGoiYNhan.map((label) {
                        return ActionChip(
                          label: Text(
                            label,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                            ),
                          ),
                          backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          onPressed: () {
                            setModalState(() {
                              nhanController.text = label;
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Hạn mức
                    TextField(
                      controller: hanMucController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: false,
                        signed: false,
                      ),
                      inputFormatters: [DinhDangTienInputFormatter()],
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        labelText: 'Hạn mức ngân sách (VNĐ)',
                        labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : Colors.grey),
                        hintText: 'Ví dụ: 2.000.000',
                        hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : Colors.grey.shade400),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F8F4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Nút Lưu
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () async {
                          final String tenNhan = nhanController.text.trim();
                          if (tenNhan.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vui lòng nhập tên / nội dung cho hũ tài chính!')),
                            );
                            return;
                          }

                          final double? hanMuc = DinhDangTienInputFormatter.giaiMaSoTien(hanMucController.text);
                          if (hanMuc == null || hanMuc <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vui lòng nhập hạn mức hợp lệ (> 0)')),
                            );
                            return;
                          }

                          final ns = MoHinhNganSach(
                            id: isEdit ? nganSachSua.id : DateTime.now().millisecondsSinceEpoch.toString(),
                            danhMuc: danhMucChon.tenDanhMuc,
                            nhan: nhanController.text.trim(),
                            gioiHan: hanMuc,
                            daDung: isEdit ? nganSachSua.daDung : 0.0,
                            icon: danhMucChon.icon,
                            mauSac: danhMucChon.mauSac,
                          );

                          await quanLy.luuNganSach(ns);

                          if (context.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isEdit
                                      ? 'Đã cập nhật nhãn hũ "${ns.tenHienThi}"'
                                      : 'Đã thiết lập hũ "${ns.tenHienThi}"',
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mauChinh,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          isEdit ? 'Lưu thay đổi nhãn & hạn mức' : 'Lưu hũ mới',
                          style: const TextStyle(
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
            );
          },
        );
      },
    );
  }

  void _xacNhanXoaNganSach(
    BuildContext context,
    QuanLyTrangThaiApp quanLy,
    MoHinhNganSach item,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Xóa hũ tài chính',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E232A),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa hũ "${item.tenHienThi}" không?',
            style: TextStyle(
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Hủy',
                style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await quanLy.xoaNganSach(item.id);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã xóa hũ "${item.tenHienThi}"')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Xóa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
