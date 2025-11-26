import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/features/event/shared/data/models/event.dart';
import 'package:event_management/features/event/event_list/presentation/widgets/event_card/event_card.dart';
import 'package:flutter/material.dart';

class EventListGrid extends StatelessWidget {
  const EventListGrid({
    required this.events,
    required this.hasNextPage,
    super.key,
    this.onEventTap,
  });

  final List<Event> events;
  final bool hasNextPage;
  final ValueChanged<Event>? onEventTap;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.spaceMD),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.spaceMD,
          mainAxisSpacing: AppSpacing.spaceMD,
          childAspectRatio: 0.68,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index >= events.length) {
            return const Center(child: CircularProgressIndicator());
          }

          final event = events[index];
          return EventCard(
            event: event,
            index: index,
            onTap: () => onEventTap?.call(event),
          );
        }, childCount: events.length + (hasNextPage ? 1 : 0)),
      ),
    );
  }
}
