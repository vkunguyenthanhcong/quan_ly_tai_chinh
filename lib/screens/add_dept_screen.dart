import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  bool showQuickAmount = false;
  List<int> quickAmounts = [];
  String _type = 'borrowed_to_me';
  final FocusNode amountFocus = FocusNode();
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
  Widget _typeDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButtonFormField<String>(
        value: _type,
        dropdownColor: const Color(0xFF232E52),
        decoration: const InputDecoration(border: InputBorder.none),
        items: const [
          DropdownMenuItem(
            value: 'borrowed_to_me',
            child: Text(
              "Người khác nợ tôi",
              style: TextStyle(color: Colors.white),
            ),
          ),
          DropdownMenuItem(
            value: 'i_owe',
            child: Text("Tôi đang nợ", style: TextStyle(color: Colors.white)),
          ),
        ],
        onChanged: (value) {
          setState(() {
            _type = value!;
          });
        },
      ),
    );
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
      backgroundColor: const Color(0xFF0F1629),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Thêm khoản nợ",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2440),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Thông tin khoản nợ",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 16),

                  _input(_nameCtrl, "Tên người"),

                  const SizedBox(height: 12),

                  _input(
                    _amountCtrl,
                    "Số tiền",
                    keyboardType: TextInputType.number,
                    focusNode: amountFocus
                  ),
                   if (quickAmounts.isNotEmpty) _quickAmountButtons(),

                  const SizedBox(height: 12),

                  _input(_noteCtrl, "Ghi chú"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_sectionTitle("Danh mục"), _typeDropdown()],
              ),
            ),

            const SizedBox(height: 30),

            /// ===== BUTTON =====
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.zero,
                ),
                onPressed: _isSaving ? null : _save,
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3A86FF), Color(0xFF4361EE)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "LƯU KHOẢN NỢ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
              _amountCtrl.text = value.toString();
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
 String _formatMoney(int value) {
  return "${value.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  )} đ";
}

}


Widget _input(
  TextEditingController ctrl,
  String label, {
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
          style: const TextStyle(color: Colors.blueAccent, fontSize: 13),
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
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    ),
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
