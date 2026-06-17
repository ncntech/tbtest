import 'package:dartz/dartz.dart';
import 'package:nasmotives/core/misc/domain/entity/unique_id.dart';
import 'package:nasmotives/core/profile/domain/entity/profile.dart';
import 'package:nasmotives/core/statistics/domain/entity/user_statistics.dart';
import 'package:nasmotives/core/subscriptions/domain/entity/user_subscription.dart';
import 'package:nasmotives/core/user_preferences/domain/entity/user_preferences.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_result.freezed.dart';

@freezed
abstract class LoginResult with _$LoginResult {
  const factory LoginResult({
    required String userId,
    required Profile profile,
    required UserPreferences preferences,
    required UserStatistics statistics,
    required Option<UserSubscription> activeSubscription,
    required List<UniqueId> archivedFactIds,
  }) = _LoginResult;
}
