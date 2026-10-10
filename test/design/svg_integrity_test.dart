import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

/// Every icon and illustration on disk is parsed and inspected.
///
/// flutter_svg fails softly -- a malformed file renders as nothing rather than
/// throwing -- so a broken asset would slip through a widget test and only show
/// up as a blank space on device. These checks read the files directly.
void main() {
  final Directory icons = Directory('assets/icons');
  final Directory images = Directory('assets/images');

  List<File> svgsIn(Directory dir) => dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.svg'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  test('both asset directories exist and are populated', () {
    expect(icons.existsSync(), isTrue);
    expect(images.existsSync(), isTrue);
    expect(svgsIn(icons), isNotEmpty);
    expect(svgsIn(images), isNotEmpty);
  });

  group('every SVG', () {
    late List<File> all;

    setUpAll(() {
      all = <File>[...svgsIn(icons), ...svgsIn(images)];
    });

    test('is well-formed XML with an <svg> root', () {
      for (final File file in all) {
        final XmlDocument doc = XmlDocument.parse(file.readAsStringSync());
        expect(
          doc.rootElement.name.local,
          'svg',
          reason: '${file.path} does not start with <svg>',
        );
      }
    });

    test('declares the SVG namespace, which flutter_svg requires', () {
      for (final File file in all) {
        final XmlDocument doc = XmlDocument.parse(file.readAsStringSync());
        expect(
          doc.rootElement.getAttribute('xmlns'),
          'http://www.w3.org/2000/svg',
          reason: '${file.path} is missing xmlns',
        );
      }
    });

    test('carries a viewBox, so it scales instead of cropping', () {
      for (final File file in all) {
        final XmlDocument doc = XmlDocument.parse(file.readAsStringSync());
        final String? viewBox = doc.rootElement.getAttribute('viewBox');
        expect(viewBox, isNotNull, reason: '${file.path} has no viewBox');

        final List<String> parts = viewBox!.split(RegExp(r'[\s,]+'));
        expect(parts, hasLength(4), reason: '${file.path} viewBox is malformed');
        expect(
          double.parse(parts[2]),
          greaterThan(0),
          reason: '${file.path} has zero width',
        );
        expect(
          double.parse(parts[3]),
          greaterThan(0),
          reason: '${file.path} has zero height',
        );
      }
    });

    test('draws something', () {
      const Set<String> shapes = <String>{
        'path', 'circle', 'rect', 'ellipse', 'polygon', 'polyline', 'line',
      };
      for (final File file in all) {
        final XmlDocument doc = XmlDocument.parse(file.readAsStringSync());
        final bool hasShape = doc.descendants
            .whereType<XmlElement>()
            .any((e) => shapes.contains(e.name.local));
        expect(hasShape, isTrue, reason: '${file.path} is empty');
      }
    });

    test('has an accessible label', () {
      for (final File file in all) {
        final XmlDocument doc = XmlDocument.parse(file.readAsStringSync());
        expect(
          doc.rootElement.getAttribute('aria-label'),
          isNotNull,
          reason: '${file.path} has no aria-label',
        );
      }
    });

    test('stays small enough to inline without bloating the bundle', () {
      for (final File file in all) {
        expect(
          file.lengthSync(),
          lessThan(300 * 1024),
          reason: '${file.path} is oversized for an inline SVG',
        );
      }
    });

    test('is named in the slug form the Figma exporter produces', () {
      final RegExp slug = RegExp(r'^[a-z0-9_]+\.svg$');
      for (final File file in all) {
        final String name = file.uri.pathSegments.last;
        expect(slug.hasMatch(name), isTrue, reason: '$name is not a valid slug');
      }
    });
  });

  group('icons specifically', () {
    test('every icon has a sane aspect ratio', () {
      // These come straight out of Figma, so they carry their own frame
      // sizes rather than a uniform grid -- several are transparent tap
      // targets wider than the glyph they hold. What must hold is that none
      // is degenerate enough to vanish or stretch absurdly when scaled.
      for (final File file in svgsIn(icons)) {
        final XmlDocument doc = XmlDocument.parse(file.readAsStringSync());
        final List<String> box =
            doc.rootElement.getAttribute('viewBox')!.split(RegExp(r'[\s,]+'));
        final double width = double.parse(box[2]);
        final double height = double.parse(box[3]);
        final double ratio = width / height;

        expect(
          ratio,
          inInclusiveRange(0.1, 10),
          reason: '${file.path} is $width x $height',
        );
      }
    });
  });
}
