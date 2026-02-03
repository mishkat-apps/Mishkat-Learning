import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mishkat_admin_dashboard/src/core/theme/admin_theme.dart';
import 'package:mishkat_admin_dashboard/src/features/payments/data/admin_payment_repository.dart';
import 'package:mishkat_admin_dashboard/src/features/payments/domain/admin_payment_model.dart';
import 'package:mishkat_admin_dashboard/src/widgets/common/dashboard_header.dart';
import 'package:mishkat_admin_dashboard/src/features/dashboard/presentation/widgets/kpi_card.dart';

class PaymentLedgerScreen extends ConsumerStatefulWidget {
  const PaymentLedgerScreen({super.key});

  @override
  ConsumerState<PaymentLedgerScreen> createState() => _PaymentLedgerScreenState();
}

class _PaymentLedgerScreenState extends ConsumerState<PaymentLedgerScreen> {
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    // We fetch a larger limit to calculate semi-accurate stats from recent volume
    final paymentsAsync = ref.watch(adminPaymentListProvider(
      limit: 100, 
      status: _statusFilter == 'all' ? null : _statusFilter
    ));

    return Scaffold(
      backgroundColor: AdminTheme.scaffoldBackground,
      body: Column(
        children: [
          DashboardHeader(
            title: 'Payments Ledger',
            subtitle: 'Monitor transaction health and financial volume',
            action: ElevatedButton.icon(
              onPressed: () {}, // Download Report
              icon: const Icon(Icons.download_outlined),
              label: const Text('Export CSV'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AdminTheme.zinc900,
                elevation: 0,
                side: BorderSide(color: Colors.grey[200]!),
              ),
            ),
          ),
          
          Expanded(
            child: paymentsAsync.when(
              data: (payments) {
                // Calculation for KPIs (based on the fetched 100 recent)
                final totalVolume = payments.length;
                final capturedCount = payments.where((p) => p.status == 'captured').length;
                final failedCount = payments.where((p) => p.status == 'failed').length;
                final totalRevenue = payments
                    .where((p) => p.status == 'captured')
                    .fold(0.0, (sum, p) => sum + p.amount);

                final successRate = totalVolume > 0 ? (capturedCount / totalVolume) * 100 : 0.0;

                return ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    // KPI Row
                    Row(
                      children: [
                        Expanded(child: KPICard(
                          label: 'Total Revenue (Recent)', 
                          value: 'USD ${totalRevenue.toStringAsFixed(0)}', 
                          icon: Icons.account_balance_wallet_outlined,
                          color: AdminTheme.primaryEmerald,
                        )),
                        const SizedBox(width: 20),
                        Expanded(child: KPICard(
                          label: 'Success Rate', 
                          value: '${successRate.toStringAsFixed(1)}%', 
                          icon: Icons.trending_up,
                          color: Colors.blue,
                        )),
                        const SizedBox(width: 20),
                        Expanded(child: KPICard(
                          label: 'Failed Txns', 
                          value: '$failedCount', 
                          icon: Icons.error_outline,
                          color: Colors.red,
                        )),
                        const SizedBox(width: 20),
                        Expanded(child: KPICard(
                          label: 'Recent Volume', 
                          value: '$totalVolume', 
                          icon: Icons.bar_chart,
                        )),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Filter Row
                    Row(
                      children: [
                        _PaymentFilterChip(
                          label: 'All Transactions', 
                          isSelected: _statusFilter == 'all', 
                          onSelected: () => setState(() => _statusFilter = 'all')
                        ),
                        const SizedBox(width: 8),
                        _PaymentFilterChip(
                          label: 'Captured', 
                          isSelected: _statusFilter == 'captured', 
                          onSelected: () => setState(() => _statusFilter = 'captured')
                        ),
                        const SizedBox(width: 8),
                        _PaymentFilterChip(
                          label: 'Failed', 
                          isSelected: _statusFilter == 'failed', 
                          onSelected: () => setState(() => _statusFilter = 'failed')
                        ),
                        const SizedBox(width: 8),
                        _PaymentFilterChip(
                          label: 'Authorized', 
                          isSelected: _statusFilter == 'authorized', 
                          onSelected: () => setState(() => _statusFilter = 'authorized')
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.filter_list, size: 20),
                          label: const Text('Advanced Filters'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Table
                    _PaymentTable(payments: payments),
                  ],
                );
              },
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
    if (payments.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: const Center(child: Text('No transactions found.')),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      clipBehavior: Clip.antiAlias,
      child: DataTable(
        headingRowHeight: 56,
        dataRowMaxHeight: 72,
        horizontalMargin: 24,
        headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
        showCheckboxColumn: false,
        columns: const [
          DataColumn(label: Text('DATE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          DataColumn(label: Text('USER / CONTACT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          DataColumn(label: Text('AMOUNT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          DataColumn(label: Text('ORDER ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          DataColumn(label: Text('METHOD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
        ],
        rows: payments.map((payment) => DataRow(
          onSelectChanged: (_) => context.push('/payments/${payment.id}'),
          cells: [
            DataCell(Text(DateFormat('MMM dd, HH:mm').format(payment.createdAt), style: const TextStyle(fontSize: 13))),
            DataCell(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(payment.email ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                if (payment.contact != null)
                  Text(payment.contact!, style: const TextStyle(fontSize: 11, color: AdminTheme.textSecondary)),
              ],
            )),
            DataCell(Text(
              '${payment.currency.toUpperCase()} ${payment.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Geist Mono', fontSize: 14),
            )),
            DataCell(_StatusBadge(status: payment.status)),
            DataCell(Text(payment.orderId, style: const TextStyle(fontSize: 12, fontFamily: 'Geist Mono', color: AdminTheme.textSecondary))),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(payment.method?.toUpperCase() ?? '-', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ),
          ],
        )).toList(),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}

class _PaymentFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _PaymentFilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: AdminTheme.zinc900,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AdminTheme.zinc900,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey[200]!),
      ),
      showCheckmark: false,
    );
  }
}
