import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../services/user_config_service.dart';
import '../services/gasto_service.dart';
import '../models/user_config.dart';
import '../widgets/resultado_card.dart';
import '../widgets/input_section.dart';
import '../widgets/title_bar.dart';
import '../widgets/progress_bar.dart';
import '../widgets/gasto_form_card.dart';
import '../utils/calculo_tiempo.dart';
import 'historial_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final TextEditingController precioController = TextEditingController();
  double salario = 0;
  double horasPorSemana = 0;
  double porcentajeAhorro = 0.1;
  String frecuencia = 'mensual';
  String moneda = 'EUR';

  double salarioDisponible = 0;
  double porcentajeGasto = 0;
  double gastoActual = 0;
  int tiempoTrabajo = 0;

  late final AnimationController _formController;
  late final Animation<Offset> _formOffsetAnimation;

  bool _mostrarTarjetaResultado = false;
  bool _mostrarFormularioGasto = false;

  String _tiempoFormateado = '';
  String _fraseImpacto = '';
  final ValueNotifier<double> _fondoOffset = ValueNotifier(0);
  Key _resultadoCardKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _cargarConfiguracionUsuario();

    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _formOffsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _formController.dispose();
    precioController.dispose();
    super.dispose();
  }

  Future<void> _cargarConfiguracionUsuario() async {
    final UserConfig config = await UserConfigService.loadConfig();
    final gastos = await GastoService.obtenerTodos();
    final sumaGastos = gastos.fold<double>(0, (suma, gasto) => suma + gasto.cantidad);

    setState(() {
      salario = config.salario;
      horasPorSemana = config.horas;
      frecuencia = config.frecuencia;
      moneda = config.moneda;
      porcentajeAhorro = config.porcentajeAhorro;

      salarioDisponible = salario * (1 - porcentajeAhorro);
      gastoActual = sumaGastos;
      porcentajeGasto = gastoActual / salarioDisponible;
    });
  }

  void calcular() {
    FocusScope.of(context).unfocus();
    final precio = double.tryParse(precioController.text) ?? 0;
    if (precio <= 0 || salario <= 0 || horasPorSemana <= 0) return;

    final resultado = calcularTiempo(
      precio: precio,
      salario: salario,
      horasPorSemana: horasPorSemana,
      frecuencia: frecuencia,
      loc: AppLocalizations.of(context)!,
    );

    setState(() {
      tiempoTrabajo = resultado['tiempo_segundos'] as int? ?? 0;
      _tiempoFormateado = resultado['tiempo']!;
      _fraseImpacto = resultado['frase']!;
      _mostrarTarjetaResultado = true;
      _mostrarFormularioGasto = false;
      _fondoOffset.value = 0;
      _resultadoCardKey = UniqueKey();
    });
  }

  void _mostrarFormulario() {
    setState(() {
      _mostrarFormularioGasto = true;
      _mostrarTarjetaResultado = true;
      _fondoOffset.value = 0;
    });
    _formController.forward(from: 0);
  }

  void _abrirHistorial() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HistorialPage()),
    ).then((_) => _cargarConfiguracionUsuario());
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Theme.of(context).scaffoldBackgroundColor,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: TitleBar(
        isDark: isDark,
        onConfigReload: _cargarConfiguracionUsuario,
        title: '',
        leadingWidget: ProgressBar(
          porcentaje: porcentajeGasto,
          gastoActual: gastoActual,
          salarioDisponible: salarioDisponible,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: loc.history,
            onPressed: _abrirHistorial,
          ),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'Buy',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Baseline(
                      baseline: 48, // Ajusta este número para alinear con el texto
                      baselineType: TextBaseline.alphabetic,
                      child: Image.asset(
                        'assets/images/icon-remove-white.png',
                        height: 42, // ajustado para que no sobresalga tanto
                        width: 42,
                      ),
                    ),
                    Text(
                      'Time',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                InputSection(
                  controller: precioController,
                  onPressed: calcular,
                  moneda: moneda,
                  loc: loc,
                ),
                const SizedBox(height: 20),
                if (_mostrarTarjetaResultado && !_mostrarFormularioGasto)
                  ResultadoCard(
                    key: _resultadoCardKey,
                    tiempo: _tiempoFormateado,
                    frase: _fraseImpacto,
                    offsetNotifier: _fondoOffset,
                    onDismissed: () {
                      setState(() {
                        _mostrarTarjetaResultado = false;
                        _mostrarFormularioGasto = false;
                        _fondoOffset.value = 0;
                        precioController.clear();
                      });
                    },
                    onFormularioPedido: _mostrarFormulario,
                  ),
                if (_mostrarFormularioGasto)
                  SlideTransition(
                    position: _formOffsetAnimation,
                    child: AnimatedOpacity(
                      opacity: 1,
                      duration: const Duration(milliseconds: 300),
                      child: GastoFormCard(
                        cantidad: double.tryParse(precioController.text) ?? 0,
                        moneda: moneda,
                        tiempoTrabajo: tiempoTrabajo,
                        tiempoFormateado: _tiempoFormateado,
                        configSnapshot: {
                          'salario': salario,
                          'horas': horasPorSemana,
                          'frecuencia': frecuencia,
                          'porcentajeAhorro': porcentajeAhorro,
                        },
                        onCancel: () {
                          setState(() {
                            _mostrarFormularioGasto = false;
                            _fondoOffset.value = 0;
                            _resultadoCardKey = UniqueKey();
                          });
                        },
                        onGastoGuardado: () async {
                          await _cargarConfiguracionUsuario();
                          setState(() {
                            _mostrarFormularioGasto = false;
                            _mostrarTarjetaResultado = false;
                            _fondoOffset.value = 0;
                            precioController.clear();
                          });
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
