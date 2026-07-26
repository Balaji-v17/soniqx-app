import 'package:flutter/material.dart';

class SkeletonPulse extends StatefulWidget {
  final Widget child;
  
  const SkeletonPulse({super.key, required this.child});

  @override
  State<SkeletonPulse> createState() => _SkeletonPulseState();
}

class _SkeletonPulseState extends State<SkeletonPulse> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.3, end: 0.8).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: widget.child,
    );
  }
}

class SkeletonSongTile extends StatelessWidget {
  const SkeletonSongTile({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = colorScheme.onBackground.withOpacity(0.1);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 54, 
        height: 54,
        decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(8)),
      ),
      title: Container(
        width: double.infinity, 
        height: 16,
        margin: const EdgeInsets.only(right: 60, bottom: 8),
        decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(4)),
      ),
      subtitle: Container(
        width: 100, 
        height: 12,
        margin: const EdgeInsets.only(right: 140),
        decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(4)),
      ),
      trailing: Container(
        width: 24, 
        height: 24,
        decoration: BoxDecoration(color: baseColor, shape: BoxShape.circle),
      ),
    );
  }
}