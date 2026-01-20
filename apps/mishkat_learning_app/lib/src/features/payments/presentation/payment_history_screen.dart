import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';
import '../../auth/data/auth_repository.dart';
import '../data/payment_repository.dart';
import '../../courses/data/course_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return const SizedBox.shrink();

    final paymentsAsync = ref.watch(userPaymentsProvider(user.uid));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Payment History',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: AppTheme.slateGrey,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppTheme.slateGrey),
      ),
      body: paymentsAsync.when(
        data: (payments) {
          if (payments.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index];
              return _PaymentCard(payment: payment);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.deepEmerald)),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: AppTheme.slateGrey.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            'No payments yet',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.slateGrey.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enroll in your first course to see records here.',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: AppTheme.slateGrey.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends ConsumerWidget {
  final Map<String, dynamic> payment;
  const _PaymentCard({required this.payment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseId = payment['courseId'] as String?;
    final amount = (payment['amount'] ?? 0.0).toDouble();
    final currency = (payment['currency'] ?? 'USD').toString().toUpperCase();
    final status = payment['status'] ?? 'pending';
    final createdAt = (payment['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final dateStr = DateFormat('MMM dd, yyyy • hh:mm a').format(createdAt);
    final transactionId = payment['paymentId'] ?? payment['id'] ?? 'N/A';

    final courseAsync = courseId != null ? ref.watch(specificCourseProvider(courseId)) : const AsyncValue.data(null);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.slateGrey.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateStr,
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: AppTheme.slateGrey.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 4),
                        courseAsync.when(
                          data: (course) => Text(
                            course?.title ?? 'Unknown Course',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.slateGrey,
                            ),
                          ),
                          loading: () => const SizedBox(height: 16, width: 100, child: LinearProgressIndicator()),
                          error: (_, __) => const Text('Error loading course'),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: status),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TRANSACTION ID',
                        style: GoogleFonts.sourceCodePro(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.slateGrey.withValues(alpha: 0.4),
                        ),
                      ),
                      Text(
                        transactionId.toString(),
                        style: GoogleFonts.sourceCodePro(
                          fontSize: 12,
                          color: AppTheme.slateGrey,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$currency ${amount.toStringAsFixed(2)}',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepEmerald,
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

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bgColor;
    String label;

    switch (status.toLowerCase()) {
      case 'captured':
      case 'successful':
      case 'success':
        color = const Color(0xFF2E7D32); // Green
        bgColor = const Color(0xFFE8F5E9);
        label = 'Successful';
        break;
      case 'failed':
        color = const Color(0xFFC62828); // Red
        bgColor = const Color(0xFFFFEBEE);
        label = 'Failed';
        break;
      case 'created':
        color = AppTheme.slateGrey;
        bgColor = AppTheme.slateGrey.withValues(alpha: 0.1);
        label = 'Incomplete';
        break;
      default:
        color = const Color(0xFFEF6C00); // Orange
        bgColor = const Color(0xFFFFF3E0);
        label = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
