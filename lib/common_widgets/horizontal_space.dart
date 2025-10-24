import 'package:flutter/material.dart';
import 'package:srl_app/core/constants/spacing.dart';

class HorizontalSpace extends StatelessWidget {
  const HorizontalSpace({super.key, this.size = SpaceSize.medium, this.custom});

  final SpaceSize size;
  final double? custom;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: custom ?? size.value);
  }
}
