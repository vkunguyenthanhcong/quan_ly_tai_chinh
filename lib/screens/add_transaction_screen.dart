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
      setState(() => showQuickAmount = amountFocus.hasFocus);
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

  // ================= LOGIC (GIỮ NGUYÊN) =================

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

  List<Map<String, dynamic>> get filteredCategories {
    return categories.where((c) {
      final store = c['category_store'];
      if (store == null || store is! Map<String, dynamic>) return false;
      return store['type'] == transactionType;
    }).toList();
  }

  void _syncCategoryWithType() {
    final list = filteredCategories;
    if (list.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnack("⚠️ Chưa có nhóm giao dịch cho loại này", Colors.orange);
        Navigator.pop(context);
      });
      return;
    }
    setState(() => categoryId = list.first['id']);
  }

  void _updateQuickAmounts() {
    if (!showQuickAmount) {
      setState(() => quickAmounts = []);
      return;
    }
    final base = int.tryParse(amountCtrl.text.trim());
    if (base == null || base <= 0) {
      setState(() => quickAmounts = []);
      return;
    }
    setState(() {
      quickAmounts = [base * 100, base * 1000, base * 10000];
    });
  }

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
        note: "",
        date: selectedDate,
      );
      //await transactionService.updateTodayExpenseWidget();

      if (!mounted) return;
      _showSnack("Đã thêm giao dịch", Colors.green);
      await Future.delayed(const Duration(milliseconds: 200));
      Navigator.pop(context, true);
    } catch (e) {
      _showSnack("Lỗi", Colors.red);
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  // ================= UI (CHỈ SỬA GIAO DIỆN) =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1629),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1629),
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
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Thông tin giao dịch"),
                    _formField("Tên giao dịch", titleCtrl),
                    _formField(
                      "Số tiền",
                      amountCtrl,
                      keyboardType: TextInputType.number,
                      focusNode: amountFocus,
                    ),
                    if (quickAmounts.isNotEmpty) _quickAmountButtons(),
                    _datePicker(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Danh mục"),
                    _typeDropdown(),
                    if (loadingCategory)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else
                      _categoryDropdown(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: isSaving ? "ĐANG LƯU..." : "LƯU GIAO DỊCH",
                  onPressed: isSaving ? () {} : _saveTransaction,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= COMPONENT UI =================

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2440),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _formField(
    String label,
    TextEditingController ctrl, {
    TextInputType keyboardType = TextInputType.text,
    FocusNode? focusNode,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.blueAccent,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF232E52),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: ctrl,
              focusNode: focusNode,
              keyboardType: keyboardType,
              maxLines: maxLines,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickAmountButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: quickAmounts.map((value) {
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFF2F3A5F),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
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
          dropdownColor: const Color(0xFF232E52),
          decoration: const InputDecoration(border: InputBorder.none),
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
          dropdownColor: const Color(0xFF232E52),
          items: list.map((item) {
            final store = item['category_store'] as Map<String, dynamic>;
            final String? iconPath = store['icon'];
            return DropdownMenuItem<String>(
              value: item['id'],
              child: Row(
                children: [
                  if (iconPath != null && iconPath.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        iconPath,
                        width: 22,
                        height: 22,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (iconPath != null && iconPath.isNotEmpty)
                    const SizedBox(width: 10),
                  Text(
                    store['name'],
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
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
              "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
              style: const TextStyle(color: Colors.white),
            ),
            const Icon(Icons.calendar_today, color: Colors.white54, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _box(Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF232E52),
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
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
