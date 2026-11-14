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

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final quanLy = QuanLyTrangThaiScope.of(context);
    final danhSachNganSach = quanLy.danhSachNganSach;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Ngân sách & Tiết kiệm',
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
              child: Text(
                'Chưa thiết lập ngân sách nào',
                style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: danhSachNganSach.length,
              itemBuilder: (context, index) {
                final item = danhSachNganSach[index];
                final double tyLe = item.gioiHan > 0 ? (item.daDung / item.gioiHan) : 0.0;
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
                          Text(
                            item.danhMuc,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? Colors.white : const Color(0xFF1E232A),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${(tyLe * 100).toInt()}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: tyLe > 0.9 ? Colors.red : mauChinh,
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
                            'Đã dùng: ${item.daDung.toInt()} đ',
                            style: TextStyle(
                              color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Hạn mức: ${item.gioiHan.toInt()} đ',
                            style: TextStyle(
                              color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _hienHopThoaiThemNganSach(context, quanLy, isDark),
        backgroundColor: mauChinh,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _hienHopThoaiThemNganSach(
    BuildContext context,
    QuanLyTrangThaiApp quanLy,
    bool isDark,
  ) {
    final TextEditingController hanMucController = TextEditingController();
    MoHinhDanhMuc danhMucChon = quanLy.danhSachDanhMuc.firstWhere(
      (c) => c.loai == LoaiGiaoDich.chiTieu,
      orElse: () => quanLy.danhSachDanhMuc.first,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final danhMucChiTieu = quanLy.danhSachDanhMuc.where((c) => c.loai == LoaiGiaoDich.chiTieu).toList();

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thiết lập ngân sách mới',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<MoHinhDanhMuc>(
                    initialValue: danhMucChon,
                    dropdownColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'Chọn danh mục',
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
                  TextField(
                    controller: hanMucController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [DinhDangTienInputFormatter()],
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'Hạn mức ngân sách (VNĐ)',
                      labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : Colors.grey),
                      hintText: 'Ví dụ: 2.000.000',
                      hintStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : Colors.grey),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F8F4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        final double? hanMuc = DinhDangTienInputFormatter.giaiMaSoTien(hanMucController.text);
                        if (hanMuc == null || hanMuc <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Vui lòng nhập hạn mức hợp lệ (> 0)')),
                          );
                          return;
                        }

                        final ns = MoHinhNganSach(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          danhMuc: danhMucChon.tenDanhMuc,
                          gioiHan: hanMuc,
                          icon: danhMucChon.icon,
                          mauSac: danhMucChon.mauSac,
                        );

                        await quanLy.luuNganSach(ns);

                        if (context.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đã thiết lập ngân sách cho "${danhMucChon.tenDanhMuc}"')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mauChinh,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Lưu ngân sách',
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
            );
          },
        );
      },
    );
  }
}
