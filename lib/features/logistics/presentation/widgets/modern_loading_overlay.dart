import 'dart:ui';
import 'package:flutter/material.dart';

class ModernLoadingOverlay extends StatelessWidget {
  const ModernLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Colors.black.withOpacity(0.15),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 56,
                        height: 56,
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                          strokeWidth: 4,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Icon(
                        Icons.cloud_sync_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Sincronizando Fase",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Guardando información...",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
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
