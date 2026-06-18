import 'package:dartz/dartz.dart';
import 'package:nasmotives/core/analytics/domain/repo/analytics_repo.dart';
import 'package:nasmotives/core/subscriptions/domain/entity/subscriptions_failure.dart';
import 'package:nasmotives/core/subscriptions/domain/repo/subscriptions_repo.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class RestoreSubscriptionUseCase {
  final SubscriptionsRepo _subscriptionsRepo;
  final AnalyticsRepo _analyticsRepo;

  const RestoreSubscriptionUseCase(
    this._subscriptionsRepo,
    this._analyticsRepo,
  );

  Future<Either<SubscriptionsFailure, Unit>> execute() async {
    final failureOrSuccess = await _subscriptionsRepo.restore();
    if (failureOrSuccess.isRight()) {
      _analyticsRepo.logSubscriptionRestore();
    }
    return failureOrSuccess;
  }
}