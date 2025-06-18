import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/input_field.dart';
import '../widgets/dropdown_field.dart';
import '../services/user_config_service.dart';
import '../models/user_config.dart';
import '../widgets/title_bar.dart';
import '../widgets/boton_principal.dart';
import '../widgets/slider_field.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {
  final TextEditingController salarioController = TextEditingController();
  final TextEditingController horasController = TextEditingController();

  String frecuenciaSalario = 'mensual';
  String monedaSeleccionada = 'EUR';
  bool mostrarTarjeta = false;

  String salarioActual = '';
  String horasActual = '';
  String frecuenciaActual = '';
  String monedaActual = '';
  double porcentajeAhorro = 0.1;
  String porcentajeAhorroActual = '10'; // valor por defecto como string para mostrar "10%"

  late AnimationController _shineController;
  late Animation<Alignment> _shineAnimation;

  final List<String> frecuencias = ['mensual', 'anual'];

  @override
  void initState() {
    super.initState();

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _shineAnimation = Tween<Alignment>(
      begin: Alignment(-2, -1),
      end: Alignment(2, 1),
    ).animate(CurvedAnimation(
      parent: _shineController,
      curve: Curves.easeInOut,
    ));

    _cargarConfiguracion();
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  Future<void> _cargarConfiguracion() async {
    setState(() => mostrarTarjeta = false);
    final config = await UserConfigService.loadConfig();
    final locale = Localizations.localeOf(context);

    await Future.delayed(const Duration(milliseconds: 150));

    setState(() {
      salarioController.text = _formatearNumero(config.salario);
      horasController.text = _formatearNumero(config.horas);
      frecuenciaSalario = config.frecuencia;
      monedaSeleccionada = config.moneda.isNotEmpty
          ? config.moneda
          : _detectarMonedaPorPais(locale.countryCode);
      porcentajeAhorro = config.porcentajeAhorro;
      porcentajeAhorroActual = (porcentajeAhorro * 100).toStringAsFixed(0);

      salarioActual = salarioController.text;
      horasActual = horasController.text;
      frecuenciaActual = frecuenciaSalario;
      monedaActual = monedaSeleccionada;

      mostrarTarjeta = true;
    });

    _shineController.forward(from: 0);
  }

  String _formatearNumero(num valor) {
    return valor % 1 == 0 ? valor.toInt().toString() : valor.toString();
  }

  String _detectarMonedaPorPais(String? countryCode) {
    switch (countryCode) {
      case 'US': return 'USD';
      case 'GB': return 'GBP';
      case 'MX': return 'MXN';
      case 'AR': return 'ARS';
      case 'CL': return 'CLP';
      case 'BR': return 'BRL';
      case 'IT':
      case 'ES':
      case 'FR':
      case 'DE':
      case 'PT':
      case 'NL':
      case 'BE':
      case 'IE':
        return 'EUR';
      default: return '\$';
    }
  }

  void guardar() {
    final salario = double.tryParse(salarioController.text) ?? 0;
    final horas = double.tryParse(horasController.text) ?? 0;

    if (salario <= 0 || horas <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.invalidInput)),
      );
      return;
    }

    UserConfigService.saveConfig(
      UserConfig(
        salario: salario,
        horas: horas,
        frecuencia: frecuenciaSalario,
        moneda: monedaSeleccionada,
        porcentajeAhorro: porcentajeAhorro,
      ),
    );

    setState(() {
      salarioActual = _formatearNumero(salario);
      horasActual = _formatearNumero(horas);
      frecuenciaActual = frecuenciaSalario;
      monedaActual = monedaSeleccionada;
      mostrarTarjeta = true;
      porcentajeAhorroActual = (porcentajeAhorro * 100).toStringAsFixed(0);
    });

    _shineController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final symbol = _getMonedaSimbolo(monedaSeleccionada);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: TitleBar(
        isDark: theme.brightness == Brightness.dark,
        onConfigReload: _cargarConfiguracion,
        title: loc.settings,
        showBackButton: true,
        showSettingsIcon: false,
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedSlide(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              offset: mostrarTarjeta ? Offset.zero : const Offset(0, 0.1),
              child: AnimatedOpacity(
                opacity: mostrarTarjeta ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: AnimatedBuilder(
                  animation: _shineAnimation,
                  builder: (context, child) {
                    return ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.05),
                            Colors.white.withOpacity(0.15),
                            Colors.white.withOpacity(0.05),
                          ],
                          stops: const [0.45, 0.5, 0.55],
                          begin: _shineAnimation.value,
                          end: Alignment.center,
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.srcATop,
                      child: child,
                    );
                  },
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.settings, size: 28, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                loc.currentConfig,
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          _buildConfigRow(context, Icons.euro, loc.salary,
                              '${_getMonedaSimbolo(monedaActual)}$salarioActual [${frecuenciaActual.toUpperCase()}]'),
                          _buildConfigRow(context, Icons.access_time, loc.weeklyHours, horasActual),
                          _buildConfigRow(context, Icons.monetization_on, loc.currency, monedaActual),
                          _buildConfigRow(
                            context,
                            Icons.savings,
                            loc.savingPercentage,
                            '$porcentajeAhorroActual%',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            InputField(
              controller: salarioController,
              label: loc.salary,
              prefix: Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Text(
                  symbol,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            DropdownField(
              value: frecuenciaSalario,
              items: frecuencias,
              label: loc.salaryFrequency,
              icon: Icons.schedule,
              onChanged: (value) {
                if (value != null) setState(() => frecuenciaSalario = value);
              },
            ),

            InputField(
              controller: horasController,
              label: loc.weeklyHours,
              icon: Icons.access_time,
            ),

            const SizedBox(height: 30),

            SliderField(
              min: 0.0,
              max: 1,
              value: porcentajeAhorro,
              divisions: 100,
              label: loc.savingPercentage,
              salario: double.tryParse(salarioController.text) ?? 0, // <- aquí lo pasas
              onChanged: (value) {
                setState(() {
                  porcentajeAhorro = value;
                });
              },
            ),


            const SizedBox(height: 30),

            BotonPrincipal(
              onPressed: guardar,
              icon: Icons.save,
              text: loc.save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  String _getMonedaSimbolo(String codigo) {
    switch (codigo) {
      case 'USD':
      case 'MXN':
      case 'ARS':
      case 'CLP':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'BRL':
        return 'R\$';
      default:
        return '\$';
    }
  }
}
