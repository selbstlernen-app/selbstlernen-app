import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({
    required this.appBarTitle,
    required this.content,
    super.key,
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
      backgroundColor: Color.lerp(
        context.colorScheme.secondary,
        Colors.white,
        0.2,
      ),
      floatingActionButton: showFloatingActionButton
          ? FloatingActionButton(
              backgroundColor: AppPalette.orange,
              onPressed: onPressedFAB,
              tooltip: 'Änderungen speichern',
              child: const Icon(Icons.save_rounded),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        toolbarHeight: 80,
        title: AutoSizeText(
          appBarTitle,
          style: context.textTheme.headlineLarge!.copyWith(
            color: context.colorScheme.brightness == Brightness.dark
                ? context.colorScheme.surface
                : context.colorScheme.onSurface,
          ),
          maxLines: 2,
          textAlign: TextAlign.center,
          minFontSize: 14,
        ),
        backgroundColor: Color.lerp(
          context.colorScheme.secondary,
          Colors.white,
          0.2,
        ),
        actions: actions,
        leading: navigateBack != null
            ? IconButton(
                onPressed: navigateBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: context.colorScheme.brightness == Brightness.dark
                    ? context.colorScheme.surface
                    : context.colorScheme.onSurface,
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
          color: Theme.of(context).scaffoldBackgroundColor,

          width: context.mediaQuery.size.width,
          child: SafeArea(
            child: Padding(padding: const EdgeInsets.all(24), child: content),
          ),
        ),
      ),
    );
  }
}
