// File: lib/presentation/widgets/timeline_widget.dart
// Purpose: Reusable vertical timeline visualization widget.

import 'package:flutter/material.dart';

/// Configuration for a single timeline item
class TimelineItem {
  /// Unique identifier
  final String id;

  /// Title text
  final String title;

  /// Subtitle/description
  final String? subtitle;

  /// Icon to display in the timeline dot
  final IconData icon;

  /// Color for the timeline dot
  final Color color;

  /// Date/time of the event
  final DateTime dateTime;

  /// Optional trailing widget (e.g., price, status badge)
  final Widget? trailing;

  /// Optional expandable content
  final Widget? expandedContent;

  /// Whether this item is currently active/highlighted
  final bool isActive;

  /// Callback when the item is tapped
  final VoidCallback? onTap;

  const TimelineItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.dateTime,
    this.trailing,
    this.expandedContent,
    this.isActive = false,
    this.onTap,
  });
}

/// Vertical timeline widget with expandable items
class TimelineWidget extends StatefulWidget {
  /// List of timeline items to display
  final List<TimelineItem> items;

  /// Whether to show the timeline in reverse order (newest first)
  final bool reversed;

  /// Line color connecting timeline dots
  final Color? lineColor;

  /// Line width
  final double lineWidth;

  /// Dot size
  final double dotSize;

  const TimelineWidget({
    super.key,
    required this.items,
    this.reversed = true,
    this.lineColor,
    this.lineWidth = 2.0,
    this.dotSize = 40.0,
  });

  @override
  State<TimelineWidget> createState() => _TimelineWidgetState();
}

class _TimelineWidgetState extends State<TimelineWidget> {
  final Set<String> _expandedItems = {};

  void _toggleExpanded(String id) {
    setState(() {
      if (_expandedItems.contains(id)) {
        _expandedItems.remove(id);
      } else {
        _expandedItems.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveLineColor = widget.lineColor ?? Colors.grey[300]!;

    final items = widget.reversed
        ? widget.items.reversed.toList()
        : widget.items;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isFirst = index == 0;
        final isLast = index == items.length - 1;
        final isExpanded = _expandedItems.contains(item.id);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline line and dot
              SizedBox(
                width: widget.dotSize + 16,
                child: Column(
                  children: [
                    // Top line
                    if (!isFirst)
                      Container(
                        width: widget.lineWidth,
                        height: 16,
                        color: effectiveLineColor,
                      ),
                    // Dot
                    Container(
                      width: widget.dotSize,
                      height: widget.dotSize,
                      decoration: BoxDecoration(
                        color: item.isActive
                            ? item.color
                            : item.color.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: item.color, width: 2),
                        boxShadow: item.isActive
                            ? [
                                BoxShadow(
                                  color: item.color.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        item.icon,
                        size: widget.dotSize * 0.5,
                        color: item.isActive ? Colors.white : item.color,
                      ),
                    ),
                    // Bottom line
                    Expanded(
                      child: isLast
                          ? const SizedBox.shrink()
                          : Container(
                              width: widget.lineWidth,
                              color: effectiveLineColor,
                            ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (item.expandedContent != null) {
                      _toggleExpanded(item.id);
                    }
                    item.onTap?.call();
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 8, bottom: isLast ? 0 : 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: item.isActive
                          ? item.color.withValues(alpha: 0.1)
                          : theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: item.isActive
                            ? item.color.withValues(alpha: 0.3)
                            : Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (item.subtitle != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      item.subtitle!,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(color: Colors.grey[600]),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (item.trailing != null) item.trailing!,
                            if (item.expandedContent != null)
                              Icon(
                                isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: Colors.grey,
                              ),
                          ],
                        ),

                        // Date
                        const SizedBox(height: 8),
                        Text(
                          _formatDate(item.dateTime),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),

                        // Expanded content
                        if (isExpanded && item.expandedContent != null) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                          item.expandedContent!,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays == 0) {
      return 'Today, ${_formatTime(dateTime)}';
    } else if (diff.inDays == 1) {
      return 'Yesterday, ${_formatTime(dateTime)}';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
