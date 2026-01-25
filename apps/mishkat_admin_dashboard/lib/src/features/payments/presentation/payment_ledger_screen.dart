import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mishkat_admin_dashboard/src/core/theme/admin_theme.dart';
import 'package:mishkat_admin_dashboard/src/features/payments/data/admin_payment_repository.dart';
import 'package:mishkat_admin_dashboard/src/features/payments/domain/admin_payment_model.dart';

class PaymentLedgerScreen extends ConsumerStatefulWidget {
  const PaymentLedgerScreen({super.key});

  @override
  ConsumerState<PaymentLedgerScreen> createState() => _PaymentLedgerScreenState();
}

class _PaymentLedgerScreenState extends ConsumerState<PaymentLedgerScreen> {
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(adminPaymentListProvider(status: _statusFilter == 'all' ? null : _statusFilter));

    return Scaffold(
      backgroundColor: AdminTheme.scaffoldBackground,
      body: Column(
        children: [
          // Toolbar
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Row(
              children: [
                Text('Payments Ledger', style: Theme.of(context).textTheme.headlineMedium),
                const Spacer(),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'all', label: Text('All')),
                    ButtonSegment(value: 'captured', label: Text('Captured')),
                    ButtonSegment(value: 'failed', label: Text('Failed')),
                  ],
                  selected: {_statusFilter},
                  onSelectionChanged: (val) => setState(() => _statusFilter = val.first),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),

          // Payment List
          Expanded(
            child: paymentsAsync.when(
              data: (payments) => _PaymentTable(payments: payments),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentTable extends StatelessWidget {
  final List<AdminPaymentModel> payments;

  const _PaymentTable({required this.payments});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AdminTheme.scaffoldBackground),
          showCheckboxColumn: false,
          columns: const [
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('User')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Order ID')),
            DataColumn(label: Text('Method')),
          ],
          rows: payments.map((payment) => DataRow(
            onSelectChanged: (_) => context.push('/payments/${payment.id}'),
            cells: [
              DataCell(Text(DateFormat('MMM dd, HH:mm').format(payment.createdAt))),
              DataCell(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(payment.email ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (payment.contact != null)
                    Text(payment.contact!, style: const TextStyle(fontSize: 11, color: AdminTheme.textSecondary)),
                ],
              )),
              DataCell(Text(
                '${payment.currency.toUpperCase()} ${payment.amount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Geist Mono'),
              )),
              DataCell(_StatusBadge(status: payment.status)),
              DataCell(Text(payment.orderId, style: const TextStyle(fontSize: 12, fontFamily: 'Geist Mono'))),
              DataCell(Text(payment.method ?? '-', style: const TextStyle(fontSize: 12))),
            ],
          )).toList(),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'captured':
        color = Colors.green;
        break;
      case 'failed':
        color = Colors.red;
        break;
      case 'authorized':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
