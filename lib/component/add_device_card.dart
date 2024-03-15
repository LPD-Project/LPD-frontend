import 'package:flutter/material.dart';
import 'package:lpd/pages/device_add.dart';

class AddDeviceCard extends StatefulWidget {
  late String url;
  AddDeviceCard({required this.url});

  @override
  _AddDeviceCardState createState() => _AddDeviceCardState();
}

class _AddDeviceCardState extends State<AddDeviceCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            PageRouteBuilder(
                pageBuilder: (context, animationT1, animationT2) =>
                    DeviceAdd(url: widget.url),
                transitionDuration: const Duration(milliseconds: 500)));
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(width: 3, color: Colors.transparent),
            color: Colors.transparent,
            boxShadow: isHovered
                ? [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Container(
            height: 250,
            width: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                width: 12,
                color: const Color.fromARGB(255, 233, 233, 233),
              ),
              color: const Color.fromARGB(255, 253, 253, 253),
            ),
            child: const Column(
              children: [
                SizedBox(height: 30),
                Icon(Icons.add,
                    color: Color.fromARGB(217, 86, 86, 86), size: 135),
                Text(
                  "Add New Device",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
