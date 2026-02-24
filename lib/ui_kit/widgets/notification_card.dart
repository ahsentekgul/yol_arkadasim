import 'package:flutter/material.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_radius.dart';

class NotificationModel {
  final dynamic id;
  final String type;
  final String title;
  final String message;
  final String? stopName;
  final String? busNumber;
  final String? estimatedTime;
  final String? platform;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.stopName,
    this.busNumber,
    this.estimatedTime,
    this.platform,
  });
}

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final bool isVisible;
  final VoidCallback? onDismiss;
  final VoidCallback? onAlternative;

  const NotificationCard({
    Key? key,
    required this.notification,
    this.isVisible = true,
    this.onDismiss,
    this.onAlternative,
  }) : super(key: key);

  Color _backgroundForType() {
    switch (notification.type) {
      case 'stop_arrival':
        return AppColors.green600;
      case 'bus_arrival':
        return AppColors.blue600;
      case 'route_alert':
        return AppColors.orange600;
      default:
        return AppColors.gray700;
    }
  }

  Color _borderForType() {
    switch (notification.type) {
      case 'stop_arrival':
        return AppColors.borderGreen500;
      case 'bus_arrival':
        return AppColors.borderBlue500;
      case 'route_alert':
        return AppColors.borderOrange500;
      default:
        return AppColors.gray700;
    }
  }

  IconData _iconForType() {
    switch (notification.type) {
      case 'stop_arrival':
        return Icons.place;
      case 'bus_arrival':
        return Icons.directions_bus;
      case 'route_alert':
        return Icons.report_problem;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final duration = Duration(milliseconds: isVisible ? 300 : 200);

    return AnimatedScale(
      scale: isVisible ? 1.0 : 0.95,
      duration: duration,
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: duration,
        child: Container(
          decoration: BoxDecoration(
            color: _backgroundForType(),
            borderRadius: BorderRadius.circular(AppRadius.rounded3xl),
            border: Border.all(color: _borderForType(), width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_iconForType(), size: 28, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (notification.estimatedTime != null)
                          Text(
                            notification.estimatedTime!,
                            style: const TextStyle(color: Colors.white70),
                          ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Text(
                notification.message,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              if (notification.stopName != null ||
                  notification.busNumber != null ||
                  notification.platform != null)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(AppRadius.rounded2xl),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (notification.stopName != null)
                        Row(
                          children: [
                            const Icon(Icons.place, color: Colors.white70),
                            const SizedBox(width: 8),
                            Text(
                              'Durak: ${notification.stopName}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      if (notification.busNumber != null)
                        Row(
                          children: [
                            const Icon(Icons.directions_bus, color: Colors.white70),
                            const SizedBox(width: 8),
                            Text(
                              'Hat: ${notification.busNumber}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      if (notification.platform != null)
                        Row(
                          children: [
                            const Icon(Icons.map, color: Colors.white70),
                            const SizedBox(width: 8),
                            Text(
                              notification.platform!,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              // Eylem düğmeleri üst bileşen tarafından callback ile sağlanır - NotificationsScreen içinde gösterilir
            ],
          ),
        ),
      ),
    );
  }
}

