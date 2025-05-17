import 'package:flutter/material.dart';

class InteractionButtonReviews extends StatelessWidget {
  const InteractionButtonReviews({
    super.key,
    required this.icon,
    required this.amount,
    required this.onTap,
  });

  final IconData icon;
  final int amount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600], size: 24),
            Text(
              (amount < 1000)
                  ? "$amount"
                  : "${(amount / 1000).toStringAsFixed(1)}k",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
