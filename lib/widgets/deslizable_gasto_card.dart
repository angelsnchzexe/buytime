import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/gasto.dart';

// Función para asignar iconos según categoría
IconData obtenerIconoPorCategoria(String categoria) {
  switch (categoria.toLowerCase()) {
    case 'comida':
      return Icons.fastfood;
    case 'ocio':
      return Icons.movie;
    case 'transporte':
      return Icons.directions_car;
    case 'tecnología':
      return Icons.devices;
    case 'hogar':
      return Icons.chair;
    case 'salud':
      return Icons.health_and_safety;
    case 'educación':
      return Icons.school;
    case 'ropa':
      return Icons.checkroom;
    case 'viajes':
      return Icons.flight;
    case 'mascotas':
      return Icons.pets;
    case 'finanzas':
      return Icons.attach_money;
    case 'regalos / donaciones':
      return Icons.volunteer_activism;
    case 'otros':
      return Icons.more_horiz;
    case 'general':
      return Icons.category;
    default:
      return Icons.label;
  }
}

class DeslizableGastoCard extends StatefulWidget {
  final Gasto gasto;
  final int index;
  final bool esSeleccionado;
  final bool bloqueado;
  final VoidCallback onTap;
  final VoidCallback onSwipeBloqueo;
  final VoidCallback onSwipeDesbloqueo;
  final VoidCallback onDelete;

  const DeslizableGastoCard({
    super.key,
    required this.gasto,
    required this.index,
    required this.esSeleccionado,
    required this.bloqueado,
    required this.onTap,
    required this.onSwipeBloqueo,
    required this.onSwipeDesbloqueo,
    required this.onDelete,
  });

  @override
  State<DeslizableGastoCard> createState() => _DeslizableGastoCardState();
}

class _DeslizableGastoCardState extends State<DeslizableGastoCard>
    with SingleTickerProviderStateMixin {
  double _offsetX = 0.0;
  static const double maxSlide = 80.0;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _offsetX = widget.bloqueado ? -maxSlide : 0;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _animateTo(double target) {
    _slideAnimation = Tween<double>(begin: _offsetX, end: target)
        .animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ))
      ..addListener(() {
        setState(() => _offsetX = _slideAnimation.value);
      });
    _animationController.forward(from: 0);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _offsetX += details.delta.dx;
      if (_offsetX < -maxSlide) _offsetX = -maxSlide;
      if (_offsetX > 0) _offsetX = 0;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_offsetX <= -maxSlide / 2) {
      widget.onSwipeBloqueo();
      _animateTo(-maxSlide);
    } else {
      widget.onSwipeDesbloqueo();
      _animateTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final formatter = DateFormat.yMMMd();

    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTap: widget.onTap,
      child: Transform.translate(
        offset: Offset(_offsetX, 0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          margin: EdgeInsets.zero,
          child: ListTile(
            leading: Icon(
              obtenerIconoPorCategoria(widget.gasto.categoria ?? 'general'),
              color: theme.colorScheme.primary,
            ),
            title: Text(widget.gasto.titulo ?? loc.untitled),
            subtitle: Text(
              '${widget.gasto.categoria} • ${formatter.format(widget.gasto.fecha)}',
            ),
            trailing: widget.esSeleccionado
                ? Text(
              _formatearTiempo(widget.gasto.tiempoTrabajo),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            )
                : Text(
              '${widget.gasto.moneda} ${widget.gasto.cantidad.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatearTiempo(int segundos) {
    final horas = segundos ~/ 3600;
    final minutos = (segundos % 3600) ~/ 60;
    final segundosRestantes = segundos % 60;

    if (horas > 0) {
      return '$horas h ${minutos.toString().padLeft(2, '0')} min';
    } else if (minutos > 0) {
      return '$minutos min ${segundosRestantes.toString().padLeft(2, '0')} s';
    } else {
      return '$segundosRestantes s';
    }
  }
}
