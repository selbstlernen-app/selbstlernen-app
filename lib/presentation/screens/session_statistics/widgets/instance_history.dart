import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InstanceHistory extends ConsumerWidget {
  const InstanceHistory({required this.sessionId});

  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(child: Text("TODO: implement"));
  }
}
