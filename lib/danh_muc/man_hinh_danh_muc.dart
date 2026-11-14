import 'package:flutter/material.dart';
import '../dich_vu/quan_ly_trang_thai_app.dart';
import '../mo_hinh/mo_hinh_giao_dich.dart';

class ManHinhDanhMuc extends StatefulWidget {
  final Function(String tenDanhMuc)? chonDanhMuc;

  const ManHinhDanhMuc({
    super.key,
    this.chonDanhMuc,
  });

  @override
  State<ManHinhDanhMuc> createState() => _ManHinhDanhMucState();
}

class _ManHinhDanhMucState extends State<ManHinhDanhMuc> {
  static const Color mauChinh = Color(0xFFE07852);

  int _viTriTab = 0; // 0: Chi tiêu, 1: Thu nhập
  String _danhMucDuocChon = 'Ăn uống';

  // Danh sách icon mẫu khi tạo danh mục mới
  final List<IconData> _danhSachIconMau = [
    Icons.restaurant_rounded,
    Icons.directions_bus_rounded,
    Icons.school_rounded,
    Icons.sports_esports_rounded,
    Icons.shopping_bag_rounded,
    Icons.home_rounded,
    Icons.favorite_rounded,
    Icons.work_rounded,
    Icons.receipt_long_rounded,
    Icons.local_hospital_rounded,
    Icons.pets_rounded,
    Icons.flight_rounded,
    Icons.phone_android_rounded,
    Icons.movie_rounded,
    Icons.fitness_center_rounded,
    Icons.more_horiz_rounded,
  ];

  // Danh sách màu mẫu
  final List<Color> _danhSachMauMau = [
    const Color(0xFFE75C5C),
    const Color(0xFF4A90E2),
    const Color(0xFF8E44AD),
    const Color(0xFFF39C12),
    const Color(0xFF16A085),
    const Color(0xFF2ECC71),
    const Color(0xFFE74C3C),
    const Color(0xFF34495E),
    const Color(0xFFE07852),
    const Color(0xFF27AE60),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final quanLy = QuanLyTrangThaiScope.of(context);
    final loai = _viTriTab == 0 ? LoaiGiaoDich.chiTieu : LoaiGiaoDich.thuNhap;

    final danhSachHienTai = quanLy.danhSachDanhMuc.where((c) => c.loai == loai).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Chọn danh mục',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? Colors.white : const Color(0xFF1E232A),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Nút chuyển tab Chi tiêu / Thu nhập
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.9) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE8EAE5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _taoNutTab(0, 'Chi tiêu', isDark),
                  ),
                  Expanded(
                    child: _taoNutTab(1, 'Thu nhập', isDark),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Lưới danh mục 3 cột
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.92,
              ),
              itemCount: danhSachHienTai.length + 1,
              itemBuilder: (context, index) {
                if (index < danhSachHienTai.length) {
                  final item = danhSachHienTai[index];
                  final bool dangChon = _danhMucDuocChon == item.tenDanhMuc;
                  return _taoTheDanhMuc(
                    item.tenDanhMuc,
                    item.icon,
                    item.mauSac,
                    dangChon,
                    isDark,
                  );
                } else {
                  return _taoTheThemMoi(isDark, quanLy, loai);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _taoNutTab(int index, String tieuDe, bool isDark) {
    final bool dangChon = _viTriTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _viTriTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: dangChon ? mauChinh : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            tieuDe,
            style: TextStyle(
              color: dangChon
                  ? Colors.white
                  : (isDark ? const Color(0xFF94A3B8) : Colors.black87),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _taoTheDanhMuc(String ten, IconData icon, Color mau, bool dangChon, bool isDark) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _danhMucDuocChon = ten;
        });
        if (widget.chonDanhMuc != null) {
          widget.chonDanhMuc!(ten);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: dangChon
              ? (isDark ? const Color(0xFF3B1D15) : const Color(0xFFFFF4E8))
              : (isDark ? const Color(0xFF1E293B).withValues(alpha: 0.88) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: dangChon
                ? mauChinh
                : (isDark ? const Color(0xFF334155) : const Color(0xFFF0F1EE)),
            width: dangChon ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: mau.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: mau,
                size: 26,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              ten,
              style: TextStyle(
                fontSize: 13,
                fontWeight: dangChon ? FontWeight.bold : FontWeight.w500,
                color: dangChon
                    ? mauChinh
                    : (isDark ? Colors.white : const Color(0xFF1E232A)),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _taoTheThemMoi(bool isDark, QuanLyTrangThaiApp quanLy, LoaiGiaoDich loai) {
    return GestureDetector(
      onTap: () => _hienThiHopThoaiThemDanhMuc(quanLy, loai),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.88) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE8EAE5),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF3B1D15) : const Color(0xFFFFF4E8),
                shape: BoxShape.circle,
                border: Border.all(color: mauChinh.withValues(alpha: 0.3)),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: mauChinh,
                size: 28,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Thêm mới',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: mauChinh,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _hienThiHopThoaiThemDanhMuc(QuanLyTrangThaiApp quanLy, LoaiGiaoDich loai) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final TextEditingController tenController = TextEditingController();
    IconData iconDuocChon = _danhSachIconMau.first;
    Color mauDuocChon = _danhSachMauMau.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 24,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Thêm danh mục mới',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close_rounded,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: tenController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Nhập tên danh mục...',
                      hintStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : Colors.grey),
                      labelText: 'Tên danh mục',
                      labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : Colors.grey),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F8F4),
                      prefixIcon: Icon(iconDuocChon, color: mauDuocChon),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Chọn biểu tượng',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _danhSachIconMau.length,
                      itemBuilder: (context, idx) {
                        final ic = _danhSachIconMau[idx];
                        final bool dangChon = iconDuocChon == ic;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              iconDuocChon = ic;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: 48,
                            decoration: BoxDecoration(
                              color: dangChon
                                  ? mauDuocChon.withValues(alpha: 0.2)
                                  : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F8F4)),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: dangChon ? mauDuocChon : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Icon(ic, color: dangChon ? mauDuocChon : Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Chọn màu sắc',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 44,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _danhSachMauMau.length,
                      itemBuilder: (context, idx) {
                        final col = _danhSachMauMau[idx];
                        final bool dangChon = mauDuocChon == col;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              mauDuocChon = col;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: col,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: dangChon ? Colors.white : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: dangChon
                                ? const Icon(Icons.check, color: Colors.white, size: 20)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        final tenText = tenController.text.trim();
                        if (tenText.isNotEmpty) {
                          final newCat = MoHinhDanhMuc(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            tenDanhMuc: tenText,
                            icon: iconDuocChon,
                            mauSac: mauDuocChon,
                            loai: loai,
                          );

                          await quanLy.themDanhMuc(newCat);

                          if (context.mounted) {
                            setState(() {
                              _danhMucDuocChon = tenText;
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Đã thêm danh mục "$tenText" vào CSDL!')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mauChinh,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Thêm danh mục',
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
