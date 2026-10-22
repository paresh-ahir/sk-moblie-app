import 'package:saleskido/core/constants/api_constants.dart';
import 'package:saleskido/core/network/api_client.dart';

class LeadService {
  LeadService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<Map<String, dynamic>> list({
    required String companyId,
    String? search,
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filters,
  }) async {
    final res = await _client.post(
      ApiConstants.leadList,
      data: {
        'company_id': companyId,
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        ...?filters,
      },
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> find(String leadId) async {
    final res = await _client.post(
      ApiConstants.leadFind,
      data: {'_id': leadId},
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> payload) async {
    final res = await _client.post(ApiConstants.leadCreate, data: payload);
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> update(Map<String, dynamic> payload) async {
    final res = await _client.put(ApiConstants.leadUpdate, data: payload);
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> delete(List<String> ids) async {
    final res = await _client.patch(
      ApiConstants.leadDelete,
      data: {'ids': ids},
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> taskList(Map<String, dynamic> payload) async {
    final res = await _client.post(ApiConstants.leadTaskList, data: payload);
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> addTask(Map<String, dynamic> payload) async {
    final res = await _client.post(ApiConstants.leadAddTask, data: payload);
    return Map<String, dynamic>.from(res.data as Map);
  }
}
