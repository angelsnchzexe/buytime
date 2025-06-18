import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/gasto.dart';

class CalendarioAnualWidget extends StatelessWidget {
  final List<Gasto> gastos;

  const CalendarioAnualWidget({super.key, required this.gastos});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final year = now.year;
    final currentMonth = now.month;

    final gastosPorFecha = <String, List<Gasto>>{};
    for (var gasto in gastos) {
      final key = DateFormat('yyyy-MM-dd').format(gasto.fecha);
      gastosPorFecha.putIfAbsent(key, () => []).add(gasto);
    }

    // Lista de meses visibles (desde el mes actual hacia atrás)
    final List<int> mesesVisibles = List.generate(currentMonth, (i) => currentMonth - i);

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: mesesVisibles.length,
      itemBuilder: (_, index) {
        final month = mesesVisibles[index];
        return _MesCalendario(
          year: year,
          month: month,
          gastosPorFecha: gastosPorFecha,
        );
      },
    );
  }
}

class _MesCalendario extends StatelessWidget {
  final int year;
  final int month;
  final Map<String, List<Gasto>> gastosPorFecha;

  const _MesCalendario({
    required this.year,
    required this.month,
    required this.gastosPorFecha,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final weekdayOffset = firstDay.weekday % 7;

    final List<Widget> dayWidgets = List.generate(
      weekdayOffset,
          (_) => const SizedBox(),
    );

    for (int day = 1; day <= daysInMonth; day++) {
      final dateKey = DateFormat('yyyy-MM-dd').format(DateTime(year, month, day));
      final tieneGasto = gastosPorFecha.containsKey(dateKey);

      dayWidgets.add(Container(
        margin: const EdgeInsets.all(2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$day', style: const TextStyle(fontSize: 12)),
            if (tieneGasto)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ));
    }

    final monthName = DateFormat.MMMM(Localizations.localeOf(context).toLanguageTag())
        .format(DateTime(year, month));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(monthName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: dayWidgets,
            ),
          ],
        ),
      ),
    );
  }
}
