import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_chi_tieu/core/theme/app_button.dart';
import 'package:quan_ly_chi_tieu/providers/transaction_provider.dart';
import 'package:quan_ly_chi_tieu/services/transaction_service.dart';
import 'package:quan_ly_chi_tieu/widgets/app_toast.dart';

import '../services/category_service.dart';

class ScanBillItem {
  File image;

  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final dateCtrl = TextEditingController();

  String? selectedCategoryId;

  ScanBillItem({required this.image});
}

String _removeVietnameseDiacritics(String str) {
  const withDiacritics =
      'àáạảãâầấậẩẫăằắặẳẵ'
      'èéẹẻẽêềếệểễ'
      'ìíịỉĩ'
      'òóọỏõôồốộổỗơờớợởỡ'
      'ùúụủũưừứựửữ'
      'ỳýỵỷỹ'
      'đ';

  const withoutDiacritics =
      'aaaaaaaaaaaaaaaaa'
      'eeeeeeeeeee'
      'iiiii'
      'ooooooooooooooooo'
      'uuuuuuuuuuu'
      'yyyyy'
      'd';

  for (int i = 0; i < withDiacritics.length; i++) {
    str = str.replaceAll(withDiacritics[i], withoutDiacritics[i]);
    str = str.replaceAll(
      withDiacritics[i].toUpperCase(),
      withoutDiacritics[i].toUpperCase(),
    );
  }
  return str;
}

String? _extractTimeLine(String text) {
  final lines = text.split('\n');

  final timeRegex = RegExp(r'\b\d{1,2}:\d{2}\b');
  final dateRegex = RegExp(r'\b\d{1,2}/\d{1,2}/\d{4}\b');

  String? time;
  String? date;

  // Duyệt NGƯỢC từ cuối (quan trọng)
  for (int i = lines.length - 1; i >= 0; i--) {
    String line = lines[i].trim();
    if (line.isEmpty) continue;

    // 🔧 FIX NĂM BỊ TÁCH: "09/02/2 026" → "09/02/2026"
    line = line.replaceAllMapped(
      RegExp(r'(\d{1,2}/\d{1,2}/)(\d)\s+(\d{3})'),
      (m) => '${m[1]}${m[2]}${m[3]}',
    );

    if (time == null && timeRegex.hasMatch(line)) {
      time = timeRegex.firstMatch(line)!.group(0);
    }

    if (date == null && dateRegex.hasMatch(line)) {
      date = dateRegex.firstMatch(line)!.group(0);
    }

    if (time != null && date != null) {
      return '$time $date';
    }
  }

  return null;
}

class ScanBillPage extends StatefulWidget {
  const ScanBillPage({super.key});

  @override
  State<ScanBillPage> createState() => _ScanBillPageState();
}

class _ScanBillPageState extends State<ScanBillPage> {
  final categoryService = CategoryService();
  final transactionService = TransactionService();

  File? _image;
  final List<ScanBillItem> _bills = [];
  int _currentIndex = 0;
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

    if (source == ImageSource.gallery) {
      final files = await picker.pickMultiImage(imageQuality: 85);
      if (files.isEmpty) return;

      for (var f in files) {
        final bill = ScanBillItem(image: File(f.path));
        _bills.add(bill);
        await _scanTextForBill(bill);
      }
    } else {
      final file = await picker.pickImage(source: source, imageQuality: 85);
      if (file == null) return;

      final bill = ScanBillItem(image: File(file.path));
      _bills.add(bill);
      await _scanTextForBill(bill);
    }

