import 'package:nasmotives/core/network/data/model/server_response.dart';
import 'package:nasmotives/core/network/domain/repo/request_executor.dart';
import 'package:nasmotives/di/server_module.dart';
import 'package:injectable/injectable.dart';

abstract class SubscriptionsEndpoints {
  static const _base = '/member';

  static const subscription = '$_base/subscription';
}

@LazySingleton()
class SubscriptionsApi {
  final RequestExecutor _client;

  const SubscriptionsApi(@API this._client);

  /// Throws:
  /// [AuthorizationException]
  /// [ConnectionException]
  /// [GenericException]
  /// 
  Future<ServerResponse> getSubscription() {
    return _client.get(SubscriptionsEndpoints.subscription);
  }
}