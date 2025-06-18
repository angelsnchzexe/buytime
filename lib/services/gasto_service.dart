import 'package:hive/hive.dart';
import '../models/gasto.dart';

class GastoService {
  static final Box<Gasto> _box = Hive.box<Gasto>('gastos');

  /// Agrega un nuevo gasto
  static Future<void> agregarGasto(Gasto gasto) async {
    await _box.add(gasto);
  }

  /// Retorna todos los gastos almacenados
  static List<Gasto> obtenerTodos() {
    return _box.values.toList();
  }

  /// Retorna los gastos entre dos fechas (inclusive)
  static List<Gasto> obtenerPorFecha(DateTime desde, DateTime hasta) {
    return _box.values.where((g) =>
      g.fecha.isAfter(desde.subtract(const Duration(seconds: 1))) &&
      g.fecha.isBefore(hasta.add(const Duration(seconds: 1)))
    ).toList();
  }

  /// Limpia todos los gastos (¡úsalo con cuidado!)
  static Future<void> limpiarGastos() async {
    await _box.clear();
  }

  /// Elimina un gasto específico
  static Future<void> eliminarGasto(Gasto gasto) async {
    await gasto.delete();
  }

  /// Filtra por categoría
  static List<Gasto> obtenerPorCategoria(String categoria) {
    return _box.values.where((g) => g.categoria == categoria).toList();
  }

  /// Total gastado en el período
  static double totalGastado(DateTime desde, DateTime hasta) {
    return obtenerPorFecha(desde, hasta)
        .fold(0.0, (suma, gasto) => suma + gasto.cantidad);
  }

  /// Total de tiempo trabajado en el período (en segundos)
  static int totalTiempoInvertido(DateTime desde, DateTime hasta) {
    return obtenerPorFecha(desde, hasta)
        .fold(0, (suma, gasto) => suma + gasto.tiempoTrabajo);
  }
}
