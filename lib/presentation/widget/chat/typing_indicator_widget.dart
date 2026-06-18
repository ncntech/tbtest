import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TypingIndicatorWidget extends StatefulWidget {
  const TypingIndicatorWidget({super.key, required this.color});

  final Color color;

  @override
  State<TypingIndicatorWidget> createState() => _TypingIndicatorWidgetState();
}

class _TypingIndicatorWidgetState extends State<TypingIndicatorWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      )..repeat(reverse: true, period: Duration(milliseconds: 800 + i * 160));
    });

    _animations = _controllers.map((c) {
      return Tween<double>(begin: 0, end: -5).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut),
      );
    }).toList();

    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 160), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20.h,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          return AnimatedBuilder(
            animation: _animations[i],
            builder: (_, __) => Transform.translate(
              offset: Offset(0, _animations[i].value),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: Container(
                  width: 6.r,
                  height: 6.r,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
