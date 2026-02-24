import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:srl_app/common_widgets/spacing/spacing.dart';
import 'package:srl_app/common_widgets/spacing/vertical_space.dart';
import 'package:srl_app/core/routing/app_routes.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/providers.dart';

class OnBoardingScreen extends ConsumerStatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  OnBoardingScreenState createState() => OnBoardingScreenState();
}

class OnBoardingScreenState extends ConsumerState<OnBoardingScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();

  Future<void> _onIntroEnd(BuildContext context) async {
    await ref.read(manageSettingsUseCaseProvider).turnOffIntroScreen();
    if (!context.mounted) return;
    await Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final pageDecoration = PageDecoration(
      titleTextStyle: context.textTheme.headlineLarge!,
      bodyTextStyle: context.textTheme.bodyLarge!,
      bodyPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),

      bodyAlignment: Alignment.center,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: context.colorScheme.brightness == Brightness.dark
          ? context.colorScheme.surface
          : Colors.white,
      globalFooter: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),

          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(shadowColor: Colors.transparent),
              child: const Text('Lass mich sofort loslegen!'),
              onPressed: () => _onIntroEnd(context),
            ),
          ),
        ),
      ),
      pages: [
        // 1. Willkommen
        PageViewModel(
          titleWidget: Column(
            children: [
              const Icon(Icons.school_rounded, size: 72),
              const VerticalSpace(),
              Text(
                'Willkommen bei der Selbstlernen.app 2.0',
                textAlign: TextAlign.center,
                style: context.textTheme.headlineLarge,
              ),
            ],
          ),
          body:
              '''Schluss mit chaotischem Lernen. Hier planst du strukturiert, lernst gezielt – und siehst sofort, was du erreicht hast.''',
          decoration: pageDecoration,
        ),

        // 2. Lerneinheiten anlegen
        PageViewModel(
          titleWidget: Column(
            children: [
              const Icon(Icons.add_task_rounded, size: 72),
              const VerticalSpace(),
              Text(
                'Lerneinheiten\nanlegen',
                textAlign: TextAlign.center,
                style: context.textTheme.headlineLarge,
              ),
            ],
          ),
          body: 'Erstelle Lerneinheiten für jedes Fach oder Thema.',
          decoration: pageDecoration,
        ),

        // 3. Zeitplanung
        PageViewModel(
          titleWidget: Column(
            children: [
              const Icon(Icons.calendar_month_rounded, size: 72),
              const VerticalSpace(),
              Text(
                'Zeitplanung',
                textAlign: TextAlign.center,
                style: context.textTheme.headlineLarge,
              ),
            ],
          ),
          body:
              '''Der beste Lernplan ist einer, den du wirklich einhältst. Wähle wann, wie lange und wie oft du lernen willst.''',
          decoration: pageDecoration,
        ),

        // 4. Zielsetzung
        PageViewModel(
          titleWidget: Column(
            children: [
              const Icon(Icons.flag_rounded, size: 72),
              const VerticalSpace(),
              Text(
                'Ziele setzen',
                textAlign: TextAlign.center,
                style: context.textTheme.headlineLarge,
              ),
            ],
          ),
          body:
              '''Setze dir klare Lernziele für jede Einheit. Was willst du am Ende können oder wissen?''',
          decoration: pageDecoration,
        ),

        // 4. Zielsetzung
        PageViewModel(
          titleWidget: Column(
            children: [
              const Icon(Icons.psychology_rounded, size: 72),
              const VerticalSpace(),
              Text(
                'Lernstrategie\nwählen',
                textAlign: TextAlign.center,
                style: context.textTheme.headlineLarge,
              ),
            ],
          ),
          body:
              '''Wie gehst du deine Ziele an? Zusammenfassen, aktives Erinnern, Erklären – wähle bewusst, wie du lernst.''',
          decoration: pageDecoration,
        ),

        // 5. Feedback
        PageViewModel(
          titleWidget: Column(
            children: [
              const Icon(Icons.insights_rounded, size: 72),
              const VerticalSpace(),
              Text(
                'Feedback &\nFortschritt',
                textAlign: TextAlign.center,
                style: context.textTheme.headlineLarge,
              ),
            ],
          ),
          body:
              '''Nach jeder Einheit reflektierst du: Was lief gut? Wo hakt es? Verfolge deinen Fortschritt und erkenne mit der Zeit, was dich wirklich weiterbringt.''',
          decoration: pageDecoration,
        ),
      ],
      next: const Icon(Icons.arrow_forward),
      back: const Icon(Icons.arrow_back),
      done: const Text(
        "Los geht's!",
      ),
      dotsFlex: 0,
      showBackButton: true,
      onDone: () => _onIntroEnd(context),
      curve: Curves.fastLinearToSlowEaseIn,
      dotsDecorator: DotsDecorator(
        color: context.colorScheme.outlineVariant,
        activeColor: context.colorScheme.primary,
        activeSize: const Size(16, 10),
        activeShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
      ),
    );
  }
}
