import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class PaymentMethod {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class PaymentMethodSelector extends StatelessWidget {
  final String selectedMethod;
  final ValueChanged<String> onMethodSelected;
  final Color accentColor;

  PaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
    required this.accentColor,
  });

  final List<PaymentMethod> methods = [
    PaymentMethod(
      id: 'mandiri',
      name: 'Mandiri Virtual Account',
      icon: Icons.account_balance_rounded,
      color: const Color(0xFFF7931E),
    ),
    PaymentMethod(
      id: 'bni',
      name: 'BNI Virtual Account',
      icon: Icons.account_balance_rounded,
      color: const Color(0xFF005E6A),
    ),
    PaymentMethod(
      id: 'bri',
      name: 'BRI Virtual Account',
      icon: Icons.account_balance_rounded,
      color: const Color(0xFF00529C),
    ),
    PaymentMethod(
      id: 'cimb',
      name: 'CIMB Niaga Virtual Account',
      icon: Icons.account_balance_rounded,
      color: const Color(0xFFED1C24),
    ),
    PaymentMethod(
      id: 'permata',
      name: 'Permata Virtual Account',
      icon: Icons.account_balance_rounded,
      color: const Color(0xFF282463),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Text(
            'Pilih Metode Pembayaran',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: methods.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final method = methods[index];
            final isSelected = selectedMethod == method.id;

            return GestureDetector(
              onTap: () => onMethodSelected(method.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? accentColor.withValues(alpha: 0.12)
                      : const Color(0xFF131E29),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? accentColor
                        : Colors.white.withValues(alpha: 0.05),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: method.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(method.icon, color: method.color, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        method.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle_rounded,
                        color: accentColor,
                        size: 24,
                      )
                    else
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 2,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
