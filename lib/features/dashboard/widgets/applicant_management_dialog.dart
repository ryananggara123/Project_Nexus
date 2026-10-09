import 'package:flutter/material.dart';

import '../../auth/models/user_role.dart';
import '../models/dashboard_models.dart';
import '../models/project_application.dart';
import '../models/project_workflow_store.dart';

class ApplicantManagementDialog extends StatelessWidget {
  const ApplicantManagementDialog({
    required this.project,
    required this.leaderName,
    required this.role,
    required this.store,
    super.key,
  });

  final ProjectListing project;
  final String leaderName;
  final UserRole role;
  final ProjectWorkflowStore store;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Kelola pelamar'),
      content: SizedBox(
        width: 520,
        child: AnimatedBuilder(
          animation: store,
          builder: (context, _) {
            final currentProject = store.projects.firstWhere(
              (item) => item.id == project.id,
              orElse: () => project,
            );
            final applications = store.applicationsFor(project.id);
            final pendingApplications = applications
                .where(
                  (application) =>
                      application.status == ProjectApplicationStatus.pending,
                )
                .toList();
            final acceptedApplications = applications
                .where(
                  (application) =>
                      application.status == ProjectApplicationStatus.accepted,
                )
                .toList();
            final rejectedApplications = applications
                .where(
                  (application) =>
                      application.status == ProjectApplicationStatus.rejected,
                )
                .toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentProject.title,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${acceptedApplications.length + 1} anggota termasuk ketua',
                    key: const Key('project_member_count'),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Jumlah anggota menyesuaikan kebutuhan proyek; tidak ada batas tetap.',
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    key: const Key('recruitment_open_toggle'),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Rekrutmen terbuka'),
                    subtitle: Text(
                      currentProject.recruitmentOpen
                          ? 'Siswa dapat mengajukan diri.'
                          : 'Pengajuan baru ditutup.',
                    ),
                    value: currentProject.recruitmentOpen,
                    onChanged: (isOpen) {
                      final result = store.setRecruitmentOpen(
                        projectId: project.id,
                        leaderName: leaderName,
                        role: role,
                        isOpen: isOpen,
                      );
                      _showActionResult(context, result);
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Menunggu (${pendingApplications.length})',
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  if (pendingApplications.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Belum ada pelamar yang menunggu keputusan.'),
                    )
                  else
                    ...pendingApplications.map(
                      (application) => _ApplicationTile(
                        project: currentProject,
                        application: application,
                        onAccept: () => _review(context, application, true),
                        onReject: () => _review(context, application, false),
                      ),
                    ),
                  if (acceptedApplications.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Anggota diterima (${acceptedApplications.length})',
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    ...acceptedApplications.map(
                      (application) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          child: Icon(Icons.person_rounded),
                        ),
                        title: Text(application.applicantName),
                        subtitle: const Text('Anggota tim'),
                        trailing: const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF39825A),
                        ),
                      ),
                    ),
                  ],
                  if (rejectedApplications.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Tidak diterima (${rejectedApplications.length})',
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    ...rejectedApplications.map(
                      (application) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          child: Icon(Icons.person_outline_rounded),
                        ),
                        title: Text(application.applicantName),
                        subtitle: const Text('Lamaran ditolak'),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
      ],
    );
  }

  void _review(
    BuildContext context,
    ProjectApplication application,
    bool accept,
  ) {
    final result = store.reviewApplication(
      projectId: project.id,
      applicantName: application.applicantName,
      reviewerName: leaderName,
      role: role,
      accept: accept,
    );
    _showActionResult(context, result);
  }

  void _showActionResult(BuildContext context, WorkflowActionResult result) {
    final message = switch (result) {
      WorkflowActionResult.success => 'Perubahan berhasil disimpan.',
      WorkflowActionResult.notProjectLeader =>
        'Hanya ketua proyek yang dapat mengelola rekrutmen.',
      WorkflowActionResult.notAuthorized =>
        'Peran akun ini tidak memiliki akses untuk tindakan tersebut.',
      WorkflowActionResult.notAssignedTeacher =>
        'Hanya guru pendamping proyek yang dapat meninjaunya.',
      WorkflowActionResult.applicationAlreadyReviewed =>
        'Lamaran ini sudah ditinjau.',
      WorkflowActionResult.applicationNotFound => 'Lamaran tidak ditemukan.',
      WorkflowActionResult.recruitmentClosed =>
        'Rekrutmen proyek sudah ditutup.',
      WorkflowActionResult.invalidTransition =>
        'Status proyek atau lamaran sudah berubah.',
      _ => 'Perubahan tidak dapat dilakukan untuk proyek ini.',
    };
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ApplicationTile extends StatelessWidget {
  const _ApplicationTile({
    required this.project,
    required this.application,
    required this.onAccept,
    required this.onReject,
  });

  final ProjectListing project;
  final ProjectApplication application;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key('application_${application.applicantName}'),
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              application.applicantName,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            if (application.skills.isNotEmpty)
              Text('Keahlian: ${application.skills.join(', ')}')
            else
              const Text('Belum mengisi keahlian profil.'),
            const SizedBox(height: 4),
            Text(
              _matchingSkillsLabel(),
              style: const TextStyle(
                color: Color(0xFF087E8B),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            if (application.portfolioItems.isEmpty)
              const Text('Belum menambahkan karya portofolio.')
            else
              ...application.portfolioItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text('${item.category} · ${item.year}'),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  key: Key('reject_${application.applicantName}'),
                  onPressed: onReject,
                  child: const Text('Tolak'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  key: Key('accept_${application.applicantName}'),
                  onPressed: onAccept,
                  child: const Text('Terima'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _matchingSkillsLabel() {
    final requiredSkills = project.skills
        .map((skill) => skill.toLowerCase())
        .toSet();
    final matched = application.skills
        .where((skill) => requiredSkills.contains(skill.toLowerCase()))
        .toSet()
        .toList();
    return matched.isEmpty
        ? 'Belum ada keahlian yang cocok.'
        : 'Keahlian cocok: ${matched.join(', ')}';
  }
}
