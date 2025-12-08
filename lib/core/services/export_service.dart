import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

/// Servicio de exportación a PDF y Excel
class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  final _currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  // ==================== EXPORTACIÓN A PDF ====================

  /// Exportar reporte de ventas a PDF
  Future<File> exportSalesReportToPdf({
    required Map<String, dynamic> salesData,
    required String period,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildPdfHeader('Reporte de Ventas', period),
        footer: (context) => _buildPdfFooter(context),
        build: (context) => [
          _buildSalesSummary(salesData),
          pw.SizedBox(height: 20),
          _buildSalesChart(salesData),
          pw.SizedBox(height: 20),
          _buildPaymentMethodsTable(salesData),
        ],
      ),
    );

    return await _savePdfFile(pdf, 'ventas_$period');
  }

  /// Exportar reporte de productos a PDF
  Future<File> exportProductsReportToPdf({
    required List<Map<String, dynamic>> topProducts,
    required Map<String, dynamic> categoryData,
    required String period,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildPdfHeader('Reporte de Productos', period),
        footer: (context) => _buildPdfFooter(context),
        build: (context) => [
          _buildTopProductsTable(topProducts),
          pw.SizedBox(height: 20),
          _buildCategoryBreakdown(categoryData),
        ],
      ),
    );

    return await _savePdfFile(pdf, 'productos_$period');
  }

  /// Exportar reporte general a PDF
  Future<File> exportGeneralReportToPdf({
    required Map<String, dynamic> summaryData,
    required String period,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildPdfHeader('Resumen General', period),
        footer: (context) => _buildPdfFooter(context),
        build: (context) => [
          _buildGeneralSummaryTable(summaryData),
          pw.SizedBox(height: 20),
          _buildInsightsSection(summaryData),
        ],
      ),
    );

    return await _savePdfFile(pdf, 'resumen_$period');
  }

  /// Exportar pedidos de cocina a PDF
  Future<File> exportKitchenOrdersToPdf({
    required List<Map<String, dynamic>> orders,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildPdfHeader(
          'Pedidos de Cocina',
          DateFormat('dd/MM/yyyy').format(DateTime.now()),
        ),
        footer: (context) => _buildPdfFooter(context),
        build: (context) => [
          _buildKitchenOrdersTable(orders),
        ],
      ),
    );

    return await _savePdfFile(
        pdf, 'cocina_${DateTime.now().millisecondsSinceEpoch}');
  }

  // ==================== EXPORTACIÓN A EXCEL ====================

  /// Exportar reporte de ventas a Excel
  Future<File> exportSalesReportToExcel({
    required Map<String, dynamic> salesData,
    required List<Map<String, dynamic>> dailyData,
    required String period,
  }) async {
    final excel = Excel.createExcel();

    // Hoja de resumen
    final summarySheet = excel['Resumen'];
    _addExcelRow(summarySheet, 0, ['Reporte de Ventas - $period'], bold: true);
    _addExcelRow(
        summarySheet, 1, ['Generado:', _dateFormat.format(DateTime.now())]);
    _addExcelRow(summarySheet, 3, ['Métrica', 'Valor'], bold: true);
    _addExcelRow(
        summarySheet, 4, ['Total Ventas', salesData['totalSales'] ?? 0]);
    _addExcelRow(summarySheet, 5,
        ['Cantidad de Pedidos', salesData['totalOrders'] ?? 0]);
    _addExcelRow(
        summarySheet, 6, ['Ticket Promedio', salesData['averageTicket'] ?? 0]);

    // Hoja de datos diarios
    final dailySheet = excel['Ventas Diarias'];
    _addExcelRow(
        dailySheet, 0, ['Fecha', 'Ventas', 'Pedidos', 'Ticket Promedio'],
        bold: true);

    for (int i = 0; i < dailyData.length; i++) {
      final day = dailyData[i];
      _addExcelRow(dailySheet, i + 1, [
        day['date'] ?? '',
        day['sales'] ?? 0,
        day['orders'] ?? 0,
        day['averageTicket'] ?? 0,
      ]);
    }

    // Hoja de métodos de pago
    final paymentSheet = excel['Métodos de Pago'];
    _addExcelRow(paymentSheet, 0, ['Método', 'Monto', 'Porcentaje'],
        bold: true);

    final payments = salesData['paymentMethods'] as List? ?? [];
    for (int i = 0; i < payments.length; i++) {
      final payment = payments[i];
      _addExcelRow(paymentSheet, i + 1, [
        payment['method'] ?? '',
        payment['amount'] ?? 0,
        '${payment['percentage'] ?? 0}%',
      ]);
    }

    // Eliminar hoja por defecto
    excel.delete('Sheet1');

    return await _saveExcelFile(excel, 'ventas_$period');
  }

  /// Exportar reporte de productos a Excel
  Future<File> exportProductsReportToExcel({
    required List<Map<String, dynamic>> topProducts,
    required List<Map<String, dynamic>> allProducts,
    required String period,
  }) async {
    final excel = Excel.createExcel();

    // Hoja de top productos
    final topSheet = excel['Top Productos'];
    _addExcelRow(topSheet, 0, ['#', 'Producto', 'Cantidad Vendida', 'Ingresos'],
        bold: true);

    for (int i = 0; i < topProducts.length; i++) {
      final product = topProducts[i];
      _addExcelRow(topSheet, i + 1, [
        i + 1,
        product['name'] ?? '',
        product['quantity'] ?? 0,
        product['revenue'] ?? 0,
      ]);
    }

    // Hoja de todos los productos
    final allSheet = excel['Todos los Productos'];
    _addExcelRow(allSheet, 0,
        ['ID', 'Nombre', 'Categoría', 'Precio', 'Cantidad Vendida', 'Ingresos'],
        bold: true);

    for (int i = 0; i < allProducts.length; i++) {
      final product = allProducts[i];
      _addExcelRow(allSheet, i + 1, [
        product['id'] ?? '',
        product['name'] ?? '',
        product['category'] ?? '',
        product['price'] ?? 0,
        product['quantity'] ?? 0,
        product['revenue'] ?? 0,
      ]);
    }

    excel.delete('Sheet1');

    return await _saveExcelFile(excel, 'productos_$period');
  }

  /// Exportar inventario a Excel
  Future<File> exportInventoryToExcel({
    required List<Map<String, dynamic>> inventory,
  }) async {
    final excel = Excel.createExcel();

    final sheet = excel['Inventario'];
    _addExcelRow(
        sheet,
        0,
        [
          'ID',
          'Nombre',
          'Categoría',
          'Cantidad',
          'Unidad',
          'Stock Mínimo',
          'Costo Unitario',
          'Última Actualización'
        ],
        bold: true);

    for (int i = 0; i < inventory.length; i++) {
      final item = inventory[i];
      _addExcelRow(sheet, i + 1, [
        item['id'] ?? '',
        item['name'] ?? '',
        item['category'] ?? '',
        item['quantity'] ?? 0,
        item['unit'] ?? '',
        item['min_stock'] ?? 0,
        item['unit_cost'] ?? 0,
        item['updated_at'] ?? '',
      ]);
    }

    excel.delete('Sheet1');

    return await _saveExcelFile(
        excel, 'inventario_${DateTime.now().millisecondsSinceEpoch}');
  }

  // ==================== MÉTODOS AUXILIARES PDF ====================

  pw.Widget _buildPdfHeader(String title, String period) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 20),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'SmartDinner',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
              pw.Text(title, style: const pw.TextStyle(fontSize: 16)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Período: $period'),
              pw.Text(
                'Generado: ${_dateFormat.format(DateTime.now())}',
                style:
                    const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'Página ${context.pageNumber} de ${context.pagesCount}',
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
      ),
    );
  }

  pw.Widget _buildSalesSummary(Map<String, dynamic> data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
              'Total Ventas', _currencyFormat.format(data['totalSales'] ?? 0)),
          _buildSummaryItem('Pedidos', '${data['totalOrders'] ?? 0}'),
          _buildSummaryItem('Ticket Promedio',
              _currencyFormat.format(data['averageTicket'] ?? 0)),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(label,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  pw.Widget _buildSalesChart(Map<String, dynamic> data) {
    final weeklyData = data['weeklyData'] as List? ?? [];

    return pw.Container(
      height: 150,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Ventas por Día',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Expanded(
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: weeklyData.map((day) {
                final value = (day['value'] as num?) ?? 0;
                final maxValue = weeklyData.fold<num>(0, (max, d) {
                  final v = (d['value'] as num?) ?? 0;
                  return v > max ? v : max;
                });
                final height = maxValue > 0 ? (value / maxValue) * 100 : 0;

                return pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Container(
                      width: 30,
                      height: height.toDouble(),
                      color: PdfColors.blue400,
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(day['label'] ?? '',
                        style: const pw.TextStyle(fontSize: 8)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPaymentMethodsTable(Map<String, dynamic> data) {
    final payments = data['paymentMethods'] as List? ?? [];

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableCell('Método de Pago', isHeader: true),
            _buildTableCell('Monto', isHeader: true),
            _buildTableCell('Porcentaje', isHeader: true),
          ],
        ),
        ...payments.map((payment) => pw.TableRow(
              children: [
                _buildTableCell(payment['method'] ?? ''),
                _buildTableCell(_currencyFormat.format(payment['amount'] ?? 0)),
                _buildTableCell('${payment['percentage'] ?? 0}%'),
              ],
            )),
      ],
    );
  }

  pw.Widget _buildTopProductsTable(List<Map<String, dynamic>> products) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Top 10 Productos Más Vendidos',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _buildTableCell('#', isHeader: true),
                _buildTableCell('Producto', isHeader: true),
                _buildTableCell('Cantidad', isHeader: true),
                _buildTableCell('Ingresos', isHeader: true),
              ],
            ),
            ...products.asMap().entries.map((entry) => pw.TableRow(
                  children: [
                    _buildTableCell('${entry.key + 1}'),
                    _buildTableCell(entry.value['name'] ?? ''),
                    _buildTableCell('${entry.value['quantity'] ?? 0}'),
                    _buildTableCell(
                        _currencyFormat.format(entry.value['revenue'] ?? 0)),
                  ],
                )),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildCategoryBreakdown(Map<String, dynamic> categoryData) {
    final categories = categoryData['categories'] as List? ?? [];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Ventas por Categoría',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        ...categories.map((cat) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(cat['name'] ?? ''),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Stack(
                      children: [
                        pw.Container(
                          height: 16,
                          decoration: pw.BoxDecoration(
                            color: PdfColors.grey200,
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                        ),
                        pw.Container(
                          height: 16,
                          width:
                              (((cat['percentage'] as num?) ?? 0) / 100) * 150,
                          decoration: pw.BoxDecoration(
                            color: PdfColors.blue400,
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text('${cat['percentage'] ?? 0}%'),
                ],
              ),
            )),
      ],
    );
  }

  pw.Widget _buildGeneralSummaryTable(Map<String, dynamic> data) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableCell('Métrica', isHeader: true),
            _buildTableCell('Valor', isHeader: true),
          ],
        ),
        _buildTableRowPair('Total Clientes', '${data['totalCustomers'] ?? 0}'),
        _buildTableRowPair('Mesas Utilizadas', '${data['tablesUsed'] ?? 0}'),
        _buildTableRowPair('Tiempo Promedio', '${data['avgTime'] ?? 0} min'),
        _buildTableRowPair('Reservaciones', '${data['reservations'] ?? 0}'),
        _buildTableRowPair(
            'Propinas', _currencyFormat.format(data['tips'] ?? 0)),
      ],
    );
  }

  pw.TableRow _buildTableRowPair(String label, String value) {
    return pw.TableRow(
      children: [
        _buildTableCell(label),
        _buildTableCell(value),
      ],
    );
  }

  pw.Widget _buildInsightsSection(Map<String, dynamic> data) {
    final insights = data['insights'] as List? ?? [];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Insights',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        ...insights.map((insight) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 8),
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: PdfColors.yellow50,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text('💡 $insight'),
            )),
      ],
    );
  }

  pw.Widget _buildKitchenOrdersTable(List<Map<String, dynamic>> orders) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableCell('Mesa', isHeader: true),
            _buildTableCell('Pedido', isHeader: true),
            _buildTableCell('Items', isHeader: true),
            _buildTableCell('Estado', isHeader: true),
            _buildTableCell('Tiempo', isHeader: true),
          ],
        ),
        ...orders.map((order) => pw.TableRow(
              children: [
                _buildTableCell('${order['table'] ?? '-'}'),
                _buildTableCell('#${order['id'] ?? ''}'),
                _buildTableCell('${order['itemCount'] ?? 0}'),
                _buildTableCell(order['status'] ?? ''),
                _buildTableCell('${order['minutes'] ?? 0} min'),
              ],
            )),
      ],
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : null,
        ),
      ),
    );
  }

  Future<File> _savePdfFile(pw.Document pdf, String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$name.pdf');
    await file.writeAsBytes(await pdf.save());
    developer.log('📄 PDF guardado: ${file.path}');
    return file;
  }

  // ==================== MÉTODOS AUXILIARES EXCEL ====================

  void _addExcelRow(Sheet sheet, int row, List<dynamic> values,
      {bool bold = false}) {
    for (int col = 0; col < values.length; col++) {
      final cell = sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
      cell.value = values[col] is String
          ? TextCellValue(values[col])
          : values[col] is int
              ? IntCellValue(values[col])
              : values[col] is double
                  ? DoubleCellValue(values[col])
                  : TextCellValue(values[col].toString());

      if (bold) {
        cell.cellStyle = CellStyle(bold: true);
      }
    }
  }

  Future<File> _saveExcelFile(Excel excel, String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$name.xlsx');
    final bytes = excel.encode();
    if (bytes != null) {
      await file.writeAsBytes(bytes);
      developer.log('📊 Excel guardado: ${file.path}');
    }
    return file;
  }

  // ==================== COMPARTIR ARCHIVOS ====================

  /// Compartir archivo exportado
  Future<void> shareFile(File file, {String? subject}) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: subject ?? 'Reporte SmartDinner',
    );
  }
}
