import 'package:nasmotives/core/misc/domain/entity/unique_id.dart';
import 'package:nasmotives/core/misc/domain/use_case/initial_route_use_case.dart';
import 'package:nasmotives/presentation/bloc/user_preferences/user_preferences_cubit.dart';
import 'package:nasmotives/presentation/shared/constants/app/app_constants.dart';
import 'package:nasmotives/presentation/shared/router/root_router.dart';
import 'package:nasmotives/presentation/shared/theme/app_theme.dart';
import 'package:nasmotives/presentation/shared/utils/redirect_util.dart';
import 'package:nasmotives/presentation/widget/shared/animations/constants/common_animation_values.dart';
import 'package:nasmotives/presentation/widget/shared/snackbars/core_global_snackbar_widget.dart';
import 'package:nasmotives/di/di.dart';
import 'package:nasmotives/presentation/shared/localization/locale_keys.g.dart';
import 'package:nasmotives/presentation/page/app/app_wrapper.dart';
import 'package:nasmotives/presentation/page/app/deeplinks_listener.dart';
import 'package:nasmotives/presentation/page/app/root_bloc_providers.dart';
import 'package:nasmotives/presentation/page/app/root_bloc_listeners.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroine/heroine.dart';

class NasMotivesApp extends StatelessWidget {
  const NasMotivesApp({super.key});

  static const designSize = Size(390.0, 844.0);

  @override
  Widget build(BuildContext context) {
    return RootBlocProviders(
      child: RootBlocListeners(
        child: ScreenUtilInit(
          designSize: NasMotivesApp.designSize,
          child: Builder(
            builder: (context) {
              final themeColorationId = context.select<UserPreferencesCubit, UniqueId>((cubit) => cubit.state.preferences.theme.colorationId);
              final themeColoration = AppConstants.config.themeColorations.firstWhere((coloration) => coloration.id == themeColorationId);

              return MaterialApp(
                restorationScopeId: 'app',
                debugShowCheckedModeBanner: false,
                locale: EasyLocalization.of(context)!.locale,
                localizationsDelegates: EasyLocalization.of(context)!.delegates,
                supportedLocales: EasyLocalization.of(context)!.supportedLocales,
                onGenerateTitle: (context) => context.tr(LocaleKeys.appTitle),
                themeAnimationDuration: CommonAnimationValues.themeChangeAnimationDuration,
                themeAnimationCurve: CommonAnimationValues.themeChangeAnimationCurve,
                theme: AppTheme.fromType(ThemeType.light).themeData(themeColoration),
                darkTheme: AppTheme.fromType(ThemeType.dark).themeData(themeColoration),
                themeMode: context.select<UserPreferencesCubit, ThemeMode>((cubit) => cubit.state.preferences.theme.mode),
                initialRoute: getIt<InitialRouteUseCase>().retrieve(),
                navigatorKey: getIt<RootRouterData>().key,
                onGenerateRoute: rootRouteFactory,
                builder: (context, child) => MediaQuery(
                  /// Setting font does not change with system font size
                  data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
                  child: GlobalSnackbarInjector(
                    child: NasMotivesAppWrapper(
                      child: DeeplinksListener(
                        onRedirect: getIt<RedirectUtil>().execute,
                        child: child!,
                      ),
                    ),
                  ),
                ),
                navigatorObservers: [HeroineController()],
              );
            },
          ),
        ),
      ),
    );
  }
}
