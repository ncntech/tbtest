import 'package:dartz/dartz.dart';
import 'package:nasmotives/core/analytics/domain/repo/analytics_repo.dart';
import 'package:nasmotives/core/subscriptions/domain/entity/premium_packages.dart';
import 'package:nasmotives/core/subscriptions/domain/entity/subscriptions_failure.dart';
import 'package:nasmotives/core/subscriptions/domain/repo/subscriptions_repo.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class PurchaseSubscriptionUseCase {
  final SubscriptionsRepo _subscriptionsRepo;
  final AnalyticsRepo _analyticsRepo;

  const PurchaseSubscriptionUseCase(
    this._subscriptionsRepo,
    this._analyticsRepo,
  );

  Future<Either<SubscriptionsFailure, Unit>> execute(
    PremiumPackage package,
  ) async {
    final failureOrSuccess = await _subscriptionsRepo.purchase(package);
    if (failureOrSuccess.isRight()) {
      _analyticsRepo.logSubscriptionPurchase(package);
    }
    return failureOrSuccess;
  }
}