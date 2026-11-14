import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' hide Image, LinearGradient;
import '../dich_vu/dich_vu_luu_tru.dart';
import '../dich_vu/dich_vu_mang.dart';

class ManHinhDangKy extends StatefulWidget {
  final VoidCallback? chuyenToiDangNhap;
  final VoidCallback? khiDangKyThanhCong;

  const ManHinhDangKy({
    super.key,
    this.chuyenToiDangNhap,
    this.khiDangKyThanhCong,
  });

  @override
  State<ManHinhDangKy> createState() => _ManHinhDangKyState();
}

class _ManHinhDangKyState extends State<ManHinhDangKy> {
  final _formKey = GlobalKey<FormState>();
  final _hoTenController = TextEditingController();
  final _emailController = TextEditingController();
  final _matKhauController = TextEditingController();
  final _xacNhanMatKhauController = TextEditingController();

  bool _hienMatKhau = false;
  bool _hienXacNhanMatKhau = false;
  bool _dongYDieuKhoan = true;

  static const Color mauChinh = Color(0xFFE07852);

  @override
  void dispose() {
    _hoTenController.dispose();
    _emailController.dispose();
    _matKhauController.dispose();
    _xacNhanMatKhauController.dispose();
    super.dispose();
  }

  Future<void> _xuLyDangKy() async {
    if (_formKey.currentState!.validate()) {
      if (!_dongYDieuKhoan) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng đồng ý với Điều khoản & Chính sách bảo mật!'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      final coMang = await DichVuMang.kiemTraCoMang();
      if (!coMang) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.wifi_off_rounded, color: Colors.white),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Bắt buộc có kết nối mạng Internet để Đăng ký tài khoản!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.redAccent,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      await DichVuLuuTru.luuDangNhap(
        email: _emailController.text.trim(),
        hoTen: _hoTenController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng ký tài khoản thành công!'),
            backgroundColor: mauChinh,
          ),
        );

        if (widget.khiDangKyThanhCong != null) {
          widget.khiDangKyThanhCong!();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () {
            if (widget.chuyenToiDangNhap != null) {
              widget.chuyenToiDangNhap!();
            } else {
              Navigator.maybePop(context);
            }
          },
        ),
      ),
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

          // Lớp 3: Toàn bộ nội dung Form Đăng ký trong Thẻ Khung Trong Suốt (Glassmorphism Card)
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
                                    'Tạo tài khoản',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Đăng ký để quản lý tài chính thông minh',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Ô nhập Họ và tên
                            _taoONhap(
                              controller: _hoTenController,
                              nhan: 'Họ và tên',
                              goiY: 'Nhập họ và tên của bạn',
                              icon: Icons.person_outline_rounded,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Vui lòng nhập họ và tên';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Ô nhập Email
                            _taoONhap(
                              controller: _emailController,
                              nhan: 'Email / Số điện thoại',
                              goiY: 'example@email.com',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Vui lòng nhập email hoặc số điện thoại';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Ô nhập Mật khẩu
                            _taoONhap(
                              controller: _matKhauController,
                              nhan: 'Mật khẩu',
                              goiY: 'Nhập mật khẩu (ít nhất 6 ký tự)',
                              icon: Icons.lock_outline_rounded,
                              isPassword: true,
                              obscureText: !_hienMatKhau,
                              onTogglePassword: () {
                                setState(() {
                                  _hienMatKhau = !_hienMatKhau;
                                });
                              },
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Vui lòng nhập mật khẩu';
                                }
                                if (val.length < 6) {
                                  return 'Mật khẩu phải có ít nhất 6 ký tự';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Ô nhập Xác nhận mật khẩu
                            _taoONhap(
                              controller: _xacNhanMatKhauController,
                              nhan: 'Xác nhận mật khẩu',
                              goiY: 'Nhập lại mật khẩu trên',
                              icon: Icons.lock_reset_rounded,
                              isPassword: true,
                              obscureText: !_hienXacNhanMatKhau,
                              onTogglePassword: () {
                                setState(() {
                                  _hienXacNhanMatKhau = !_hienXacNhanMatKhau;
                                });
                              },
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Vui lòng xác nhận mật khẩu';
                                }
                                if (val != _matKhauController.text) {
                                  return 'Mật khẩu xác nhận không trùng khớp';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 14),

                            // Checkbox Đồng ý điều khoản
                            Row(
                              children: [
                                SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: Checkbox(
                                    value: _dongYDieuKhoan,
                                    activeColor: mauChinh,
                                    side: const BorderSide(color: Colors.white70, width: 1.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    onChanged: (val) {
                                      setState(() {
                                        _dongYDieuKhoan = val ?? false;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Tôi đồng ý với Điều khoản & Chính sách',
                                    style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Nút Đăng ký
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _xuLyDangKy,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: mauChinh,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 3,
                                ),
                                child: const Text(
                                  'Đăng ký ngay',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Chuyển sang màn hình Đăng nhập
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Đã có tài khoản? ',
                                  style: TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (widget.chuyenToiDangNhap != null) {
                                      widget.chuyenToiDangNhap!();
                                    } else {
                                      Navigator.maybePop(context);
                                    }
                                  },
                                  child: const Text(
                                    'Đăng nhập ngay',
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

  Widget _taoONhap({
    required TextEditingController controller,
    required String nhan,
    required String goiY,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nhan,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: Color(0xFF1E232A)),
          decoration: InputDecoration(
            hintText: goiY,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
            prefixIcon: Icon(icon, color: mauChinh, size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                    onPressed: onTogglePassword,
                  )
                : null,
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.92),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          ),
        ),
      ],
    );
  }
}
