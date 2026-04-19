import 'dart:math';
import 'package:flutter/material.dart';
import '../models/calculator_mode.dart';

class CalculatorProvider extends ChangeNotifier {
  CalculatorMode mode = CalculatorMode.basic;

  String phepTinh = '';
  String ketQua = '0';

  bool laDo = true;
  double boNho = 0;
  bool vuaTinhXong = false;

  // =========================
  // CHUYỂN CHẾ ĐỘ (MODE)
  // =========================
  void chuyenMode() {
    if (mode == CalculatorMode.basic) {
      mode = CalculatorMode.scientific;
    } else if (mode == CalculatorMode.scientific) {
      mode = CalculatorMode.programmer;
    } else {
      mode = CalculatorMode.basic;
    }
    phepTinh = '';
    ketQua = '0';
    notifyListeners();
  }

  void doiGoc() {
    laDo = !laDo;
    notifyListeners();
  }

  // =========================
  // XỬ LÝ NHẬP LIỆU (INPUT)
  // =========================
  void bamNut(String text) {
    // Nếu vừa tính xong mà nhập số hoặc hằng số thì reset phép tính mới
    if (vuaTinhXong) {
      if (RegExp(r'^[0-9.]+$').hasMatch(text) ||
          text == 'Π' ||
          text == 'sin' ||
          text == 'cos' ||
          text == 'tan' ||
          text == '√') {
        phepTinh = '';
      }
      vuaTinhXong = false;
    }

    switch (text) {
      case 'C':
        phepTinh = '';
        ketQua = '0';
        break;

      case 'CE':
        if (phepTinh.isNotEmpty) {
          phepTinh = phepTinh.substring(0, phepTinh.length - 1);
        }
        break;

      case '=':
        if (phepTinh.isEmpty) return;
        _thucHienTinhToan();
        vuaTinhXong = true;
        return; // Không chạy xuống notify ở dưới vì trong _thucHienTinhToan đã có

      case '±':
        doiDau();
        break;

      case '%':
        phanTram();
        break;

      case 'Π':
        phepTinh += pi.toString();
        break;

      case '√':
        phepTinh += 'sqrt(';
        break;

      case 'sin':
      case 'cos':
      case 'tan':
      case 'Ln':
      case 'log':
        phepTinh += '$text(';
        break;

      case 'x²':
        phepTinh += '^2';
        break;

      case 'x^y':
        phepTinh += '^';
        break;

      // --- FIX M+, M-, MR, MC ---
      case 'MC':
        boNho = 0;
        // Không reset phepTinh để người dùng vẫn thấy số cũ nếu muốn
        break;

      case 'MR':
        phepTinh += formatSo(boNho);
        break;

      case 'M+':
        // Lấy giá trị đang hiển thị ở kết quả để cộng vào bộ nhớ
        double giaTriHienTai = double.tryParse(ketQua) ?? 0;
        boNho += giaTriHienTai;
        vuaTinhXong = true; // Cho phép nhập số mới sau khi lưu memory
        break;

      case 'M-':
        double giaTriHienTai = double.tryParse(ketQua) ?? 0;
        boNho -= giaTriHienTai;
        vuaTinhXong = true;
        break;

      case 'AND':
      case 'OR':
      case 'XOR':
      case '<<':
      case '>>':
        phepTinh += ' $text ';
        break;

      case 'NOT':
        phepTinh = 'NOT ($phepTinh)';
        break;

      default:
        phepTinh += text;
    }
    notifyListeners();
  }

  // =========================
  // ĐIỀU PHỐI TÍNH TOÁN
  // =========================
  void _thucHienTinhToan() {
    try {
      String exp = phepTinh.replaceAll('×', '*').replaceAll('÷', '/');

      if (mode == CalculatorMode.programmer) {
        _tinhProgrammer(exp);
      } else {
        double result = tinhBieuThuc(exp);
        ketQua = formatSo(result);
        phepTinh = ketQua; // Hiển thị kết quả lên dòng trên để tính tiếp
      }
    } catch (e) {
      ketQua = e.toString().contains('Undefined') ? 'Undefined' : 'Error';
    }
    notifyListeners();
  }

