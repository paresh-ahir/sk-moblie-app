import 'package:saleskido/core/constants/api_constants.dart';
import 'package:saleskido/core/network/api_client.dart';

class QuotationService {
  QuotationService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<Map<String, dynamic>> list({
    required String companyId,
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final res = await _client.post(
      ApiConstants.quotationList,
      data: {
        'company_id': companyId,
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> getOne(String id) async {
    final res = await _client.post(
      ApiConstants.quotationGetOne,
      data: {'_id': id},
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> addAndEdit(Map<String, dynamic> payload) async {
    final res = await _client.post(
      ApiConstants.quotationAddEdit,
      data: payload,
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> delete(List<String> ids) async {
    final res = await _client.patch(
      ApiConstants.quotationDelete,
      data: {'ids': ids},
    );
    return Map<String, dynamic>.from(res.data as Map);
  }
}
