// File: lib/presentation/screens/technician/performance_dashboard.dart
// Purpose: Dashboard showing technician performance insights, earnings, and statistics.

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../widgets/wrappers.dart';

class PerformanceDashboard extends StatefulWidget {
  final String technicianId;

  const PerformanceDashboard({super.key, required this.technicianId});

  @override
  State<PerformanceDashboard> createState() => _PerformanceDashboardState();
}

class _PerformanceDashboardState extends State<PerformanceDashboard> {
  bool _isLoading = true;
  late _PerformanceData _data;
  DateTimeRange? _selectedDateRange;
  String _selectedRangeLabel = 'thisMonth';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Mock data for demonstration
    await Future.delayed(const Duration(milliseconds: 500));

    _data = _PerformanceData(
      totalEarnings: 28500,
      currentMonthEarnings: 4200,
      lastMonthEarnings: 3800,
      completedJobs: 127,
      rating: 4.8,
      reviewCount: 89,
      acceptanceRate: 0.92,
      completionRate: 0.98,
      avgResponseTime: 8, // minutes
      topCategory: 'Plumbing',
      monthlyEarnings: {
        'Jul': 3200,
        'Aug': 3500,
        'Sep': 4100,
        'Oct': 3800,
        'Nov': 3800,
        'Dec': 4200,
      },
      categoryEarnings: {
        'Plumbing': 12000,
        'Electrical': 8500,
        'AC Repair': 5000,
        'General': 3000,
      },
      recentReviews: [
        _Review(
          customerName: 'Ahmed M.',
          rating: 5,
          comment: 'Excellent work, very professional!',
          date: DateTime.now().subtract(const Duration(days: 2)),
        ),
        _Review(
          customerName: 'Sara K.',
          rating: 5,
          comment: 'Fixed the issue quickly',
          date: DateTime.now().subtract(const Duration(days: 5)),
        ),
        _Review(
          customerName: 'Mohamed A.',
          rating: 4,
          comment: 'Good service',
          date: DateTime.now().subtract(const Duration(days: 8)),
        ),
      ],
    );

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showDateRangeFilter() {
    final theme = Theme.of(context);
    final now = DateTime.now();

    final presets = {
      'thisWeek': DateTimeRange(
        start: now.subtract(Duration(days: now.weekday - 1)),
        end: now,
      ),
      'thisMonth': DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: now,
      ),
      'last3Months': DateTimeRange(
        start: DateTime(now.year, now.month - 2, 1),
        end: now,
      ),
      'last6Months': DateTimeRange(
        start: DateTime(now.year, now.month - 5, 1),
        end: now,
      ),
      'thisYear': DateTimeRange(start: DateTime(now.year, 1, 1), end: now),
    };

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'selectDateRange'.tr(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ...presets.entries.map((entry) {
                final isSelected = _selectedRangeLabel == entry.key;
                return ListTile(
                  leading: Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: isSelected ? theme.colorScheme.primary : Colors.grey,
                  ),
                  title: Text(
                    entry.key.tr(),
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedRangeLabel = entry.key;
                      _selectedDateRange = entry.value;
                    });
                    Navigator.pop(context);
                    // Reload data with new filter
                    _loadData();
                  },
                );
              }),
              const Divider(),
              ListTile(
                leading: Icon(
                  _selectedRangeLabel == 'custom'
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: _selectedRangeLabel == 'custom'
                      ? theme.colorScheme.primary
                      : Colors.grey,
                ),
                title: Text('customRange'.tr()),
                onTap: () async {
                  Navigator.pop(context);
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: now,
                    initialDateRange: _selectedDateRange,
                  );
                  if (range != null) {
                    setState(() {
                      _selectedRangeLabel = 'custom';
                      _selectedDateRange = range;
                    });
                    _loadData();
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showAllReviews() {
    final theme = Theme.of(context);

    // Extended mock reviews for "All Reviews"
    final allReviews = [
      ..._data.recentReviews,
      _Review(
        customerName: 'Fatima H.',
        rating: 5,
        comment: 'Very punctual and professional. Would recommend!',
        date: DateTime.now().subtract(const Duration(days: 12)),
      ),
      _Review(
        customerName: 'Omar S.',
        rating: 4,
        comment: 'Good work overall',
        date: DateTime.now().subtract(const Duration(days: 15)),
      ),
      _Review(
        customerName: 'Layla M.',
        rating: 5,
        comment: 'Excellent! Fixed everything perfectly.',
        date: DateTime.now().subtract(const Duration(days: 20)),
      ),
      _Review(
        customerName: 'Youssef A.',
        rating: 5,
        comment: null,
        date: DateTime.now().subtract(const Duration(days: 25)),
      ),
      _Review(
        customerName: 'Nour K.',
        rating: 4,
        comment: 'Fast and reliable service',
        date: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'allReviews'.tr(),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${allReviews.length} ${'reviews'.tr()}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        // Average rating
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _data.rating.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  // Reviews list
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: allReviews.length,
                      itemBuilder: (context, index) {
                        final review = allReviews[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: theme
                                              .colorScheme
                                              .primary
                                              .withValues(alpha: 0.1),
                                          child: Text(
                                            review.customerName[0],
                                            style: TextStyle(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              review.customerName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              _formatReviewDate(review.date),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: List.generate(
                                        5,
                                        (i) => Icon(
                                          i < review.rating
                                              ? Icons.star
                                              : Icons.star_border,
                                          size: 16,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (review.comment != null) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    review.comment!,
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatReviewDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'today'.tr();
    } else if (diff.inDays == 1) {
      return 'yesterday'.tr();
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ${'daysAgo'.tr()}';
    } else if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return '$weeks ${'weeksAgo'.tr()}';
    } else {
      final months = (diff.inDays / 30).floor();
      return '$months ${'monthsAgo'.tr()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('performance'.tr())),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return PerformanceMonitorWrapper(
      screenName: 'PerformanceDashboard',
      child: Scaffold(
        appBar: AppBar(
          title: Text('performance'.tr()),
          actions: [
            IconButton(
              icon: const Icon(Icons.date_range),
              onPressed: _showDateRangeFilter,
              tooltip: 'selectDateRange'.tr(),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Earnings header
                _buildEarningsHeader(theme),

                // Stats grid
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildStatsGrid(theme),
                ),

                // Monthly earnings chart
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildEarningsChart(theme),
                ),

                const SizedBox(height: 24),

                // Category breakdown
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildCategoryBreakdown(theme),
                ),

                const SizedBox(height: 24),

                // Recent reviews
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildRecentReviews(theme),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEarningsHeader(ThemeData theme) {
    final growth = _data.currentMonthEarnings - _data.lastMonthEarnings;
    final growthPercent = (growth / _data.lastMonthEarnings * 100).toInt();
    final isGrowth = growth >= 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Text(
            'thisMonthEarnings'.tr(),
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '${_data.currentMonthEarnings.toInt()} EGP',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isGrowth ? Icons.trending_up : Icons.trending_down,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${isGrowth ? '+' : ''}$growthPercent% ${'vsLastMonth'.tr()}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _HeaderStat(
                label: 'totalEarnings'.tr(),
                value:
                    '${(_data.totalEarnings / 1000).toStringAsFixed(1)}K EGP',
              ),
              Container(width: 1, height: 30, color: Colors.white30),
              _HeaderStat(
                label: 'completedJobs'.tr(),
                value: _data.completedJobs.toString(),
              ),
              Container(width: 1, height: 30, color: Colors.white30),
              _HeaderStat(label: 'rating'.tr(), value: '⭐ ${_data.rating}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'performanceMetrics'.tr(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'acceptanceRate'.tr(),
                value: '${(_data.acceptanceRate * 100).toInt()}%',
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'completionRate'.tr(),
                value: '${(_data.completionRate * 100).toInt()}%',
                icon: Icons.verified,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'avgResponseTime'.tr(),
                value: '${_data.avgResponseTime} min',
                icon: Icons.timer,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'reviews'.tr(),
                value: _data.reviewCount.toString(),
                icon: Icons.star_rate,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEarningsChart(ThemeData theme) {
    final maxValue = _data.monthlyEarnings.values.reduce(
      (a, b) => a > b ? a : b,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'earningsTrend'.tr(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 150,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _data.monthlyEarnings.entries.map((entry) {
              final height = (entry.value / maxValue) * 120;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${(entry.value / 1000).toStringAsFixed(1)}K',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: height,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.7,
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.key,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'earningsByCategory'.tr(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ..._data.categoryEarnings.entries.map((entry) {
          final percentage = entry.value / _data.totalEarnings;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key),
                    Text(
                      '${entry.value.toInt()} EGP',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRecentReviews(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'recentReviews'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(onPressed: _showAllReviews, child: Text('seeAll'.tr())),
          ],
        ),
        const SizedBox(height: 8),
        ..._data.recentReviews.map(
          (review) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        review.customerName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < review.rating ? Icons.star : Icons.star_border,
                            size: 16,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (review.comment != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      review.comment!,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String label;
  final String value;

  const _HeaderStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceData {
  final double totalEarnings;
  final double currentMonthEarnings;
  final double lastMonthEarnings;
  final int completedJobs;
  final double rating;
  final int reviewCount;
  final double acceptanceRate;
  final double completionRate;
  final int avgResponseTime;
  final String topCategory;
  final Map<String, double> monthlyEarnings;
  final Map<String, double> categoryEarnings;
  final List<_Review> recentReviews;

  _PerformanceData({
    required this.totalEarnings,
    required this.currentMonthEarnings,
    required this.lastMonthEarnings,
    required this.completedJobs,
    required this.rating,
    required this.reviewCount,
    required this.acceptanceRate,
    required this.completionRate,
    required this.avgResponseTime,
    required this.topCategory,
    required this.monthlyEarnings,
    required this.categoryEarnings,
    required this.recentReviews,
  });
}

class _Review {
  final String customerName;
  final int rating;
  final String? comment;
  final DateTime date;

  _Review({
    required this.customerName,
    required this.rating,
    this.comment,
    required this.date,
  });
}
