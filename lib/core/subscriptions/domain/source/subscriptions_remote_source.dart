import 'package:nasmotives/core/network/data/model/connection_exception.dart';
import 'package:nasmotives/core/subscriptions/data/model/user_subscription_dto.dart';

abstract class SubscriptionsRemoteSource {
  /// Throws:
  /// [AuthorizationException]
  /// [ConnectionException]
  /// [GenericException]
  Future<UserSubscriptionDto?> getSubscription();
}
