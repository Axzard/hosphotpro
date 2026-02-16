import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'view_models/subscription_view_model.dart';
import '../../domain/models/transaction_model.dart';

class SubscriptionStatusScreen extends GetView<SubscriptionViewModel> {
  const SubscriptionStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Load history when screen opens
    controller.loadTransactionHistory();
    controller.loadCurrentSubscription();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(),
              const SizedBox(height: 32),
              _buildMainStatusCard(),
              const SizedBox(height: 48),
              _buildHistoryHeader(),
              const SizedBox(height: 20),
              _buildHistoryList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white10),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.cyan,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 20),
        const Text(
          'Status Langganan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMainStatusCard() {
    return Obx(() {
      final subscription = controller.currentSubscription.value;
      if (subscription == null) {
        return const Center(child: Text('Tidak ada langganan aktif', style: TextStyle(color: Colors.white70)));
      }

      final endDate = subscription.endDate ?? DateTime.now();
      final remainingDays = endDate.difference(DateTime.now()).inDays;
      final remainingHours = endDate.difference(DateTime.now()).inHours % 24;

      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.5),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.cyan.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.cyan.withOpacity(0.05),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.wifi_tethering, color: Colors.cyan, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${subscription.packageName} Hotspot',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'ID: HSP-2024-0892',
                        style: TextStyle(color: Colors.white38, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'AKTIF',
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildStatusItem(Icons.access_time, 'Sisa Waktu', '$remainingDays Hari, $remainingHours Jam'),
            const Divider(color: Colors.white10),
            _buildStatusItem(Icons.speed, 'Kecepatan', 'Up to 20 Mbps', valueColor: Colors.cyan),
            const Divider(color: Colors.white10),
            _buildStatusItem(Icons.calendar_today, 'Masa Berlaku', subscription.endDate != null ? DateFormat('dd MMM yyyy').format(subscription.endDate!) : '-'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => controller.navigateToPackages(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF22D3EE)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh, color: Colors.white, size: 20),
                        SizedBox(width: 12),
                        Text(
                          'Perbarui Langganan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatusItem(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Riwayat Langganan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () => controller.navigateToTransactions(),
          child: const Text(
            'Lihat Semua',
            style: TextStyle(color: Colors.cyan, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList() {
    return Obx(() {
      if (controller.transactions.isEmpty) {
        return const Center(child: Text('Belum ada riwayat', style: TextStyle(color: Colors.white38)));
      }

      // Show top 4 items like the design
      final displayItems = controller.transactions.take(4).toList();

      return Column(
        children: displayItems.map((transaction) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.history, color: Colors.white70, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Paket ${transaction.packageName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMM').format(transaction.createdAt) + ' - ' + 
                        DateFormat('dd MMM yyyy').format(transaction.createdAt.add(const Duration(days: 30))),
                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(transaction.amount),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.status == TransactionStatus.success ? 'SELESAI' : 'GAGAL',
                      style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }
}
