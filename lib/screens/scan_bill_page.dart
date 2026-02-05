import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:intl/intl.dart';
import 'package:quan_ly_chi_tieu/services/transaction_service.dart';
import 'package:quan_ly_chi_tieu/widgets/app_toast.dart';

import '../services/category_service.dart';

class ScanBillPage extends StatefulWidget {
  const ScanBillPage({super.key});

  @override
  State<ScanBillPage> createState() => _ScanBillPageState();
}

class _ScanBillPageState extends State<ScanBillPage> {
  final categoryService = CategoryService();
  final transactionService = TransactionService();


  File? _image;
  bool _loadingOCR = false;
  bool _loadingCategory = true;

  // controllers
  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final dateCtrl = TextEditingController();

  // category
  List<Map<String, dynamic>> userCategories = [];
  String? selectedCategoryId;

  // ================= INIT =================

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final data = await categoryService.getUserCategories();

      setState(() {
        userCategories = data
            .where((c) => c['category_store']['type'] == 'expense')
            .toList();
        _loadingCategory = false;
      });
    } catch (e) {
      _toast(e.toString());
      Navigator.pop(context);
    }
  }

  // ================= PICK IMAGE =================

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (file == null) return;

    setState(() {
      _image = File(file.path);
    });

    await _scanText();
  }

  // ================= OCR =================

  Future<void> _scanText() async {
    if (_image == null) return;

    setState(() => _loadingOCR = true);

    final inputImage = InputImage.fromFile(_image!);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final result = await recognizer.processImage(inputImage);
    recognizer.close();

    _parseText(result.text);

    setState(() => _loadingOCR = false);
  }

  // ================= PARSE =================

  void _parseText(String text) {
    titleCtrl.text = _extractTitle(text) ?? 'Chi tiêu';
    amountCtrl.text = _extractAmount(text)?.toString() ?? '';
    dateCtrl.text =
        DateFormat('dd/MM/yyyy').format(_extractDate(text) ?? DateTime.now());

    final detectedName = _detectCategoryName(text);
    _mapDetectedCategory(detectedName);
  }

  int? _extractAmount(String text) {
    final regex = RegExp(r'(\d{1,3}([.,]\d{3})+)');
    final match = regex.firstMatch(text);
    if (match == null) return null;

    return int.parse(
      match.group(0)!.replaceAll('.', '').replaceAll(',', ''),
    );
  }

  DateTime? _extractDate(String text) {
    final regex = RegExp(r'(\d{2}/\d{2}/\d{4})');
    final match = regex.firstMatch(text);
    if (match == null) return null;

    return DateFormat('dd/MM/yyyy').parse(match.group(0)!);
  }

  String? _extractTitle(String text) {
    final lines = text.split('\n');
    return lines.isNotEmpty ? lines.first : null;
  }

  // ================= CATEGORY LOGIC =================

  String _detectCategoryName(String text) {
    final t = text.toLowerCase();

    if (t.contains('an uong') || t.contains('com') || t.contains('cafe')) {
      return 'Ăn uống';
    }
    if (t.contains('xang') || t.contains('grab')) {
      return 'Đi lại';
    }
    if (t.contains('shopee') || t.contains('lazada')) {
      return 'Mua sắm';
    }
    return 'Khác';
  }

  void _mapDetectedCategory(String detectedName) {
    final match = userCategories.firstWhere(
      (c) =>
          c['category_store']['name']
              .toString()
              .toLowerCase() ==
          detectedName.toLowerCase(),
      orElse: () => {},
    );

    if (match.isNotEmpty) {
      selectedCategoryId = match['id'];
    } else {
      selectedCategoryId = null; // bắt user chọn
    }
  }

  // ================= SAVE =================
Future<void> _save() async {
  if (selectedCategoryId == null) {
    _toast("Vui lòng chọn loại chi tiêu");
    return;
  }

  final amount = int.tryParse(amountCtrl.text.trim());
  if (amount == null || amount <= 0) {
    _toast("Số tiền không hợp lệ");
    return;
  }

  DateTime date;
  try {
    date = DateFormat('dd/MM/yyyy').parse(dateCtrl.text.trim());
  } catch (_) {
    _toast("Ngày không hợp lệ");
    return;
  }

  try {
    await transactionService.addTransaction(
      categoryId: selectedCategoryId!,
      title: titleCtrl.text.trim().isEmpty
          ? 'Chi tiêu'
          : titleCtrl.text.trim(),
      amount: amount,
      type: 'expense',
      date: date,
    );

    AppToast.show(context, message: "Đã lưu giao dịch", type: ToastType.success);
    await Future.delayed(const Duration(milliseconds: 300));
    Navigator.pop(context, true);
  } catch (e) {
    _toast(e.toString());
  }
}


  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121826),
      appBar: AppBar(
        title: const Text("Quét Bill"),
        backgroundColor: const Color(0xFF121826),
      ),
      body: _loadingCategory
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _image == null ? _pickBox() : _preview(),

                  const SizedBox(height: 16),

                  if (_loadingOCR) const CircularProgressIndicator(),

                  if (!_loadingOCR && _image != null) _form(),
                ],
              ),
            ),
    );
  }

  Widget _pickBox() {
    return Column(
      children: [
        const Icon(Icons.document_scanner,
            size: 80, color: Colors.white38),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => _pickImage(ImageSource.camera),
          icon: const Icon(Icons.camera_alt),
          label: const Text("Chụp bill"),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _pickImage(ImageSource.gallery),
          icon: const Icon(Icons.image),
          label: const Text("Chọn ảnh"),
        ),
      ],
    );
  }

  Widget _preview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(_image!),
    );
  }

  Widget _form() {
    return Column(
      children: [
        _input(titleCtrl, "Tên giao dịch"),
        _input(amountCtrl, "Số tiền",
            keyboard: TextInputType.number),
        _input(dateCtrl, "Ngày"),

        const SizedBox(height: 8),

        _categoryDropdown(),

        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: _save,
          child: const Text("LƯU GIAO DỊCH"),
        ),
      ],
    );
  }

  // ================= BEAUTIFUL DROPDOWN =================

  Widget _categoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2538),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selectedCategoryId == null
              ? Colors.redAccent.withOpacity(0.6)
              : Colors.transparent,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCategoryId,
          isExpanded: true,
          dropdownColor: const Color(0xFF1E2538),
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Colors.white70),
          hint: const Text(
            "Chọn loại chi tiêu *",
            style: TextStyle(color: Colors.white38),
          ),
          items: userCategories.map((c) {
            final store = c['category_store'];
            return DropdownMenuItem<String>(
              value: c['id'],
              child: Row(
                children: [
                  _categoryIcon(store['icon']),
                  const SizedBox(width: 10),
                  Text(
                    store['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (v) {
            setState(() => selectedCategoryId = v);
          },
        ),
      ),
    );
  }

  Widget _categoryIcon(dynamic iconPath) {
  if (iconPath == null || iconPath.toString().isEmpty) {
    return const Icon(
      Icons.category,
      color: Colors.white54,
      size: 20,
    );
  }

  // icon là asset local: assets/logos/xxx.png
  if (iconPath is String && iconPath.startsWith('assets/')) {
    return Image.asset(
      iconPath,
      width: 22,
      height: 22,
      fit: BoxFit.contain,
    );
  }

  // fallback
  return const Icon(
    Icons.category,
    color: Colors.white54,
    size: 20,
  );
}


  // ================= INPUT =================

  Widget _input(
    TextEditingController ctrl,
    String label, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboard,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF1E2538),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  void _toast(String text) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text)));
  }
}
