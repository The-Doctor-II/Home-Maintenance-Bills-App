import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../constants/app_constants.dart';
import '../models/invoice.dart';
import '../services/local_db.dart';

class ManageInvoicesPage extends StatelessWidget {
  const ManageInvoicesPage({super.key});

  String formatDate(DateTime date) {
    return DateFormat('yyyy/MM/dd', 'ar').format(date);
  }

  void showInvoiceDialog(BuildContext context, {Invoice? invoice}) {
    final nameController = TextEditingController(text: invoice?.name ?? '');
    final amountController = TextEditingController(
      text: invoice == null ? '' : invoice.amount.toString(),
    );
    final detailsController = TextEditingController(text: invoice?.details ?? '');

    String selectedCategory = invoice?.category ?? invoiceCategories.first;
    DateTime selectedDate = invoice?.date ?? DateTime.now();
    bool isPaid = invoice?.isPaid ?? false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(invoice == null ? 'إضافة فاتورة' : 'تعديل فاتورة'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم الفاتورة',
                        prefixIcon: Icon(Icons.receipt),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'المبلغ',
                        prefixIcon: Icon(Icons.payments),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'تصنيف الفاتورة',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: invoiceCategories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value ?? invoiceCategories.first;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.date_range),
                      title: const Text('تاريخ الفاتورة'),
                      subtitle: Text(formatDate(selectedDate)),
                      trailing: const Icon(Icons.edit_calendar),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );

                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: detailsController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'التفاصيل',
                        prefixIcon: Icon(Icons.notes),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      value: isPaid,
                      title: const Text('تم السداد'),
                      activeColor: Colors.blue,
                      onChanged: (value) {
                        setState(() {
                          isPaid = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final amount = double.tryParse(
                      amountController.text.trim().replaceAll(',', '.'),
                    );

                    if (name.isEmpty || amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('يرجى إدخال اسم الفاتورة والمبلغ بشكل صحيح'),
                        ),
                      );
                      return;
                    }

                    final newInvoice = Invoice(
                      id: invoice?.id ??
                          DateTime.now().microsecondsSinceEpoch.toString(),
                      name: name,
                      amount: amount,
                      details: detailsController.text.trim(),
                      category: selectedCategory,
                      date: selectedDate,
                      isPaid: isPaid,
                      createdAt: invoice?.createdAt ?? DateTime.now(),
                    );

                    await LocalDb.saveInvoice(newInvoice);

                    if (context.mounted) {
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void deleteInvoice(BuildContext context, Invoice invoice) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('حذف الفاتورة'),
          content: Text('هل تريد حذف فاتورة "${invoice.name}"؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                await LocalDb.deleteInvoice(invoice.id);

                if (context.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              icon: const Icon(Icons.delete),
              label: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الفواتير'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showInvoiceDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('إضافة'),
      ),
      body: ValueListenableBuilder(
        valueListenable: LocalDb.invoicesBox.listenable(),
        builder: (context, box, _) {
          final invoices = LocalDb.getInvoices();

          if (invoices.isEmpty) {
            return const Center(
              child: Text('لا توجد فواتير بعد'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoices[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: CircleAvatar(
                    backgroundColor: invoice.isPaid
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    child: Icon(
                      invoice.isPaid ? Icons.check : Icons.schedule,
                      color: invoice.isPaid ? Colors.green : Colors.orange,
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
                          '${invoice.details.isEmpty ? 'لا توجد تفاصيل' : invoice.details}',
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        invoice.amount.toStringAsFixed(2),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            showInvoiceDialog(context, invoice: invoice);
                          } else if (value == 'delete') {
                            deleteInvoice(context, invoice);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('تعديل'),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('حذف'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}