import 'package:flutter/material.dart';

class ProgressBar extends StatefulWidget {
  final double porcentaje;
  final double gastoActual;
  final double salarioDisponible;

  const ProgressBar({
    Key? key,
    required this.porcentaje,
    required this.gastoActual,
    required this.salarioDisponible,
  }) : super(key: key);

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar> with SingleTickerProviderStateMixin {
  late final AnimationController _shineController;
  late final Animation<double> _shineAnimation;

  @override
  void initState() {
    super.initState();
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _shineAnimation = Tween<double>(begin: -1, end: 2).animate(CurvedAnimation(
      parent: _shineController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Colors.white;

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;
        final barHeight = 16.0;

        return TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: 0,
            end: widget.porcentaje.clamp(0.0, 1.0),
          ),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOut,
          builder: (context, animatedPct, child) {
            final percentageWidth = animatedPct * barWidth;
            final textLeft = percentageWidth - 40 < 8 ? 8 : percentageWidth - 40;

            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: barHeight,
                    width: barWidth,
                    color: color.withOpacity(0.15),
                  ),
                ),
                // barra animada con efecto brillante encima
                Positioned(
                  left: 0,
                  child: AnimatedBuilder(
                    animation: _shineAnimation,
                    builder: (context, child) {
                      return ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            begin: Alignment(_shineAnimation.value, 0),
                            end: Alignment(_shineAnimation.value + 0.3, 0),
                            colors: [
                              color,
                              Colors.white.withOpacity(0.5),
                              color,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.srcATop,
                        child: Container(
                          height: barHeight,
                          width: percentageWidth,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: textLeft.toDouble(),
                  child: Text(
                    '${(animatedPct * 100).toStringAsFixed(1)}%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      overflow: TextOverflow.ellipsis,
                      shadows: const [
                        Shadow(color: Colors.black26, blurRadius: 2, offset: Offset(1, 1))
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
