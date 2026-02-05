import 'package:flutter/material.dart';
import 'package:quan_ly_chi_tieu/core/theme/app_button.dart';
import 'package:quan_ly_chi_tieu/core/theme/app_colors.dart';
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

  final FocusNode amountFocus = FocusNode();

  final categoryService = CategoryService();
  final transactionService = TransactionService();

  List<Map<String, dynamic>> categories = [];
  List<int> quickAmounts = [];
  String? categoryId;

  String transactionType = 'expense';
  DateTime selectedDate = DateTime.now();

  bool isSaving = false;
  bool loadingCategory = true;
  bool showQuickAmount = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();

    amountFocus.addListener(() {
      setState(() {
        showQuickAmount = amountFocus.hasFocus;
      });
      _updateQuickAmounts();
    });

    amountCtrl.addListener(_updateQuickAmounts);
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    amountCtrl.dispose();
    noteCtrl.dispose();
    amountFocus.dispose();
    super.dispose();
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

      _syncCategoryWithType();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showSnack(e.toString(), Colors.red);
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

  // ================= SYNC CATEGORY =================

  void _syncCategoryWithType() {
    final list = filteredCategories;

    if (list.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnack("⚠️ Chưa có nhóm giao dịch cho loại này", Colors.orange);
        Navigator.pop(context);
      });
      return;
    }

    setState(() {
      categoryId = list.first['id'];
    });
  }

  // ================= QUICK AMOUNT =================

  void _updateQuickAmounts() {
    if (!showQuickAmount) {
      setState(() => quickAmounts = []);
      return;
    }

    final text = amountCtrl.text.trim();
    final base = int.tryParse(text);

    if (base == null || base <= 0) {
      setState(() => quickAmounts = []);
      return;
    }

    setState(() {
      quickAmounts = [base * 10000, base * 100000];
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

      _showSnack("Đã thêm giao dịch", Colors.green);
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
                focusNode: amountFocus,
              ),

              if (quickAmounts.isNotEmpty) _quickAmountButtons(),

              _datePicker(),
              _noteField(),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: "HỦY",
                      color: AppColors.danger,
                      onPressed: isSaving
                          ? () {}
                          : () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppButton(
                      text: "LƯU",
                      onPressed: isSaving ? () {} : _saveTransaction,
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

  Widget _quickAmountButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: quickAmounts.map((value) {
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A3350),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              amountCtrl.text = value.toString();
              amountFocus.unfocus();
            },
            child: Text(
              _formatMoney(value),
              style: const TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
      ),
    );
  }

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
              child: Text("Chi tiêu", style: TextStyle(color: Colors.white)),
            ),
            DropdownMenuItem(
              value: 'income',
              child: Text("Thu nhập", style: TextStyle(color: Colors.white)),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              transactionType = value;
              categoryId = null;
            });
            _syncCategoryWithType();
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
          items: list.map((item) {
            final store = item['category_store'] as Map<String, dynamic>;
            return DropdownMenuItem<String>(
              value: item['id'],
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
    FocusNode? focusNode,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctrl,
        focusNode: focusNode,
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

  String _formatMoney(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  void _showSnack(String text, Color color) {
    AppToast.show(context, message: text, type: ToastType.success);
  }
}
