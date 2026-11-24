import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../models/future_plan.dart';
import '../services/local_db.dart';

class FuturePlansPage extends StatelessWidget {
  const FuturePlansPage({super.key});

  String formatDate(DateTime date) {
    return DateFormat('yyyy/MM/dd', 'ar').format(date);
  }

  void showPlanDialog(BuildContext context, {FuturePlan? plan}) {
    final titleController = TextEditingController(text: plan?.title ?? '');
    final detailsController = TextEditingController(text: plan?.details ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(plan == null ? 'إضافة خطة مستقبلية' : 'تعديل الخطة'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'عنوان الخطة',
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: detailsController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'تفاصيل الخطة',
                    prefixIcon: Icon(Icons.notes),
                  ),
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
                final title = titleController.text.trim();

                if (title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('يرجى إدخال عنوان الخطة'),
                    ),
                  );
                  return;
                }

                final newPlan = FuturePlan(
                  id: plan?.id ??
                      DateTime.now().microsecondsSinceEpoch.toString(),
                  title: title,
                  details: detailsController.text.trim(),
                  createdAt: plan?.createdAt ?? DateTime.now(),
                );

                await LocalDb.savePlan(newPlan);

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
  }

  void deletePlan(BuildContext context, FuturePlan plan) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('حذف الخطة'),
          content: Text('هل تريد حذف خطة "${plan.title}"؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                await LocalDb.deletePlan(plan.id);

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
        title: const Text('الخطط المستقبلية'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showPlanDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('إضافة'),
      ),
      body: ValueListenableBuilder(
        valueListenable: LocalDb.plansBox.listenable(),
        builder: (context, box, _) {
          final plans = LocalDb.getPlans();

          if (plans.isEmpty) {
            return const Center(
              child: Text('لا توجد خطط مستقبلية'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: Icon(
                      Icons.event_note,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  title: Text(
                    plan.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${formatDate(plan.createdAt)}\n'
                          '${plan.details.isEmpty ? 'لا توجد تفاصيل' : plan.details}',
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        showPlanDialog(context, plan: plan);
                      } else if (value == 'delete') {
                        deletePlan(context, plan);
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}