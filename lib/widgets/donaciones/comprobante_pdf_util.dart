import 'package:donaciones_movil/controllers/detalle_asignacion_controller.dart';
import 'package:donaciones_movil/models/asignacion.dart';
import 'package:donaciones_movil/models/campania.dart';
import 'package:donaciones_movil/models/donacion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

Future<void> generarComprobantePdf({
  required BuildContext context,
  required Asignacion asignacion,
  required Donacion donacion,
  required Campania campania,
  required String nombreEstado,
}) async {
  final pdf = pw.Document();
  final detalles = context.read<DetalleAsignacionController>()
      .detalles
      ?.where((d) => d.asignacionId == asignacion.asignacionId)
      .toList() ?? [];

  final subtotal = detalles.fold<double>(0, (sum, d) => sum + (d.cantidad * d.precioUnitario));
  final now = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

  // Cargar logo
  final logoData = await rootBundle.load('assets/logo.png');
  final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

  // Definir colores usando la paleta proporcionada
  final colorPrimario = PdfColor.fromHex('#F58C5B');
  final colorSecundario = PdfColor.fromHex('#5C6B73');
  final colorFondo = PdfColor.fromHex('#FFF8F4');
  final colorTexto = PdfColor.fromHex('#2F2F2F');
  final colorTextoSecundario = PdfColor.fromHex('#787878');
  final colorSuave = PdfColor.fromHex('#FFE5D4');

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Stack(
          children: [
            // Marca de agua
            pw.Positioned(
              left: (PdfPageFormat.a4.width - 400) / 2,
              top: (PdfPageFormat.a4.height - 400) / 2,
              child: pw.Opacity(
                opacity: 0.1,
                child: pw.Image(
                  logoImage,
                  width: 300,
                  height: 300,
                ),
              ),
            ),

            // Contenido principal
            pw.Padding(
              padding: const pw.EdgeInsets.all(40),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Encabezado con logo centrado
                  pw.Table(
                    columnWidths: {
                      0: const pw.FlexColumnWidth(1),
                      1: const pw.FlexColumnWidth(1),
                      2: const pw.FlexColumnWidth(1),
                    },
                    children: [
                      pw.TableRow(
                        children: [
                          pw.Container(), // Celda vacía izquierda
                          pw.Center(
                            child: pw.Image(
                              logoImage,
                              width: 80,
                              height: 80,
                            ),
                          ),
                          pw.Container(), // Celda vacía derecha
                        ],
                      ),
                    ],
                  ),
                  
                  pw.SizedBox(height: 20),
                  
                  // Información de la organización y número de comprobante
                  pw.Table(
                    columnWidths: {
                      0: const pw.FlexColumnWidth(3),
                      1: const pw.FlexColumnWidth(2),
                    },
                    children: [
                      pw.TableRow(
                        children: [
                          // Información de la organización
                          pw.Container(
                            padding: const pw.EdgeInsets.all(12),
                            decoration: pw.BoxDecoration(
                              borderRadius: pw.BorderRadius.circular(8),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'TRACEGIVE',
                                  style: pw.TextStyle(
                                    fontSize: 14,
                                    fontWeight: pw.FontWeight.bold,
                                    color: colorTexto,
                                  ),
                                ),
                                pw.SizedBox(height: 4),
                                pw.Text(
                                  'Sistema de Donaciones',
                                  style: pw.TextStyle(fontSize: 10, color: colorTextoSecundario),
                                ),
                                pw.Text(
                                  'Transparencia en cada donación',
                                  style: pw.TextStyle(fontSize: 10, color: colorTextoSecundario),
                                ),
                              ],
                            ),
                          ),
                          
                          // Número de comprobante
                          pw.Container(
                            padding: const pw.EdgeInsets.all(12),
                            decoration: pw.BoxDecoration(
                              borderRadius: pw.BorderRadius.circular(8),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              children: [
                                pw.Text(
                                  'COMPROBANTE',
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                    fontWeight: pw.FontWeight.bold,
                                    color: colorTexto,
                                  ),
                                ),
                                pw.Text(
                                  '#${asignacion.asignacionId?.toString().padLeft(6, '0') ?? '000000'}',
                                  style: pw.TextStyle(
                                    fontSize: 14,
                                    fontWeight: pw.FontWeight.bold,
                                    color: colorPrimario,
                                  ),
                                ),
                                pw.Text(
                                  'Fecha: $now',
                                  style: pw.TextStyle(fontSize: 9, color: colorTextoSecundario),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  pw.SizedBox(height: 20),
                  
                  // Línea separadora
                  pw.Container(
                    height: 2,
                    color: colorSecundario,
                  ),
                  
                  pw.SizedBox(height: 20),
                  
                  // Información de donación y campaña
                  pw.Table(
                    columnWidths: {
                      0: const pw.FlexColumnWidth(1),
                      1: const pw.FlexColumnWidth(1),
                    },
                    children: [
                      pw.TableRow(
                        children: [
                          // Información de donación
                          pw.Container(
                            padding: const pw.EdgeInsets.all(12),
                            decoration: pw.BoxDecoration(
                              borderRadius: pw.BorderRadius.circular(8),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'DATOS DE LA DONACIÓN',
                                  style: pw.TextStyle(
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold,
                                    color: colorTexto,
                                  ),
                                ),
                                pw.SizedBox(height: 6),
                                pw.Text(
                                  'Monto: Bs ${donacion.monto.toStringAsFixed(2)}',
                                  style: pw.TextStyle(fontSize: 10, color: colorTextoSecundario),
                                ),
                                pw.Text(
                                  'Tipo: ${donacion.tipoDonacion}',
                                  style: pw.TextStyle(fontSize: 10, color: colorTextoSecundario),
                                ),
                                if (donacion.fechaDonacion != null)
                                  pw.Text(
                                    'Fecha: ${DateFormat('dd/MM/yyyy').format(donacion.fechaDonacion!)}',
                                    style: pw.TextStyle(fontSize: 10, color: colorTextoSecundario),
                                  ),
                              ],
                            ),
                          ),
                          
                          // Información de campaña
                          pw.Container(
                            padding: const pw.EdgeInsets.all(12),
                            decoration: pw.BoxDecoration(
                              borderRadius: pw.BorderRadius.circular(8),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'CAMPAÑA BENEFICIARIA',
                                  style: pw.TextStyle(
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold,
                                    color: colorTexto,
                                  ),
                                ),
                                pw.SizedBox(height: 6),
                                pw.Text(
                                  campania.titulo,
                                  style: pw.TextStyle(fontSize: 10, color: colorTextoSecundario),
                                ),
                                pw.Text(
                                  campania.descripcion,
                                  style: pw.TextStyle(fontSize: 9, color: colorTextoSecundario),
                                  maxLines: 3,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  pw.SizedBox(height: 16),
                  
                  // Información de asignación
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: colorSuave,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'ASIGNACIÓN ESPECÍFICA',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: colorTexto,
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          'Descripción: ${asignacion.descripcion}',
                          style: pw.TextStyle(fontSize: 10, color: colorTextoSecundario),
                        ),
                        if (asignacion.fechaAsignacion != null)
                          pw.Text(
                            'Fecha de asignación: ${DateFormat('dd/MM/yyyy').format(asignacion.fechaAsignacion!)}',
                            style: pw.TextStyle(fontSize: 10, color: colorTextoSecundario),
                          ),
                        pw.Text(
                          'Estado: $nombreEstado',
                          style: pw.TextStyle(fontSize: 10, color: colorTextoSecundario),
                        ),
                      ],
                    ),
                  ),
                  
                  pw.SizedBox(height: 16),
                  
                  // Tabla de detalles si existe
                  if (detalles.isNotEmpty) ...[
                    pw.Table(
                      border: pw.TableBorder.all(color: colorSecundario, width: 0.5),
                      columnWidths: {
                        0: const pw.FlexColumnWidth(3),
                        1: const pw.FlexColumnWidth(1),
                        2: const pw.FlexColumnWidth(2),
                        3: const pw.FlexColumnWidth(2),
                      },
                      children: [
                        // Encabezado
                        pw.TableRow(
                          decoration: pw.BoxDecoration(color: colorPrimario),
                          children: [
                            pw.Container(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                'Concepto',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white,
                                ),
                              ),
                            ),
                            pw.Container(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                'Cant.',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white,
                                ),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Container(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                'P. Unitario',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white,
                                ),
                                textAlign: pw.TextAlign.right,
                              ),
                            ),
                            pw.Container(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                'Subtotal',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white,
                                ),
                                textAlign: pw.TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                        
                        // Filas de datos
                        ...detalles.asMap().entries.map((entry) {
                          final index = entry.key;
                          final d = entry.value;
                          final sub = d.cantidad * d.precioUnitario;
                          final rowColor = index % 2 == 0 ? colorFondo : PdfColors.white;
                          
                          return pw.TableRow(
                            decoration: pw.BoxDecoration(color: rowColor),
                            children: [
                              pw.Container(
                                padding: const pw.EdgeInsets.all(6),
                                child: pw.Text(
                                  d.concepto,
                                  style: pw.TextStyle(fontSize: 9, color: colorTexto),
                                ),
                              ),
                              pw.Container(
                                padding: const pw.EdgeInsets.all(6),
                                child: pw.Text(
                                  '${d.cantidad}',
                                  style: pw.TextStyle(fontSize: 9, color: colorTexto),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                              pw.Container(
                                padding: const pw.EdgeInsets.all(6),
                                child: pw.Text(
                                  'Bs ${d.precioUnitario.toStringAsFixed(2)}',
                                  style: pw.TextStyle(fontSize: 9, color: colorTexto),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                              pw.Container(
                                padding: const pw.EdgeInsets.all(6),
                                child: pw.Text(
                                  'Bs ${sub.toStringAsFixed(2)}',
                                  style: pw.TextStyle(fontSize: 9, color: colorTexto),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                        
                        // Fila de total
                        pw.TableRow(
                          decoration: pw.BoxDecoration(color: colorSecundario),
                          children: [
                            pw.Container(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                'TOTAL ASIGNADO:',
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white,
                                ),
                                textAlign: pw.TextAlign.right,
                              ),
                            ),
                            pw.Container(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(''),
                            ),
                            pw.Container(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(''),
                            ),
                            pw.Container(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                'Bs ${subtotal.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white,
                                ),
                                textAlign: pw.TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 16),
                  ],
                  
                  pw.Spacer(),
                  
                  // Pie de página
                  pw.Center(
                    child: pw.Column(
                      children: [
                        pw.Text(
                          '¡Gracias por su generosa contribución!',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: colorPrimario,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Este documento certifica el uso específico de los fondos donados.',
                          style: pw.TextStyle(fontSize: 9, color: colorTextoSecundario),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.Text(
                          'Su transparencia es nuestro compromiso.',
                          style: pw.TextStyle(fontSize: 9, color: colorTextoSecundario),
                          textAlign: pw.TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(onLayout: (format) => pdf.save());
}