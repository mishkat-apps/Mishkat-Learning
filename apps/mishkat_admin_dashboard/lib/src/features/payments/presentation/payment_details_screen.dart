import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mishkat_admin_dashboard/src/core/theme/admin_theme.dart';
import 'package:mishkat_admin_dashboard/src/features/payments/data/admin_payment_repository.dart';
import 'package:mishkat_admin_dashboard/src/features/users/data/admin_user_repository.dart';
import 'dart:convert';

class PaymentDetailsScreen extends ConsumerWidget {
  final String paymentId;

  const PaymentDetailsScreen({super.key, required this.paymentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentAsync = ref.watch(adminPaymentDetailsProvider(paymentId));

    return Scaffold(
      backgroundColor: AdminTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Transaction Receipt'),
        backgroundColor: Colors.white,
        foregroundColor: AdminTheme.zinc900,
        elevation: 0,
        centerTitle: false,
      ),
      body: paymentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (payment) => SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Transaction Info
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: payment.status == 'captured' 
                          ? AdminTheme.primaryEmerald.withValues(alpha: 0.1) 
                          : Colors.grey.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        payment.status == 'captured' ? Icons.check_circle_outline : Icons.info_outline,
                        color: payment.status == 'captured' ? AdminTheme.primaryEmerald : Colors.grey,
                        size: 40,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${payment.currency.toUpperCase()} ${payment.amount.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'Geist Mono'),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMMM dd, yyyy • HH:mm:ss').format(payment.createdAt),
                            style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    _StatusChip(status: payment.status),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transaction Details
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _DetailCard(
                          title: 'Payment Information',
                          children: [
                            _DetailRow(label: 'Order ID', value: payment.orderId, isMono: true),
                            _DetailRow(label: 'Payment ID', value: payment.paymentId ?? '-', isMono: true),
                            _DetailRow(label: 'Method', value: payment.method?.toUpperCase() ?? '-'),
                            _DetailRow(label: 'Currency', value: payment.currency.toUpperCase()),
                            _DetailRow(label: 'Course ID', value: payment.courseId, isMono: true),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _UserCard(uid: payment.uid, email: payment.email, contact: payment.contact),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 32),
                  
                  // Meta & Actions
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        _ActionCard(paymentId: payment.id),
                        const SizedBox(height: 24),
                        _RawDataCard(data: payment.toMap()),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _UserCard extends ConsumerWidget {
  final String uid;
  final String? email;
  final String? contact;

  const _UserCard({required this.uid, this.email, this.contact});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(adminUserDetailsProvider(uid));

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Customer Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          userAsync.when(
            data: (user) => Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AdminTheme.zinc100,
                  backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                  child: user.photoUrl == null ? Text(user.displayName[0], style: const TextStyle(fontWeight: FontWeight.bold)) : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(user.email, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () {}, // Navigate to user details
                  child: const Text('View Profile'),
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow(label: 'User ID', value: uid, isMono: true),
                _DetailRow(label: 'Email', value: email ?? '-'),
                _DetailRow(label: 'Contact', value: contact ?? '-'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String paymentId;

  const _ActionCard({required this.paymentId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh),
              label: const Text('Refund Transaction'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.print_outlined),
              label: const Text('Print Receipt'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RawDataCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _RawDataCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Raw Data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: jsonEncode(data)));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('JSON copied to clipboard')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AdminTheme.zinc50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              const JsonEncoder.withIndent('  ').convert(data),
              style: const TextStyle(fontFamily: 'Geist Mono', fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isMono;

  const _DetailRow({required this.label, required this.value, this.isMono = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 14)),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: isMono ? 'Geist Mono' : null,
                fontSize: 14,
                color: AdminTheme.zinc900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'captured':
        color = AdminTheme.primaryEmerald;
        break;
      case 'failed':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
      ),
    );
  }
}
