import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';

void main() {
  runApp(HeartbeatApp());
}

class HeartbeatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HeartbeatScreen(),
    );
  }
}

class HeartbeatScreen extends StatefulWidget {
  @override
  _HeartbeatScreenState createState() => _HeartbeatScreenState();
}

class _HeartbeatScreenState extends State<HeartbeatScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late ConfettiController _confettiController;
  int _timeLeft = 10; // Countdown timer starting at 10
  bool _showMessage = false;
  bool _showBalloons = false;
  TextEditingController _customMessageController = TextEditingController();

  String _customMessage = ''; // Store the custom message
  Timer? _timer; // Timer to manage countdown

  @override
  void initState() {
    super.initState();

    // Heartbeat animation setup
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
      lowerBound: 0.8,
      upperBound: 1.0, // Ensures no out-of-bound errors
    )..repeat(reverse: true);

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Confetti controller
    _confettiController = ConfettiController(duration: Duration(seconds: 3));

    // Start countdown timer
    startCountdown();
  }

  // Start countdown timer function
  void startCountdown() {
    _timeLeft = 10; // Reset timer to 10 when starting over

    // Cancel any previous timers to prevent multiple countdowns
    _timer?.cancel();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        timer.cancel();
        _controller.stop(); // Stop heartbeat animation
        _confettiController.play(); // Start confetti
        setState(() {
          _showMessage = true;
          _showBalloons = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    _timer?.cancel(); // Dispose the timer to avoid memory leaks
    super.dispose();
  }

  // Fixed Floating Balloons (moving up)
  Widget _buildFloatingBalloons() {
    Random random = Random();
    return _showBalloons
        ? Stack(
            children: List.generate(5, (index) {
              double leftPosition = random.nextDouble() * MediaQuery.of(context).size.width;
              return AnimatedPositioned(
                duration: Duration(seconds: 5 + index),
                bottom: _showBalloons ? MediaQuery.of(context).size.height : -100, // Moves up
                left: leftPosition.clamp(20, MediaQuery.of(context).size.width - 50), // Keep within bounds
                child: Icon(Icons.favorite, color: Colors.pink, size: 50), // Heart-shaped balloons
              );
            }),
          )
        : SizedBox();
  }

  // Reset the countdown and animation
  void _reset() {
    setState(() {
      _showMessage = false;
      _showBalloons = false;
      _controller.repeat(reverse: true); // Restart heartbeat animation
    });
    startCountdown(); // Start countdown from 10 again
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Floating Balloons (moving up)
          _buildFloatingBalloons(),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 150,
                ),
              ),
              SizedBox(height: 20),
              Text(
                _timeLeft > 0 ? "Beating for $_timeLeft seconds..." : "",
                style: GoogleFonts.pacifico(
                  textStyle: TextStyle(fontSize: 24, color: Colors.red),
                ),
              ),
              SizedBox(height: 20),

              // Custom message input
              TextField(
                controller: _customMessageController,
                decoration: InputDecoration(
                  hintText: 'Enter a custom message...',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (text) {
                  setState(() {
                    _customMessage = text;
                  });
                },
              ),
            ],
          ),

          // Heart-shaped Confetti Effect
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [Colors.red, Colors.pink, Colors.white],
              createParticlePath: (size) {
                // Custom particle shape: heart-shaped particles
                return Path()
                  ..moveTo(0, size.height)
                  ..lineTo(size.width / 2, 0)
                  ..lineTo(size.width, size.height);
              },
            ),
          ),

          // Valentine's Day Message (Appears after timer ends)
          if (_showMessage)
            Center(
              child: AnimatedOpacity(
                opacity: _showMessage ? 1.0 : 0.0,
                duration: Duration(seconds: 2),
                child: Text(
                  _customMessage.isEmpty
                      ? "You're Loved! ❤️"
                      : _customMessage, // Display custom message
                  style: GoogleFonts.dancingScript(
                    textStyle: TextStyle(fontSize: 30, color: Colors.redAccent),
                  ),
                ),
              ),
            ),

          // Reset Button at the bottom
          Positioned(
            bottom: 30,
            child: ElevatedButton(
              onPressed: _reset,
              child: Text("Reset Timer"),
            ),
          ),
        ],
      ),
    );
  }
}
