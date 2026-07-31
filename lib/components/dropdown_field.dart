import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tija/constants/app_theme.dart';

class DropdownField<T> extends StatefulWidget {
  final String hintText;
  final T? value;
  final List<DropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final Widget? prefixIcon;
  final String? label;
  final String? errorText;

  const DropdownField({
    super.key,
    required this.hintText,
    this.value,
    required this.items,
    this.onChanged,
    this.prefixIcon,
    this.label,
    this.errorText,
  });

  @override
  State<DropdownField<T>> createState() => _DropdownFieldState<T>();
}

class _DropdownFieldState<T> extends State<DropdownField<T>> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    final renderBox = _fieldKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final theme = AppTheme.of(context);

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            // Transparent barrier — tapping outside the menu closes it.
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeOverlay,
                child: Container(color: Colors.transparent),
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 8),
              child: Align(
                alignment: Alignment.topLeft,
                child: Material(
                  color: Colors.transparent,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOut,
                    builder: (context, t, child) {
                      return Opacity(
                        opacity: t,
                        child: Transform.translate(
                          offset: Offset(0, (1 - t) * -6),
                          child: child,
                        ),
                      );
                    },
                    // Width is locked to the field's own width — never the screen's.
                    child: Container(
                      width: size.width,
                      constraints: const BoxConstraints(maxHeight: 280),
                      decoration: BoxDecoration(
                        color: theme.secondaryBackground,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.14),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shrinkWrap: true,
                          itemCount: widget.items.length,
                          itemBuilder: (context, index) {
                            final item = widget.items[index];
                            final isSelected = item.value == widget.value;
                            return InkWell(
                              onTap: () {
                                widget.onChanged?.call(item.value);
                                _removeOverlay();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                color: isSelected
                                    ? theme.primaryColor.withOpacity(0.08)
                                    : Colors.transparent,
                                child: Row(
                                  children: [
                                    if (item.icon != null) ...[
                                      IconTheme(
                                        data: IconThemeData(
                                          size: 18,
                                          color: isSelected
                                              ? theme.primaryColor
                                              : theme.secondaryText,
                                        ),
                                        child: item.icon!,
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                    Expanded(
                                      child: Text(
                                        item.label,
                                        style: TextStyle(
                                          fontSize: 14.5,
                                          color: isSelected
                                              ? theme.primaryColor
                                              : theme.primaryText,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Iconsax.tick_circle5,
                                        size: 16,
                                        color: theme.primaryColor,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _isOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    final matches = widget.items.where((i) => i.value == widget.value);
    final selectedLabel = matches.isNotEmpty ? matches.first.label : null;

    final Color borderColor = hasError
        ? const Color(0xFFE55555)
        : _isOpen
            ? theme.primaryColor
            : Colors.transparent;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null) ...[
            Text(
              widget.label!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.primaryText,
              ),
            ),
            const SizedBox(height: 8),
          ],
          GestureDetector(
            key: _fieldKey,
            onTap: _toggleDropdown,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: theme.inputFilledColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 1.4),
                boxShadow: _isOpen
                    ? [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  if (widget.prefixIcon != null) ...[
                    IconTheme(
                      data: IconThemeData(
                        color: _isOpen ? theme.primaryColor : theme.secondaryText,
                        size: 20,
                      ),
                      child: widget.prefixIcon!,
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      selectedLabel ?? widget.hintText,
                      style: TextStyle(
                        fontSize: 14.5,
                        color: selectedLabel != null
                            ? theme.primaryText
                            : theme.secondaryText,
                        fontWeight: selectedLabel != null
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 180),
                    turns: _isOpen ? 0.5 : 0,
                    child: Icon(
                      Iconsax.arrow_down_1,
                      size: 18,
                      color: _isOpen ? theme.primaryColor : theme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DropdownItem<T> {
  final String label;
  final T value;
  final Widget? icon;

  const DropdownItem({required this.label, required this.value, this.icon});
}