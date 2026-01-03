import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../theme/design_tokens.dart';

/// An animated search bar that expands from an icon to a full input field
///
/// Inspired by Fixawy website's search interaction pattern.
/// Collapsed: 40px icon button
/// Expanded: 280px input field with close button
class AnimatedSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final Function(String)? onChanged;
  final VoidCallback? onExpanded;
  final VoidCallback? onCollapsed;
  final String? hintText;
  final double expandedWidth;
  final Duration animationDuration;

  const AnimatedSearchBar({
    super.key,
    required this.onSearch,
    this.onChanged,
    this.onExpanded,
    this.onCollapsed,
    this.hintText,
    this.expandedWidth = 280,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar> {
  bool _isExpanded = false;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _focusNode.requestFocus();
        widget.onExpanded?.call();
      } else {
        _controller.clear();
        _focusNode.unfocus();
        widget.onCollapsed?.call();
      }
    });
  }

  void _handleSubmit(String value) {
    if (value.trim().isNotEmpty) {
      widget.onSearch(value.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: widget.animationDuration,
      curve: Curves.easeInOut,
      width: _isExpanded ? widget.expandedWidth : 40,
      height: 40,
      decoration: BoxDecoration(
        color: _isExpanded ? colorScheme.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
        border: _isExpanded
            ? Border.all(
                color: colorScheme.outline.withValues(alpha: 0.5),
                width: 1,
              )
            : null,
        boxShadow: _isExpanded ? DesignTokens.shadowSoft : null,
      ),
      child: Row(
        children: [
          // Search/Close button
          Semantics(
            button: true,
            label: _isExpanded ? 'Close search' : 'Open search',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _toggleSearch,
                borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _isExpanded ? Icons.close : Icons.search_rounded,
                      key: ValueKey(_isExpanded),
                      color: _isExpanded
                          ? DesignTokens.neutral600
                          : colorScheme.primary,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Text field (only visible when expanded)
          if (_isExpanded)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: DesignTokens.spaceSM),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: widget.onChanged,
                  onSubmitted: _handleSubmit,
                  textInputAction: TextInputAction.search,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: widget.hintText ?? 'searchService'.tr(),
                    hintStyle: TextStyle(
                      color: DesignTokens.neutral400,
                      fontSize: DesignTokens.fontSizeBase,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
