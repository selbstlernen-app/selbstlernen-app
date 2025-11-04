import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/main_layout.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/full_session_model.dart';
import 'package:srl_app/main_navigation.dart';
import 'package:srl_app/presentation/screens/add_session/pages/bottom_up_page.dart';
import 'package:srl_app/presentation/screens/add_session/pages/prompt_page.dart';
import 'package:srl_app/presentation/screens/add_session/pages/start_info_page.dart';
import 'package:srl_app/presentation/screens/add_session/pages/strategy_page.dart';
import 'package:srl_app/presentation/screens/add_session/pages/timer_page.dart';
import 'package:srl_app/presentation/screens/add_session/pages/top_down_page.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_state.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_view_model.dart';

class AddSessionScreen extends ConsumerStatefulWidget {
  const AddSessionScreen({super.key, this.fullSessionModel});

  // If in editing mode
  final FullSessionModel? fullSessionModel;

  @override
  ConsumerState<AddSessionScreen> createState() => _AddSessionScreenState();
}

class _AddSessionScreenState extends ConsumerState<AddSessionScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int currentPage = 0;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    // Denominator is the total amount of pages available
    _progress = 1 / 5;

    // if in edit mode
    if (widget.fullSessionModel != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(addSessionViewModelProvider.notifier)
            .initializeState(widget.fullSessionModel!);
      });
    }
  }

  void _navigateBack() {
    if (currentPage > 0) {
      setState(() {
        currentPage -= 1;
        _progress = (currentPage + 1) / 5;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInBack,
      );
    } else {
      if (widget.fullSessionModel != null) {
        // Go back to details page
        Navigator.pop(context);
      } else {
        // Go back to home screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => const MainNavigation(),
          ),
          (Route<dynamic> route) => false,
        );
      }
      ref.read(addSessionViewModelProvider.notifier).resetFields();
    }
  }

  void _navigateForward() {
    setState(() {
      currentPage += 1;
      _progress = (currentPage + 1) / 5;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final AddSessionState state = ref.watch(addSessionViewModelProvider);

    return MainLayout(
      appBarTitle: widget.fullSessionModel != null
          ? "Lerneinheit bearbeiten"
          : "Neue Einheit",
      bottomBarWidget: PreferredSize(
        preferredSize: const Size.fromHeight(30.0),
        child: Padding(
          padding: const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 20.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              minHeight: 8.0,
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
          state.setGoals
              ? TopDownPage(navigateForward: _navigateForward)
              : BottomUpPage(navigateForward: _navigateForward),
          StrategyPage(navigateForward: _navigateForward),
          TimerPage(navigateForward: _navigateForward),
          PromptPage(navigateForward: _navigateForward),
        ],
      ),
      navigateBack: _navigateBack,
    );
  }
}
