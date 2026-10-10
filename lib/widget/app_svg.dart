import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/app_colors.dart';

/// An SVG from `assets/`, with a placeholder for the ones that have not been
/// exported from Figma yet.
///
/// The export is a separate step (`tool/figma_assets.py`), so during layout
/// work most of these files are missing. flutter_svg would throw for each one
/// and bury the screen in red; instead the first failed load is remembered and
/// a soft rounded block of the right size is drawn in its place.
class AppSvg extends StatefulWidget {
  const AppSvg(
    this.asset, {
    super.key,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
  });

  final String asset;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;

  @override
  State<AppSvg> createState() => _AppSvgState();
}

class _AppSvgState extends State<AppSvg> {
  /// Assets already known to be absent, so we only probe each one once.
  static final Set<String> _missing = <String>{};

  late Future<bool> _exists;

  @override
  void initState() {
    super.initState();
    _exists = _probe();
  }

  @override
  void didUpdateWidget(AppSvg oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset != widget.asset) _exists = _probe();
  }

  Future<bool> _probe() async {
    if (_missing.contains(widget.asset)) return false;
    try {
      await rootBundle.load(widget.asset);
      return true;
    } on FlutterError {
      _missing.add(widget.asset);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // The box is reserved up front rather than left to the artwork. A contained
    // SVG otherwise shrinks to its own aspect ratio, so the widget would occupy
    // less than it was given and everything beside it would shift once the file
    // loaded.
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: FutureBuilder<bool>(
        future: _exists,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.data != true) return _placeholder();
          return SvgPicture.asset(
            widget.asset,
            fit: widget.fit,
            colorFilter: widget.color == null
                ? null
                : ColorFilter.mode(widget.color!, BlendMode.srcIn),
          );
        },
      ),
    );
  }

  /// Shown only for an asset that is genuinely absent. It is deliberately
  /// plain, and deliberately not invisible, so a missing file reads as a gap
  /// during development rather than silently collapsing the layout.
  Widget _placeholder() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceTinted,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
