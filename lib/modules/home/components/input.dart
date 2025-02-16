import 'package:flutter/material.dart';

class Input extends StatefulWidget {
  const Input({
    super.key,
    required this.title,
    required this.value,
    required this.onInputChange,
  });
  final String title;
  final Function(String) onInputChange;
  final String value;

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  late TextEditingController _controller;

  @override
  initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: TextField(
        controller: _controller,
        onSubmitted: widget.onInputChange,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: widget.title,
        ),
      ),
    );
  }
}
