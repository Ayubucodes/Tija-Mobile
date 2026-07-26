import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tija/constants/app_theme.dart';

class DropdownField<T> extends StatefulWidget {
  final String label;
  final String hintText;
  final T? value;
  final List<DropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final Widget? prefixIcon;

  const DropdownField({
    super.key,
    this.label = '',
    required this.hintText,
    this.value,
    required this.items,
    this.onChanged,
    this.prefixIcon,
  });

  @override
  State<DropdownField<T>> createState() => _DropdownFieldState<T>();
}

class _DropdownFieldState<T> extends State<DropdownField<T>> {
  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.primaryText,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.inputFilledColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: widget.value,
              hint: Text(
                widget.hintText,
                style: TextStyle(
                  color: theme.secondaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              items: widget.items.map((item) {
                return DropdownMenuItem<T>(
                  value: item.value,
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.primaryText,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                );
              }).toList(),
              onChanged: widget.onChanged,
              icon: const Icon(
                Iconsax.arrow_down_1,
                color: Color(0xFFAAAAAA),
                size: 20,
              ),
              iconEnabledColor: const Color(0xFFAAAAAA),
              iconDisabledColor: const Color(0xFFAAAAAA),
              dropdownColor: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(14),
              style: TextStyle(
                fontSize: 14,
                color: theme.primaryText,
                fontWeight: FontWeight.w400,
              ),
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              selectedItemBuilder: (context) {
                return widget.items.map((item) {
                  return DropdownMenuItem<T>(
                    value: item.value,
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.primaryText,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ],
    );
  }
}

class DropdownItem<T> {
  final String label;
  final T value;

  const DropdownItem({
    required this.label,
    required this.value,
  });
}
