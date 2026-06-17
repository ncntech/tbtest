import 'dart:ui';
import 'package:nasmotives/presentation/shared/theme/app_colors.dart';
import 'package:nasmotives/presentation/shared/theme/app_theme.dart';
import 'package:nasmotives/presentation/shared/theme/text_styles.dart';
import 'package:nasmotives/presentation/widget/shared/animations/tap_animations/bounce_tap_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatInputBarWidget extends StatefulWidget {
  const ChatInputBarWidget({
    super.key,
    required this.onSend,
    required this.onStop,
    required this.isStreaming,
    required this.isSending,
  });

  final ValueChanged<String> onSend;
  final VoidCallback onStop;
  final bool isStreaming;
  final bool isSending;

  @override
  State<ChatInputBarWidget> createState() => _ChatInputBarWidgetState();
}

class _ChatInputBarWidgetState extends State<ChatInputBarWidget>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  late final AnimationController _sendAnimController;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _sendAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
        if (hasText) {
          _sendAnimController.forward();
        } else {
          _sendAnimController.reverse();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _sendAnimController.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    setState(() => _hasText = false);
    _sendAnimController.reverse();
    widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.themeType == ThemeType.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withOpacity(0.6)
                : Colors.white.withOpacity(0.8),
            border: Border(
              top: BorderSide(
                color: isDark ? Colors.white10 : Colors.black.withOpacity(0.07),
              ),
            ),
          ),
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h + MediaQuery.of(context).padding.bottom),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  constraints: BoxConstraints(maxHeight: 120.h),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.07)
                        : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(
                      color: _focusNode.hasFocus
                          ? primary.withOpacity(0.4)
                          : (isDark ? Colors.white12 : Colors.black12),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    maxLines: null,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    style: bodyM.copyWith(color: context.textColor),
                    decoration: InputDecoration(
                      hintText: 'Message NasTech AI…',
                      hintStyle: bodyM.copyWith(
                        color: context.textColorTernary,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              _ActionButton(
                isStreaming: widget.isStreaming || widget.isSending,
                hasText: _hasText,
                primary: primary,
                onSend: _submit,
                onStop: widget.onStop,
                sendAnimController: _sendAnimController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.isStreaming,
    required this.hasText,
    required this.primary,
    required this.onSend,
    required this.onStop,
    required this.sendAnimController,
  });

  final bool isStreaming;
  final bool hasText;
  final Color primary;
  final VoidCallback onSend;
  final VoidCallback onStop;
  final AnimationController sendAnimController;

  @override
  Widget build(BuildContext context) {
    return BounceTapAnimation(
      onTap: isStreaming ? onStop : (hasText ? onSend : null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        width: 44.r,
        height: 44.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isStreaming
              ? AppColors.lightRed
              : hasText
                  ? primary
                  : primary.withOpacity(0.3),
          boxShadow: (isStreaming || hasText)
              ? [
                  BoxShadow(
                    color: (isStreaming ? AppColors.lightRed : primary)
                        .withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: isStreaming
              ? Icon(Icons.stop_rounded, color: Colors.white, size: 20.r, key: const ValueKey('stop'))
              : Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20.r, key: const ValueKey('send')),
        ),
      ),
    );
  }
}
