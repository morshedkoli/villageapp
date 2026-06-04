import 'package:flutter/material.dart';

abstract final class AppSpacing {
  AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double xxxxl = 40;
  static const double huge = 48;
  static const double massive = 64;

  // Padding helpers
  static const EdgeInsets allXs = EdgeInsets.all(xs);
  static const EdgeInsets allSm = EdgeInsets.all(sm);
  static const EdgeInsets allMd = EdgeInsets.all(md);
  static const EdgeInsets allLg = EdgeInsets.all(lg);
  static const EdgeInsets allXl = EdgeInsets.all(xl);
  static const EdgeInsets allXxl = EdgeInsets.all(xxl);
  static const EdgeInsets allXxxl = EdgeInsets.all(xxxl);
  static const EdgeInsets allHuge = EdgeInsets.all(huge);

  static const EdgeInsets horzSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horzMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horzLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horzXl = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets horzXxl = EdgeInsets.symmetric(horizontal: xxl);
  static const EdgeInsets horzXxxl = EdgeInsets.symmetric(horizontal: xxxl);

  static const EdgeInsets vertSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets vertMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets vertLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets vertXl = EdgeInsets.symmetric(vertical: xl);
  static const EdgeInsets vertXxl = EdgeInsets.symmetric(vertical: xxl);
  static const EdgeInsets vertXxxl = EdgeInsets.symmetric(vertical: xxxl);

  static EdgeInsets sym({double h = 0, double v = 0}) =>
      EdgeInsets.symmetric(horizontal: h, vertical: v);

  static EdgeInsets only({
    double l = 0,
    double t = 0,
    double r = 0,
    double b = 0,
  }) =>
      EdgeInsets.only(left: l, top: t, right: r, bottom: b);

  // SizedBox helpers
  static const SizedBox gapXs = SizedBox(width: xs, height: xs);
  static const SizedBox gapSm = SizedBox(width: sm, height: sm);
  static const SizedBox gapMd = SizedBox(width: md, height: md);
  static const SizedBox gapLg = SizedBox(width: lg, height: lg);
  static const SizedBox gapXl = SizedBox(width: xl, height: xl);
  static const SizedBox gapXxl = SizedBox(width: xxl, height: xxl);

  static const SizedBox wXs = SizedBox(width: xs);
  static const SizedBox wSm = SizedBox(width: sm);
  static const SizedBox wMd = SizedBox(width: md);
  static const SizedBox wLg = SizedBox(width: lg);
  static const SizedBox wXl = SizedBox(width: xl);
  static const SizedBox wXxl = SizedBox(width: xxl);

  static const SizedBox hXs = SizedBox(height: xs);
  static const SizedBox hSm = SizedBox(height: sm);
  static const SizedBox hMd = SizedBox(height: md);
  static const SizedBox hLg = SizedBox(height: lg);
  static const SizedBox hXl = SizedBox(height: xl);
  static const SizedBox hXxl = SizedBox(height: xxl);
  static const SizedBox hXxxl = SizedBox(height: xxxl);
  static const SizedBox hHuge = SizedBox(height: huge);
  static const SizedBox hMassive = SizedBox(height: massive);
}
