import 'package:flutter/material.dart';

import '../../../core/theme/project_nexus_colors.dart';
import '../../dashboard/widgets/project_card.dart';
import '../../notifications/models/app_notification.dart';
import '../models/team_chat_store.dart';
import '../models/team_message.dart';

/// Ruang diskusi satu tim: ketua, anggota, dan guru pendamping dapat saling
/// berkirim pesan tanpa harus pindah ke aplikasi lain.
class TeamDiscussionScreen extends StatefulWidget {
  const TeamDiscussionScreen({
    required this.store,
    required this.projectId,
    required this.projectTitle,
    required this.me,
    required this.members,
    this.readOnly = false,
    super.key,
  });

  final TeamChatStore store;
  final String projectId;
  final String projectTitle;
  final String me;

  /// Pasangan (nama, peran) anggota tim untuk label pengirim.
  final List<(String, String)> members;
  final bool readOnly;

  @override
  State<TeamDiscussionScreen> createState() => _TeamDiscussionScreenState();
}

class _TeamDiscussionScreenState extends State<TeamDiscussionScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.store.watch(widget.projectId);
    widget.store.addListener(_scrollToEnd);
    _scrollToEnd();
  }

  @override
  void dispose() {
    widget.store.removeListener(_scrollToEnd);
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  void _send() {
    final sent = widget.store.send(
      projectId: widget.projectId,
      sender: widget.me,
      text: _input.text,
    );
    if (sent) _input.clear();
  }

  String _roleOf(String name) {
    for (final (member, role) in widget.members) {
      if (member.toLowerCase() == name.toLowerCase()) return role;
    }
    return 'Anggota tim';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Diskusi tim'),
            Text(
              widget.projectTitle,
              style: const TextStyle(
                fontSize: 12,
                color: ProjectNexusColors.muted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListenableBuilder(
              listenable: widget.store,
              builder: (context, _) {
                final messages = widget.store.messagesFor(widget.projectId);
                if (messages.isEmpty) {
                  return const _EmptyDiscussion();
                }
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final previous = index == 0 ? null : messages[index - 1];
                    final newDay =
                        previous == null ||
                        !_sameDay(previous.sentAt, message.sentAt);
                    final grouped =
                        !newDay && previous.sender == message.sender;
                    return Column(
                      children: [
                        if (newDay) _DayDivider(message.sentAt),
                        _Bubble(
                          message: message,
                          mine:
                              message.sender.toLowerCase() ==
                              widget.me.toLowerCase(),
                          role: _roleOf(message.sender),
                          showSender: !grouped,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          if (widget.readOnly)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Hanya anggota tim yang dapat mengirim pesan.',
                style: TextStyle(color: ProjectNexusColors.muted),
              ),
            )
          else
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                decoration: const BoxDecoration(
                  color: ProjectNexusColors.surface,
                  border: Border(
                    top: BorderSide(color: ProjectNexusColors.border),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('discussion_input'),
                        controller: _input,
                        minLines: 1,
                        maxLines: 4,
                        maxLength: TeamMessage.maxLength,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: const InputDecoration(
                          hintText: 'Tulis pesan untuk tim…',
                          counterText: '',
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton.filled(
                      key: const Key('discussion_send'),
                      tooltip: 'Kirim',
                      onPressed: _send,
                      icon: const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _EmptyDiscussion extends StatelessWidget {
  const _EmptyDiscussion();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 48,
              color: ProjectNexusColors.teal,
            ),
            SizedBox(height: 12),
            Text(
              'Belum ada pesan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 4),
            Text(
              'Sapa timmu dan mulai bagi ide, jadwal latihan, atau kabar terbaru.',
              textAlign: TextAlign.center,
              style: TextStyle(color: ProjectNexusColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayDivider extends StatelessWidget {
  const _DayDivider(this.time);

  final DateTime time;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(time.year, time.month, time.day);
    final label = switch (today.difference(day).inDays) {
      0 => 'Hari ini',
      1 => 'Kemarin',
      // Lebih dari seminggu dipaksa agar tampil sebagai tanggal.
      _ => relativeTimeLabel(time, time.add(const Duration(days: 30))),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: ProjectNexusColors.field,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: ProjectNexusColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.message,
    required this.mine,
    required this.role,
    required this.showSender,
  });

  final TeamMessage message;
  final bool mine;
  final String role;
  final bool showSender;

  @override
  Widget build(BuildContext context) {
    final time =
        '${message.sentAt.hour.toString().padLeft(2, '0')}.'
        '${message.sentAt.minute.toString().padLeft(2, '0')}';
    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 520),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      decoration: BoxDecoration(
        color: mine ? ProjectNexusColors.teal : ProjectNexusColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(mine ? 16 : 4),
          bottomRight: Radius.circular(mine ? 4 : 16),
        ),
        border: mine ? null : Border.all(color: ProjectNexusColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showSender && !mine)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '${message.sender} · $role',
                style: const TextStyle(
                  color: ProjectNexusColors.teal,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          Text(
            message.text,
            style: TextStyle(
              color: mine ? Colors.white : ProjectNexusColors.ink,
              fontSize: 14,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.bottomRight,
            widthFactor: 1,
            child: Text(
              time,
              style: TextStyle(
                color: mine
                    ? Colors.white.withValues(alpha: 0.75)
                    : ProjectNexusColors.muted,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
    return Padding(
      padding: EdgeInsets.only(top: showSender ? 8 : 3),
      child: Row(
        mainAxisAlignment: mine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!mine) ...[
            showSender
                ? PersonAvatar(message.sender, radius: 14)
                : const SizedBox(width: 28),
            const SizedBox(width: 8),
          ],
          Flexible(child: bubble),
        ],
      ),
    );
  }
}
