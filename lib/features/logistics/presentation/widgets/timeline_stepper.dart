import 'package:flutter/material.dart';

import '../../domain/entities/order_phase.dart';

class TimelineStepper extends StatelessWidget {
  final OrderPhase currentPhase;

  const TimelineStepper({super.key, required this.currentPhase});

  static const _icons = [
    Icons.assignment_ind_rounded,
    Icons.local_shipping_rounded,
    Icons.location_on_rounded,
    Icons.engineering_rounded,
    Icons.verified_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = currentPhase.index0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(OrderPhase.values.length, (index) {
          final isCompleted = index <= currentIndex;
          final isCurrent = index == currentIndex;
          final phase = OrderPhase.values[index];

          return Expanded(
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.all(isCurrent ? 14 : 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade100,
                    boxShadow: [
                      BoxShadow(
                        color: isCurrent
                            ? Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.3)
                            : Colors.transparent,
                        blurRadius: isCurrent ? 12.0 : 0.0,
                        spreadRadius: isCurrent ? 2.0 : 0.0,
                      ),
                    ],
                  ),
                  child: Icon(
                    _icons[index],
                    color: isCompleted ? Colors.white : Colors.grey.shade400,
                    size: isCurrent ? 24 : 18,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                    color: isCompleted ? const Color(0xFF0F172A) : Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(phase.label),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
