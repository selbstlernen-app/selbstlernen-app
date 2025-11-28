import 'package:flutter/material.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({
    required this.appBarTitle, required this.content, super.key,
    this.navigateBack,
    this.bottomBarWidget,
    this.actions,
    this.showFloatingActionButton = false,
    this.onPressedFAB,
  });

  final String appBarTitle;
  final Widget content;
  final VoidCallback? navigateBack;
  final PreferredSizeWidget? bottomBarWidget;
  final List<Widget>? actions;
  final bool showFloatingActionButton;
  final void Function()? onPressedFAB;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.secondary,
      floatingActionButton: showFloatingActionButton
          ? Padding(
              padding: const EdgeInsets.only(top: 70),
              child: FloatingActionButton(
                backgroundColor: AppPalette.orange,
                onPressed: onPressedFAB,
                tooltip: 'Änderungen speichern',
                child: const Icon(Icons.save_rounded),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        toolbarHeight: 80,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            appBarTitle,
            style: context.textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
        ),
        backgroundColor: context.colorScheme.secondary,
        actions: actions,
        leading: navigateBack != null
            ? IconButton(
                onPressed: navigateBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: context.colorScheme.onSurface,
              )
            : null,
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
          child: SafeArea(
            child: Padding(padding: const EdgeInsets.all(24), child: content),
          ),
        ),
      ),
    );
  }
}
