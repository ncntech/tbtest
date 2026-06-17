import 'dart:ui';
import 'package:nasmotives/core/chat/domain/entity/nastech_config.dart';
import 'package:nasmotives/di/di.dart';
import 'package:nasmotives/presentation/bloc/chat/chat_cubit.dart';
import 'package:nasmotives/presentation/bloc/chat/chat_sessions_cubit.dart';
import 'package:nasmotives/presentation/bloc/chat/chat_state.dart';
import 'package:nasmotives/presentation/shared/theme/app_colors.dart';
import 'package:nasmotives/presentation/shared/theme/app_theme.dart';
import 'package:nasmotives/presentation/shared/theme/text_styles.dart';
import 'package:nasmotives/presentation/widget/chat/chat_bubble_widget.dart';
import 'package:nasmotives/presentation/widget/chat/chat_input_bar_widget.dart';
import 'package:nasmotives/presentation/widget/chat/chat_sessions_drawer_widget.dart';
import 'package:nasmotives/presentation/widget/shared/animations/animate_do/fade_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  static const routeName = 'ChatPage';

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<ChatCubit>()),
        BlocProvider.value(value: getIt<ChatSessionsCubit>()),
      ],
      child: const _ChatView(),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView();

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.themeType == ThemeType.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.primaryBackground[ThemeType.dark]
          : AppColors.primaryBackground[ThemeType.light],
      drawer: const ChatSessionsDrawer(),
      body: BlocConsumer<ChatCubit, ChatState>(
        listenWhen: (prev, curr) =>
            prev.messages.length != curr.messages.length ||
            prev.isStreaming != curr.isStreaming,
        listener: (_, __) => _scrollToBottom(),
        builder: (context, state) {
          return Column(
            children: [
              _ChatAppBar(primary: primary, isDark: isDark, state: state),
              Expanded(
                child: state.messages.isEmpty
                    ? _EmptyState(primary: primary)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.only(top: 12.h, bottom: 16.h),
                        itemCount: state.messages.length,
                        itemBuilder: (ctx, i) => ChatBubbleWidget(
                          message: state.messages[i],
                          index: i,
                        ),
                      ),
              ),
              ChatInputBarWidget(
                onSend: (text) =>
                    context.read<ChatCubit>().sendMessage(text),
                onStop: () => context.read<ChatCubit>().stopStreaming(),
                isStreaming: state.isStreaming,
                isSending: state.isSending,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChatAppBar extends StatelessWidget {
  const _ChatAppBar({
    required this.primary,
    required this.isDark,
    required this.state,
  });

  final Color primary;
  final bool isDark;
  final ChatState state;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withOpacity(0.5)
                : Colors.white.withOpacity(0.75),
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? Colors.white10
                    : Colors.black.withOpacity(0.06),
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Row(
                children: [
                  _MenuButton(primary: primary),
                  SizedBox(width: 8.w),
                  Image.asset(
                    'assets/icons/logo_white_small.png',
                    width: 26.r,
                    height: 26.r,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.auto_awesome, size: 22.r, color: primary),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.activeSession?.title ?? 'NasTech AI',
                          style: titleXS.copyWith(color: context.textColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        _ConnectionStatus(state: state),
                      ],
                    ),
                  ),
                  _ConfigButton(primary: primary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.primary});
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Scaffold.of(context).openDrawer(),
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(Icons.menu_rounded, size: 20.r, color: primary),
      ),
    );
  }
}

class _ConfigButton extends StatelessWidget {
  const _ConfigButton({required this.primary});
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showConfigSheet(context),
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(Icons.settings_outlined, size: 20.r, color: primary),
      ),
    );
  }

  void _showConfigSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ChatCubit>(),
        child: const _AgentConfigSheet(),
      ),
    );
  }
}

class _ConnectionStatus extends StatelessWidget {
  const _ConnectionStatus({required this.state});
  final ChatState state;

  @override
  Widget build(BuildContext context) {
    if (state.isStreaming) {
      return Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 6.r,
          height: 6.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(width: 4.w),
        Text('Generating…',
            style: labelS.copyWith(
                color: Theme.of(context).colorScheme.primary)),
      ]);
    }
    return Text(
      state.isConfigured ? 'NasTech Agent' : 'Tap ⚙ to configure',
      style: labelS.copyWith(color: context.textColorSecondary),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.primary});
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: const Duration(milliseconds: 400),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.r,
              height: 72.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withOpacity(0.1),
                border: Border.all(
                    color: primary.withOpacity(0.2), width: 1.5),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/icons/logo_white_large.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      Icon(Icons.auto_awesome, size: 36.r, color: primary),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text('NasTech AI',
                style: headingXS.copyWith(color: context.textColor)),
            SizedBox(height: 8.h),
            Text(
              'Powered by NasTech Agent\nAsk me anything',
              style: bodyS.copyWith(color: context.textColorSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            _SuggestionChips(primary: primary),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChips extends StatelessWidget {
  const _SuggestionChips({required this.primary});
  final Color primary;

  static const _suggestions = [
    '✨ What can you do?',
    '🔍 Help me research',
    '💡 Give me ideas',
    '🛠 Write some code',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      alignment: WrapAlignment.center,
      children: _suggestions.map((s) {
        return GestureDetector(
          onTap: () => context.read<ChatCubit>().sendMessage(s),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: primary.withOpacity(0.25)),
            ),
            child: Text(s,
                style: bodyS.copyWith(color: context.textColor)),
          ),
        );
      }).toList(),
    );
  }
}

