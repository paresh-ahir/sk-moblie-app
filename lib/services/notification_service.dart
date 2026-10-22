import 'package:saleskido/core/constants/api_constants.dart';
import 'package:saleskido/core/network/api_client.dart';

class NotificationService {
  NotificationService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<Map<String, dynamic>> getNotifications({
    String? userId,
    String? companyId,
  }) async {
    final res = await _client.get(
      ApiConstants.notifications,
      query: {
        if (userId != null) 'userId': userId,
        if (companyId != null) 'company_id': companyId,
      },
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> clearAll(Map<String, dynamic> body) async {
    final res = await _client.post(
      ApiConstants.clearNotifications,
      data: body,
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> markAsRead(String id) async {
    final res = await _client.post(ApiConstants.markNotificationRead(id));
    return Map<String, dynamic>.from(res.data as Map);
  }
}
