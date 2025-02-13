import 'package:flutter/material.dart';
import 'package:rideapp/utils/theme/app_text_theme.dart';

class OptionTile extends StatelessWidget {
  final String title;
  final void Function()? onTap;
  final bool showDivider; 


  const OptionTile({
    super.key,
    required this.title,
   this.onTap,
    this.showDivider = true, 
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTextTheme.getLightTextTheme(context).titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            color: Colors.black12,
            indent: 20,
            endIndent: 20,
          ),
       
      ],
    );
  }
}

