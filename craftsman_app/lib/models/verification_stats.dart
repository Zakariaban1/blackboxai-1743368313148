import 'package:flutter/material.dart';

class VerificationStats {
  final int totalUsers;
  final int verifiedUsers;
  final int emailVerified;
  final int manuallyVerified;
  final DateTimeRange? dateRange;

  VerificationStats({
    required this.totalUsers,
    required this.verifiedUsers,
    required this.emailVerified,
    required this.manuallyVerified,
    this.dateRange,
  });

  double get verificationRate => totalUsers > 0 
      ? verifiedUsers / totalUsers 
      : 0;

  String get dateRangeLabel {
    if (dateRange == null) return 'All Time';
    return '${_formatDate(dateRange!.start)} to ${_formatDate(dateRange!.end)}';
  }

  String get dateRangeSummary {
    if (dateRange == null) return 'All Time Data';
    
    final now = DateTime.now();
    final diff = dateRange!.end.difference(dateRange!.start).inDays;
    
    if (diff == 0) return 'Data for ${_formatDate(dateRange!.start)}';
    if (diff == 6) return 'Weekly Data (${_formatDate(dateRange!.start)} - ${_formatDate(dateRange!.end)})';
    if (diff >= 28 && diff <= 31) return 'Monthly Data (${_formatDate(dateRange!.start)} - ${_formatDate(dateRange!.end)})';
    
    return 'Data from ${_formatDate(dateRange!.start)} to ${_formatDate(dateRange!.end)}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}