import 'dart:typed_data';

import 'package:flutter/material.dart';

class DeviceCard extends StatefulWidget {
  final String deviceName;
  final String status;
  final String deviceSerialCode;
  final Uint8List imageBytes;

  DeviceCard({
    required this.imageBytes,
    required this.deviceName,
    required this.status,
    required this.deviceSerialCode,
  });

  @override
  _DeviceCardState createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
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
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              Container(
                  width: 111,
                  height: 86,
                  child: widget.imageBytes.isEmpty
                      ? Container(
                          decoration: const BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image:
                                      AssetImage('assets/icons/cam_icon.png'))))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(
                              150), // Half of width or height to make it a circle
                          child: Image.memory(widget.imageBytes))),
              const SizedBox(height: 10),
              Text(
                widget.deviceName,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                height: 10,
                margin: const EdgeInsets.only(
                  top: 7,
                  bottom: 7,
                  left: 30,
                  right: 30,
                ),
                decoration: BoxDecoration(
                  color: widget.status == 'connected'
                      ? const Color.fromARGB(255, 174, 215, 189)
                      : widget.status == 'preparing'
                          ? Color.fromARGB(255, 218, 199, 149)
                          : widget.status == "disconnected"
                              ? const Color.fromARGB(255, 242, 194, 194)
                              : widget.status == "on call"
                                  ? Color.fromARGB(255, 158, 163, 229)
                                  : Color.fromARGB(255, 188, 188, 188),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("status : "),
                  Text(
                    widget.status,
                    style: TextStyle(
                      color: widget.status == 'connected'
                          ? const Color.fromARGB(255, 15, 114, 25)
                          : widget.status == 'preparing'
                              ? Color.fromARGB(255, 212, 176, 87)
                              : widget.status == 'disconnected'
                                  ? const Color.fromARGB(255, 178, 100, 100)
                                  : widget.status == "on call"
                                      ? Color.fromARGB(255, 114, 119, 189)
                                      : Color.fromARGB(255, 93, 93, 93),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 7),
                alignment: Alignment.center,
                child: widget.status == 'connected'
                    ? const Text(
                        "click for control",
                        style: TextStyle(
                          color: Color.fromARGB(255, 200, 200, 200),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
