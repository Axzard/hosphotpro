import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/models/user_subscription_model.dart';

class SubscriptionStatusBadge extends StatelessWidget {
  final SubscriptionStatus status;

  const SubscriptionStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case SubscriptionStatus.active:
        bgColor = const Color(0xFF4ADE80).withValues(alpha: 0.15);
        textColor = const Color(0xFF4ADE80);
        label = 'AKTIF';
        break;
      case SubscriptionStatus.pending:
        bgColor = Colors.orange.withValues(alpha: 0.15);
        textColor = Colors.orange;
        label = 'PENDING';
        break;
      case SubscriptionStatus.expired:
        bgColor = Colors.redAccent.withValues(alpha: 0.15);
        textColor = Colors.redAccent;
        label = 'EXPIRED';
        break;
      case SubscriptionStatus.none:
        bgColor = Colors.grey.withValues(alpha: 0.15);
        textColor = Colors.grey;
        label = 'NONE';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
