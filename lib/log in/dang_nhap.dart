import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' hide Image, LinearGradient;
import '../dich_vu/dich_vu_firebase.dart';
import '../dich_vu/dich_vu_csdl.dart';
import '../dich_vu/quan_ly_trang_thai_app.dart';

class ManHinhDangNhap extends StatefulWidget {
  final VoidCallback? chuyenToiDangKy;
  final VoidCallback? khiDangNhapThanhCong;

  const ManHinhDangNhap({
    super.key,
    this.chuyenToiDangKy,
    this.khiDangNhapThanhCong,
  });

  @override
  State<ManHinhDangNhap> createState() => _ManHinhDangNhapState();
}

class _ManHinhDangNhapState extends State<ManHinhDangNhap> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _matKhauController = TextEditingController();
  bool _hienMatKhau = false;
  bool _ghiNhoDangNhap = true;

  static const Color mauChinh = Color(0xFFE07852);

  @override
  void dispose() {
    _emailController.dispose();
    _matKhauController.dispose();
    super.dispose();
  }

  Future<void> _xuLyDangNhap() async {
    if (_formKey.currentState!.validate()) {
      await DichVuFirebase.dangNhap(_emailController.text.trim(), _matKhauController.text);
      if (!mounted) return;
      await QuanLyTrangThaiScope.of(context)
          .chuyenNguoiDung(_emailController.text.trim());

      if (_ghiNhoDangNhap) {
        await DichVuCSDL.luuThongTinNguoiDung(
          email: _emailController.text.trim(),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng nhập thành công!'),
            backgroundColor: mauChinh,
          ),
        );

        if (widget.khiDangNhapThanhCong != null) {
          widget.khiDangNhapThanhCong!();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Lớp 1: Hoạt ảnh Rive shapes.riv làm Nền Full Màn Hình
          const Positioned.fill(
            child: RiveAnimation.asset(
              'lib/hoat-anh/shapes.riv',
              fit: BoxFit.cover,
            ),
          ),

          // Lớp 2: Hiệu ứng kính mờ (BackdropFilter) phủ full màn hình
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                color: Colors.black.withValues(alpha: 0.2),
              ),
            ),
          ),

          // Lớp 3: Toàn bộ nội dung Form nằm trong Thẻ Khung Trong Suốt (Glassmorphism Card)
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22), // Khung trong suốt
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.45), // Viền kính trong suốt
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Logo & Tiêu đề
                            Center(
                              child: Column(
                                children: [
                                  Container(
                                    width: 84,
                                    height: 84,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(22),
                                      boxShadow: [
                                        BoxShadow(
                                          color: mauChinh.withValues(alpha: 0.25),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(22),
                                      child: Image.asset(
                                        'lib/images/67392de9-e046-4e1f-82b6-fc46608aa81e.jpg',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.account_balance_wallet_rounded,
                                            size: 46,
                                            color: mauChinh,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Chào mừng trở lại!',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Đăng nhập để tiếp tục quản lý tài chính',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Ô nhập Email
                            _taoLabel('Email hoặc Số điện thoại'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: Color(0xFF1E232A)),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Vui lòng nhập email hoặc số điện thoại';
                                }
                                return null;
                              },
                              decoration: _taoInputDecoration(
                                hint: 'nhapemail@example.com',
                                icon: Icons.email_outlined,
                              ),
                            ),

                            const SizedBox(height: 18),

                            // Ô nhập Mật khẩu
                            _taoLabel('Mật khẩu'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _matKhauController,
                              obscureText: !_hienMatKhau,
                              style: const TextStyle(color: Color(0xFF1E232A)),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Vui lòng nhập mật khẩu';
                                }
                                return null;
                              },
                              decoration: _taoInputDecoration(
                                hint: 'Nhập mật khẩu',
                                icon: Icons.lock_outline_rounded,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _hienMatKhau ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: Colors.grey.shade600,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _hienMatKhau = !_hienMatKhau;
                                    });
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Ghi nhớ & Quên mật khẩu
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: Checkbox(
                                        value: _ghiNhoDangNhap,
                                        activeColor: mauChinh,
                                        side: const BorderSide(color: Colors.white70, width: 1.5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        onChanged: (val) {
                                          setState(() {
                                            _ghiNhoDangNhap = val ?? false;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Ghi nhớ đăng nhập',
                                      style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Chức năng quên mật khẩu đang phát triển')),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Quên mật khẩu?',
                                    style: TextStyle(color: Color(0xFFFFAB91), fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Nút Đăng nhập
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _xuLyDangNhap,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: mauChinh,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 3,
                                ),
                                child: const Text(
                                  'Đăng nhập',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Chuyển sang Đăng ký
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Chưa có tài khoản? ',
                                  style: TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (widget.chuyenToiDangKy != null) {
                                      widget.chuyenToiDangKy!();
                                    }
                                  },
                                  child: const Text(
                                    'Đăng ký ngay',
                                    style: TextStyle(
                                      color: Color(0xFFFFAB91),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _taoLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  InputDecoration _taoInputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      prefixIcon: Icon(icon, color: mauChinh, size: 22),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.92),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: mauChinh, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }
}
