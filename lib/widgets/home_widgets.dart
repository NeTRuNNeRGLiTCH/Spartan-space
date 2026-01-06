import 'package:flutter/material.dart';

class HomeQuoteCard extends StatelessWidget {
  final String quote;
  const HomeQuoteCard({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.orangeAccent.withOpacity(0.03),
            blurRadius: 40,
            spreadRadius: 10,
          )
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.format_quote_rounded, color: Colors.orangeAccent, size: 40),
          const SizedBox(height: 20),
          Text(
            quote,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 40,
            height: 2,
            color: Colors.orangeAccent.withOpacity(0.3),
          )
        ],
      ),
    );
  }
}

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return "RISE & GRIND";
    if (hour < 17) return "POWER THROUGH";
    return "STAY DISCIPLINED";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getGreeting(),
          style: const TextStyle(
            color: Colors.orangeAccent,
            letterSpacing: 6,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          "TITAN LOG",
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            letterSpacing: -2,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}