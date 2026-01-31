import 'package:flutter/material.dart';
import 'package:quan_ly_chi_tieu/widgets/app_toast.dart';
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

  // ================= LOAD CATEGORY =================

  Future<void> _loadCategories() async {
    try {
      final data = await categoryService.getUserCategories();
      if (!mounted) return;

      setState(() {
        categories = data;
        loadingCategory = false;
      });

      _syncCategoryWithType(); // 🔴 sync lần đầu
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      Future.delayed(Duration.zero, () {
        _showSnack(e.toString(), Colors.red);
      });
    }
  }

  // ================= FILTER CATEGORY =================

  List<Map<String, dynamic>> get filteredCategories {
    return categories.where((c) {
      final store = c['category_store'];
      if (store == null || store is! Map<String, dynamic>) return false;
      return store['type'] == transactionType;
    }).toList();
  }

  // ================= SYNC CATEGORY WHEN TYPE CHANGE =================

  void _syncCategoryWithType() {
    final list = filteredCategories;

    if (list.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnack(
          "⚠️ Chưa có nhóm giao dịch cho loại này. Vui lòng thêm mới.",
          Colors.orange,
        );
        Navigator.pop(context);
      });
      return;
    }

    setState(() {
      categoryId = list.first['id']; // ✅ auto chọn category đầu tiên
    });
  }

  // ================= SAVE =================

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

      _showSnack(" Đã thêm giao dịch", Colors.green);
      await Future.delayed(const Duration(milliseconds: 200));
      Navigator.pop(context, true);
    } catch (e) {
      _showSnack(e.toString(), Colors.red);
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  // ================= UI =================

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
                      onPressed:
                          isSaving ? null : () => Navigator.pop(context),
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

  // ================= COMPONENTS =================

  Widget _typeDropdown() {
    return _box(
      DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          value: transactionType,
          dropdownColor: const Color(0xFF1E2538),
          decoration: _decoration("Loại giao dịch"),
          items: const [
            DropdownMenuItem(
              value: 'expense',
              child: Text("Chi tiêu",
                  style: TextStyle(color: Colors.white)),
            ),
            DropdownMenuItem(
              value: 'income',
              child: Text("Thu nhập",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              transactionType = value;
              categoryId = null; // 🔴 reset category cũ
            });

            _syncCategoryWithType(); // 🔴 filter + set category mới
          },
        ),
      ),
    );
  }

  Widget _categoryDropdown() {
    final list = filteredCategories;

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
          items: list.map<DropdownMenuItem<String>>((item) {
            final store = item['category_store'] as Map<String, dynamic>;

            return DropdownMenuItem<String>(
              value: item['id'] as String,
              child: Text(
                store['name'],
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
   AppToast.show(
  context,
  message: text,
  type: ToastType.success,
);
  }
}
