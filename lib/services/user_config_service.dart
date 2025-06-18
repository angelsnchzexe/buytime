import 'package:shared_preferences/shared_preferences.dart';

class UserConfigService {
  static const String _keySalario = 'salario';
  static const String _keyHoras = 'horas';
  static const String _keyFrecuencia = 'frecuencia';
  static const String _keyMoneda = 'moneda';
  static const String _keyPorcentajeAhorro = 'porcentajeAhorro';

  static Future<void> saveConfig(
    double salario,
    double horas,
    String frecuencia,
    String moneda,
    double porcentajeAhorro,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keySalario, salario);
    await prefs.setDouble(_keyHoras, horas);
    await prefs.setString(_keyFrecuencia, frecuencia);
    await prefs.setString(_keyMoneda, moneda);
    await prefs.setDouble(_keyPorcentajeAhorro, porcentajeAhorro);
  }

  static Future<Map<String, dynamic>> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();

    final salario = prefs.getDouble(_keySalario) ?? 1200.0;
    final horas = prefs.getDouble(_keyHoras) ?? 40.0;
    final frecuencia = prefs.getString(_keyFrecuencia) ?? 'mensual';
    final moneda = prefs.getString(_keyMoneda) ?? 'EUR';
    final porcentajeAhorro = prefs.getDouble(_keyPorcentajeAhorro) ?? 0.1;

    return {
      'salario': salario,
      'horas': horas,
      'frecuencia': frecuencia,
      'moneda': moneda,
      'porcentajeAhorro': porcentajeAhorro,
    };
  }
}
