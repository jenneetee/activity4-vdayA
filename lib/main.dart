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
  List<ConfettiParticle> _confetti = [];
  final TextEditingController _messageController = TextEditingController();
  String _selectedMessage = "";

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
      _generateConfetti();
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
      _confetti.clear();
    });
  }

  void _generateConfetti() {
    _confetti = List.generate(20, (index) => ConfettiParticle());
  }

  @override
  void dispose() {
    _controller.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.pink[50],
        appBar: AppBar(
          title: Text("Activity 4: Valentine's Heartbeat"),
          backgroundColor: Colors.pink,
        ),
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Enter a Valentine's message",
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedMessage = value;
                        });
                      },
                    ),
                  ),
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
                      _selectedMessage.isEmpty
                          ? "Happy Valentine's Day! ❤️"
                          : _selectedMessage,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            if (_isPlaying) ..._confetti,
          ],
        ),
      ),
    );
  }
}

class ConfettiParticle extends StatefulWidget {
  @override
  _ConfettiParticleState createState() => _ConfettiParticleState();
}

class _ConfettiParticleState extends State<ConfettiParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final Random _random = Random();
  double left = 0;

  @override
  void initState() {
    super.initState();
    left = _random.nextDouble() * 300;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3 + _random.nextInt(3)),
    )..forward();

    _animation = Tween<double>(begin: -50, end: 600)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          left: left,
          top: _animation.value,
          child: Icon(
            Icons.star,
            color: Colors.primaries[_random.nextInt(Colors.primaries.length)],
            size: _random.nextDouble() * 15 + 10,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
