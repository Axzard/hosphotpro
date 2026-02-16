import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../domain/models/transaction_model.dart';
import 'view_models/subscription_view_model.dart';

class TransactionHistoryScreen extends GetView<SubscriptionViewModel> {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Load transactions when screen opens
    controller.loadTransactionHistory();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.transactions.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Belum ada transaksi'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadTransactionHistory,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.transactions.length,
            itemBuilder: (context, index) {
              final transaction = controller.transactions[index];
              return _buildTransactionCard(context, transaction);
            },
          ),
        );
      }),
    );
  }

  Widget _buildTransactionCard(BuildContext context, TransactionModel transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _buildStatusIcon(transaction.status),
        title: Text(
          transaction.packageName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                  .format(transaction.amount),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd MMM yyyy, HH:mm').format(transaction.createdAt),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: _buildStatusChip(transaction.status),
      ),
    );
  }

  Widget _buildStatusIcon(TransactionStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case TransactionStatus.success:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case TransactionStatus.pending:
        icon = Icons.pending;
        color = Colors.orange;
        break;
      case TransactionStatus.failed:
      case TransactionStatus.cancelled:
      case TransactionStatus.expired:
        icon = Icons.cancel;
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color),
    );
  }

  Widget _buildStatusChip(TransactionStatus status) {
    Color color;

    switch (status) {
      case TransactionStatus.success:
        color = Colors.green;
        break;
      case TransactionStatus.pending:
        color = Colors.orange;
        break;
      case TransactionStatus.failed:
      case TransactionStatus.cancelled:
      case TransactionStatus.expired:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
