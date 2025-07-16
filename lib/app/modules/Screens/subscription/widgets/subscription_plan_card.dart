import 'package:flutter/material.dart';

import '../controllers/subscription_controller.dart';

class PlanCard extends StatelessWidget {
  final UserType userType;
  const PlanCard({required this.userType});

  Color getColor() {
    switch (userType) {
      case UserType.student:
        return Colors.red;
      case UserType.professional:
        return Colors.black;
      case UserType.business:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: getColor()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('₹1100 - One time',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('For next 5 years'),
            ],
          ),
          Column(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: getColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Best value'),
              ),
              const Icon(Icons.check_circle_outline),
            ],
          )
        ],
      ),
    );
  }
}
