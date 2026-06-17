import 'package:nasmotives/core/network/data/model/server_response.dart';
import 'package:nasmotives/core/statistics/data/model/user_statistics_dto.dart';
import 'package:nasmotives/core/statistics/data/source/remote/statistics_api.dart';
import 'package:nasmotives/core/statistics/domain/source/statistics_remote_source.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: StatisticsRemoteSource)
class StatisticsRemoteSourceImpl implements StatisticsRemoteSource {
  final StatisticsApi _api;

  const StatisticsRemoteSourceImpl(this._api);

  @override
  Future<UserStatisticsDto> getStatistics() async {
    final response = await _api.getStatistics();
    return response.parseOrThrow(UserStatisticsDto.fromJson);
  }
}