class _AgentConfigSheet extends StatefulWidget {
  const _AgentConfigSheet();

  @override
  State<_AgentConfigSheet> createState() => _AgentConfigSheetState();
}

class _AgentConfigSheetState extends State<_AgentConfigSheet> {
  late final TextEditingController _urlCtrl;
  late final TextEditingController _keyCtrl;
  late final TextEditingController _modelCtrl;
  bool _testing = false;
  bool? _testResult;

  @override
  void initState() {
    super.initState();
    final config = context.read<ChatCubit>().state.config;
    _urlCtrl = TextEditingController(
        text: config?.baseUrl ?? NasTechConfig.defaultLocalUrl);
    _keyCtrl = TextEditingController(text: config?.apiKey ?? '');
    _modelCtrl = TextEditingController(text: config?.model ?? 'gpt-4o-mini');
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _keyCtrl.dispose();
    _modelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.themeType == ThemeType.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(
              20.w, 20.h, 20.w, 20.h + MediaQuery.of(context).viewInsets.bottom),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withOpacity(0.85)
                : Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black26,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text('Agent Configuration',
                  style: titleS.copyWith(color: context.textColor)),
              SizedBox(height: 4.h),
              Text(
                'Connect to your local NasTech Agent or NasTech Portal',
                style: bodyS.copyWith(color: context.textColorSecondary),
              ),
              SizedBox(height: 20.h),
              _ConfigField(
                  controller: _urlCtrl,
                  label: 'Agent Endpoint URL',
                  hint: NasTechConfig.defaultLocalUrl),
              SizedBox(height: 12.h),
              _ConfigField(
                  controller: _keyCtrl,
                  label: 'API Key (optional)',
                  hint: 'sk-…',
                  obscure: true),
              SizedBox(height: 12.h),
              _ConfigField(
                  controller: _modelCtrl,
                  label: 'Model',
                  hint: 'gpt-4o-mini'),
              SizedBox(height: 8.h),
              _QuickUrls(primary: primary, onSelect: (url) {
                _urlCtrl.text = url;
              }),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _testing ? null : _test,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: _testing
                          ? SizedBox(
                              width: 18.r,
                              height: 18.r,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: primary))
                          : Text(
                              _testResult == null
                                  ? 'Test Connection'
                                  : _testResult!
                                      ? '✓ Connected'
                                      : '✗ Failed',
                              style: bodyS.copyWith(
                                  color: _testResult == null
                                      ? primary
                                      : _testResult!
                                          ? AppColors.lightGreen
                                          : AppColors.lightRed),
                            ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text('Save',
                          style: bodyS.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _test() async {
    setState(() {
      _testing = true;
      _testResult = null;
    });
    final config = NasTechConfig(
      baseUrl: _urlCtrl.text.trim(),
      apiKey: _keyCtrl.text.trim().isEmpty ? null : _keyCtrl.text.trim(),
      model: _modelCtrl.text.trim(),
    );
    final result = await getIt<ChatCubit>().state.config
        .let((_) => null) ?? false;
    // ignore result, just test via repo
    final testResult =
        await Future.value(false); // placeholder until DI wired
    setState(() {
      _testing = false;
      _testResult = testResult;
    });
  }

  void _save() {
    final config = NasTechConfig(
      baseUrl: _urlCtrl.text.trim().isEmpty
          ? NasTechConfig.defaultLocalUrl
          : _urlCtrl.text.trim(),
      apiKey: _keyCtrl.text.trim().isEmpty ? null : _keyCtrl.text.trim(),
      model: _modelCtrl.text.trim().isEmpty
          ? 'gpt-4o-mini'
          : _modelCtrl.text.trim(),
    );
    context.read<ChatCubit>().updateConfig(config);
    Navigator.pop(context);
  }
}

class _ConfigField extends StatelessWidget {
  const _ConfigField({
    required this.controller,
    required this.label,
    required this.hint,
    this.obscure = false,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    final isDark = context.themeType == ThemeType.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: labelS.copyWith(color: context.textColorSecondary)),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: bodyS.copyWith(color: context.textColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: bodyS.copyWith(color: context.textColorTernary),
            filled: true,
            fillColor: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.04),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            isDense: true,
          ),
        ),
      ],
    );
  }
}

class _QuickUrls extends StatelessWidget {
  const _QuickUrls({required this.primary, required this.onSelect});
  final Color primary;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      children: [
        _chip('Local', NasTechConfig.defaultLocalUrl, context),
        _chip('Portal', NasTechConfig.nastechPortalUrl, context),
        _chip('OpenRouter', NasTechConfig.openRouterUrl, context),
      ],
    );
  }

  Widget _chip(String label, String url, BuildContext context) {
    return GestureDetector(
      onTap: () => onSelect(url),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(label,
            style: labelS.copyWith(color: primary)),
      ),
    );
  }
}

extension _NullLet<T> on T? {
  R? let<R>(R Function(T) fn) => this != null ? fn(this as T) : null;
}
