import 'package:flutter/material.dart';
import '../models/calculator_mode.dart';
import '../utils/calculator_logic.dart';

class CalculatorProvider extends ChangeNotifier {
  CalculatorMode mode = CalculatorMode.basic;

  String phepTinh = '';
  String ketQua = '0';
  String lichSu = '';

  bool laDo = true;
  double boNho = 0;

  bool vuaTinhXong = false;

  String toanTuCuoi = '';
  String soCuoi = '';

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
    lichSu = '';
    vuaTinhXong = false;

    notifyListeners();
  }

  void doiGoc() {
    laDo = !laDo;
    notifyListeners();
  }

  void bamNut(String text) {
    switch (text) {
      case 'C':
        phepTinh = '';
        ketQua = '0';
        lichSu = '';
        vuaTinhXong = false;
        break;

      case 'CE':
        if (phepTinh.isNotEmpty) {
          phepTinh = phepTinh.substring(
            0,
            phepTinh.length - 1,
          );
        }
        break;

      case '=':
        if (vuaTinhXong) {
          lapLaiBang();
        } else {
          tinhKetQua();
        }
        return;

      case 'M+':
      case 'M-':
      case 'MR':
      case 'MC':
        phepTinh = phepTinh.trim();
        phepTinh += ' $text ';
        break;

      case '%':
        phepTinh += '%';
        break;

      case '+':
      case '-':
      case '×':
      case '÷':
        if (mode == CalculatorMode.programmer) {
          phepTinh = phepTinh.trim();
          phepTinh += ' $text ';
          break;
        }

        if (vuaTinhXong) {
          phepTinh = ketQua;
          vuaTinhXong = false;
        }

        if (phepTinh.isNotEmpty &&
            RegExp(
              r'[+\-×÷]$',
            ).hasMatch(phepTinh)) {
          phepTinh = phepTinh.substring(
            0,
            phepTinh.length - 1,
          );
        }

        phepTinh += text;
        break;

      case 'sin':
      case 'cos':
      case 'tan':
      case 'Ln':
      case 'log':
        phepTinh += '$text(';
        break;

      case '√':
        phepTinh += 'sqrt(';
        break;

      case 'Π':
        phepTinh += 'pi';
        break;

      case 'x²':
        phepTinh += '^2';
        break;

      case 'x^y':
        phepTinh += '^';
        break;

      case '±':
        if (phepTinh.startsWith('-')) {
          phepTinh = phepTinh.substring(1);
        } else {
          phepTinh = '-$phepTinh';
        }
        break;

      case 'AND':
      case 'OR':
      case 'XOR':
      case '<<':
      case '>>':
        phepTinh = phepTinh.trim();
        phepTinh += ' $text ';
        break;

      case 'NOT':
        phepTinh = 'NOT(${phepTinh.trim()})';
        break;

      default:
        if (vuaTinhXong) {
          phepTinh = '';
          vuaTinhXong = false;
        }

        phepTinh += text.toUpperCase();
    }

    notifyListeners();
  }

  void tinhKetQua() {
    try {
      String exp = phepTinh.trim();

      if (exp.contains('M+') ||
          exp.contains('M-') ||
          exp.contains('MR') ||
          exp.contains('MC')) {
        List<String> parts = exp.split(
          RegExp(r'\s+'),
        );

        for (int i = 0; i < parts.length; i++) {
          String item = parts[i];

          if (item == 'M+') {
            double so = double.tryParse(
                  parts[i - 1],
                ) ??
                0;

            boNho += so;
          } else if (item == 'M-') {
            double so = double.tryParse(
                  parts[i - 1],
                ) ??
                0;

            boNho -= so;
          } else if (item == 'MC') {
            boNho = 0;
          }
        }

        ketQua = CalculatorLogic.formatSo(
          boNho,
        );

        lichSu = phepTinh;

        vuaTinhXong = true;

        notifyListeners();
        return;
      }

      exp = exp.replaceAll(
        '%',
        '/100',
      );

      if (mode == CalculatorMode.programmer) {
        ketQua = CalculatorLogic.tinhProgrammer(
          exp,
        );
      } else {
        double result = CalculatorLogic.tinhBieuThuc(
          exp,
          laDo,
        );

        ketQua = CalculatorLogic.formatSo(
          result,
        );
      }

      _luuChainData();

      lichSu = phepTinh;

      vuaTinhXong = true;
    } catch (e) {
      ketQua = 'Error';
    }

    notifyListeners();
  }

  void _luuChainData() {
    final match = RegExp(
      r'([+\-×÷])\s*([0-9A-Fa-f.x]+)$',
    ).firstMatch(phepTinh);

    if (match != null) {
      toanTuCuoi = match.group(1)!;

      soCuoi = match.group(2)!;
    }
  }

  void lapLaiBang() {
    if (toanTuCuoi.isEmpty) return;

    String expMoi = '$ketQua $toanTuCuoi $soCuoi';

    lichSu = expMoi;

    phepTinh = expMoi;

    vuaTinhXong = false;

    tinhKetQua();
  }
}
