import 'dart:ui';
import 'package:nasmotives/core/chat/domain/entity/chat_session.dart';
import 'package:nasmotives/presentation/bloc/chat/chat_cubit.dart';
import 'package:nasmotives/presentation/bloc/chat/chat_sessions_cubit.dart';
import 'package:nasmotives/presentation/bloc/chat/chat_sessions_state.dart';
import 'package:nasmotives/presentation/shared/theme/app_colors.dart';
import 'package:nasmotives/presentation/shared/theme/app_theme.dart';
import 'package:nasmotives/presentation/shared/theme/text_styles.dart';
import 'package:nasmotives/presentation/widget/shared/animations/tap_animations/bounce_tap_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatSessionsDrawer extends StatelessWidget {
  const ChatSessionsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.themeType == ThemeType.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: 280.w,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withOpacity(0.75)
                : Colors.white.withOpacity(0.88),
            border: Border(
              right: BorderSide(
                color: isDark ? Colors.white10 : Colors.black.withOpacity(0.08),
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icons/logo_white_small.png',
                        width: 28.r,
                        height: 28.r,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.auto_awesome,
                          size: 24.r,
                          color: primary,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text('NasMotives',
                          style: titleS.copyWith(color: context.textColor)),
                      const Spacer(),
                      BounceTapAnimation(
                        onTap: () {
                          context.read<ChatCubit>().startNewSession();
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(Icons.add_rounded,
                              size: 18.r, color: primary),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: isDark ? Colors.white10 : Colors.black.withOpacity(0.07),
                  height: 1,
                ),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text('Conversations',
                      style: labelS.copyWith(
                          color: context.textColorSecondary)),
                ),
                SizedBox(height: 8.h),
                Expanded(
                  child: BlocBuilder<ChatSessionsCubit, ChatSessionsState>(
                    builder: (context, state) {
                      if (state.sessions.isEmpty) {
                        return Center(
                          child: Text(
                            'No conversations yet',
                            style: bodyS.copyWith(
                                color: context.textColorTernary),
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        itemCount: state.sessions.length,
                        itemBuilder: (ctx, i) => _SessionTile(
                          session: state.sessions[i],
                          onTap: () {
                            context
                                .read<ChatCubit>()
                                .loadSession(state.sessions[i]);
                            Navigator.pop(context);
                          },
                          onDelete: () {
                            context
                                .read<ChatSessionsCubit>()
                                .deleteSession(state.sessions[i].id.value.toString());
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.session,
    required this.onTap,
    required this.onDelete,
  });

  final ChatSession session;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return BounceTapAnimation(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: context.themeType == ThemeType.dark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.03),
        ),
        child: Row(
          children: [
            Icon(Icons.chat_bubble_outline_rounded,
                size: 16.r, color: context.textColorSecondary),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.title,
                    style: bodyS.copyWith(
                        color: context.textColor,
                        fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (session.lastMessage != null)
                    Text(
                      session.lastMessage!.content,
                      style: labelS.copyWith(color: context.textColorTernary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onDelete,
              child: Padding(
                padding: EdgeInsets.all(4.r),
                child: Icon(Icons.close_rounded,
                    size: 14.r, color: context.textColorTernary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
