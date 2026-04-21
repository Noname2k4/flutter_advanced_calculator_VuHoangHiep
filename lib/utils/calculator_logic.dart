// lib/utils/calculator_logic.dart

import 'dart:math';

class CalculatorLogic {
  // =============================
  // NORMAL / SCIENTIFIC MODE
  // =============================
  static double tinhBieuThuc(
    String exp,
    bool laDo,
  ) {
    exp = exp.replaceAll('×', '*');
    exp = exp.replaceAll('÷', '/');
    exp = exp.replaceAll(' ', '');

    if (exp.isEmpty) return 0;

    // xử lý hàm + ngoặc
    while (exp.contains('(')) {
      final match = RegExp(
        r'(sin|cos|tan|log|Ln|sqrt)?\(([^()]+)\)',
      ).firstMatch(exp);

      if (match == null) break;

      String? ham = match.group(1);
      String benTrong = match.group(2)!;

      double value = tinhBieuThuc(benTrong, laDo);

      if (ham != null) {
        value = tinhHam(ham, value, laDo);
      }

      exp = exp.replaceFirst(
        match.group(0)!,
        value.toString(),
      );
    }

    int i = tim(exp, ['+', '-']);

    if (i != -1) {
      if (i == 0) {
        return -tinhBieuThuc(
          exp.substring(1),
          laDo,
        );
      }

      double a = tinhBieuThuc(
        exp.substring(0, i),
        laDo,
      );

      double b = tinhBieuThuc(
        exp.substring(i + 1),
        laDo,
      );

      return exp[i] == '+' ? a + b : a - b;
    }

    i = tim(exp, ['*', '/']);

    if (i != -1) {
      double a = tinhBieuThuc(
        exp.substring(0, i),
        laDo,
      );

      double b = tinhBieuThuc(
        exp.substring(i + 1),
        laDo,
      );

      return exp[i] == '*' ? a * b : a / b;
    }

    i = tim(exp, ['^']);

    if (i != -1) {
      double a = tinhBieuThuc(
        exp.substring(0, i),
        laDo,
      );

      double b = tinhBieuThuc(
        exp.substring(i + 1),
        laDo,
      );

      return pow(a, b).toDouble();
    }

    if (exp.toLowerCase() == 'pi') {
      return pi;
    }

    return double.parse(exp);
  }

  static int tim(
    String exp,
    List<String> ds,
  ) {
    int depth = 0;

    for (int i = exp.length - 1; i >= 0; i--) {
      if (exp[i] == ')') depth++;
      if (exp[i] == '(') depth--;

      if (depth == 0 && ds.contains(exp[i])) {
        if (i == 0) continue;
        return i;
      }
    }

    return -1;
  }

  static double tinhHam(
    String ham,
    double x,
    bool laDo,
  ) {
    switch (ham) {
      case 'sin':
        return sin(
          laDo ? x * pi / 180 : x,
        );

      case 'cos':
        return cos(
          laDo ? x * pi / 180 : x,
        );

      case 'tan':
        return tan(
          laDo ? x * pi / 180 : x,
        );

      case 'sqrt':
        return sqrt(x);

      case 'log':
        return log(x) / ln10;

      case 'Ln':
        return log(x);

      default:
        return x;
    }
  }

  // =============================
  // PROGRAMMER MODE
  // =============================
  static String tinhProgrammer(
    String exp,
  ) {
    try {
      exp = exp.trim();

      List<String> parts = exp.split(RegExp(r'\s+'));

      if (parts.length != 3) {
        return 'Error';
      }

      int a = parseHex(parts[0]);
      int b = parseHex(parts[2]);

      String op = parts[1];

      switch (op) {
        case 'AND':
          return toHex(a & b);

        case 'OR':
          return toHex(a | b);

        case 'XOR':
          return toHex(a ^ b);

        case '<<':
          return toHex(a << b);

        case '>>':
          return toHex(a >> b);

        case '+':
          return toHex(a + b);

        case '-':
          return toHex(a - b);

        case '×':
          return toHex(a * b);

        case '÷':
          return toHex(a ~/ b);
      }

      return 'Error';
    } catch (e) {
      return 'Error';
    }
  }

  // =============================
  // PARSE HEX
  // =============================
  static int parseHex(String s) {
    s = s.trim().toUpperCase();

    // 0xFF
    if (s.startsWith('0X')) {
      return int.parse(
        s.substring(2),
        radix: 16,
      );
    }

    // FF
    if (RegExp(
      r'^[0-9A-F]+$',
    ).hasMatch(s)) {
      return int.parse(
        s,
        radix: 16,
      );
    }

    // decimal
    return int.parse(s);
  }

  // =============================
  // HEX OUTPUT
  // =============================
  static String toHex(int n) {
    String hex = n.toRadixString(16).toUpperCase();

    if (hex.length == 1) {
      hex = '0$hex';
    }

    return '0x$hex';
  }

  // =============================
  // FORMAT NUMBER
  // =============================
  static String formatSo(
    double n,
  ) {
    if (n % 1 == 0) {
      return n.toInt().toString();
    }

    String s = n.toStringAsFixed(10);

    s = s.replaceAll(
      RegExp(r'0+$'),
      '',
    );

    s = s.replaceAll(
      RegExp(r'\.$'),
      '',
    );

    return s;
  }
}
