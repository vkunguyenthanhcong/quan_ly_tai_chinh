import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quan_ly_chi_tieu/models/user_model.dart';
import 'package:quan_ly_chi_tieu/widgets/app_toast.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final userService = UserService();

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  UserModel? user;
  bool isSaving = false;

  final ImagePicker _picker = ImagePicker();
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // ================= LOAD USER =================
  Future<void> _loadUser() async {
    try {
      final map = await userService.getCurrentUser();
      final u = UserModel.fromMap(map);

      setState(() {
        user = u;
        nameCtrl.text = u.fullName;
        emailCtrl.text = u.email;
      });
    } catch (e) {
      _toast(e.toString());
    }
  }

  // ================= SAVE =================
  Future<void> _save() async {
  if (nameCtrl.text.trim().isEmpty) {
    _toast("Tên không được để trống");
    return;
  }

  setState(() => isSaving = true);

  try {
    String? avatarUrl = user?.avatarUrl;

    // 🔥 nếu có ảnh mới → upload
    if (_pickedImage != null) {
      avatarUrl = await userService.uploadAvatar(_pickedImage!);
    }

    await userService.updateProfile(
      fullName: nameCtrl.text.trim(),
      avatarUrl: avatarUrl,
    );

    AppToast.show(context, message: "Cập nhật thành công", type : ToastType.success);

    // reload user
    await _loadUser();
    _pickedImage = null;
  } catch (e) {
    _toast(e.toString());
  } finally {
    setState(() => isSaving = false);
  }
}


  // ================= PERMISSION =================
  Future<bool> _requestGalleryPermission() async {
  if (Platform.isIOS) {
    final status = await Permission.photos.request();
    return status.isGranted;
  } else {
    // ✅ Android
    final androidInfo = await DeviceInfoPlugin().androidInfo;

    if (androidInfo.version.sdkInt >= 33) {
      // Android 13+
      final status = await Permission.photos.request();
      return status.isGranted;
    } else {
      // Android 12 trở xuống
      final status = await Permission.storage.request();
      return status.isGranted;
    }
  }
}


  // ================= PICK IMAGE =================
  Future<void> _pickImage(ImageSource source) async {
    bool granted = false;

    if (source == ImageSource.camera) {
      granted = await _requestGalleryPermission();
    } else {
      granted = await _requestGalleryPermission();
    }

    if (!granted) {
      _showPermissionDialog();
      return;
    }

    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
      });
    }
  }

  // ================= BOTTOM SHEET =================
  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2236),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading:
                    const Icon(Icons.photo_library, color: Colors.white),
                title: const Text(
                  "Chọn ảnh từ thư viện",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.camera_alt, color: Colors.white),
                title: const Text(
                  "Chụp ảnh",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= DIALOG KHI TỪ CHỐI =================
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cần cấp quyền"),
        content: const Text(
          "Ứng dụng cần quyền truy cập camera hoặc thư viện ảnh để chọn ảnh đại diện.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Huỷ"),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text("Mở cài đặt"),
          ),
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1624),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1624),
        title: const Text("Tài khoản của tôi"),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: isSaving ? null : _save,
            child: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text("Lưu"),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              child: Column(
                children: [
                  _avatar(user!),
                  const SizedBox(height: 24),
                  _input("Tên", nameCtrl),
                  _input("Email", emailCtrl, enabled: false),
                ],
              ),
            ),
    );
  }

  // ================= AVATAR =================
  Widget _avatar(UserModel user) {
    final initial = user.fullName.isNotEmpty
        ? user.fullName.trim()[0].toUpperCase()
        : "?";

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 55,
          backgroundColor: Colors.blueAccent,
          child: ClipOval(
            child: _pickedImage != null
                ? Image.file(
                    _pickedImage!,
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                  )
                : user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                    ? Image.network(
                        user.avatarUrl!,
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _initialAvatar(initial),
                      )
                    : _initialAvatar(initial),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.camera_alt,
                color: Colors.white, size: 18),
            onPressed: _showImagePicker,
          ),
        ),
      ],
    );
  }

  Widget _initialAvatar(String text) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ================= INPUT =================
  Widget _input(
    String label,
    TextEditingController ctrl, {
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            enabled: enabled,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF1A2236),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}
