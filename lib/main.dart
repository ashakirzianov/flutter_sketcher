import 'package:flutter/material.dart';
import 'package:flutter_sketcher/sketcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: double.infinity,
      height: double.infinity,
      child: SceneWidget<int>(
        state: 0,
        animator: (state) => state + 1,
        layers: [
          Layer<int>(
            render: (Canvas canvas, Size size, int state) {
              final paint = Paint()
                ..color = Colors.black
                ..style = PaintingStyle.fill;
              canvas.drawCircle(
                Offset(size.width / 2, size.height / 2 + state.toDouble()),
                size.width / 2,
                paint,
              );
              canvas.drawRect(
                  Rect.fromLTWH(0, 0, size.width, size.height),
                  Paint()
                    ..color = Colors.red
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 10);
            },
          ),
        ],
      ),
    ));
  }
}
