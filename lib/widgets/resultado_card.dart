import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class ResultadoCard extends StatefulWidget {
  final String tiempo;
  final String frase;
  final VoidCallback onDismissed;
  final ValueNotifier<double> offsetNotifier;
  final VoidCallback? onFormularioPedido;

  const ResultadoCard({
    super.key,
    required this.tiempo,
    required this.frase,
    required this.onDismissed,
    required this.offsetNotifier,
    this.onFormularioPedido,
  });

  @override
  State<ResultadoCard> createState() => _ResultadoCardState();
}

const Duration _borderAnimDuration = Duration(milliseconds: 200);

class _ResultadoCardState extends State<ResultadoCard> with TickerProviderStateMixin {
  double _offsetX = 0;
  double _opacity = 1.0;
  final double _threshold = 120;
  final AudioPlayer _player = AudioPlayer();
  String? _estado;

  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _player.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _offsetX += details.delta.dx;
      _opacity = (1 - (_offsetX.abs() / 300)).clamp(0.0, 1.0);
      _estado = _offsetX > 60
          ? "ahorrado"
          : _offsetX < -60
          ? "pagado"
          : null;
      widget.offsetNotifier.value = _offsetX;
    });

    if (_offsetX.abs() > 5) {
      _scaleController.stop();
    }
  }

  void _onPanEnd(DragEndDetails details) async {
    if (_offsetX.abs() > _threshold) {
      if (_estado == "ahorrado") {
        await _player.play(AssetSource('sounds/ahorrado.mp3'));
        widget.onDismissed();
      } else if (_estado == "pagado") {
        await _player.play(AssetSource('sounds/pagado.mp3'));
        widget.onFormularioPedido?.call();
      }
      return;
    }

    setState(() {
      _offsetX = 0;
      _opacity = 1.0;
      _estado = null;
      widget.offsetNotifier.value = 0;
    });

    _scaleController.repeat(reverse: true);
  }

  Widget _buildEtiqueta(BuildContext context) {
    if (_estado == null) return const SizedBox.shrink();

    final isAhorrado = _estado == "ahorrado";
    final alignment = isAhorrado ? Alignment.topLeft : Alignment.topRight;
    final padding = isAhorrado
        ? const EdgeInsets.only(top: 0.0, left: 5.0)
        : const EdgeInsets.only(top: 0.0, right: 15.0);
    final rotation = isAhorrado ? -0.7 : 0.7;
    final assetPath = isAhorrado
        ? 'assets/images/saved.png'
        : 'assets/images/paid.png';

    return Align(
      alignment: alignment,
      child: Padding(
        padding: padding,
        child: Transform.rotate(
          angle: rotation,
          child: Opacity(
            opacity: (_offsetX.abs() / 120).clamp(0.0, 1.0),
            child: Image.asset(
              assetPath,
              width: 120,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  Color _getBorderColor(BuildContext context) {
    final colorFactor = (_offsetX / 75).clamp(-1.0, 1.0);
    if (_offsetX > 0) {
      return Colors.green.withOpacity(colorFactor.abs());
    } else if (_offsetX < 0) {
      return Colors.red.withOpacity(colorFactor.abs());
    } else {
      return Colors.white; // blanco semi-transparente por defecto
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 100),
          opacity: _opacity,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: FractionallySizedBox(
                widthFactor: 1,
                child: Container( // ⬅️ FORZAMOS EL ANCHO AQUÍ
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Transform.translate(
                      offset: Offset(_offsetX, 0),
                      child: Transform.rotate(
                        angle: _offsetX * 0.0015,
                        child: Stack(
                          children: [
                            AnimatedContainer(
                              duration: _borderAnimDuration,
                              curve: Curves.easeInOut,
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _getBorderColor(context),
                                  width: 4,
                                ),
                                boxShadow: [
                                  if (_offsetX.abs() > 10)
                                    BoxShadow(
                                      color: _getBorderColor(context).withOpacity(0.4),
                                      blurRadius: 12,
                                      spreadRadius: 3,
                                    ),
                                ],
                              ),
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Icon(Icons.access_time_filled,
                                      size: 48, color: theme.colorScheme.primary),
                                  const SizedBox(height: 16),
                                  Text(
                                    widget.tiempo,
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    widget.frase,
                                    style: theme.textTheme.bodyLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            _buildEtiqueta(context),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}
