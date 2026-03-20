import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/main_layout.dart';
import 'package:srl_app/core/constants/constants.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/full_session_model.dart';
import 'package:srl_app/presentation/screens/add_session/pages/goal_setting_page.dart';
import 'package:srl_app/presentation/screens/add_session/pages/plan_start_page.dart';
import 'package:srl_app/presentation/screens/add_session/pages/prompt_page.dart';
import 'package:srl_app/presentation/screens/add_session/pages/setup_wizard_page.dart';
import 'package:srl_app/presentation/screens/add_session/pages/strategy_page.dart';
import 'package:srl_app/presentation/screens/add_session/pages/timer_page.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_view_model.dart';

class AddSessionScreen extends ConsumerStatefulWidget {
  const AddSessionScreen({
    super.key,
    this.fullSessionModel,
    this.fromHomeScreen,
  });

  // If in editing mode
  final FullSessionModel? fullSessionModel;
  final bool? fromHomeScreen;

  @override
  ConsumerState<AddSessionScreen> createState() => _AddSessionScreenState();
}

class _AddSessionScreenState extends ConsumerState<AddSessionScreen> {
  final PageController _pageController = PageController();
  int currentPage = 0;
  double _progress = 0;

  @override
  void initState() {
    super.initState();

    _progress = 1 / 6;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.fullSessionModel != null) {
        // Edit mode: initialize with existing data;
        // navigating back always possible
        ref
            .read(addSessionViewModelProvider.notifier)
            .initializeState(widget.fullSessionModel!);
      } else {
        // Create mode: ensure state is clean by resetting
        ref.read(addSessionViewModelProvider.notifier).resetFields();
      }
    });
  }

  Future<void> _navigateBack() async {
    FocusScope.of(context).unfocus();

    final totalPages = ref.read(
      addSessionViewModelProvider.select((s) => s.totalPages),
    );

    if (currentPage > 0) {
      final targetPage = currentPage - 1;

      await _pageController
          .animateToPage(
            targetPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          )
          .then((_) {
            setState(() {
              currentPage = targetPage;
              _progress = (currentPage + 1) / totalPages;
            });
          });
    } else {
      if (widget.fullSessionModel != null) {
        ref.read(addSessionViewModelProvider.notifier).resetFields();
      }
      Navigator.pop(context);
    }
  }

  Future<void> _navigateForward() async {
    final targetPage = currentPage + 1;
    final totalPages = ref.read(addSessionViewModelProvider).totalPages;

    FocusScope.of(context).unfocus();

    await _pageController
        .animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
        .then((_) {
          setState(() {
            currentPage = targetPage;
            _progress = (currentPage + 1) / totalPages;
          });
        });
  }

  String _getAppBarTitle(String title) {
    if (widget.fullSessionModel != null) {
      return '${widget.fullSessionModel!.session.title} bearbeiten';
    }
    if (currentPage == 0) {
      return 'Lerneinheit erstellen';
    } else {
      return '$title konfigurieren';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addSessionViewModelProvider);
    final showBackButton =
        widget.fullSessionModel != null ||
        currentPage > 0 ||
        (widget.fromHomeScreen ?? false);

    return MainLayout(
      appBarTitle: _getAppBarTitle(state.title),
      showFloatingActionButton: state.isEditMode,
      onPressedFAB: () async {
        await ref
            .read(addSessionViewModelProvider.notifier)
            .handleSaveSession();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 2),
              content: Text(Constants.successModified),
            ),
          );
          Navigator.pop(context);
        }
      },
      bottomBarWidget: PreferredSize(
        preferredSize: const Size.fromHeight(30),
        child: Padding(
          padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: _progress,
              color: context.colorScheme.primary,
              backgroundColor: Colors.white,
            ),
          ),
        ),
      ),
      navigateBack: showBackButton ? _navigateBack : null,
      content: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            currentPage = index;
            // Recalculate progress based on page count
            final total = !state.isEditMode ? 6 : 5;
            _progress = (index + 1) / total;
          });
        },
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          if (!state.isEditMode)
            SetupWizardPage(navigateForward: _navigateForward),

          PlanStartPage(navigateForward: _navigateForward),

          TimerPage(navigateForward: _navigateForward),

          GoalSettingPage(navigateForward: _navigateForward),

          StrategyPage(navigateForward: _navigateForward),

          const PromptPage(),
        ],
      ),
    );
  }
}
