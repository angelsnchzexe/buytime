class UserConfig {
  final double salario;
  final double horas;
  final String frecuencia;
  final String moneda;
  final double porcentajeAhorro;

  const UserConfig({
    required this.salario,
    required this.horas,
    required this.frecuencia,
    required this.moneda,
    required this.porcentajeAhorro,
  });

  factory UserConfig.fromMap(Map<String, dynamic> map) {
    return UserConfig(
      salario: map['salario'] as double? ?? 0.0,
      horas: map['horas'] as double? ?? 0.0,
      frecuencia: map['frecuencia'] as String? ?? 'mensual',
      moneda: map['moneda'] as String? ?? 'EUR',
      porcentajeAhorro: map['porcentajeAhorro'] as double? ?? 0.1,
    );
  }

  Map<String, dynamic> toMap() => {
        'salario': salario,
        'horas': horas,
        'frecuencia': frecuencia,
        'moneda': moneda,
        'porcentajeAhorro': porcentajeAhorro,
      };
}
