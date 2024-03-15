import 'package:flutter/material.dart';
import 'package:lpd/pages/control_room.dart';

class ToggleButton extends StatefulWidget {
  final ToggleState toggleState;

  ToggleButton({required this.toggleState});

  @override
  _ToggleButtonState createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.toggleState
            .updateCameraToggle(!widget.toggleState.isCameraToggle);
        print(widget.toggleState.isCameraToggle);
      },
      child: Container(
        width: 100,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: widget.toggleState.isCameraToggle ? Colors.green : Colors.red,
        ),
        child: Text(
          widget.toggleState.isCameraToggle ? 'ON' : 'OFF',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
