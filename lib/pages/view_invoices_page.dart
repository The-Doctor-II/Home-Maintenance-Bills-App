import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../constants/app_constants.dart';
import '../models/invoice.dart';
import '../services/local_db.dart';

class ViewInvoicesPage extends StatefulWidget {
  const ViewInvoicesPage({super.key});

  @override
  State<ViewInvoicesPage> createState() => _ViewInvoicesPageState();
}

class _ViewInvoicesPageState extends State<ViewInvoicesPage> {
  String statusFilter = 'all';
  String categoryFilter = 'all';

  String formatDate(DateTime date) {
    return DateFormat('yyyy/MM/dd', 'ar').format(date);
  }

  List<Invoice> applyFilters(List<Invoice> invoices) {
    List<Invoice> filtered = invoices;

    if (statusFilter == 'paid') {
      filtered = filtered.where((invoice) => invoice.isPaid).toList();
    } else if (statusFilter == 'pending') {
      filtered = filtered.where((invoice) => !invoice.isPaid).toList();
    }

    if (categoryFilter != 'all') {
      filtered = filtered
          .where((invoice) => invoice.category == categoryFilter)
          .toList();
    }

    return filtered;
  }

  double calculateTotal(List<Invoice> invoices) {
    return invoices.fold<double>(0, (sum, invoice) => sum + invoice.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('عرض الفواتير'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('الكل'),
                      selected: statusFilter == 'all',
                      onSelected: (_) {
                        setState(() => statusFilter = 'all');
                      },
                    ),
                    ChoiceChip(
                      label: const Text('تم سداده'),
                      selected: statusFilter == 'paid',
                      onSelected: (_) {
                        setState(() => statusFilter = 'paid');
                      },
                    ),
                    ChoiceChip(
                      label: const Text('معلق'),
                      selected: statusFilter == 'pending',
                      onSelected: (_) {
                        setState(() => statusFilter = 'pending');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: categoryFilter,
                  decoration: const InputDecoration(
                    labelText: 'فلترة حسب التصنيف',
                    prefixIcon: Icon(Icons.filter_list),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: 'all',
                      child: Text('كل التصنيفات'),
                    ),
                    ...invoiceCategories.map(
                          (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      categoryFilter = value ?? 'all';
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: LocalDb.invoicesBox.listenable(),
              builder: (context, box, _) {
                final invoices = applyFilters(LocalDb.getInvoices());
                final total = calculateTotal(invoices);

                if (invoices.isEmpty) {
                  return const Center(
                    child: Text('لا توجد فواتير مطابقة'),
                  );
                }

                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calculate,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'إجمالي النتائج:',
                            style: TextStyle(color: Colors.white),
                          ),
                          const Spacer(),
                          Text(
                            '${total.toStringAsFixed(2)} جنيه سوداني',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        itemCount: invoices.length,
                        itemBuilder: (context, index) {
                          final invoice = invoices[index];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(14),
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade50,
                                child: Icon(
                                  invoice.isPaid
                                      ? Icons.check_circle
                                      : Icons.pending_actions,
                                  color: invoice.isPaid
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                              title: Text(
                                invoice.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  '${invoice.category} • ${formatDate(invoice.date)}\n'
                                      '${invoice.isPaid ? 'مسدد' : 'معلق'}',
                                ),
                              ),
                              trailing: Text(
                                '${invoice.amount.toStringAsFixed(2)} جنيه سوداني',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}