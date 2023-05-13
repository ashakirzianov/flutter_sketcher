import 'dart:ui' as ui;
import 'package:flutter/material.dart';

typedef Render<State> = void Function(Canvas canvas, Size size, State state);
typedef Animator<State> = State Function(State state);

class Layer<State> {
  const Layer({this.render, this.background});
  final Render<State>? render;
  final Render<State>? background;
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (var layer in widget.layers)
          LayerWidget<S>(
            state: state,
            render: layer.render,
            background: layer.background,
          ),
      ],
    );
  }
}

class LayerWidget<S> extends StatefulWidget {
  const LayerWidget({
    Key? key,
    required this.state,
    this.render,
    this.background,
  }) : super(key: key);
  final S state;
  final Render<S>? render;
  final Render<S>? background;

  @override
  State<LayerWidget<S>> createState() => _LayerWidgetState<S>();
}

class _LayerWidgetState<S> extends State<LayerWidget<S>> {
  ui.Image? _cachedImage;
  void updateCachedImage(ui.Image image) {
    setState(() {
      _cachedImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    var foreground = widget.render != null
        ? CanvasPainter(
            onFinish: updateCachedImage,
            render: (canvas, size) {
              if (_cachedImage != null) {
                canvas.drawImage(_cachedImage!, Offset.zero, Paint());
              }
              widget.render!(canvas, size, widget.state);
            },
          )
        : null;
    var painter = widget.background != null
        ? CanvasPainter(render: (canvas, size) {
            widget.background!(canvas, size, widget.state);
          })
        : null;
    return CustomPaint(
      painter: painter,
      foregroundPainter: foreground,
      size: MediaQuery.of(context).size,
    );
  }
}

class CanvasPainter<S> extends CustomPainter {
  const CanvasPainter({
    required this.render,
    this.onFinish,
  });

  final Function(Canvas, Size) render;
  final Function(ui.Image)? onFinish;

  @override
  void paint(Canvas canvas, Size size) {
    if (onFinish == null) {
      render(canvas, size);
    } else {
      var recorder = ui.PictureRecorder();
      final offscreenCanvas = Canvas(recorder);
      render(offscreenCanvas, size);
      render(canvas, size);

      final picture = recorder.endRecording();
      picture.toImage(size.width.toInt(), size.height.toInt()).then((image) {
        onFinish!(image.clone());
      });
    }
  }

  @override
  bool shouldRepaint(CanvasPainter<S> oldDelegate) {
    return onFinish != null;
  }
}
