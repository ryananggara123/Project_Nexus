import 'package:flutter/material.dart';

import '../../../core/theme/project_nexus_colors.dart';
import '../models/app_notification.dart';
import '../models/notification_store.dart';

/// Tombol lonceng dengan lencana jumlah notifikasi yang belum dibaca.
class NotificationBell extends StatelessWidget {
  const NotificationBell({
    required this.store,
    required this.recipient,
    super.key,
  });

  final NotificationStore store;
  final String recipient;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final unread = store.unreadCountFor(recipient);
        return IconButton(
          key: const Key('notification_bell'),
          tooltip: 'Notifikasi',
          onPressed: () => showNotificationCenter(
            context,
            store: store,
            recipient: recipient,
          ),
          icon: Badge(
            key: const Key('notification_badge'),
            isLabelVisible: unread > 0,
            backgroundColor: ProjectNexusColors.error,
            label: Text(unread > 99 ? '99+' : '$unread'),
            child: Icon(
              unread > 0
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_none_rounded,
              size: 21,
            ),
          ),
          style: IconButton.styleFrom(
            backgroundColor: ProjectNexusColors.surface,
            foregroundColor: ProjectNexusColors.ink,
            side: const BorderSide(color: ProjectNexusColors.border),
            fixedSize: const Size(44, 44),
          ),
        );
      },
    );
  }
}

/// Membuka daftar notifikasi. Daftar ikut berubah bila notifikasi baru masuk
/// saat lembar ini terbuka.
Future<void> showNotificationCenter(
  BuildContext context, {
  required NotificationStore store,
  required String recipient,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: ProjectNexusColors.surface,
    constraints: const BoxConstraints(maxWidth: 560),
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.75,
      child: _NotificationCenter(store: store, recipient: recipient),
    ),
  );
}

class _NotificationCenter extends StatelessWidget {
  const _NotificationCenter({required this.store, required this.recipient});

  final NotificationStore store;
  final String recipient;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final items = store.notificationsFor(recipient);
        final unread = store.unreadCountFor(recipient);
        final now = store.now;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notifikasi',
                          style: TextStyle(
                            color: ProjectNexusColors.ink,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          unread == 0
                              ? 'Semua notifikasi sudah dibaca'
                              : '$unread belum dibaca',
                          style: const TextStyle(
                            color: ProjectNexusColors.muted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (unread > 0)
                    TextButton(
                      key: const Key('notification_mark_all'),
                      onPressed: () => store.markAllRead(recipient),
                      child: const Text('Tandai semua dibaca'),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: items.isEmpty
                  ? const _EmptyNotifications()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: items.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, indent: 72),
                      itemBuilder: (context, index) => _NotificationTile(
                        items[index],
                        now: now,
                        onTap: () => store.markRead(items[index]),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile(this.notification, {required this.now, this.onTap});

  final AppNotification notification;
  final DateTime now;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final type = notification.type;
    final unread = !notification.read;
    return Material(
      color: unread ? ProjectNexusColors.mint.withValues(alpha: 0.55) : null,
      child: InkWell(
        key: Key('notification_${notification.id}'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: type.color.withValues(alpha: 0.12),
                child: Icon(type.icon, color: type.color, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        color: ProjectNexusColors.ink,
                        fontSize: 14,
                        fontWeight: unread ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notification.body,
                      style: const TextStyle(
                        color: ProjectNexusColors.muted,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      relativeTimeLabel(notification.createdAt, now),
                      style: const TextStyle(
                        color: ProjectNexusColors.muted,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (unread)
                Container(
                  margin: const EdgeInsets.only(left: 8, top: 6),
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: ProjectNexusColors.teal,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 44,
              color: ProjectNexusColors.muted,
            ),
            SizedBox(height: 12),
            Text(
              'Belum ada notifikasi',
              style: TextStyle(
                color: ProjectNexusColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Kabar tentang proyek, lamaran, dan tugas akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: ProjectNexusColors.muted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
