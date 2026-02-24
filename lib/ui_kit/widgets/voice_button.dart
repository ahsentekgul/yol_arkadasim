import 'package:flutter/material.dart';
import 'app_button.dart';

/// Reusable UI-only voice button. Does not perform real speech recognition.
class VoiceButton extends StatefulWidget {
  final void Function(String) onVoiceResult;
  final String? semanticsLabel;

  const VoiceButton({Key? key, required this.onVoiceResult, this.semanticsLabel}) : super(key: key);

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton> {
  bool isListening = false;

  void _toggleListening() {
    setState(() {
      isListening = !isListening;
    });
    if (!isListening) {
      // Demo: immediately return a sample result
      widget.onVoiceResult('İstiklal Caddesi');
    } else {
      // TODO: Start real speech recognition when integrating platform APIs
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppButton(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isListening ? Icons.mic : Icons.mic_none, color: Colors.white),
          const SizedBox(width: 8),
          Text(isListening ? 'Dinleniyor...' : 'Sesli Komut', style: const TextStyle(color: Colors.white)),
        ],
      ),
      onPressed: _toggleListening,
      semanticsLabel: widget.semanticsLabel ?? 'Sesli komut ver',
      fullWidth: true,
      size: 'custom',
      minHeight: 100,
    );
  }
}

