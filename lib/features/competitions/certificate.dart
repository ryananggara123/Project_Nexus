import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../dashboard/models/dashboard_models.dart';

const _teal = PdfColor.fromInt(0xFF087E8B);
const _tealDeep = PdfColor.fromInt(0xFF0B2A2E);
const _gold = PdfColor.fromInt(0xFFC9972B);
const _muted = PdfColor.fromInt(0xFF627174);

const _months = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', //
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

String _date(DateTime date) =>
    '${date.day} ${_months[date.month - 1]} ${date.year}';

/// Membuat sertifikat untuk satu anggota tim. Juara 1–3 dan Harapan
/// mendapat sertifikat prestasi; finalis dan peserta mendapat sertifikat
/// partisipasi.
Future<Uint8List> buildCertificate({
  required String memberName,
  required ProjectListing project,
  required String eventName,
}) async {
  Future<pw.Font> font(int weight) async => pw.Font.ttf(
    await rootBundle.load('assets/fonts/PlusJakartaSans-$weight.ttf'),
  );
  final regular = await font(400);
  final bold = await font(700);
  final heavy = await font(800);
  final logo = pw.MemoryImage(
    (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List(),
  );
  final result = project.result ?? CompetitionResult.participant;
  final achievement = result.isWinner || result == CompetitionResult.honorable;
  final issued = project.resultAt ?? DateTime.now();

  final doc = pw.Document(
    title: 'Sertifikat $memberName',
    author: 'ProjectNexus',
    theme: pw.ThemeData.withFont(base: regular, bold: bold),
  );
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: pw.EdgeInsets.zero,
      build: (context) => pw.Container(
        margin: const pw.EdgeInsets.all(22),
        padding: const pw.EdgeInsets.all(6),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: _gold, width: 2),
        ),
        child: pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 60, vertical: 36),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: _teal, width: 6),
          ),
          child: pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Image(logo, width: 28, height: 28),
                  pw.SizedBox(width: 10),
                  pw.Text(
                    'ProjectNexus',
                    style: pw.TextStyle(
                      font: heavy,
                      fontSize: 18,
                      color: _tealDeep,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 22),
              pw.Text(
                achievement ? 'SERTIFIKAT PRESTASI' : 'SERTIFIKAT PARTISIPASI',
                style: pw.TextStyle(
                  font: heavy,
                  fontSize: 32,
                  color: _tealDeep,
                  letterSpacing: 3,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Container(width: 120, height: 3, color: _gold),
              pw.SizedBox(height: 22),
              pw.Text(
                'Diberikan kepada',
                style: const pw.TextStyle(fontSize: 13, color: _muted),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                memberName,
                style: pw.TextStyle(font: heavy, fontSize: 34, color: _teal),
              ),
              pw.SizedBox(height: 14),
              pw.Text(
                achievement
                    ? 'atas prestasinya meraih ${result.label} bersama tim '
                          '“${project.title}”'
                    : 'atas partisipasinya sebagai ${result.label.toLowerCase()} '
                          'bersama tim “${project.title}”',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 15),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'dalam $eventName',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(font: bold, fontSize: 15, color: _tealDeep),
              ),
              if ((project.resultNote ?? '').isNotEmpty) ...[
                pw.SizedBox(height: 8),
                pw.Text(
                  project.resultNote!,
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 11, color: _muted),
                ),
              ],
              pw.Spacer(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Diterbitkan',
                        style: const pw.TextStyle(fontSize: 10, color: _muted),
                      ),
                      pw.Text(
                        _date(issued),
                        style: pw.TextStyle(font: bold, fontSize: 12),
                      ),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(width: 180, height: 1, color: _tealDeep),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        project.teacherName,
                        style: pw.TextStyle(font: bold, fontSize: 12),
                      ),
                      pw.Text(
                        'Guru Pendamping',
                        style: const pw.TextStyle(fontSize: 10, color: _muted),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
  return doc.save();
}

/// Membuka lembar bagikan (Android) atau mengunduh berkas (web).
Future<void> shareCertificate({
  required String memberName,
  required ProjectListing project,
  required String eventName,
}) async {
  final bytes = await buildCertificate(
    memberName: memberName,
    project: project,
    eventName: eventName,
  );
  final slug = memberName.toLowerCase().replaceAll(RegExp('[^a-z0-9]+'), '-');
  await Printing.sharePdf(bytes: bytes, filename: 'sertifikat-$slug.pdf');
}
