import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/home_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> quotes = [
    "The only bad workout is the one that didn't happen.",
    "Suffer the pain of discipline or suffer the pain of regret.",
    "Motivation gets you started. Habit keeps you going.",
    "Your body can stand almost anything. It’s your mind you have to convince.",
    "Hustle for that muscle.",
    "Train insane or remain the same.",
    "Results happen over time, not overnight. Work hard, stay patient.",
    "Focus on your goals, not the obstacles.",
    "Discipline is doing what needs to be done, even if you don't want to do it.",
    "What seems impossible today will one day become your warm-up.",
    "No pain, no gain. Shut up and train.",
    "The hardest lift of all is lifting your butt off the couch.",
    "Believe in yourself and you will be unstoppable.",
    "Fitness is about being better than you were yesterday.",
    "Don't wish for it, work for it.",
    "Success starts with self-discipline.",
    "Great things never come from comfort zones.",
    "Don't stop when you're tired. Stop when you're done.",
    "A one-hour workout is only 4% of your day. No excuses.",
    "Your health is an investment, not an expense.",
    "Small progress is still progress.",
    "Strength does not come from winning. Your struggles develop your strengths.",
    "Action is the foundational key to all success.",
    "Look in the mirror. That’s your competition.",
    "Wake up. Work out. Look hot. Kick ass.",
    "Sweat is just fat crying.",
    "The only way to define your limits is by going beyond them.",
    "Don't count the days, make the days count.",
    "Everything you've ever wanted is on the other side of fear.",
    "The difference between the impossible and the possible lies in a person’s determination.",
    "The gym is not a social club. Get in, do work, get out.",
    "You don’t have to be great to start, but you have to start to be great.",
    "Obsession beats talent every time.",
    "If it doesn't challenge you, it doesn't change you.",
    "Go another round. When you're tired, go another round.",
    "Physical fitness is not only one of the most important keys to a healthy body, it is the basis of dynamic and creative intellectual activity.",
    "Energy and persistence conquer all things.",
    "The clock is ticking. Are you becoming the person you want to be?",
    "First they will ask you why you are doing it. Later they will ask you how you did it.",
    "Your desire to change must be greater than your desire to stay the same.",
    "Don't decrease the goal. Increase the effort.",
    "A champion is someone who gets up when they can't.",
    "If you want something you've never had, you must be willing to do something you've never done.",
    "Today I will do what others won't, so tomorrow I can do what others can't.",
    "The successful warrior is the average man, with laser-like focus.",
    "Strength is the product of struggle.",
    "You are one workout away from a good mood.",
    "Discipline turns goals into reality.",
    "Excuses don't build empires.",
    "Hard work beats talent when talent doesn't work hard.",
    "Consistency is the quiet key to transformation."
  ];

  late String currentQuote;

  @override
  void initState() {
    super.initState();
    currentQuote = quotes[Random().nextInt(quotes.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -50,
            child: _buildGlow(Colors.orangeAccent.withOpacity(0.1)),
          ),
          Positioned(
            bottom: -100,
            right: -50,
            child: _buildGlow(Colors.blueAccent.withOpacity(0.05)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const HomeHeader(),
                  const Spacer(),
                  HomeQuoteCard(quote: currentQuote),
                  const Spacer(),
                  _buildQuickStats(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlow(Color color) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 120, spreadRadius: 60)],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _miniStat("READY", Icons.bolt),
        _miniStat("FOCUSED", Icons.remove_red_eye_outlined),
        _miniStat("TITAN", Icons.shield_outlined),
      ],
    );
  }

  Widget _miniStat(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.orangeAccent),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}