import 'package:dartz/dartz.dart';
import 'package:nasmotives/core/misc/domain/entity/unique_id.dart';
import 'package:nasmotives/core/profile/data/model/profile_dto.dart';
import 'package:nasmotives/core/auth/domain/entity/login_result.dart';
import 'package:nasmotives/core/statistics/data/model/user_statistics_dto.dart';
import 'package:nasmotives/core/subscriptions/data/model/get_user_subscription_response_dto.dart';
import 'package:nasmotives/core/user_preferences/data/model/user_preferences_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class LoginResponseDto {
  @JsonKey(name: 'access_token') final String accessToken;
  @JsonKey(name: 'user_id') final String userId;
  final ProfileDto profile;
  final UserPreferencesDto preferences;
  final UserStatisticsDto statistics;
  final GetUserSubscriptionResponseDto subscription;
  @JsonKey(name: 'archived_fact_ids') final List<int> archivedFactIds;

  const LoginResponseDto({
    required this.accessToken,
    required this.userId,
    required this.profile,
    required this.preferences,
    required this.statistics,
    required this.subscription,
    required this.archivedFactIds,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseDtoFromJson(json);

  LoginResult toResult() => LoginResult(
        userId: userId,
        profile: profile.toDomain(),
        preferences: preferences.toDomain(),
        statistics: statistics.toDomain(),
        activeSubscription: optionOf(subscription.active?.toDomain()),
        archivedFactIds: archivedFactIds.map(UniqueId.fromValue).toList(),
      );
}