    setState(() {});
  }

  Future<void> _scanTextForBill(ScanBillItem bill) async {
    setState(() => _loadingOCR = true);

    final inputImage = InputImage.fromFile(bill.image);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);

    final result = await recognizer.processImage(inputImage);
    recognizer.close();

    _parseTextForBill(result.text, bill);

    setState(() => _loadingOCR = false);
  }

  void _parseTextForBill(String text, ScanBillItem bill) {
    bill.titleCtrl.text = _extractTimeLine(text) ?? 'Chi tiêu';

    bill.amountCtrl.text = _extractAmount(text)?.toString() ?? '';

    bill.dateCtrl.text = DateFormat(
      'dd/MM/yyyy',
    ).format(_extractDate(text) ?? DateTime.now());

    final detectedName = _detectCategoryName(text);
    _mapDetectedCategoryForBill(detectedName, bill);
  }

  void _mapDetectedCategoryForBill(String detectedName, ScanBillItem bill) {
    final match = userCategories.firstWhere(
      (c) =>
          c['category_store']['name'].toString().toLowerCase() ==
          detectedName.toLowerCase(),
      orElse: () => {},
    );

    if (match.isNotEmpty) {
      bill.selectedCategoryId = match['id'];
    } else {
      bill.selectedCategoryId = null;
    }
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
    titleCtrl.text = _extractTimeLine(text) ?? 'Chi tiêu';
    amountCtrl.text = _extractAmount(text)?.toString() ?? '';
    dateCtrl.text = DateFormat(
      'dd/MM/yyyy',
    ).format(_extractDate(text) ?? DateTime.now());

    final detectedName = _detectCategoryName(text);
    _mapDetectedCategory(detectedName);
  }

  int? _extractAmount(String text) {
    final regex = RegExp(r'(\d{1,3}([.,]\d{3})+)');
    final match = regex.firstMatch(text);
    if (match == null) return null;

    return int.parse(match.group(0)!.replaceAll('.', '').replaceAll(',', ''));
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
    final t = _removeVietnameseDiacritics(text.toLowerCase());

    // 🍜 Ăn uống
    if (t.contains('an uong') ||
        t.contains('an') ||
        t.contains('uong') ||
        t.contains('com') ||
        t.contains('bun') ||
        t.contains('pho') ||
        t.contains('chao') ||
        t.contains('lau') ||
        t.contains('do an') ||
        t.contains('nuoc') ||
        t.contains('cafe') ||
        t.contains('coffee') ||
        t.contains('cf') ||
        t.contains('ca phe') ||
        t.contains('tra sua') ||
        t.contains('quan an') ||
        t.contains('nha hang')) {
      return 'Ăn uống';
    }

    // 🚗 Đi lại
    if (t.contains('xang') ||
        t.contains('do xang') ||
        t.contains('grab') ||
        t.contains('be') ||
        t.contains('gojek') ||
        t.contains('xe') ||
        t.contains('taxi') ||
        t.contains('gui xe') ||
        t.contains('ve xe')) {
      return 'Đi lại';
    }

    // 🛍️ Mua sắm
    if (t.contains('shopee') ||
        t.contains('lazada') ||
        t.contains('tiki') ||
        t.contains('sendo') ||
        t.contains('shopping') ||
        t.contains('mua sam') ||
        t.contains('quan ao') ||
        t.contains('giay') ||
        t.contains('my pham')) {
      return 'Mua sắm';
    }

    return 'Khác';
  }

  void _mapDetectedCategory(String detectedName) {
    final match = userCategories.firstWhere(
      (c) =>
          c['category_store']['name'].toString().toLowerCase() ==
          detectedName.toLowerCase(),
      orElse: () => {},
    );

    if (match.isNotEmpty) {
      selectedCategoryId = match['id'];
    } else {
      selectedCategoryId = null; // bắt user chọn
    }
  }

  Future<void> _save() async {
    if (_bills.isEmpty) return;

    for (int i = 0; i < _bills.length; i++) {
      final bill = _bills[i];

      if (bill.selectedCategoryId == null) {
        _toast("Bill ${i + 1}: Vui lòng chọn loại chi tiêu");
        return;
      }

      final amount = int.tryParse(bill.amountCtrl.text.trim());
      if (amount == null || amount <= 0) {
        _toast("Bill ${i + 1}: Số tiền không hợp lệ");
        return;
      }

      DateTime date;
      try {
        date = DateFormat('dd/MM/yyyy').parse(bill.dateCtrl.text.trim());
      } catch (_) {
        _toast("Bill ${i + 1}: Ngày không hợp lệ");
        return;
      }

      try {
        await context.read<TransactionProvider>().addTransaction(
          categoryId: bill.selectedCategoryId!,
          title: bill.titleCtrl.text.trim().isEmpty
              ? 'Chi tiêu'
              : bill.titleCtrl.text.trim(),
          amount: amount,
          type: 'expense',
          note: "",
          date: date,
        );
      } catch (e) {
        _toast("Bill ${i + 1}: ${e.toString()}");
        return;
      }
    }

    AppToast.show(
      context,
      message: "Đã lưu ${_bills.length} giao dịch",
      type: ToastType.success,
    );

    await Future.delayed(const Duration(milliseconds: 300));

    Navigator.pop(context, true);
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                children: [
                  _bills.isEmpty ? _pickBox() : _preview(),

                  const SizedBox(height: 16),

                  if (_loadingOCR) const CircularProgressIndicator(),

                  if (!_loadingOCR && _bills.isNotEmpty) _form(),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _pickBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2035),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFF232A44),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.document_scanner_rounded,
              size: 48,
              color: Colors.blueAccent,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            "Quét hóa đơn",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            "Chụp hoặc chọn ảnh hóa đơn để tự động nhận diện",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text("Chụp hóa đơn"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.image_rounded),
              label: const Text("Chọn từ thư viện"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rescanItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF232A44),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.blueAccent),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showRescanOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2035),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),

              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              const SizedBox(height: 16),

              _rescanItem(
                icon: Icons.camera_alt_rounded,
                title: "Chụp lại bằng camera",
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),

              _rescanItem(
                icon: Icons.image_rounded,
                title: "Chọn ảnh từ thư viện",
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _preview() {
    final bill = _bills[_currentIndex];

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              barrierColor: Colors.black.withOpacity(0.85),
              builder: (_) => GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Center(
                  child: InteractiveViewer(child: Image.file(bill.image)),
                ),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: PageView.builder(
                itemCount: _bills.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (_, index) {
                  return Image.file(_bills[index].image, fit: BoxFit.cover);
                },
              ),
            ),
          ),
        ),

        /// 🔥 HIỂN THỊ SỐ BILL
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${_currentIndex + 1} / ${_bills.length}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),

        Positioned(
          top: 10,
          right: 10,
          child: InkWell(
            onTap: _loadingOCR ? null : _showRescanOptions,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: const [
                  Icon(Icons.refresh_rounded, size: 18, color: Colors.white),
                  SizedBox(width: 6),
                  Text("Quét lại", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _form() {
    final bill = _bills[_currentIndex];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2035),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle("Thông tin giao dịch"),

          const SizedBox(height: 12),

          _input(bill.titleCtrl, "Tên giao dịch"),
          _input(bill.amountCtrl, "Số tiền", keyboard: TextInputType.number),
          _input(bill.dateCtrl, "Ngày"),

          const SizedBox(height: 12),

          _sectionTitle("Danh mục"),

          const SizedBox(height: 8),

          _categoryDropdown(),

          const SizedBox(height: 24),

          AppButton(onPressed: _save, text: "LƯU GIAO DỊCH"),
        ],
      ),
    );
  }

  // ================= BEAUTIFUL DROPDOWN =================

  Widget _categoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF232A44),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selectedCategoryId == null
              ? Colors.redAccent.withOpacity(0.6)
              : Colors.transparent,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _bills[_currentIndex].selectedCategoryId,
          isExpanded: true,
          dropdownColor: const Color(0xFF232A44),
          icon: const Icon(Icons.expand_more, color: Colors.white54),
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
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (v) =>
              setState(() => _bills[_currentIndex].selectedCategoryId = v),
        ),
      ),
    );
  }

  Widget _categoryIcon(dynamic iconPath) {
    if (iconPath == null || iconPath.toString().isEmpty) {
      return const Icon(Icons.category, color: Colors.white54, size: 20);
    }

    // icon là asset local: assets/logos/xxx.png
    if (iconPath is String && iconPath.startsWith('assets/')) {
      return Image.asset(iconPath, width: 22, height: 22, fit: BoxFit.contain);
    }

    // fallback
    return const Icon(Icons.category, color: Colors.white54, size: 20);
  }

  // ================= INPUT =================

  Widget _input(
    TextEditingController ctrl,
    String label, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: StatefulBuilder(
        builder: (context, setInnerState) {
          ctrl.addListener(() {
            setInnerState(() {});
          });

          return TextField(
            controller: ctrl,
            keyboardType: keyboard,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
              floatingLabelStyle: const TextStyle(color: Colors.blueAccent),
              filled: true,
              fillColor: const Color(0xFF232A44),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),

              /// 🔥 NÚT XOÁ NHANH
              suffixIcon: ctrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.white54,
                      ),
                      onPressed: () {
                        ctrl.clear();
                        setInnerState(() {});
                      },
                    )
                  : null,

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          );
        },
      ),
    );
  }

  void _toast(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}