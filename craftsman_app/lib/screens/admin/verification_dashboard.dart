import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:craftsman_app/models/verification_stats.dart';
import 'package:craftsman_app/services/verification_repository.dart';

class VerificationDashboard extends ConsumerStatefulWidget {
  const VerificationDashboard({super.key});

  @override
  ConsumerState<VerificationDashboard> createState() => _VerificationDashboardState();
}

class _VerificationDashboardState extends ConsumerState<VerificationDashboard> {
  DateTimeRange? _dateRange;

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  void _setPresetRange(DateTimeRange range) {
    setState(() => _dateRange = range);
  }

  bool _isPresetActive(String label) {
    if (_dateRange == null) return label == 'All Time';
    
    final now = DateTime.now();
    switch (label) {
      case 'Today':
        return _dateRange!.start.day == now.day && 
               _dateRange!.start.month == now.month &&
               _dateRange!.start.year == now.year;
      case 'This Week':
        return _dateRange!.start == now.subtract(Duration(days: now.weekday - 1));
      case 'This Month':
        return _dateRange!.start == DateTime(now.year, now.month, 1);
      case 'Last 7 Days':
        return _dateRange!.start == now.subtract(const Duration(days: 7));
      case 'Last 30 Days':
        return _dateRange!.start == now.subtract(const Duration(days: 30));
      case 'All Time':
        return _dateRange!.start.year == 2020;
      default:
        return false;
    }
  }

  Widget _buildPresetButton(String label, VoidCallback onPressed) {
    final bool isActive = _isPresetActive(label);
    
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: isActive ? Colors.blue[50] : null,
        foregroundColor: isActive ? Colors.blue[800] : Colors.grey[800],
        side: BorderSide(
          color: isActive ? Colors.blue : Colors.grey[300]!,
          width: isActive ? 1.5 : 1.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildDateRangePresets() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          _buildPresetButton('Today', () {
            final now = DateTime.now();
            _setPresetRange(DateTimeRange(
              start: DateTime(now.year, now.month, now.day),
              end: now,
            ));
          }),
          const SizedBox(width: 8),
          _buildPresetButton('This Week', () {
            final now = DateTime.now();
            _setPresetRange(DateTimeRange(
              start: now.subtract(Duration(days: now.weekday - 1)),
              end: now,
            ));
          }),
          const SizedBox(width: 8),
          _buildPresetButton('This Month', () {
            final now = DateTime.now();
            _setPresetRange(DateTimeRange(
              start: DateTime(now.year, now.month, 1),
              end: now,
            ));
          }),
          const SizedBox(width: 8),
          _buildPresetButton('Last 7 Days', () {
            final now = DateTime.now();
            _setPresetRange(DateTimeRange(
              start: now.subtract(const Duration(days: 7)),
              end: now,
            ));
          }),
          const SizedBox(width: 8),
          _buildPresetButton('Last 30 Days', () {
            final now = DateTime.now();
            _setPresetRange(DateTimeRange(
              start: now.subtract(const Duration(days: 30)),
              end: now,
            ));
          }),
          const SizedBox(width: 8),
          _buildPresetButton('All Time', () {
            _setPresetRange(DateTimeRange(
              start: DateTime(2020),
              end: DateTime.now(),
            ));
          }),
          const SizedBox(width: 8),
          _buildCustomRangeButton(),
        ],
      ),
    );
  }

  Widget _buildCustomRangeButton() {
    return OutlinedButton.icon(
      onPressed: () => _selectDateRange(context),
      icon: const Icon(Icons.calendar_today, size: 16),
      label: const Text('Custom Range'),
      style: OutlinedButton.styleFrom(
        foregroundColor: _dateRange != null && !_isAnyPresetActive() 
            ? Colors.blue[800] 
            : Colors.grey[800],
        side: BorderSide(
          color: _dateRange != null && !_isAnyPresetActive()
              ? Colors.blue
              : Colors.grey[300]!,
          width: _dateRange != null && !_isAnyPresetActive() ? 1.5 : 1.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  bool _isAnyPresetActive() {
    return _isPresetActive('Today') ||
           _isPresetActive('This Week') ||
           _isPresetActive('This Month') ||
           _isPresetActive('Last 7 Days') ||
           _isPresetActive('Last 30 Days') ||
           _isPresetActive('All Time');
  }

  Widget _buildDateRangeSummary(AsyncValue<VerificationStats> statsAsync) {
    return statsAsync.when(
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
      data: (stats) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            stats.dateRangeSummary,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  Widget _buildCustomRangeIndicator() {
    if (_dateRange == null || _isAnyPresetActive()) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Chip(
            label: Text(
              '${_dateRange!.start.toString().substring(0, 10)} to ${_dateRange!.end.toString().substring(0, 10)}',
            ),
            deleteIcon: const Icon(Icons.close, size: 18),
            onDeleted: () => setState(() => _dateRange = null),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(verificationStatsProvider(_dateRange));
    final logsAsync = ref.watch(verificationLogsProvider(_dateRange));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDateRange(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateRangePresets(),
          _buildCustomRangeIndicator(),
          _buildDateRangeSummary(statsAsync),
          Expanded(
            child: statsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (stats) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildStatsCards(context, stats),
                      const SizedBox(height: 24),
                      _buildVerificationChart(stats),
                      const SizedBox(height: 24),
                      _buildVerificationLogs(logsAsync),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, VerificationStats stats) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
          context,
          'Total Users',
          stats.totalUsers.toString(),
          Colors.blue,
        ),
        _buildStatCard(
          context,
          'Verified Users',
          stats.verifiedUsers.toString(),
          Colors.green,
        ),
        _buildStatCard(
          context,
          'Verification Rate',
          '${(stats.verificationRate * 100).toStringAsFixed(1)}%',
          Colors.purple,
        ),
        _buildStatCard(
          context,
          'Manual Verifications',
          stats.manuallyVerified.toString(),
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, 
    String title, 
    String value,
    Color color,
  ) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationChart(VerificationStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verification Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SfCircularChart(
                series: <CircularSeries>[
                  PieSeries<Map<String, dynamic>, String>(
                    dataSource: [
                      {'type': 'Email Verified', 'value': stats.emailVerified},
                      {'type': 'Manual Verified', 'value': stats.manuallyVerified},
                      {'type': 'Unverified', 'value': stats.totalUsers - stats.verifiedUsers},
                    ],
                    xValueMapper: (data, _) => data['type'],
                    yValueMapper: (data, _) => data['value'],
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    enableTooltip: true,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationLogs(AsyncValue<List<VerificationLog>> logsAsync) {
    return logsAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
      data: (logs) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recent Verification Activity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return ListTile(
                      leading: Icon(
                        log.type == 'manual' ? Icons.admin_panel_settings : Icons.email,
                        color: log.type == 'manual' ? Colors.orange : Colors.green,
                      ),
                      title: Text(log.type == 'manual' 
                          ? 'Manually verified by admin' 
                          : 'Email verification sent'),
                      subtitle: Text(log.timestamp.toLocal().toString()),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}