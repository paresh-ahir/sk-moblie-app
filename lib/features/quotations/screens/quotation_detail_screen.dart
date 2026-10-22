import 'package:flutter/material.dart';
import 'package:saleskido/core/theme/app_colors.dart';
import 'package:saleskido/services/quotation_service.dart';

class QuotationDetailScreen extends StatefulWidget {
  const QuotationDetailScreen({super.key, required this.id});

  final String id;

  @override
  State<QuotationDetailScreen> createState() => _QuotationDetailScreenState();
}

class _QuotationDetailScreenState extends State<QuotationDetailScreen> {
  bool _loading = true;
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await QuotationService().getOne(widget.id);
      final data = res['data'];
      if (!mounted) return;
      setState(() {
        _data = data is Map ? Map<String, dynamic>.from(data) : {};
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quotation Details')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _row('Client', (_data['clientName'] ?? _data['name'] ?? '-').toString()),
                _row('Status', (_data['status'] ?? '-').toString()),
                _row('Total', '₹ ${(_data['grandTotal'] ?? _data['total'] ?? 0)}'),
                _row('Discount', '₹ ${(_data['discount'] ?? 0)}'),
                _row('Tax', '₹ ${(_data['tax'] ?? 0)}'),
                const SizedBox(height: 12),
                const Text(
                  'Products',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ..._products(),
              ],
            ),
    );
  }

  List<Widget> _products() {
    final products = _data['products'] ?? _data['items'] ?? [];
    if (products is! List || products.isEmpty) {
      return [
        const Text('No products', style: TextStyle(color: AppColors.textSecondary)),
      ];
    }
    return products.map((p) {
      final m = Map<String, dynamic>.from(p as Map);
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '${m['productName'] ?? m['name'] ?? 'Item'}  × ${m['quantity'] ?? 1}',
        ),
      );
    }).toList();
  }

  Widget _row(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
