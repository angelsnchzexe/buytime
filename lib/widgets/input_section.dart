import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/input_field.dart';
import '../widgets/boton_principal.dart';

class InputSection extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onPressed;
  final String moneda;
  final AppLocalizations loc;

  const InputSection({
    super.key,
    required this.controller,
    required this.onPressed,
    required this.moneda,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final symbol = _getMonedaSimbolo(moneda);
    final color = theme.colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InputField(
          controller: controller,
          label: loc.productPrice,
          prefix: Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: Text(
              symbol,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        BotonPrincipal(
          onPressed: onPressed,
          icon: Icons.calculate,
          text: loc.calculate,
        ),
      ],
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
        return '';
    }
  }
}
