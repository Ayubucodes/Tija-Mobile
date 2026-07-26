import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tija/constants/app_theme.dart';

class SearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final VoidCallback? onCameraTap;
  final ValueChanged<String>? onChanged;

  const SearchField({
    super.key,
    this.controller,
    this.hintText = 'Search Here',
    this.onCameraTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppTheme.of(context).inputFilledColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(
            Iconsax.search_normal,
            color: AppTheme.of(context).secondaryText,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.of(context).primaryText,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: AppTheme.of(context).secondaryText,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          GestureDetector(
            onTap: onCameraTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Icon(
                Iconsax.camera,
                color: AppTheme.of(context).secondaryText,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
