import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:craftsman_app/models/verification_stats.dart';

class ReportExportService {
  Future<void> exportVerificationReport(VerificationStats stats) async {
    try {
      // Create PDF document
      final PdfDocument document = PdfDocument();
      
      // Add cover page with logo
      final PdfPage coverPage = document.pages.add();
      _drawCoverPage(coverPage);

      // Add stats page
      final PdfPage statsPage = document.pages.add();
      _drawTitle(statsPage, 'Verification Statistics');
      _drawStatsTable(statsPage, stats);

      // Add chart page
      final PdfPage chartPage = document.pages.add();
      _drawTitle(chartPage, 'Verification Breakdown');
      _drawVerificationChart(chartPage, stats);

      // Add footer to all pages
      for (int i = 0; i < document.pages.count; i++) {
        _drawFooter(document.pages[i], DateTime.now());
      }

      // Save and open document
      final Directory directory = await getApplicationDocumentsDirectory();
      final String path = '${directory.path}/verification_report.pdf';
      final File file = File(path);
      await file.writeAsBytes(await document.save());
      document.dispose();

      await OpenFile.open(path);
    } catch (e) {
      throw Exception('Failed to generate report: $e');
    }
  }

  void _drawCoverPage(PdfPage page) {
    final Size pageSize = page.getClientSize();
    
    // Add title
    page.graphics.drawString(
      'Verification Report',
      PdfStandardFont(PdfFontFamily.helvetica, 30, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(0, pageSize.height / 3, pageSize.width, 50),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );

    // Add subtitle
    page.graphics.drawString(
      'Craftsman App Analytics',
      PdfStandardFont(PdfFontFamily.helvetica, 18),
      bounds: Rect.fromLTWH(0, pageSize.height / 3 + 60, pageSize.width, 30),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );

    // Add date
    page.graphics.drawString(
      'Generated on ${DateTime.now().toLocal()}',
      PdfStandardFont(PdfFontFamily.helvetica, 12),
      bounds: Rect.fromLTWH(0, pageSize.height - 100, pageSize.width, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
  }

  void _drawTitle(PdfPage page, String title) {
    page.graphics.drawString(
      title,
      PdfStandardFont(PdfFontFamily.helvetica, 20, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(0, 30, page.getClientSize().width, 40),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
  }

  void _drawStatsTable(PdfPage page, VerificationStats stats) {
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 2);
    grid.headers.add(1);

    // Style grid
    grid.style = PdfGridStyle(
      cellPadding: PdfPaddings(left: 10, right: 10, top: 10, bottom: 10),
      backgroundBrush: PdfBrushes.white,
      textBrush: PdfBrushes.black,
      font: PdfStandardFont(PdfFontFamily.helvetica, 12),
    );

    // Style header
    grid.headers[0].style = PdfGridRowStyle(
      backgroundBrush: PdfBrushes.darkBlue,
      textBrush: PdfBrushes.white,
      font: PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
    );

    // Add headers
    final PdfGridRow headerRow = grid.headers[0];
    headerRow.cells[0].value = 'Metric';
    headerRow.cells[1].value = 'Value';

    // Add data rows
    _addGridRow(grid, 'Total Users', stats.totalUsers.toString());
    _addGridRow(grid, 'Verified Users', stats.verifiedUsers.toString());
    _addGridRow(grid, 'Verification Rate', 
        '${(stats.verificationRate * 100).toStringAsFixed(1)}%');
    _addGridRow(grid, 'Email Verified', stats.emailVerified.toString());
    _addGridRow(grid, 'Manual Verified', stats.manuallyVerified.toString());

    // Style alternate rows
    for (int i = 0; i < grid.rows.count; i++) {
      if (i % 2 == 0) {
        grid.rows[i].style = PdfGridRowStyle(
          backgroundBrush: PdfBrushes.lightGray,
        );
      }
    }

    // Draw grid
    grid.draw(
      page: page,
      bounds: Rect.fromLTWH(50, 100, page.getClientSize().width - 100, 0),
    );
  }

  void _addGridRow(PdfGrid grid, String metric, String value) {
    final PdfGridRow row = grid.rows.add();
    row.cells[0].value = metric;
    row.cells[1].value = value;
  }

  void _drawVerificationChart(PdfPage page, VerificationStats stats) {
    final PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 12);
    final Size pageSize = page.getClientSize();

    // Create pie chart
    final PdfPieChart chart = PdfPieChart();
    chart.chartTitle = PdfChartTitle(
      'Verification Methods',
      font: PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold),
    );
    chart.legend = PdfChartLegend(
      position: PdfLegendPosition.bottom,
      font: font,
    );

    // Add series
    chart.series = PdfPieSeries(
      dataSource: [
        {'type': 'Email Verified', 'value': stats.emailVerified},
        {'type': 'Manual Verified', 'value': stats.manuallyVerified},
        {'type': 'Unverified', 'value': stats.totalUsers - stats.verifiedUsers},
      ],
      xValue: (data, _) => data['type'].toString(),
      yValue: (data, _) => data['value'] as num,
      dataLabel: PdfPieDataLabel(
        isVisible: true,
        font: font,
        position: PdfPieDataLabelPosition.outside,
      ),
    );

    // Draw chart
    chart.draw(
      page: page,
      bounds: Rect.fromLTWH(50, 100, pageSize.width - 100, pageSize.height - 200),
    );
  }

  void _drawFooter(PdfPage page, DateTime timestamp) {
    final PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 10);
    final Size pageSize = page.getClientSize();

    page.graphics.drawString(
      'Page ${page.section!.pages.indexOf(page) + 1} of ${page.section!.pages.count} • Generated on ${timestamp.toLocal()}',
      font,
      bounds: Rect.fromLTWH(
        0,
        pageSize.height - 40,
        pageSize.width,
        30,
      ),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );

    // Add page border
    page.graphics.drawRectangle(
      bounds: Rect.fromLTWH(25, 25, pageSize.width - 50, pageSize.height - 50),
      pen: PdfPen(PdfColor(200, 200, 200)),
    );
  }
}