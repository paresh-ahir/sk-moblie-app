import 'package:saleskido/core/constants/api_constants.dart';
import 'package:saleskido/core/network/api_client.dart';

class WhatsappService {
  WhatsappService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<Map<String, dynamic>> activeChats(
    String companyId, {
    Map<String, dynamic>? body,
  }) async {
    final res = await _client.post(
      ApiConstants.activeChats(companyId),
      data: body ?? {},
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> requestingChats(
    String companyId, {
    Map<String, dynamic>? body,
  }) async {
    final res = await _client.post(
      ApiConstants.requestingChats(companyId),
      data: body ?? {},
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> getMessages(
    String userId, {
    required Map<String, dynamic> body,
  }) async {
    final res = await _client.post(
      ApiConstants.getMessages(userId),
      data: body,
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> sendMessage(Map<String, dynamic> body) async {
    final res = await _client.post(ApiConstants.sendMessages, data: body);
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> pinMessage(
    String userId,
    Map<String, dynamic> body,
  ) async {
    final res = await _client.post(
      ApiConstants.pinMessage(userId),
      data: body,
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> unpinMessage(
    String userId,
    Map<String, dynamic> body,
  ) async {
    final res = await _client.post(
      ApiConstants.unpinMessage(userId),
      data: body,
    );
    return Map<String, dynamic>.from(res.data as Map);
  }
}
