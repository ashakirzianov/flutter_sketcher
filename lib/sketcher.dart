import 'dart:ui' as ui;
import 'package:flutter/material.dart';

typedef Render<State> = void Function(Canvas canvas, Size size, State state);
typedef Animator<State> = State Function(State state);

class Layer<State> {
  const Layer({required this.render});
  final Render<State> render;
}

class SceneWidget<S> extends StatefulWidget {
  const SceneWidget({
    Key? key,
    required this.layers,
    required this.state,
    required this.animator,
  }) : super(key: key);

  final List<Layer<S>> layers;
  final S state;
  final Animator<S> animator;

  @override
  State<SceneWidget<S>> createState() => _SceneWidgetState<S>();
}

class _SceneWidgetState<S> extends State<SceneWidget<S>> {
  late S state;
  ui.Image? _cachedImage;

  @override
  void initState() {
    super.initState();
    state = widget.state;
    loop();
  }

  loop() {
    Future.delayed(const Duration(milliseconds: 40), () {
      setState(() {
        state = widget.animator(state);
      });
      loop();
    });
  }

  void updateCachedImage(ui.Image image) {
    setState(() {
      _cachedImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ScenePainter<S>(
        layers: widget.layers,
        state: state,
        cachedImage: _cachedImage,
        onImageUpdated: updateCachedImage,
      ),
      size: MediaQuery.of(context).size,
    );
  }
}

class ScenePainter<S> extends CustomPainter {
  ScenePainter({
    required this.layers,
    required this.state,
    required this.cachedImage,
    required this.onImageUpdated,
  });

  final List<Layer<S>> layers;
  final S state;
  final ui.Image? cachedImage;
  final Function(ui.Image) onImageUpdated;

  @override
  void paint(Canvas canvas, Size size) {
    var recorder = ui.PictureRecorder();
    final offscreenCanvas = Canvas(recorder);
    if (cachedImage != null) {
      canvas.drawImage(cachedImage!, Offset.zero, Paint());
      offscreenCanvas.drawImage(cachedImage!, Offset.zero, Paint());
    }

    for (final layer in layers) {
      layer.render(offscreenCanvas, size, state);
      layer.render(canvas, size, state);
    }

    final picture = recorder.endRecording();
    picture.toImage(size.width.toInt(), size.height.toInt()).then((image) {
      onImageUpdated(image.clone());
    });
  }

  @override
  bool shouldRepaint(ScenePainter<S> oldDelegate) {
    return true;
  }
}
