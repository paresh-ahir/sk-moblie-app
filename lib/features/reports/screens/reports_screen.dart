import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleskido/core/theme/app_colors.dart';
import 'package:saleskido/features/auth/providers/auth_provider.dart';
import 'package:saleskido/services/dashboard_service.dart';
import 'package:saleskido/shared/widgets/sk_button.dart';
import 'package:saleskido/shared/widgets/stat_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _dateFilter = 'last_7_days';
  bool _loading = false;
  bool _searched = false;
  Map<String, dynamic> _stats = {};
  final List<double> _line = [1, 2, 1.5, 3, 2.5, 4, 3.5];

  final _dateOptions = const {
    'today': 'Today',
    'yesterday': 'Yesterday',
    'last_7_days': 'Last 7 days',
    'last_30_days': 'Last 30 days',
    'last_90_days': 'Last 90 days',
  };

  Future<void> _search() async {
    final auth = context.read<AuthProvider>();
    setState(() => _loading = true);
    try {
      final res = await DashboardService().overAllTotal(
        companyId: auth.companyId,
        createBy: auth.userId,
        dateWiseFilter: _dateFilter,
      );
      Map<String, dynamic> stats = {};
      if (res['data'] is Map) {
        stats = Map<String, dynamic>.from(res['data'] as Map);
      }
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _searched = true;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _searched = true;
        _loading = false;
      });
    }
  }

  String _num(String key) {
    dynamic v = _stats[key];
    if (v is Map) v = v['count'] ?? v['total'];
    return (v ?? 0).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Basic Information',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _dateFilter,
            decoration: const InputDecoration(labelText: 'Select Date'),
            items: _dateOptions.entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (v) => setState(() => _dateFilter = v ?? 'last_7_days'),
          ),
          const SizedBox(height: 20),
          SkButton(label: 'Search Report', loading: _loading, onPressed: _search),
          if (_searched) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Leads',
                    value: _num('totalLeads'),
                    percent: '+7.2%',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    title: 'Quotation',
                    value: _num('totalQuotation'),
                    percent: '+2.1%',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: LineChart(
                LineChartData(
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        _line.length,
                        (i) => FlSpot(i.toDouble(), _line[i]),
                      ),
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Overall Summary',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('Total Generated Quotation: ${_num('totalQuotation')}'),
            Text('Total Leads: ${_num('totalLeads')}'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SkButton(label: 'Download', onPressed: () {}),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SkButton(
                    label: 'Share',
                    outlined: true,
                    onPressed: () => _showShare(context),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showShare(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  'Share Report',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: AppColors.primary,
                    tabs: [Tab(text: 'WhatsApp'), Tab(text: 'Email')],
                  ),
                  SizedBox(
                    height: 140,
                    child: TabBarView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Enter Mobile Number',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Enter Email ID',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SkButton(
              label: 'Submit',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
