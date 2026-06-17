import 'package:nasmotives/core/network/data/model/connection_exception.dart';
import 'package:nasmotives/core/statistics/data/model/user_statistics_dto.dart';

abstract class StatisticsRemoteSource {
  /// Throws:
  /// [AuthorizationException]
  /// [ConnectionException]
  /// [GenericException]
  Future<UserStatisticsDto> getStatistics();
}
