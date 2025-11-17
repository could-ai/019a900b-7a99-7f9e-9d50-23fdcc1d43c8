import 'dart:async';

import 'package:flutter/material.dart';

class TypingPage extends StatefulWidget {
  const TypingPage({super.key});

  @override
  State<TypingPage> createState() => _TypingPageState();
}

class _TypingPageState extends State<TypingPage> {
  final String _textToType =
      "The quick brown fox jumps over the lazy dog. This sentence contains all the letters of the alphabet. Practice makes perfect. Keep typing to improve your speed and accuracy. Flutter is a beautiful and powerful UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.";
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  int _currentIndex = 0;
  int _correctChars = 0;
  int _incorrectChars = 0;
  Timer? _timer;
  int _secondsElapsed = 0;
  double _wpm = 0.0;
  double _accuracy = 100.0;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    // Request focus when the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
        _calculateWpm();
      });
    });
  }

  void _onTextChanged() {
    if (!_isTyping && _controller.text.isNotEmpty) {
      _isTyping = true;
      _startTimer();
    }

    setState(() {
      String typedText = _controller.text;
      if (typedText.isEmpty) {
        _resetState();
        return;
      }

      _currentIndex = typedText.length;
      _correctChars = 0;
      _incorrectChars = 0;

      for (int i = 0; i < _currentIndex; i++) {
        if (i < _textToType.length) {
          if (typedText[i] == _textToType[i]) {
            _correctChars++;
          } else {
            _incorrectChars++;
          }
        } else {
          _incorrectChars++;
        }
      }
      _calculateAccuracy();
      _calculateWpm();
    });
  }

  void _calculateWpm() {
    if (_secondsElapsed > 0) {
      // WPM is often calculated as (number of characters / 5) / time in minutes
      double words = (_correctChars / 5.0);
      double minutes = _secondsElapsed / 60.0;
      setState(() {
        _wpm = words / minutes;
      });
    }
  }

  void _calculateAccuracy() {
    int totalTyped = _correctChars + _incorrectChars;
    if (totalTyped > 0) {
      setState(() {
        _accuracy = (_correctChars / totalTyped) * 100;
      });
    } else {
      setState(() {
        _accuracy = 100.0;
      });
    }
  }

  void _resetState() {
    _timer?.cancel();
    setState(() {
      _controller.clear();
      _currentIndex = 0;
      _correctChars = 0;
      _incorrectChars = 0;
      _secondsElapsed = 0;
      _wpm = 0.0;
      _accuracy = 100.0;
      _isTyping = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Touch Typing Trainer'),
        backgroundColor: const Color(0xFF21252B),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(_focusNode),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildStats(),
              const SizedBox(height: 20),
              _buildTextDisplay(),
              const SizedBox(height: 20),
              _buildTextField(),
              const SizedBox(height: 30),
              _buildVirtualKeyboard(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _resetState,
                child: const Text('Reset'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('WPM', _wpm.toStringAsFixed(1)),
        _buildStatItem('Accuracy', '${_accuracy.toStringAsFixed(1)}%'),
        _buildStatItem('Time', '$_secondsElapsed s'),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 5),
        Text(value,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF61AFEE))),
      ],
    );
  }

  Widget _buildTextDisplay() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF21252B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
              fontSize: 24,
              fontFamily: 'monospace',
              color: Color(0xFFABB2BF)),
          children: _buildTextSpans(),
        ),
      ),
    );
  }

  List<TextSpan> _buildTextSpans() {
    List<TextSpan> spans = [];
    for (int i = 0; i < _textToType.length; i++) {
      Color color;
      TextDecoration? decoration;
      Color? decorationColor;

      if (i < _currentIndex) {
        if (_controller.text[i] == _textToType[i]) {
          color = const Color(0xFF98C379); // Correctly typed
        } else {
          color = const Color(0xFFE06C75); // Incorrectly typed
          decoration = TextDecoration.underline;
          decorationColor = const Color(0xFFE06C75);
        }
      } else if (i == _currentIndex) {
        color = Colors.white; // Current character
        decoration = TextDecoration.underline;
        decorationColor = const Color(0xFF61AFEE);
      } else {
        color = Colors.grey; // Upcoming text
      }
      spans.add(
        TextSpan(
          text: _textToType[i],
          style: TextStyle(
            color: color,
            backgroundColor: i == _currentIndex
                ? Colors.grey.withOpacity(0.5)
                : Colors.transparent,
            decoration: decoration,
            decorationColor: decorationColor,
            decorationThickness: 2,
          ),
        ),
      );
    }
    return spans;
  }

  Widget _buildTextField() {
    // An invisible text field to capture input
    return SizedBox(
      width: 0,
      height: 0,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: true,
        autocorrect: false,
        enableSuggestions: false,
        keyboardType: TextInputType.text,
      ),
    );
  }

  Widget _buildVirtualKeyboard() {
    const List<List<String>> keyboardLayout = [
      [
        '`',
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9',
        '0',
        '-',
        '=',
        'Backspace'
      ],
      ['Tab', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\\'],
      [
        'Caps Lock',
        'a',
        's',
        'd',
        'f',
        'g',
        'h',
        'j',
        'k',
        'l',
        ';',
        '\'',
        'Enter'
      ],
      ['Shift', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 'Shift'],
      ['Ctrl', 'Alt', 'Space', 'Alt', 'Ctrl'],
    ];

    return Column(
      children: keyboardLayout.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((key) {
            bool isSpecialKey = key.length > 1;
            bool isActive = false;
            if (_currentIndex < _textToType.length) {
              isActive =
                  _textToType[_currentIndex].toLowerCase() == key.toLowerCase();
            }
            if (key == 'Space' &&
                _currentIndex < _textToType.length &&
                _textToType[_currentIndex] == ' ') {
              isActive = true;
            }

            return Container(
              margin: const EdgeInsets.all(3),
              width: isSpecialKey ? (key == 'Space' ? 200 : 80) : 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    isActive ? const Color(0xFF61AFEE) : const Color(0xFF21252B),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.grey.shade700),
              ),
              child: Center(
                child: Text(
                  key,
                  style: TextStyle(
                    color: isActive ? Colors.black : Colors.white,
                    fontSize: isSpecialKey ? 12 : 16,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
