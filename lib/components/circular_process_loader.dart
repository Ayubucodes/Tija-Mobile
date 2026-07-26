import 'package:flutter/material.dart';
import 'package:tija/constants/app_asset.dart';

class CircularProcessLoader extends StatelessWidget {
  const CircularProcessLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: width,
          height: width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: width / 4,
                height: width / 4,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Image.asset(
                    AppAssets.LOADING_GIF,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
