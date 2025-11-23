import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/features/admin/presentation/widgets/event_card_admin.dart';
import 'package:event_management/features/event/data/models/event.dart';
import 'package:event_management/features/event/presentation/bloc/event_list_bloc.dart';
import 'package:event_management/features/event/presentation/bloc/event_list_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EventListGridAdmin extends StatelessWidget {
  const EventListGridAdmin({
    required this.events,
    required this.hasNextPage,
    super.key,
    this.onEventTap,
    this.onEventEdit,
    this.onEventDelete,
  });

  final List<Event> events;
  final bool hasNextPage;
  final ValueChanged<Event>? onEventTap;
  final ValueChanged<Event>? onEventEdit;
  final ValueChanged<Event>? onEventDelete;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.spaceMD),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.spaceMD,
          mainAxisSpacing: AppSpacing.spaceMD,
          childAspectRatio: 0.68, // Adjusted to prevent overflow
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index >= events.length) {
            // Load more indicator
            if (hasNextPage) {
              context.read<EventListBloc>().add(
                const EventListLoadMore(isManaged: false),
              );
              return const Center(child: CircularProgressIndicator());
            }
            return const SizedBox.shrink();
          }

          final event = events[index];
          return EventCardAdmin(
            event: event,
            index: index,
            onTap: () {
              onEventTap?.call(event);
              context.go('/events/${event.id}');
            },
            onEdit: () {
              onEventEdit?.call(event);
            },
            onDelete: () {
              onEventDelete?.call(event);
            },
          );
        }, childCount: events.length + (hasNextPage ? 1 : 0)),
      ),
    );
  }
}
