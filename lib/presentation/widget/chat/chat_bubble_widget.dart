import 'dart:ui';
import 'package:nasmotives/core/chat/domain/entity/chat_message.dart';
import 'package:nasmotives/presentation/shared/theme/app_colors.dart';
import 'package:nasmotives/presentation/shared/theme/app_theme.dart';
import 'package:nasmotives/presentation/shared/theme/text_styles.dart';
import 'package:nasmotives/presentation/widget/shared/animations/animate_do/fade_in_up.dart';
import 'package:nasmotives/presentation/widget/chat/typing_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatBubbleWidget extends StatelessWidget {
  const ChatBubbleWidget({
    super.key,
    required this.message,
    required this.index,
  });

  final ChatMessage message;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final isStreaming = message.isStreaming;
    final isError = message.isError;

    return FadeInUp(
      duration: const Duration(milliseconds: 280),
      delay: Duration(milliseconds: index == 0 ? 0 : 40),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        child: Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser) ...[
              _AgentAvatar(),
              SizedBox(width: 8.w),
            ],
            Flexible(
              child: _BubbleBody(
                message: message,
                isUser: isUser,
                isStreaming: isStreaming,
                isError: isError,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgentAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30.r,
      height: 30.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/icons/logo_white_small.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(
            Icons.auto_awesome,
            size: 16.r,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _BubbleBody extends StatelessWidget {
  const _BubbleBody({
    required this.message,
    required this.isUser,
    required this.isStreaming,
    required this.isError,
  });

  final ChatMessage message;
  final bool isUser;
  final bool isStreaming;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = context.themeType == ThemeType.dark;

    final bubbleColor = isUser
        ? primary
        : isError
            ? AppColors.lightRed.withOpacity(0.15)
            : (isDark
                ? AppColors.primaryContainer[ThemeType.dark]!
                : AppColors.primaryContainer[ThemeType.light]!);

    final textColor = isUser
        ? Colors.white
        : isError
            ? AppColors.lightRed
            : context.textColor;

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.r),
        topRight: Radius.circular(20.r),
        bottomLeft: Radius.circular(isUser ? 20.r : 4.r),
        bottomRight: Radius.circular(isUser ? 4.r : 20.r),
      ),
      child: BackdropFilter(
        filter: isUser
            ? ImageFilter.blur(sigmaX: 0, sigmaY: 0)
            : ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
              bottomLeft: Radius.circular(isUser ? 20.r : 4.r),
              bottomRight: Radius.circular(isUser ? 4.r : 20.r),
            ),
            border: isUser
                ? null
                : Border.all(
                    color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
                    width: 0.5,
                  ),
          ),
          child: isStreaming && message.content.isEmpty
              ? TypingIndicatorWidget(color: textColor)
              : Text(
                  message.content,
                  style: bodyM.copyWith(color: textColor, height: 1.5),
                ),
        ),
      ),
    );
  }
}
