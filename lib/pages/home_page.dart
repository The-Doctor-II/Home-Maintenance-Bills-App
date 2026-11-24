import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/invoice.dart';
import '../services/local_db.dart';
import '../widgets/app_menu_card.dart';
import '../widgets/summary_card.dart';
import 'future_plans_page.dart';
import 'manage_invoices_page.dart';
import 'view_invoices_page.dart';
import 'auth/change_pin_page.dart';

class HomePage extends StatelessWidget {
  final VoidCallback onLock;

  const HomePage({
    super.key,
    required this.onLock,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('صيانة المنزل'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChangePinPage(),
                ),
              );
            },
            icon: const Icon(Icons.password),
            tooltip: 'تغيير الرقم السري',
          ),
          IconButton(
            onPressed: onLock,
            icon: const Icon(Icons.lock_outline),
            tooltip: 'قفل التطبيق',
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: LocalDb.invoicesBox.listenable(),
        builder: (context, box, _) {
          final List<Invoice> invoices = LocalDb.getInvoices();

          final paidTotal = invoices
              .where((invoice) => invoice.isPaid)
              .fold<double>(0, (sum, invoice) => sum + invoice.amount);

          final pendingTotal = invoices
              .where((invoice) => !invoice.isPaid)
              .fold<double>(0, (sum, invoice) => sum + invoice.amount);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SummaryCard(
                title: 'إجمالي المبلغ المسدد',
                amount: paidTotal,
                icon: Icons.verified,
                amountColor: Colors.lightGreenAccent,
                colors: const [
                  Color(0xFF1565C0),
                  Color(0xFF42A5F5),
                ],
              ),
              const SizedBox(height: 16),
              SummaryCard(
                title: 'إجمالي المبلغ المعلق',
                amount: pendingTotal,
                icon: Icons.pending_actions,
                amountColor: Colors.redAccent,
                colors: const [
                  Color(0xFF0D47A1),
                  Color(0xFF1976D2),
                ],
              ),
              const SizedBox(height: 24),
              AppMenuCard(
                title: 'إدارة الفواتير',
                subtitle: 'إضافة، تعديل أو حذف فواتير الصيانة',
                icon: Icons.edit_document,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageInvoicesPage(),
                    ),
                  );
                },
              ),
              AppMenuCard(
                title: 'عرض الفواتير',
                subtitle: 'عرض الفواتير حسب الحالة أو التصنيف',
                icon: Icons.receipt_long,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ViewInvoicesPage(),
                    ),
                  );
                },
              ),
              AppMenuCard(
                title: 'الخطط المستقبلية',
                subtitle: 'تسجيل أعمال الصيانة القادمة',
                icon: Icons.event_note,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FuturePlansPage(),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}