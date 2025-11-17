import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/router/app_router.dart';
import 'package:event_management/core/services/calendar_service.dart';
import 'package:event_management/features/event/data/models/event_detail_response.dart';
import 'package:event_management/features/event/data/models/event_status.dart';
import 'package:event_management/features/event/presentation/bloc/event_detail/event_detail_bloc.dart';
import 'package:event_management/features/event/presentation/bloc/event_detail/event_detail_event.dart';
import 'package:event_management/features/event/presentation/bloc/event_detail/event_detail_state.dart';
import 'package:event_management/features/event/presentation/widgets/event_detail/event_detail_banner.dart';
import 'package:event_management/features/event/presentation/widgets/event_detail/event_detail_cta_button.dart';
import 'package:event_management/features/event/presentation/widgets/event_detail/event_detail_description.dart';
import 'package:event_management/features/event/presentation/widgets/event_detail/event_detail_info_section.dart';
import 'package:event_management/features/event/presentation/widgets/event_detail/event_detail_participants_section.dart';
import 'package:event_management/features/event/presentation/widgets/event_detail/event_detail_status_chip.dart';
import 'package:event_management/features/event/presentation/widgets/event_detail/event_detail_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({required this.eventId, super.key});

  final int eventId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<EventDetailBloc, EventDetailState>(
        builder: (context, state) {
          if (state is EventDetailLoading) {
            return _LoadingState();
          }

          if (state is EventDetailError) {
            return _ErrorState(
              error: state.error,
              onRetry: () {
                context.read<EventDetailBloc>().add(
                  EventDetailFetch(eventId: eventId),
                );
              },
            );
          }

          if (state is EventDetailSuccess) {
            return _EventDetailContent(eventDetail: state.eventDetail);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _EventDetailContent extends StatelessWidget {
  const _EventDetailContent({required this.eventDetail});

  final EventDetailResponse eventDetail;

  Future<void> _addEventToCalendar(
    BuildContext context,
    EventDetailResponse eventDetail,
  ) async {
    if (eventDetail.status == EventStatus.completed ||
        eventDetail.status == EventStatus.cancelled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Sự kiện này đã kết thúc, không thể thêm vào lịch',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.coolGray500,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    var result = false;
    try {
      result = await CalendarService.addEventDetailToCalendar(eventDetail);
    } finally {
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result
                  ? 'Đã thêm sự kiện vào lịch của bạn!'
                  : 'Không thể thêm sự kiện vào lịch.',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: result ? AppColors.green500 : AppColors.red500,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.vkuBlue,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.white),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.eventList);
                }
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: AppColors.white),
                onPressed: () {
                  // TODO: Implement share functionality
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.calendar_month_rounded,
                  color: AppColors.white,
                ),
                onPressed: () {
                  _addEventToCalendar(context, eventDetail);
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: EventDetailBanner(bannerUrl: eventDetail.banner),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.spaceMD),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EventDetailTitle(title: eventDetail.title),
                      const SizedBox(height: AppSpacing.spaceXM),
                      EventDetailStatusChip(status: eventDetail.status),
                    ],
                  ),
                ),

                EventDetailInfoSection(eventDetail: eventDetail),

                const SizedBox(height: AppSpacing.spaceMD),

                EventDetailParticipantsSection(
                  participants: eventDetail.participants,
                  maxParticipants: eventDetail.maxParticipants,
                ),

                const SizedBox(height: AppSpacing.spaceMD),

                if (eventDetail.description != null &&
                    eventDetail.description!.isNotEmpty)
                  EventDetailDescription(description: eventDetail.description!),

                const SizedBox(height: AppSpacing.spaceMD),

                if (eventDetail.urlDocs != null &&
                    eventDetail.urlDocs!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.spaceMD,
                    ),
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse(eventDetail.urlDocs!);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      icon: const Icon(Icons.description_rounded),
                      label: const Text('Xem tài liệu sự kiện'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.spaceLG,
                          vertical: AppSpacing.spaceMD,
                        ),
                        side: const BorderSide(
                          color: AppColors.vkuBlue,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: AppSpacing.spaceLG),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: EventDetailCtaButton(eventDetail: eventDetail),
    );
  }
}

class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.vkuBlue,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.white),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.eventList);
                }
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(gradient: AppColors.primaryGradient),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.white),
                ),
              ),
            ),
          ),
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.eventList);
            }
          },
        ),
        title: const Text('Chi tiết sự kiện'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.spaceLG),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.spaceLG),
                decoration: const BoxDecoration(
                  color: AppColors.red100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: AppColors.red500,
                ),
              ),
              const SizedBox(height: AppSpacing.spaceLG),
              Text(
                'Đã xảy ra lỗi',
                style: AppTextStyles.heading2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.spaceMD),
              Text(
                error,
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.spaceXL),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spaceLG,
                    vertical: AppSpacing.spaceMD,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
