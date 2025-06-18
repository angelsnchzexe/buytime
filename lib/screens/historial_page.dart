import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/deslizable_gasto_card.dart';
import '../models/gasto.dart';
import '../services/gasto_service.dart';
import '../widgets/calendario_gastos.dart';
import '../widgets/input_field.dart';

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  late Future<List<Gasto>> _gastosFuture;
  List<Gasto> _gastos = [];
  List<Gasto> _gastosFiltrados = [];
  final TextEditingController _busquedaController = TextEditingController();

  int? _gastoSeleccionadoIndex;
  Set<String> _gastosBloqueados = {};
  bool _mostrarCalendario = false;
  bool _ordenarPorPrecio = false;
  bool _precioAscendente = false;

  @override
  void initState() {
    super.initState();
    _gastosFuture = _cargarGastos();
    _busquedaController.addListener(_filtrarGastos);
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  Future<List<Gasto>> _cargarGastos() async {
    final lista = await GastoService.obtenerTodos();
    lista.sort((a, b) => b.fecha.compareTo(a.fecha));
    _gastos = lista;
    _gastosFiltrados = List.from(lista);
    return lista;
  }

  void _filtrarGastos() {
    final texto = _busquedaController.text.toLowerCase().trim();
    setState(() {
      if (texto.isEmpty) {
        _gastosFiltrados = List.from(_gastos);
      } else {
        _gastosFiltrados = _gastos.where((g) {
          final titulo = g.titulo?.toLowerCase() ?? '';
          final descripcion = g.descripcion?.toLowerCase() ?? '';
          return titulo.contains(texto) || descripcion.contains(texto);
        }).toList();
      }
    });
  }

  Future<void> _eliminarGasto(Gasto gasto) async {
    await GastoService.eliminarGasto(gasto);
    setState(() {
      _gastos.removeWhere((g) => g.key == gasto.key);
      _gastosFiltrados.removeWhere((g) => g.key == gasto.key);
      _gastosBloqueados.remove(gasto.key.toString());
    });
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.history),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _mostrarCalendario ? const SizedBox.shrink() : const Icon(Icons.attach_money, size: 20),
                _mostrarCalendario
                    ? const SizedBox.shrink()
                    :
                    Icon(
                      _precioAscendente ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 16,
                    ),
              ],
            ),
            tooltip: 'Ordenar por precio',
            onPressed: () {
              setState(() {
                _ordenarPorPrecio = true;
                _precioAscendente = !_precioAscendente;
                _gastosFiltrados.sort((a, b) {
                  return _precioAscendente
                      ? a.cantidad.compareTo(b.cantidad)
                      : b.cantidad.compareTo(a.cantidad);
                });
              });
            },
            onLongPress: () {
              setState(() {
                _ordenarPorPrecio = false;
                _precioAscendente = false;
                _gastosFiltrados.sort((a, b) => b.fecha.compareTo(a.fecha));
              });
            },
          ),
          IconButton(
            icon: Icon(_mostrarCalendario ? Icons.list : Icons.calendar_today),
            tooltip: _mostrarCalendario ? loc.history : 'Calendario',
            onPressed: () {
              setState(() {
                _mostrarCalendario = !_mostrarCalendario;
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Gasto>>(
        future: _gastosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text(loc.errorLoadingData));
          } else if (_gastos.isEmpty) {
            return Center(child: Text(loc.noExpensesFound));
          }

          if (_mostrarCalendario) {
            return CalendarioAnualWidget(gastos: _gastosFiltrados);
          }

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.02, // 2% superior
                  left: 16,
                  right: 16,
                ),
                child: InputField(
                  controller: _busquedaController,
                  label: 'Buscar',
                  icon: Icons.search,
                  keyboardType: TextInputType.text,
                ),
              ),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _gastosFiltrados.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final gasto = _gastosFiltrados[index];
                    final key = gasto.key.toString();
                    final esSeleccionado = _gastoSeleccionadoIndex == index;
                    final bloqueado = _gastosBloqueados.contains(key);

                    return Dismissible(
                      key: ValueKey(key),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _eliminarGasto(gasto),
                      child: DeslizableGastoCard(
                        gasto: gasto,
                        index: index,
                        esSeleccionado: esSeleccionado,
                        bloqueado: bloqueado,
                        onTap: () {
                          setState(() {
                            _gastoSeleccionadoIndex =
                            esSeleccionado ? null : index;
                          });
                        },
                        onSwipeBloqueo: () {
                          HapticFeedback.mediumImpact();
                          setState(() {
                            _gastosBloqueados.add(key);
                          });
                        },
                        onSwipeDesbloqueo: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _gastosBloqueados.remove(key);
                          });
                        },
                        onDelete: () => _eliminarGasto(gasto),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
