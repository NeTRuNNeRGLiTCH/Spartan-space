import 'package:flutter/material.dart';

class CodexPage extends StatelessWidget {
  const CodexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        title: const Text("TITANSCRIPT v2.1.0 MANUAL",
            style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900, fontSize: 12)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        children: [
          _buildHeroHeader(),
          const SizedBox(height: 40),

          _sectionHeader("01. BRANCH-AS-CLOSURE ( . / END )"),
          _bodyText("TitanScript v2.1.0 uses a surgical dot-balance system. Every individual branch of logic must be terminated by a space and a period [ . ]."),
          _bulletPoint("Simple Actions", "Require 1 period. (e.g., Weight + 5 .)"),
          _bulletPoint("Logic Blocks", "A standard [WHEN] with no [OTHERWISE] requires 1 period to close."),
          _bulletPoint("Logic Bridges", "A [WHEN-OTHERWISE] structure requires 2 periods: one after the DO branch, and one after the OTHERWISE branch."),
          _codeBlock("WHEN Condition DO\n  Action .\nOTHERWISE\n  Action .\nEND ."),

          _sectionHeader("02. THE RE-ARMING STACK"),
          _bodyText("In v2.1.0, the dot after a [DO] branch does not end the statement if an [OTHERWISE] is detected. The engine 're-arms' the scope automatically."),
          _warningText("THE NESTING RULE: In nested structures, ensure you have enough dots to reach the 'Root' counter before the next keyword."),

          _sectionHeader("03. ASSIGNMENT VS EQUALITY"),
          _bodyText("To prevent logical leaks, v2.1.0 separates setting a value from checking a value."),
          _bulletPoint("= (Assignment)", "Sets the target to the right value. (e.g., Weight = 100)"),
          _bulletPoint("=? (Equality)", "Checks if values are exactly equal. (e.g., Reps =? 12)"),

          _sectionHeader("04. COMPLEX CONDITIONS (AND / OR / NOT)"),
          _bodyText("Multiple biological triggers can be chained. Conditions are evaluated based on the absolute performance record of the current session."),
          _codeBlock("WHEN Reps > 10 and not Weight > 100 DO\n  Weight + 5 .\nEND ."),

          _sectionHeader("05. PROCEDURAL CHAINING ( , )"),
          _bodyText("Execute multiple mutations within a single branch using the comma separator. Ensure there is a space on both sides of the comma."),
          _codeBlock("DO Weight + 5 , Reps = 8 ."),

          _sectionHeader("06. GLOBAL REGISTRY (GLOBAL)"),
          _bodyText("Values stored via [STORE] are local. Use [GLOBAL] to save values into the permanent Titan Registry accessible by all blueprints."),
          _codeBlock("GLOBAL Weight of set1 AS max_bench ."),

          _sectionHeader("07. NESTED INTERPRETATION"),
          _bodyText("Logic depth is calculated in real-time. A dot will always close the innermost active scope first."),
          _codeBlock("WHEN Condition1 DO\n  REPEAT 3 DO\n    WHEN Condition2 DO\n      Action .\n    OTHERWISE\n      Action .\n  . // Closes REPEAT\n. // Closes Outer WHEN\nEND ."),

          _sectionHeader("08. ITERATIVE LOOPS (REPEAT)"),
          _bodyText("The [REPEAT] command executes its body for X iterations, automatically incrementing the [SET(THIS)] pointer."),
          _codeBlock("REPEAT 3 DO Weight of set(this) + 5 . END ."),

          _sectionHeader("09. INTERFACE TELEMETRY (IDE)"),
          _colorGuideRow("CYAN", "Keywords: WHEN, DO, OTHERWISE, REPEAT, END."),
          _colorGuideRow("ORANGE", "Pointers: all, set1, set(this)."),
          _colorGuideRow("GREEN", "Data: Numerical values and variables."),
          _colorGuideRow("RED", "Errors: Structural mismatch or unknown identifier."),

          _sectionHeader("10. OPTIMIZED v2.1.0 TEMPLATES"),
          _exampleGroup("THE SMART OVERLOAD", "Increases intensity only if absolute compliance is met."),
          _codeBlock("WHEN Reps of all >= 12 DO\n  Weight of all + 2.5 .\nOTHERWISE\n  Reps of all + 2 .\nEND ."),

          const SizedBox(height: 100),
          const Center(child: Text("TITAN_CORE_V2.1.0 // STABLE BUILD", style: TextStyle(color: Colors.white10, fontSize: 8, letterSpacing: 4))),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.cyanAccent.withOpacity(0.05),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: const [
          Icon(Icons.psychology_outlined, color: Colors.cyanAccent, size: 40),
          SizedBox(height: 15),
          Text("TITANSCRIPT OPERATING MANUAL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
          SizedBox(height: 10),
          Text(
            "Version 2.1.0 // Author: NeTRuNNeR \nStatus: Logic Core Calibrated",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 10, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 15),
      child: Text(title, style: const TextStyle(color: Colors.orangeAccent, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
    );
  }

  Widget _bodyText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6)),
    );
  }

  Widget _warningText(String text) {
    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.redAccent.withOpacity(0.3))
      ),
      child: Row(
        children: [
          const Icon(Icons.security, color: Colors.redAccent, size: 20),
          const SizedBox(width: 15),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold, height: 1.4))),
        ],
      ),
    );
  }

  Widget _codeBlock(String code) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Text(code, style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace', fontSize: 13, height: 1.5, fontWeight: FontWeight.bold)),
    );
  }

  Widget _bulletPoint(String key, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.chevron_right, color: Colors.cyanAccent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: "$key: ", style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                  TextSpan(text: desc, style: const TextStyle(color: Colors.white60, fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorGuideRow(String colorName, String desc) {
    Color c = colorName == "CYAN" ? Colors.cyanAccent :
    colorName == "ORANGE" ? Colors.orangeAccent :
    colorName == "GREEN" ? Colors.greenAccent : Colors.redAccent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
              width: 70,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
              child: Center(child: Text(colorName, style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 10)))
          ),
          const SizedBox(width: 15),
          Expanded(child: Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _exampleGroup(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.white24, fontSize: 10)),
        ],
      ),
    );
  }
}