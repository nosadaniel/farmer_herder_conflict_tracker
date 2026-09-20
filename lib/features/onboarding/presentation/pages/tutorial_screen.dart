import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/tutorial_step.dart';

/// Onboarding Screen 4 (UX doc): a 4-step swipeable carousel with a
/// "Get Started" button on the last step.
class TutorialScreen extends StatefulWidget {
  const TutorialScreen({required this.onGetStarted, super.key});

  final VoidCallback onGetStarted;

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  static const _steps = [
    TutorialStep(icon: Icons.mic, text: 'Press and hold to report'),
    TutorialStep(icon: Icons.keyboard, text: 'Or type your report'),
    TutorialStep(icon: Icons.map, text: 'See threats on the map'),
    TutorialStep(icon: Icons.share, text: 'Share with your community'),
  ];

  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _currentIndex = 0;

  bool get _isLastStep => _currentIndex == _steps.length - 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              Expanded(
                child: CarouselSlider(
                  controller: _carouselController,
                  items: _steps
                      .map((step) => TutorialStepCard(step: step))
                      .toList(),
                  options: CarouselOptions(
                    height: double.infinity,
                    viewportFraction: 1,
                    enableInfiniteScroll: false,
                    onPageChanged: (index, _) =>
                        setState(() => _currentIndex = index),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _steps.length,
                  (i) => _SwipeIndicatorDot(active: i == _currentIndex),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLastStep
                      ? widget.onGetStarted
                      : () => _carouselController.nextPage(
                          duration: const Duration(milliseconds: 300),
                        ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child: Text(_isLastStep ? 'Get Started' : 'Next'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwipeIndicatorDot extends StatelessWidget {
  const _SwipeIndicatorDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? AppColors.secondary : AppColors.neutral,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
