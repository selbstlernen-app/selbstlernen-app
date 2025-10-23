import 'package:flutter/material.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({
    super.key,
    required this.appBarTitle,
    required this.content,
    required this.navigateBack,
    this.bottomBarWidget,
    this.actions,
  });

  final String appBarTitle;
  final Widget content;
  final VoidCallback navigateBack;
  final PreferredSizeWidget? bottomBarWidget;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.secondary,
      appBar: AppBar(
        centerTitle: true,
        title: Text(appBarTitle, style: context.textTheme.headlineLarge),
        backgroundColor: context.colorScheme.secondary,
        actions: actions,
        leading: IconButton(
          onPressed: navigateBack,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: context.colorScheme.onSurface,
        ),
        bottom: bottomBarWidget,
      ),
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),

        child: Container(
          color: Colors.white,
          width: context.mediaQuery.size.width,
          child: Padding(padding: const EdgeInsets.all(24.0), child: content),
        ),
      ),
    );
  }
}
