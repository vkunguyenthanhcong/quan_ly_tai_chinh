import 'package:flutter/material.dart';
import '../services/category_service.dart';
import '../services/transaction_service.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  final categoryService = CategoryService();
  final transactionService = TransactionService();

  List<Map<String, dynamic>> categories = [];
  String? categoryId;

  String transactionType = 'expense'; // expense | income
  DateTime selectedDate = DateTime.now();
  bool isSaving = false;
  bool loadingCategory = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
  try {
    final data = await categoryService.getUserCategories(transactionType);
    if (!mounted) return;

    // 🔴 KIỂM TRA category_store null
    final hasInvalid = data.any((e) =>
        e['category_store'] == null ||
        e['category_store'] is! Map<String, dynamic>);

    if (hasInvalid) {
      if (!mounted) return;

      // Thoát màn hiện tại
      Navigator.pop(context);

      // Đợi frame sau để show snackbar
      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "⚠️ Bạn cần thêm nhóm chi tiêu mới trước khi tạo giao dịch",
            ),
            backgroundColor: Colors.orange,
          ),
        );
      });

      return;
    }

    setState(() {
      categories = data;
      categoryId = data.isNotEmpty ? data.first['id'] : null;
      loadingCategory = false;
    });
  } catch (e) {
    if (!mounted) return;
    Navigator.pop(context);
    Future.delayed(Duration.zero, () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121826),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121826),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Giao dịch mới",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _typeDropdown(),

              if (loadingCategory)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: CircularProgressIndicator(),
                )
              else
                _categoryDropdown(),

              _inputField(titleCtrl, "Tên giao dịch *"),
              _inputField(
                amountCtrl,
                "Số tiền giao dịch *",
                keyboardType: TextInputType.number,
              ),

              _datePicker(),
              _noteField(),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isSaving
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text("HỦY"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isSaving ? null : _saveTransaction,
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text("LƯU"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= LOGIC =================

  Future<void> _saveTransaction() async {
    if (categoryId == null ||
        titleCtrl.text.trim().isEmpty ||
        amountCtrl.text.trim().isEmpty) {
      _showSnack("Vui lòng nhập đầy đủ thông tin", Colors.orange);
      return;
    }

    final amount = int.tryParse(amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      _showSnack("Số tiền không hợp lệ", Colors.orange);
      return;
    }

    setState(() => isSaving = true);

    try {
      await transactionService.addTransaction(
        categoryId: categoryId!,
        title: titleCtrl.text.trim(),
        amount: amount,
        type: transactionType,
        note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
        date: selectedDate,
      );

      if (!mounted) return;

      _showSnack("✅ Đã thêm giao dịch", Colors.green);
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.pop(context, true);
    } catch (e) {
      _showSnack(e.toString(), Colors.red);
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  // ================= UI COMPONENTS =================

  Widget _typeDropdown() {
    return _box(
      DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: transactionType,
          isExpanded: true,
          dropdownColor: const Color(0xFF1E2538),
          items: const [
            DropdownMenuItem(
              value: 'expense',
              child: Text("Chi tiêu", style: TextStyle(color: Colors.white)),
            ),
            DropdownMenuItem(
              value: 'income',
              child: Text("Thu nhập", style: TextStyle(color: Colors.white)),
            ),
          ],
          onChanged: (v) {
            if (v == null) return;
            setState(() {
              transactionType = v;
              loadingCategory = true;
            });
            _loadCategories();
          },
        ),
      ),
    );
  }

  Widget _categoryDropdown() {
    return _box(
      DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: categoryId,
          isExpanded: true,
          dropdownColor: const Color(0xFF1E2538),
          hint: const Text(
            "Chọn nhóm giao dịch *",
            style: TextStyle(color: Colors.white38),
          ),
          items: categories.map<DropdownMenuItem<String>>((c) {
            final item = c as Map<String, dynamic>;
            final store = item['category_store'] as Map<String, dynamic>;

            return DropdownMenuItem<String>(
              value: item['id'] as String,
              child: Text(
                store['name'] as String,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
          onChanged: (v) => setState(() => categoryId = v),
        ),
      ),
    );
  }

  Widget _datePicker() {
    return _box(
      GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
            initialDate: selectedDate,
          );
          if (picked != null) {
            setState(() => selectedDate = picked);
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Ngày giao dịch: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
              style: const TextStyle(color: Colors.white),
            ),
            const Icon(Icons.calendar_today, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  Widget _inputField(
    TextEditingController ctrl,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: _decoration(hint),
      ),
    );
  }

  Widget _noteField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: noteCtrl,
        maxLines: 3,
        style: const TextStyle(color: Colors.white),
        decoration: _decoration("Ghi chú"),
      ),
    );
  }

  Widget _box(Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2538),
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: const Color(0xFF1E2538),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  void _showSnack(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: color),
    );
  }
}
