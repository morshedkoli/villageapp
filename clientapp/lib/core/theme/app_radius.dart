import 'package:flutter/material.dart';

abstract final class AppRadius {
  AppRadius._();

  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double full = 999;

  static const BorderRadius xsBorder = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smBorder = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdBorder = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgBorder = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlBorder = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius xxlBorder = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius xxxlBorder = BorderRadius.all(Radius.circular(xxxl));
  static const BorderRadius fullBorder = BorderRadius.all(Radius.circular(full));

  static const RoundedRectangleBorder xsShape =
      RoundedRectangleBorder(borderRadius: xsBorder);
  static const RoundedRectangleBorder smShape =
      RoundedRectangleBorder(borderRadius: smBorder);
  static const RoundedRectangleBorder mdShape =
      RoundedRectangleBorder(borderRadius: mdBorder);
  static const RoundedRectangleBorder lgShape =
      RoundedRectangleBorder(borderRadius: lgBorder);
  static const RoundedRectangleBorder xlShape =
      RoundedRectangleBorder(borderRadius: xlBorder);
  static const RoundedRectangleBorder xxlShape =
      RoundedRectangleBorder(borderRadius: xxlBorder);
  static const RoundedRectangleBorder xxxlShape =
      RoundedRectangleBorder(borderRadius: xxxlBorder);
}
