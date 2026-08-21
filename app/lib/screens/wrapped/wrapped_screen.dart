import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../state/wrapped_provider.dart';
import '../../widgets/wrapped_slide.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/error_banner.dart';
import '../../core/constants/app_constants.dart';

class WrappedScreen extends ConsumerStatefulWidget {
  const WrappedScreen({super.key});

  @override
  ConsumerState<WrappedScreen> createState() => _WrappedScreenState();
}

class _WrappedScreenState extends ConsumerState<WrappedScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storyAsync = ref.watch(wrappedStoryProvider);
    final currencyFormatter = NumberFormat.currency(symbol: AppConstants.currencySymbol, decimalDigits: 2);

    return Scaffold(
      backgroundColor: Colors.black,
      body: storyAsync.when(
        data: (story) {
          final List<Widget> slides = [];

          // Slide 1: Overview
          slides.add(
            WrappedSlide(
              title: 'Your Monthly Story',
              heroText: currencyFormatter.format(story.totalSpend),
              subtitle: 'Spent across ${story.totalTransactions} transactions this month.',
              icon: Icons.account_balance_wallet,
              gradientColors: const [Color(0xFF4F46E5), Color(0xFF7C3AED)],
              badgeText: story.monthYear,
            ),
          );

          if (story.sufficientData) {
            // Slide 2: Top Category
            if (story.topCategoryName != null) {
              slides.add(
                WrappedSlide(
                  title: 'Your #1 Expense Area',
                  heroText: story.topCategoryName!,
                  subtitle: 'Took up ${story.topCategoryPercentage.toStringAsFixed(1)}% of your total spend (${currencyFormatter.format(story.topCategoryAmount ?? 0)}).',
                  icon: Icons.pie_chart_outline,
                  gradientColors: const [Color(0xFF0284C7), Color(0xFF2563EB)],
                ),
              );
            }

            // Slide 3: Weekend vs Weekday
            final weekendMsg = story.weekendSpentMore
                ? 'You spent ${story.weekendVsWeekdayDeltaPct.abs().toStringAsFixed(1)}% MORE on weekends!'
                : 'You kept weekend spending controlled (${story.weekendVsWeekdayDeltaPct.abs().toStringAsFixed(1)}% lower than weekdays).';
            slides.add(
              WrappedSlide(
                title: 'Weekend Habit',
                heroText: story.weekendSpentMore ? 'Weekend Spender' : 'Weekday Saver',
                subtitle: weekendMsg,
                icon: Icons.weekend,
                gradientColors: const [Color(0xFFD97706), Color(0xFFDC2626)],
              ),
            );

            // Slide 4: Peak Day
            if (story.peakDate != null) {
              slides.add(
                WrappedSlide(
                  title: 'Biggest Single Day',
                  heroText: story.peakDate!,
                  subtitle: 'You logged ${currencyFormatter.format(story.peakAmount ?? 0)} in a single day.',
                  icon: Icons.local_fire_department,
                  gradientColors: const [Color(0xFF7E22CE), Color(0xFFC026D3)],
                ),
              );
            }
          }

          // Final Slide: Personality Tag
          slides.add(
            WrappedSlide(
              title: 'Your Financial Personality',
              heroText: story.personalityTag,
              subtitle: story.personalityDescription,
              icon: Icons.stars_rounded,
              gradientColors: const [Color(0xFF059669), Color(0xFF10B981)],
              badgeText: 'RESULT',
            ),
          );

          return Stack(
            children: [
              PageView(
                controller: _pageController,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                children: slides,
              ),

              // Progress Bar Indicators
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: List.generate(slides.length, (idx) {
                      final isCurrent = idx == _currentPage;
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: isCurrent ? Colors.white : Colors.white30,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),

              // Close Button
              Positioned(
                top: 48,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (err, _) => Center(
          child: ErrorBanner(
            message: 'Failed to load Wrapped story: $err',
            onRetry: () => ref.invalidate(wrappedStoryProvider),
          ),
        ),
      ),
    );
  }
}
