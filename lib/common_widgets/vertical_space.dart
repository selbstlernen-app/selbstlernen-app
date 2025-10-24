import 'package:flutter/widgets.dart';
import 'package:srl_app/core/constants/spacing.dart';

class VerticalSpace extends StatelessWidget {
  const VerticalSpace({super.key, this.size = SpaceSize.medium, this.custom});

  final SpaceSize size;
  final double? custom;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: custom ?? size.value);
  }
}
