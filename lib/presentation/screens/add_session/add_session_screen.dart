import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/main_layout.dart';
import 'package:srl_app/core/constants/constants.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/full_session_model.dart';
import 'package:srl_app/presentation/screens/add_session/pages/bottom_up_page.dart';
import 'package:srl_app/presentation/screens/add_session/pages/prompt_page.dart';
import 'package:srl_app/presentation/screens/add_session/pages/start_info_page.dart';
import 'package:srl_app/presentation/screens/add_session/pages/strategy_page.dart';
import 'package:srl_app/presentation/screens/add_session/pages/timer_page.dart';
import 'package:srl_app/presentation/screens/add_session/pages/top_down_page.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_view_model.dart';

class AddSessionScreen extends ConsumerStatefulWidget {
  const AddSessionScreen({super.key, this.fullSessionModel});

  // If in editing mode
  final FullSessionModel? fullSessionModel;

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
    // Denominator is the total amount of pages available
    _progress = 1 / 5;

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
    final totalPages = ref.read(addSessionViewModelProvider).totalPages;

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
        // reset fields and then navigate back!
        ref.read(addSessionViewModelProvider.notifier).resetFields();
        Navigator.pop(context);
      }
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addSessionViewModelProvider);
    final showBackButton = widget.fullSessionModel != null || currentPage > 0;

    return MainLayout(
      appBarTitle: widget.fullSessionModel != null
          ? 'Lerneinheit bearbeiten'
          : 'Neue Lerneinheit erstellen',
      showFloatingActionButton: state.isEditMode,
      onPressedFAB: () async {
        await ref
            .read(addSessionViewModelProvider.notifier)
            .updateSessionAndReset();

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
      content: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          StartInfoPage(navigateForward: _navigateForward),
          // Always show TopDownPage in edit mode
          if (state.isEditMode || state.setGoals)
            TopDownPage(navigateForward: _navigateForward)
          else
            BottomUpPage(navigateForward: _navigateForward),

          StrategyPage(navigateForward: _navigateForward),

          // Do not show this page in edit mode, since nothing should
          // be changed here anyway
          if (!state.isEditMode) ...[
            TimerPage(navigateForward: _navigateForward),
          ],

          PromptPage(navigateForward: _navigateForward),
        ],
      ),
      navigateBack: showBackButton ? _navigateBack : null,
    );
  }
}
