import 'package:automation_app/features/mailbox/domain/entities/mailbox_config.dart';
import 'package:automation_app/features/mailbox/domain/entities/mailbox_status.dart';
import 'package:automation_app/features/mailbox/domain/entities/received_reply.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract class MailboxDatasource {
  Future<MailboxConfig> getConfig();

  Future<MailboxConfig> saveConfig(MailboxConfigUpdate update);

  Future<MailboxStatus> getStatus();

  Future<List<ReceivedReply>> getReplies({bool includeAcknowledged});

  Future<void> acknowledge(String id);
}

/// Spricht die Postfach-Endpunkte des Backends an
/// (`api/mailbox/config|status|replies`).
@Injectable(as: MailboxDatasource)
class ApiMailboxDatasource implements MailboxDatasource {
  final Dio _dio;

  ApiMailboxDatasource(this._dio);

  @override
  Future<MailboxConfig> getConfig() async {
    final response = await _dio.get('/api/mailbox/config');
    return MailboxConfig.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MailboxConfig> saveConfig(MailboxConfigUpdate update) async {
    final response = await _dio.put(
      '/api/mailbox/config',
      data: update.toJson(),
      options: Options(contentType: Headers.jsonContentType),
    );
    return MailboxConfig.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MailboxStatus> getStatus() async {
    final response = await _dio.get('/api/mailbox/status');
    return MailboxStatus.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<ReceivedReply>> getReplies({
    bool includeAcknowledged = false,
  }) async {
    final response = await _dio.get(
      '/api/mailbox/replies',
      queryParameters: {'includeAcknowledged': includeAcknowledged},
    );
    final list = response.data as List;
    return list
        .map((item) => ReceivedReply.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> acknowledge(String id) async {
    await _dio.post('/api/mailbox/replies/$id/acknowledge');
  }
}
