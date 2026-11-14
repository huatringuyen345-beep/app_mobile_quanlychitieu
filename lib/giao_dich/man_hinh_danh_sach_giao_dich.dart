import 'package:flutter/material.dart';
import '../dich_vu/quan_ly_trang_thai_app.dart';
import '../mo_hinh/mo_hinh_giao_dich.dart';

class ManHinhDanhSachGiaoDich extends StatefulWidget {
  final Function(MoHinhGiaoDich)? chonGiaoDich;

  const ManHinhDanhSachGiaoDich({
    super.key,
    this.chonGiaoDich,
  });

  @override
  State<ManHinhDanhSachGiaoDich> createState() => _ManHinhDanhSachGiaoDichState();
}

class _ManHinhDanhSachGiaoDichState extends State<ManHinhDanhSachGiaoDich> {
  int _viTriLoc = 0; // 0: Tất cả, 1: Thu nhập, 2: Chi tiêu
  String _tuKhoaTimKiem = '';

  static const Color mauChinh = Color(0xFFE07852);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final quanLy = QuanLyTrangThaiScope.of(context);

    List<MoHinhGiaoDich> danhSachLoc = quanLy.danhSachGiaoDich.where((item) {
      if (_viTriLoc == 1 && !item.laThuNhap) return false;
      if (_viTriLoc == 2 && item.laThuNhap) return false;
      if (_tuKhoaTimKiem.isNotEmpty &&
          !item.tieuDe.toLowerCase().contains(_tuKhoaTimKiem.toLowerCase()) &&
          !item.danhMuc.toLowerCase().contains(_tuKhoaTimKiem.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Lịch sử giao dịch',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E232A),
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Ô tìm kiếm
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _tuKhoaTimKiem = value;
                });
              },
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm giao dịch...',
                hintStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : Colors.grey),
                prefixIcon: Icon(Icons.search, color: isDark ? const Color(0xFF94A3B8) : Colors.grey),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.9) : Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: mauChinh, width: 1.5),
                ),
              ),
            ),
          ),

          // Bộ lọc Tab
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _taoNutLoc(0, 'Tất cả', isDark),
                const SizedBox(width: 8),
                _taoNutLoc(1, 'Thu nhập', isDark),
                const SizedBox(width: 8),
                _taoNutLoc(2, 'Chi tiêu', isDark),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Danh sách giao dịch
          Expanded(
            child: danhSachLoc.isEmpty
                ? Center(
                    child: Text(
                      'Không tìm thấy giao dịch nào',
                      style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: danhSachLoc.length,
                    itemBuilder: (context, index) {
                      final item = danhSachLoc[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.88) : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFF0F1EE),
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            if (widget.chonGiaoDich != null) {
                              widget.chonGiaoDich!(item);
                            }
                          },
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: item.mauNenIcon,
                                child: Icon(item.icon, color: Colors.black87),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.tieuDe,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item.danhMuc} • ${item.ngayGiaoDich.day}/${item.ngayGiaoDich.month}/${item.ngayGiaoDich.year}',
                                      style: TextStyle(
                                        color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${item.laThuNhap ? '+' : '-'}${item.soTien.toInt()} đ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: item.laThuNhap
                                      ? const Color(0xFF27AE60)
                                      : const Color(0xFFE07852),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _taoNutLoc(int index, String nhan, bool isDark) {
    final bool dangChon = _viTriLoc == index;
    return ChoiceChip(
      label: Text(nhan),
      selected: dangChon,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _viTriLoc = index;
          });
        }
      },
      selectedColor: mauChinh,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      labelStyle: TextStyle(
        color: dangChon
            ? Colors.white
            : (isDark ? const Color(0xFF94A3B8) : Colors.black87),
        fontWeight: dangChon ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: dangChon
              ? mauChinh
              : (isDark ? const Color(0xFF334155) : Colors.grey.shade300),
        ),
      ),
    );
  }
}
