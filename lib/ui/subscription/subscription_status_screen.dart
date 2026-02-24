import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'view_models/subscription_view_model.dart';
import 'widgets/subscription_header.dart';
import 'widgets/subscription_empty_state.dart';
import 'widgets/active_subscription_card.dart';
import 'widgets/subscription_item_card.dart';

class SubscriptionStatusScreen extends GetView<SubscriptionViewModel> {
  const SubscriptionStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0A1118);
    const cardColor = Color(0xFF131E29);
    const accentColor = Color(0xFF00C2FF);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const SubscriptionHeader(
              title: 'Status Langganan',
              subtitle: 'Kelola Langganan Anda',
              accentColor: accentColor,
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: accentColor),
                  );
                }

                if (controller.mySubscriptions.isEmpty) {
                  return SubscriptionEmptyState(
                    accentColor: accentColor,
                    onActionPressed: () => controller.navigateToPackages(),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.loadMySubscriptions,
                  color: accentColor,
                  backgroundColor: cardColor,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      const SizedBox(height: 8),
                      // Show active subscription card prominently if exists
                      ...controller.mySubscriptions
                          .where((s) => s.isActive)
                          .map(
                            (s) => Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: ActiveSubscriptionCard(
                                subscription: s,
                                cardColor: cardColor,
                                accentColor: accentColor,
                                controller: controller,
                              ),
                            ),
                          ),
                      // Show pending subscriptions
                      if (controller.mySubscriptions.any(
                        (s) => s.isPending,
                      )) ...[
                        const SizedBox(height: 12),
                        _buildSectionTitle(
                          'Menunggu Pembayaran',
                          Colors.orange,
                        ),
                        const SizedBox(height: 16),
                        ...controller.mySubscriptions
                            .where((s) => s.isPending)
                            .map(
                              (s) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: SubscriptionItemCard(
                                  subscription: s,
                                  cardColor: cardColor,
                                  controller: controller,
                                ),
                              ),
                            ),
                      ],
                      // Show expired subscriptions
                      if (controller.mySubscriptions.any(
                        (s) => s.isExpired,
                      )) ...[
                        const SizedBox(height: 12),
                        _buildSectionTitle('Kadaluarsa', Colors.redAccent),
                        const SizedBox(height: 16),
                        ...controller.mySubscriptions
                            .where((s) => s.isExpired)
                            .map(
                              (s) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: SubscriptionItemCard(
                                  subscription: s,
                                  cardColor: cardColor,
                                  controller: controller,
                                ),
                              ),
                            ),
                      ],
                      const SizedBox(height: 100), // Space for bottom button
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(accentColor),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1118),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () => controller.navigateToPackages(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor, accentColor.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Beli Paket Baru',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
