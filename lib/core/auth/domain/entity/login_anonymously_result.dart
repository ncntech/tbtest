import 'package:nasmotives/core/profile/domain/entity/profile.dart';
import 'package:nasmotives/core/statistics/domain/entity/user_statistics.dart';
import 'package:nasmotives/core/user_preferences/domain/entity/user_preferences.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_anonymously_result.freezed.dart';

@freezed
abstract class LoginAnonymouslyResult with _$LoginAnonymouslyResult {
  const factory LoginAnonymouslyResult({
    required String userId,
    required Profile profile,
    required UserPreferences preferences,
    required UserStatistics statistics,
  }) = _LoginAnonymouslyResult;
}
