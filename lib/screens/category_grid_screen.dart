import 'package:flutter/material.dart';
import '../services/category_manage_service.dart';

class CategoryGridScreen extends StatefulWidget {
  final String type; // expense | income

  const CategoryGridScreen({super.key, required this.type});

  @override
  State<CategoryGridScreen> createState() => _CategoryGridScreenState();
}

class _CategoryGridScreenState extends State<CategoryGridScreen> {
  final service = CategoryManageService();

  List<Map<String, dynamic>> categories = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await service.getStoreCategories(widget.type);
    if (!mounted) return;
    setState(() {
      categories = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length + 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        if (index == categories.length) {
          return _addButton();
        }

        final c = categories[index];
        return _categoryItem(c);
      },
    );
  }

  Widget _categoryItem(Map<String, dynamic> c) {
    return GestureDetector(
      onTap: () async {
        await service.toggleUserCategory(c);
        setState(() {
          c['selected'] = !c['selected'];
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              c['icon'],
              width: 40,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image_not_supported, size: 36);
              },
            ),
            const SizedBox(height:4),
            Flexible(
  child: Text(
    c['name'],
    textAlign: TextAlign.center,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.black
    ),
  ),
),

            const SizedBox(height: 2),
            Icon(
              c['selected']
                  ? Icons.check_circle
                  : Icons.add_circle_outline,
              color: c['selected'] ? Colors.green : Colors.grey,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _addButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.add, color: Colors.white, size: 32),
    );
  }
}
