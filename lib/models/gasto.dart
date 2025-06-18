import 'package:hive/hive.dart';

part 'gasto.g.dart';

@HiveType(typeId: 0)
class Gasto extends HiveObject {
  @HiveField(0)
  double cantidad;

  @HiveField(1)
  String moneda;

  @HiveField(2)
  DateTime fecha;

  @HiveField(3)
  int tiempoTrabajo; // en segundos

  @HiveField(4)
  String? descripcion; // opcional

  @HiveField(5)
  String? categoria; // opcional

  @HiveField(6)
  Map<String, dynamic>? configSnapshot; // para guardar salario, horas, ahorro...
  
  @HiveField(7)
  String? titulo;

  Gasto({
    required this.cantidad,
    required this.titulo,
    required this.moneda,
    required this.fecha,
    required this.tiempoTrabajo,
    this.descripcion,
    this.categoria,
    this.configSnapshot,
  });
}
