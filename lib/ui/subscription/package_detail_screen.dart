import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../domain/models/subscription_package_model.dart';
import 'view_models/subscription_view_model.dart';
import 'widgets/package_detail_header.dart';
import 'widgets/package_info_card.dart';
import 'widgets/package_benefits_grid.dart';
import 'widgets/package_duration_selector.dart';
import 'widgets/package_detail_bottom_bar.dart';

class PackageDetailScreen extends GetView<SubscriptionViewModel> {
  const PackageDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final package = Get.arguments as SubscriptionPackageModel;

    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    const bgColor = Color(0xFF0A1118);
    const cardColor = Color(0xFF131E29);
    const accentColor = Color(0xFF00C2FF);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const PackageDetailHeader(accentColor: accentColor),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    PackageInfoCard(
                      package: package,
                      currencyFormat: currencyFormat,
                      cardColor: cardColor,
                      accentColor: accentColor,
                    ),
                    const SizedBox(height: 28),
                    PackageDurationSelector(
                      cardColor: cardColor,
                      accentColor: accentColor,
                      controller: controller,
                    ),
                    const SizedBox(height: 28),
                    PackageBenefitsGrid(
                      package: package,
                      currencyFormat: currencyFormat,
                      cardColor: cardColor,
                      accentColor: accentColor,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            PackageDetailBottomBar(
              package: package,
              currencyFormat: currencyFormat,
              accentColor: accentColor,
              controller: controller,
            ),
          ],
        ),
      ),
    );
  }
}
