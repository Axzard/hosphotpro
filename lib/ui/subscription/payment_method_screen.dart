import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/models/subscription_package_model.dart';
import 'view_models/subscription_view_model.dart';

class PaymentMethodScreen extends GetView<SubscriptionViewModel> {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final package = Get.arguments['package'] as SubscriptionPackageModel;
    final duration = Get.arguments['duration'] as int;
    final totalPrice = Get.arguments['totalPrice'] as double;
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    const bgColor = Color(0xFF0A1118);
    const cardColor = Color(0xFF131E29);
    const accentColor = Color(0xFF00C2FF);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(accentColor),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildPackageSummary(package, duration, totalPrice, currencyFormat, cardColor, accentColor),
                    const SizedBox(height: 24),
                    _buildPaymentMethods(cardColor, accentColor),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            _buildBottomBar(package, totalPrice, currencyFormat, accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color accentColor) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pembayaran',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'PILIH METODE PEMBAYARAN',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: accentColor.withValues(alpha: 0.6),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPackageSummary(SubscriptionPackageModel package, int duration, double totalPrice, NumberFormat currencyFormat, Color cardColor, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paket Terpilih',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.6),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            package.name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Harga',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              Text(
                currencyFormat.format(totalPrice),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(Color cardColor, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'E-WALLET & QRIS',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white.withValues(alpha: 0.6),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => _buildPaymentOption('qris', 'QRIS', 'Scan - Prosperity & Lainnya', Icons.qr_code_2, cardColor, accentColor)),
        const SizedBox(height: 12),
        Obx(() => _buildPaymentOption('gopay', 'GoPay', 'Bayar dengan aplikasi Gojek', Icons.account_balance_wallet, cardColor, accentColor)),
        const SizedBox(height: 24),
        Text(
          'VIRTUAL ACCOUNT',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white.withValues(alpha: 0.6),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => _buildPaymentOption('bca_va', 'BCA Virtual Account', 'Via transfer ke nomor VA BCA', Icons.account_balance, cardColor, accentColor)),
        const SizedBox(height: 12),
        Obx(() => _buildPaymentOption('mandiri_va', 'Mandiri Bill Payment', 'Transfer via kode Mandiri', Icons.account_balance, cardColor, accentColor)),
        const SizedBox(height: 12),
        Obx(() => _buildPaymentOption('bni_va', 'BNI Virtual Account', 'Transfer via kode BNI banking', Icons.account_balance, cardColor, accentColor)),
        const SizedBox(height: 24),
        Text(
          'KARTU KREDIT/DEBIT',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white.withValues(alpha: 0.6),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => _buildPaymentOption('credit_card', 'Kartu Kredit / Debit', 'Visa, Mastercard, JCB', Icons.credit_card, cardColor, accentColor)),
      ],
    );
  }

  Widget _buildPaymentOption(String method, String title, String subtitle, IconData icon, Color cardColor, Color accentColor) {
    final isSelected = controller.selectedPaymentMethod.value == method;

    return GestureDetector(
      onTap: () => controller.selectedPaymentMethod.value = method,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.1) : cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor : Colors.white.withValues(alpha: 0.05),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? accentColor : Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: method,
              groupValue: controller.selectedPaymentMethod.value,
              onChanged: (value) => controller.selectedPaymentMethod.value = value!,
              activeColor: accentColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(SubscriptionPackageModel package, double totalPrice, NumberFormat currencyFormat, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF131E29),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, color: Colors.white.withValues(alpha: 0.4), size: 14),
              const SizedBox(width: 6),
              Text(
                'Secured by MIDTRANS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.4),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.selectedPaymentMethod.value.isEmpty
                      ? null
                      : () => controller.processPayment(package, totalPrice),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 10,
                    shadowColor: accentColor.withValues(alpha: 0.4),
                    disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Bayar Sekarang',
                        style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.lock, size: 18),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
