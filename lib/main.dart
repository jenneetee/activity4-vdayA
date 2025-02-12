import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(HeartbeatApp());
}

class HeartbeatApp extends StatefulWidget {
  @override
  _HeartbeatAppState createState() => _HeartbeatAppState();
}

class _HeartbeatAppState extends State<HeartbeatApp>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Timer _timer;
  int _countdown = 10;
  bool _isPlaying = false;
  final Random _random = Random();
  List<Widget> _sparkles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.5)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void _startTimer() {
    setState(() {
      _isPlaying = true;
      _countdown = 10;
      _generateSparkles();
    });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _stopTimer();
        }
      });
    });
  }

  void _stopTimer() {
    _timer.cancel();
    setState(() {
      _isPlaying = false;
      _sparkles.clear();
    });
  }

  void _generateSparkles() {
    _sparkles = List.generate(15, (index) {
      double left = _random.nextDouble() * 300;
      double top = _random.nextDouble() * 600;
      return Positioned(
        left: left,
        top: top,
        child: Icon(
          Icons.star,
          color: const Color.fromARGB(255, 225, 60, 126),
          size: _random.nextDouble() * 15 + 10,
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.pink[50],
        appBar: AppBar(
          title: Text("Valentine's Heartbeat"),
          backgroundColor: Colors.pink,
        ),
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _animation,
                    child: Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 100,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "$_countdown",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isPlaying ? null : _startTimer,
                    child: Text("Start Heartbeat"),
                  ),
                  SizedBox(height: 20),
                  AnimatedOpacity(
                    opacity: _isPlaying ? 1.0 : 0.0,
                    duration: Duration(seconds: 1),
                    child: Text(
                      "Happy Valentine's Day! ❤️",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            if (_isPlaying) ..._sparkles,
          ],
        ),
      ),
    );
  }
}
