import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_chi_tieu/core/theme/app_colors.dart';
import 'package:quan_ly_chi_tieu/providers/dept_provider.dart';

class AddDebtScreen extends StatefulWidget {
  const AddDebtScreen({super.key});

  @override
  State<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  final FocusNode amountFocus = FocusNode();

  bool showQuickAmount = false;
  List<int> quickAmounts = [];
  String _type = 'borrowed_to_me';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    amountFocus.addListener(() {
      setState(() => showQuickAmount = amountFocus.hasFocus);
      _updateQuickAmounts();
    });

    _amountCtrl.addListener(_updateQuickAmounts);
  }

  void _updateQuickAmounts() {
    if (!showQuickAmount) {
      setState(() => quickAmounts = []);
      return;
    }

    final base = int.tryParse(_amountCtrl.text.trim());

    if (base == null || base <= 0) {
      setState(() => quickAmounts = []);
      return;
    }

    setState(() {
      quickAmounts = [base * 100, base * 1000, base * 10000];
    });
  }

  @override
  void dispose() {
    amountFocus.dispose();
    _amountCtrl.dispose();
    _nameCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = int.tryParse(_amountCtrl.text.trim());

    if (_nameCtrl.text.isEmpty || amount == null || amount <= 0) return;

    setState(() => _isSaving = true);

    await context.read<DebtProvider>().addDebt(
          personName: _nameCtrl.text.trim(),
          amount: amount,
          type: _type,
          note: _noteCtrl.text.trim(),
        );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Thêm khoản nợ",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// ===== TYPE SELECTOR =====
            _typeSelector(),

            const SizedBox(height: 24),
            if (quickAmounts.isNotEmpty) _quickAmountButtons(),

            const SizedBox(height: 24),

            /// ===== INFO CARD =====
            _infoCard(
              child: Column(
                children: [
                  _input(_nameCtrl, "Tên người"),
                  _input(_amountCtrl, "Số tiền"),
                  _input(_noteCtrl, "Ghi chú", maxLines: 2),
                ],
              ),
            ),

            const SizedBox(height: 32),

            /// ===== SAVE BUTTON =====
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                ),
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "LƯU KHOẢN NỢ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= TYPE SELECTOR =================

  Widget _typeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          _typeOption("borrowed_to_me", "Người nợ tôi"),
          _typeOption("i_owe", "Tôi đang nợ"),
        ],
      ),
    );
  }

  Widget _typeOption(String value, String label) {
    final selected = _type == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? Colors.white
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  /// ================= AMOUNT INPUT =================

  

  /// ================= QUICK AMOUNT =================

  Widget _quickAmountButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: quickAmounts.map((value) {
          return OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.divider),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              _amountCtrl.text = value.toString();
              amountFocus.unfocus();
            },
            child: Text(
              _formatMoney(value),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// ================= INPUT =================

  Widget _input(
  TextEditingController ctrl,
  String label, {
  int maxLines = 1,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),

        filled: true,
        fillColor: AppColors.surface.withOpacity(0.6),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: AppColors.accent,
            width: 1.5,
          ),
        ),
      ),
    ),
  );
}

  /// ================= CARD =================

  Widget _infoCard({required Widget child}) {
    return Container(
      
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  String _formatMoney(int value) {
    return "${value.toString().replaceAllMapped(
      RegExp(r'(\\d)(?=(\\d{3})+(?!\\d))'),
      (m) => '${m[1]}.',
    )} đ";
  }
}