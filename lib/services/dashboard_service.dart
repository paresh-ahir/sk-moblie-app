import 'package:saleskido/core/constants/api_constants.dart';
import 'package:saleskido/core/network/api_client.dart';

class DashboardService {
  DashboardService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<Map<String, dynamic>> overAllTotal({
    required String companyId,
    String? createBy,
    String dateWiseFilter = 'last_7_days',
  }) async {
    final res = await _client.post(
      ApiConstants.overAllTotal,
      data: {
        'company_id': companyId,
        if (createBy != null) 'createBy': createBy,
        'DateWiseFilter': dateWiseFilter,
      },
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> leadGraph({
    required String companyId,
    String? createBy,
  }) async {
    final res = await _client.post(
      ApiConstants.leadGraph,
      data: {
        'company_id': companyId,
        if (createBy != null) 'createBy': createBy,
      },
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> leadList({
    required String companyId,
    String? createBy,
    int page = 1,
    int limit = 10,
  }) async {
    final res = await _client.post(
      ApiConstants.leadListDash,
      data: {
        'company_id': companyId,
        if (createBy != null) 'createBy': createBy,
        'page': page,
        'limit': limit,
      },
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> emailSummary({
    required String companyId,
  }) async {
    final res = await _client.post(
      ApiConstants.emailSummary,
      data: {'company_id': companyId},
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> whatsAppGraph({
    required String companyId,
  }) async {
    final res = await _client.post(
      ApiConstants.whatsAppGraph,
      data: {'company_id': companyId},
    );
    return Map<String, dynamic>.from(res.data as Map);
  }
}
