import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'frase_impacto.dart';

Map<String, dynamic> calcularTiempo({
  required double precio,
  required double salario,
  required double horasPorSemana,
  required String frecuencia,
  required AppLocalizations loc,
}) {
  double salarioMensual = switch (frecuencia) {
    'mensual' => salario,
    'anual' => salario / 12,
    _ => salario,
  };

  final sueldoHora = salarioMensual / (horasPorSemana * 4);
  final horasNecesarias = precio / sueldoHora;

  final totalSegundos = (horasNecesarias * 3600).round(); // ✅ aquí en segundos
  final totalMinutos = totalSegundos ~/ 60;
  final horas = totalMinutos ~/ 60;
  final minutos = totalMinutos % 60;

  final tiempoFormateado = formatearTiempo(
    horas: horas,
    minutos: minutos,
    loc: loc,
  );

  final frase = generarFraseImpacto(horasNecesarias);

  return {
    'tiempo': tiempoFormateado,
    'frase': frase,
    'tiempo_segundos': totalSegundos, // ✅ NUEVO
  };
}


String formatearTiempo({
  required int horas,
  required int minutos,
  required AppLocalizations loc,
}) {
  final partes = <String>[];
  if (horas > 0) partes.add('$horas h');
  if (minutos > 0) partes.add('$minutos m');
  return partes.join(' ');
}
