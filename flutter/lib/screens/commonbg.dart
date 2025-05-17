import 'package:flutter/material.dart';

class bg extends StatelessWidget {
  final Widget child;
    final Widget? bottomNavigationBar;

    const bg({super.key, required this.child, this.bottomNavigationBar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        children: [
          // Background Image
          
          // Stretched Radial Gradient Overlay
          Positioned.fill(
            child: Transform.scale(
              scaleY: 2,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.0, 0.0),
                    radius: 0.65,
                    colors: [
                      Color(0xAA66C498), // semi-transparent green
                      Color(0xFF3A4B44), // darker edge
                    ],
                  ),
                ),
              ),
            ),
          ),


          Transform.scale(
            scaleX:0.8,
            scaleY:0.8,
            child: Center(
              child:Image.asset(
              'lib/screens/bg.png', // <-- Update to your image path
              
            )),
          ),

          // Foreground UI
          SafeArea(child: child),
        ],
      ),
    );
  }
}
