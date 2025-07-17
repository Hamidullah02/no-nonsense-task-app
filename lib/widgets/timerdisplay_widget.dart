
import 'package:flutter/material.dart';

class TimerDisplay extends StatelessWidget {
  final Duration duration;
  final double size;
  final double timerdivpadding;
  final double horizontalsize;




  const TimerDisplay({super.key, required this.duration, required this.size, required this.horizontalsize, required this.timerdivpadding});

  @override
  Widget build(BuildContext context) {
    final hours = (duration.inHours % 60).toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (duration.inHours > 0) ...[buildTimeBox(hours), buildSeparator()],
        buildTimeBox(minutes),
        buildSeparator(),
        buildTimeBox(seconds),
      ],
    );
  }

  Widget buildTimeBox(String digits) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      transitionBuilder:
          (child, animation) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
      child: SizedBox(
        width:horizontalsize,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent.withOpacity(.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -10,
                left: horizontalsize/2-10,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Color.fromARGB(247, 80, 79, 79),
                  child: CircleAvatar(
                    radius: 7,
                    backgroundColor: Color.fromARGB(255, 9, 147, 142),
                  ),
                ),
              ),

              Positioned(
                bottom: -10,
                left: horizontalsize/2-10,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Color.fromARGB(255, 80, 79, 79),
                  child: CircleAvatar(
                    radius: 7,
                    backgroundColor: Color.fromARGB(255, 9, 147, 142),
                  ),
                ),
              ),
              Center(
                child: Container(
                  key: ValueKey(digits),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    digits,
                    textAlign: TextAlign.center,
                    style:TextStyle(
                      color: Colors.greenAccent,
                      fontSize: size,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSeparator() => Padding(
    padding: EdgeInsets.symmetric(horizontal: timerdivpadding),
    child: Text(":", style: TextStyle(fontSize:size, color: Colors.white)),
  );
}
