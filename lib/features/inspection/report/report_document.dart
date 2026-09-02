import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Turns a laid-out report widget into a PDF.
///
/// The page is drawn by Flutter and rasterised, rather than composed with the
/// PDF library's own text layout. That library does not shape complex scripts:
/// Bangla conjuncts (ক্ষ, ঙ্গ) and pre-base vowel signs (ে, ি) come out broken or
/// reordered. A government office receiving a mangled Bangla document is worse
/// off than one receiving none, so the text is rendered by the engine that gets
/// it right and placed into the page as an image.
class ReportDocument {
  const ReportDocument();

  /// Generous ceiling for the measuring pass. A report longer than this is
  /// already unreadable as one page.
  static const double _maxPageHeight = 30000;

  /// Renders [child] at [width] logical pixels, at whatever height it needs.
  ///
  /// Built off-screen through its own pipeline so the user never sees a flash
  /// of the print layout, and so the capture is not clipped to the viewport
  /// the way a RepaintBoundary inside a scroll view would be.
  Future<Uint8List> rasterise(
    Widget child, {
    double width = 1240,
    double pixelRatio = 1.0,
  }) async {
    final boundary = RenderRepaintBoundary();
    final view = WidgetsBinding.instance.platformDispatcher.views.first;

    final renderView = RenderView(
      view: view,
      child: RenderPositionedBox(
        alignment: Alignment.topLeft,
        child: boundary,
      ),
      // The measuring pass fixes the width and leaves the height free, so the
      // content settles at its natural size. Tightening the height here — as
      // an obvious first attempt does — pins every report to that height and
      // silently crops it.
      configuration: ViewConfiguration(
        logicalConstraints: BoxConstraints(
          minWidth: width,
          maxWidth: width,
          maxHeight: _maxPageHeight,
        ),
        devicePixelRatio: pixelRatio,
      ),
    );

    final pipelineOwner = PipelineOwner()..rootNode = renderView;
    renderView.prepareInitialFrame();

    final buildOwner = BuildOwner(focusManager: FocusManager());
    final element = RenderObjectToWidgetAdapter<RenderBox>(
      container: boundary,
      child: Directionality(textDirection: TextDirection.ltr, child: child),
    ).attachToRenderTree(buildOwner);

    // First pass measures the natural height, second lays it out for real.
    buildOwner
      ..buildScope(element)
      ..finalizeTree();
    pipelineOwner
      ..flushLayout()
      ..flushCompositingBits()
      ..flushPaint();

    final height = boundary.size.height;
    renderView.configuration = ViewConfiguration(
      logicalConstraints: BoxConstraints.tight(Size(width, height)),
      devicePixelRatio: pixelRatio,
    );

    buildOwner
      ..buildScope(element)
      ..finalizeTree();
    pipelineOwner
      ..flushLayout()
      ..flushCompositingBits()
      ..flushPaint();

    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data!.buffer.asUint8List();
  }

  /// Wraps a rendered page image into a single-page PDF sized to match it.
  Future<Uint8List> toPdf(Uint8List pageImage) async {
    final doc = pw.Document();
    final image = pw.MemoryImage(pageImage);
    // A4 width, height following the image so nothing is cropped.
    final aspect = (image.height ?? 1) / (image.width ?? 1);
    final pageHeight = PdfPageFormat.a4.width * aspect;
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(PdfPageFormat.a4.width, pageHeight),
        build: (_) => pw.Image(image, fit: pw.BoxFit.fitWidth),
      ),
    );
    return doc.save();
  }

  /// Writes [bytes] into [directory] and returns the file.
  Future<File> write(
    Uint8List bytes,
    Directory directory,
    String fileName,
  ) async {
    if (!directory.existsSync()) directory.createSync(recursive: true);
    final file = File('${directory.path}/$fileName');
    file.writeAsBytesSync(bytes);
    return file;
  }
}
