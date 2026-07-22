import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logistics_pro/core/router/app_router.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _indexFromLocation(String location){
    if(location.contains(AppRouter.createOrden)) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currenIndex = _indexFromLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4)
            )
          ]
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navigatorItem(
                  icon: Icons.people_alt_rounded,
                  label: 'Personal',
                  isSelected: currenIndex == 0,
                  onTap: () => context.go(AppRouter.adminHome),
                ),
                _navigatorItem(
                  icon: Icons.my_library_books,
                  label: 'Orders',
                  isSelected: currenIndex == 1,
                  onTap: () => context.go(AppRouter.createOrden),
                )

              ],
            ),
          )
        ),
      ),
    );
  }
}

Widget _navigatorItem({
  required IconData icon,
  required String label,
  required bool isSelected,
  required VoidCallback onTap,
}){
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
        borderRadius: BorderRadius.circular(12)
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            size: 20,
          ),
          if(isSelected)...[
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13
              ),
            )
          ]
        ],
      ),
    ),
  );
}