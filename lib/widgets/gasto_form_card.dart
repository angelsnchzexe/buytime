import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/gasto.dart';
import '../services/gasto_service.dart';
import '../widgets/input_field.dart';
import '../widgets/dropdown_field.dart';
import '../widgets/boton_principal.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GastoFormCard extends StatefulWidget {
  final double cantidad;
  final String moneda;
  final int tiempoTrabajo;
  final String tiempoFormateado;
  final Map<String, dynamic> configSnapshot;
  final VoidCallback onCancel;
  final VoidCallback onGastoGuardado;

  const GastoFormCard({
    super.key,
    required this.cantidad,
    required this.moneda,
    required this.tiempoTrabajo,
    required this.tiempoFormateado,
    required this.configSnapshot,
    required this.onCancel,
    required this.onGastoGuardado,
  });

  @override
  State<GastoFormCard> createState() => _GastoFormCardState();
}

class _GastoFormCardState extends State<GastoFormCard> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  String _categoriaSeleccionada = 'General';
  bool _guardando = false;
  bool _tituloValido = false;
  bool _destacarTitulo = false;

  final List<String> _categorias = [
    'General',
    'Comida',
    'Ocio',
    'Transporte',
    'Tecnología',
    'Hogar',
    'Salud',
    'Educación',
    'Ropa',
    'Viajes',
    'Mascotas',
    'Finanzas',
    'Regalos / Donaciones',
    'Otros',
  ];

  @override
  void initState() {
    super.initState();
    _tituloController.addListener(_validarTitulo);
  }

  void _validarTitulo() {
    setState(() {
      _tituloValido = _tituloController.text.trim().isNotEmpty;
    });
  }

  void _activarGlowTitulo() {
    setState(() => _destacarTitulo = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _destacarTitulo = false);
    });
  }

  @override
  void dispose() {
    _tituloController.removeListener(_validarTitulo);
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  void _guardarGasto() async {
    setState(() => _guardando = true);

    final gasto = Gasto(
      cantidad: widget.cantidad,
      moneda: widget.moneda,
      fecha: DateTime.now(),
      tiempoTrabajo: widget.tiempoTrabajo,
      titulo: _tituloController.text.trim(),
      descripcion: _descripcionController.text.trim().isEmpty ? null : _descripcionController.text.trim(),
      categoria: _categoriaSeleccionada,
      configSnapshot: widget.configSnapshot,
    );

    await GastoService.agregarGasto(gasto);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gasto guardado correctamente')),
      );
      widget.onGastoGuardado();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final formatter = NumberFormat.currency(locale: 'es', symbol: widget.moneda);

    final String tituloPreview = _tituloController.text.trim().isEmpty
        ? 'Nuevo gasto'
        : _tituloController.text.trim();

    return Center(
      child: Card(
        elevation: 8,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tituloPreview,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Total: ${formatter.format(widget.cantidad)}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tiempo trabajado: ${widget.tiempoFormateado}',
                  style: theme.textTheme.bodySmall,
                ),
                const Divider(height: 28),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: _destacarTitulo
                        ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        blurRadius: 66,
                        spreadRadius: 20,
                      ),
                    ] : [],
                  ),
                  child: InputField(
                    controller: _tituloController,
                    label: 'Título',
                    icon: Icons.title,
                    keyboardType: TextInputType.text,
                  ),
                ),

                InputField(
                  controller: _descripcionController,
                  label: 'Descripción',
                  icon: Icons.description,
                  keyboardType: TextInputType.text,
                ),

                DropdownField(
                  value: _categoriaSeleccionada,
                  items: _categorias,
                  label: 'Categoría',
                  icon: Icons.category,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _categoriaSeleccionada = value);
                    }
                  },
                ),

                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: BotonPrincipal(
                          text: loc.cancel,
                          icon: Icons.close,
                          onPressed: widget.onCancel,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            if (!_tituloValido || _guardando) {
                              _activarGlowTitulo();
                            }
                          },
                          child: BotonPrincipal(
                            text: loc.save,
                            icon: Icons.save,
                            onPressed: (_guardando || !_tituloValido) ? null : _guardarGasto,
                            enabled: !_guardando && _tituloValido,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}