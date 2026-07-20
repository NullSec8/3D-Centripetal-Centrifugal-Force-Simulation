import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'simulation_state.dart';
import 'simulation_painter.dart';
import 'logo_painter.dart';

class SimulationPage extends StatefulWidget {
  const SimulationPage({super.key});

  @override
  State<SimulationPage> createState() => _SimulationPageState();
}

class _SimulationPageState extends State<SimulationPage> {
  final SimulationState _state = SimulationState();
  final FocusNode _focusNode = FocusNode();
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  bool _showSliders = true;
  Offset? _lastDragPos;

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(milliseconds: 16), _onTick);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTick(Timer timer) {
    final elapsed = _stopwatch.elapsedMicroseconds / 1000000.0;
    _stopwatch.reset();
    _stopwatch.start();
    _state.update(elapsed.clamp(0.001, 0.1));
    if (mounted) setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_lastDragPos == null) {
      _lastDragPos = details.globalPosition;
      return;
    }
    final dx = details.globalPosition.dx - _lastDragPos!.dx;
    final dy = details.globalPosition.dy - _lastDragPos!.dy;
    _lastDragPos = details.globalPosition;
    setState(() {
      _state.cameraAngleX += dx * 0.4;
      _state.cameraAngleY = (_state.cameraAngleY - dy * 0.4).clamp(5.0, 175.0);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _lastDragPos = null;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (details.scale != 1.0) {
      setState(() {
        _state.cameraDistance =
            (_state.cameraDistance / details.scale).clamp(2.0, 80.0);
      });
    }
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    setState(() {
      final key = event.logicalKey;
      if (key == LogicalKeyboardKey.arrowUp) {
        _state.omega += 0.1;
      } else if (key == LogicalKeyboardKey.arrowDown) {
        _state.omega = (_state.omega - 0.1).clamp(0.1, 999.0);
      } else if (key == LogicalKeyboardKey.arrowRight) {
        _state.rrezja += 0.2;
      } else if (key == LogicalKeyboardKey.arrowLeft) {
        _state.rrezja = (_state.rrezja - 0.2).clamp(0.5, 999.0);
      } else if (key == LogicalKeyboardKey.keyW) {
        _state.masa += 0.1;
      } else if (key == LogicalKeyboardKey.keyS) {
        _state.masa = (_state.masa - 0.1).clamp(0.1, 999.0);
      } else if (key == LogicalKeyboardKey.equal ||
          key == LogicalKeyboardKey.numpadAdd) {
        _state.shkallaVizuale += 0.05;
      } else if (key == LogicalKeyboardKey.minus ||
          key == LogicalKeyboardKey.numpadSubtract) {
        _state.shkallaVizuale =
            (_state.shkallaVizuale - 0.05).clamp(0.01, 999.0);
      } else if (key == LogicalKeyboardKey.keyA) {
        _state.cameraAngleX -= 5.0;
      } else if (key == LogicalKeyboardKey.keyD) {
        _state.cameraAngleX += 5.0;
      } else if (key == LogicalKeyboardKey.keyQ) {
        _state.cameraAngleY =
            (_state.cameraAngleY - 5.0).clamp(5.0, 175.0);
      } else if (key == LogicalKeyboardKey.keyE) {
        _state.cameraAngleY =
            (_state.cameraAngleY + 5.0).clamp(5.0, 175.0);
      } else if (key == LogicalKeyboardKey.keyZ) {
        _state.cameraDistance =
            (_state.cameraDistance - 1.0).clamp(2.0, 80.0);
      } else if (key == LogicalKeyboardKey.keyX) {
        _state.cameraDistance =
            (_state.cameraDistance + 1.0).clamp(2.0, 80.0);
      } else if (key == LogicalKeyboardKey.digit1) {
        _state.shfaqForcenCentripetale =
            !_state.shfaqForcenCentripetale;
      } else if (key == LogicalKeyboardKey.digit2) {
        _state.shfaqForcenCentrifugale =
            !_state.shfaqForcenCentrifugale;
      } else if (key == LogicalKeyboardKey.digit3) {
        _state.shfaqShpejtesine = !_state.shfaqShpejtesine;
      } else if (key == LogicalKeyboardKey.digit4) {
        _state.shfaqRrugen = !_state.shfaqRrugen;
      } else if (key == LogicalKeyboardKey.digit5) {
        _state.perspektiva3D = !_state.perspektiva3D;
      } else if (key == LogicalKeyboardKey.keyP) {
        _state.pauzuar = !_state.pauzuar;
      } else if (key == LogicalKeyboardKey.space) {
        _state.reset();
      }
    });
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141420),
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _onKeyEvent,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                onScaleUpdate: _onScaleUpdate,
                child: CustomPaint(
                  painter: SimulationPainter(_state),
                ),
              ),
            ),
            if (_state.pauzuar)
              const Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'PAUSED',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 12,
              right: 12,
              child: _buildInfoPanel(),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: _buildLegendPanel(),
            ),
            if (_showSliders) Positioned(
              bottom: 50,
              left: 12,
              child: _buildSliders(),
            ),
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: _buildControlsBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendPanel() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xCC1A1A2E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _legendItem('Centripetal (Blue)', const Color(0xFF0080FF)),
          _legendItem('Centrifugal (Red)', const Color(0xFFFF0000)),
          _legendItem('Velocity (Green)', const Color(0xFF00CC00)),
          _legendItem('Orbit (Gray)', const Color(0xFF808080)),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 12, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _buildSliders() {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xCC1A1A2E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _slider('Radius', _state.rrezja, 0.5, 10.0, (v) => setState(() => _state.rrezja = v)),
          _slider('Omega', _state.omega, 0.1, 5.0, (v) => setState(() => _state.omega = v)),
          _slider('Mass', _state.masa, 0.1, 10.0, (v) => setState(() => _state.masa = v)),
          const SizedBox(height: 6),
          Row(
            children: [
              _toggleBtn('F_c', _state.shfaqForcenCentripetale,
                  () => setState(() => _state.shfaqForcenCentripetale = !_state.shfaqForcenCentripetale)),
              const SizedBox(width: 4),
              _toggleBtn('F_cf', _state.shfaqForcenCentrifugale,
                  () => setState(() => _state.shfaqForcenCentrifugale = !_state.shfaqForcenCentrifugale)),
              const SizedBox(width: 4),
              _toggleBtn('v', _state.shfaqShpejtesine,
                  () => setState(() => _state.shfaqShpejtesine = !_state.shfaqShpejtesine)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _slider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text('$label:', style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace')),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: const Color(0xFF0080FF),
                inactiveTrackColor: Colors.white24,
                thumbColor: Colors.white,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                trackHeight: 2,
                overlayColor: const Color(0x330080FF),
              ),
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(value.toStringAsFixed(1),
                style: const TextStyle(color: Colors.white54, fontSize: 10, fontFamily: 'monospace'),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0080FF) : Colors.white12,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label,
            style: TextStyle(
                color: active ? Colors.white : Colors.white54,
                fontSize: 10,
                fontFamily: 'monospace')),
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xCC1A1A2E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LogoWidget(size: 56),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Centripetal Force',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    'F = m\u03C9\u00B2r',
                    style: TextStyle(
                      color: Colors.white.withAlpha(150),
                      fontSize: 12,
                      fontFamily: 'monospace',
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(width: 160, height: 1, color: Colors.white24),
          const SizedBox(height: 8),
          _infoRow('F', '${_state.fc.toStringAsFixed(2)} N'),
          _infoRow('m', '${_state.masa.toStringAsFixed(1)} kg'),
          _infoRow('\u03C9', '${_state.omega.toStringAsFixed(1)} rad/s'),
          _infoRow('r', '${_state.rrezja.toStringAsFixed(1)} m'),
          _infoRow('v', '${_state.v.toStringAsFixed(2)} m/s'),
          _infoRow('a', '${_state.ac.toStringAsFixed(2)} m/s\u00B2'),
          _infoRow('T', '${_state.T.toStringAsFixed(2)} s'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
              color: Colors.white70, fontSize: 13, fontFamily: 'monospace'),
          children: [
            TextSpan(
              text: '$label = ',
              style: const TextStyle(color: Colors.white),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsBar() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xCC1A1A2E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Drag: rotate | Scroll: zoom | 1-5: toggle | P: pause | Space: reset',
              style: TextStyle(
                  color: Colors.white54, fontSize: 11, fontFamily: 'monospace'),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => setState(() => _showSliders = !_showSliders),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _showSliders ? 'Hide UI' : 'Show UI',
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 10, fontFamily: 'monospace'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