  // =========================
  // CORE LOGIC (TÍNH TOÁN CHUỖI)
  // =========================
  double tinhBieuThuc(String exp) {
    exp = exp.trim();
    if (exp.isEmpty) return 0;

    // Xử lý ngoặc và các hàm (sin, cos, sqrt...)
    while (exp.contains('(')) {
      final match =
          RegExp(r'(sin|cos|tan|Ln|log|sqrt)?\(([^()]+)\)').firstMatch(exp);
      if (match != null) {
        String? ham = match.group(1);
        String noiDungTrong = match.group(2)!;
        double giaTriTrong = tinhBieuThuc(noiDungTrong);
        double result =
            (ham != null) ? _tinhHamMath(ham, giaTriTrong) : giaTriTrong;
        exp = exp.replaceFirst(match.group(0)!, result.toString());
      } else {
        break;
      }
    }

    // Thứ tự ưu tiên ngược: Cộng/Trừ -> Nhân/Chia -> Lũy thừa
    int i = _timDauNgoaiCung(exp, ['+', '-']);
    if (i != -1) {
      String left = exp.substring(0, i);
      String right = exp.substring(i + 1);
      if (left.isEmpty && exp[i] == '-') return -tinhBieuThuc(right);
      return exp[i] == '+'
          ? tinhBieuThuc(left) + tinhBieuThuc(right)
          : tinhBieuThuc(left) - tinhBieuThuc(right);
    }

    i = _timDauNgoaiCung(exp, ['*', '/']);
    if (i != -1) {
      double divisor = tinhBieuThuc(exp.substring(i + 1));
      if (exp[i] == '/' && divisor == 0) throw Exception('Div by 0');
      return exp[i] == '*'
          ? tinhBieuThuc(exp.substring(0, i)) * divisor
          : tinhBieuThuc(exp.substring(0, i)) / divisor;
    }

    i = _timDauNgoaiCung(exp, ['^']);
    if (i != -1) {
      return pow(tinhBieuThuc(exp.substring(0, i)),
              tinhBieuThuc(exp.substring(i + 1)))
          .toDouble();
    }

    return double.tryParse(exp) ?? 0;
  }

  double _tinhHamMath(String ham, double x) {
    switch (ham) {
      case 'sin':
        return sin(laDo ? x * pi / 180 : x);
      case 'cos':
        return cos(laDo ? x * pi / 180 : x);
      case 'tan':
        double r = tan(laDo ? x * pi / 180 : x);
        if (r.abs() > 1e15) throw Exception('Undefined');
        return r;
      case 'Ln':
        return x > 0 ? log(x) : throw Exception();
      case 'log':
        return x > 0 ? log(x) / ln10 : throw Exception();
      case 'sqrt':
        return x >= 0 ? sqrt(x) : throw Exception();
      default:
        return x;
    }
  }

  int _timDauNgoaiCung(String exp, List<String> ops) {
    int depth = 0;
    for (int i = exp.length - 1; i >= 0; i--) {
      if (exp[i] == ')')
        depth++;
      else if (exp[i] == '(')
        depth--;
      else if (depth == 0 && ops.contains(exp[i])) {
        if (exp[i] == '-' && (i == 0 || '+-*/^('.contains(exp[i - 1])))
          continue;
        return i;
      }
    }
    return -1;
  }

  // =========================
  // PROGRAMMER MODE
  // =========================
  void _tinhProgrammer(String exp) {
    try {
      if (exp.contains('NOT')) {
        String s = exp
            .replaceAll('NOT', '')
            .replaceAll('(', '')
            .replaceAll(')', '')
            .trim();
        int a = _parseIntFlex(s);
        ketQua = (~a).toString();
        return;
      }

      final parts = exp.split(RegExp(r'\s+'));
      if (parts.length == 3) {
        int a = _parseIntFlex(parts[0]);
        int b = _parseIntFlex(parts[2]);
        String op = parts[1];
        switch (op) {
          case 'AND':
            ketQua = (a & b).toString();
            break;
          case 'OR':
            ketQua = (a | b).toString();
            break;
          case 'XOR':
            ketQua = (a ^ b).toString();
            break;
          case '<<':
            ketQua = (a << b).toString();
            break;
          case '>>':
            ketQua = (a >> b).toString();
            break;
        }
      } else {
        int n = _parseIntFlex(exp);
        ketQua =
            'BIN: ${n.toRadixString(2)}\nOCT: ${n.toRadixString(8)}\nHEX: ${n.toRadixString(16).toUpperCase()}';
      }
    } catch (e) {
      ketQua = 'Error';
    }
  }

  int _parseIntFlex(String s) {
    s = s.trim();
    if (s.startsWith('0x')) return int.parse(s.substring(2), radix: 16);
    if (s.startsWith('0b')) return int.parse(s.substring(2), radix: 2);
    return int.parse(s);
  }

  // =========================
  // TIỆN ÍCH (UTILS)
  // =========================
  void doiDau() {
    if (phepTinh.isEmpty) return;
    if (phepTinh.startsWith('-')) {
      phepTinh = phepTinh.substring(1);
    } else {
      phepTinh = '-$phepTinh';
    }
    notifyListeners();
  }

  void phanTram() {
    try {
      double n = double.parse(ketQua != '0' ? ketQua : phepTinh);
      ketQua = formatSo(n / 100);
      phepTinh = ketQua;
    } catch (e) {
      ketQua = 'Error';
    }
    notifyListeners();
  }

  String formatSo(double value) {
    if (value.isNaN) return 'Error';
    if (value.isInfinite) return value > 0 ? '∞' : '-∞';
    double rounded = double.parse(value.toStringAsFixed(10));
    if (rounded % 1 == 0) return rounded.toInt().toString();
    String s = rounded.toString();
    return s.contains('.')
        ? s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '')
        : s;
  }
}
