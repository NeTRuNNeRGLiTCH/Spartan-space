import 'package:flutter/material.dart';

class CodexPage extends StatelessWidget {
  const CodexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        title: const Text("TITANSCRIPT_OS // CORE MANUAL",
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

          _sectionHeader("01. THE FOUNDATION: SENTENCES"),
          _bodyText("TitanScript doesn't use brackets or complex symbols. It uses sentences. Every time you finish an instruction, you must tell the app to 'commit' it to the database."),
          _bodyText("The symbol for this is the Command Dot [ . ]. Think of it as the period at the end of a sentence or the [Enter] key on a keyboard."),
          _codeBlock("Weight of all + 5 ."),
          _bodyText("In this example, the engine reads 'Weight of all + 5', sees the dot, and immediately saves that change."),
          _warningText("THE SPACE RULE: \nYou MUST put a space before the dot. \n[ 10 . ] is a command. \n[ 10. ] is a decimal number. \nFailure to add a space will cause a LOGIC_LEAK error in the console."),

          _sectionHeader("02. TOOLS: OPERATORS & MATH"),
          _bodyText("You can manipulate your performance data using two types of tools: Mathematical and Logical."),
          _bulletPoint("+ , - , * , /", "Math Tools: Use these to change numbers. \nExample: [Weight * 1.1] increases your weight by 10%."),
          _bulletPoint("> , < , =", "Logic Tools: Use these to check your performance. \nExample: [Reps > 10] checks if you did more than 10 reps."),
          _bulletPoint(">= , <=", "Precision Tools: Greater or equal to / Smaller or equal to."),
          _codeBlock("WHEN Weight of set1 >= 100 DO Reps + 2 ."),

          _sectionHeader("03. DECISION MAKING (WHEN)"),
          _bodyText("The [WHEN] keyword turns the app into an intelligent coach. It allows the app to make a choice based on how you feel or perform."),
          _bodyText("A decision has three parts: The Condition, The Action, and the Fallback."),
          _codeBlock("WHEN [Performance] DO [Change] OTHERWISE [Stay Same] ."),
          _bodyText("Detailed Example: \n[WHEN Reps of set1 < 8 DO Weight of all - 5 OTHERWISE Weight of all + 2.5 . ]"),
          _bodyText("Human Translation: 'If I failed to hit 8 reps in my first set, I am tired—so drop the weight by 5kg for everyone. But if I hit 8 or more, I am strong—add 2.5kg for next time.'"),

          _sectionHeader("04. AUTOMATION (REPEAT)"),
          _bodyText("The [REPEAT] command is designed to build complex set structures (like Pyramids) without typing every set manually."),
          _bodyText("Inside a loop, the engine provides you with a 'Pointer' called [set(this)]. This word automatically changes into set1, set2, set3... as the loop runs."),
          _codeBlock("REPEAT 4 DO Weight of set(this) + 10 ."),
          _bodyText("This one line generates a 4-set heavy pyramid: \n• Set 1: +10kg \n• Set 2: +20kg \n• Set 3: +30kg \n• Set 4: +40kg"),
          _bodyText("If you want to change two things at once inside a loop, use the [AND] connector."),
          _codeBlock("REPEAT 3 DO Weight + 5 AND Reps - 2 ."),

          _sectionHeader("05. SYSTEM MEMORY (STORE)"),
          _bodyText("Sometimes you need to 'remember' a number to see if you improved later in the script. [STORE] creates a temporary 'Sticky Note' in the engine's memory."),
          _codeBlock("STORE Weight of set1 AS baseline ."),
          _bodyText("Now, for the rest of the script, the word [baseline] represents whatever weight you used in Set 1. You can name these notes anything: [my_max], [goal], [prev_reps]."),
          _warningText("AUTO-SHRED: To keep the Titan Engine fast, all Sticky Notes are shredded and deleted as soon as the script finishes. They do not save between different exercises."),

          _sectionHeader("06. MEASUREMENT SCOPES"),
          _bodyText("Variables are strictly locked to the exercise type to prevent system crashes. You cannot calculate 'Weight' for a 'Plank'."),
          _scopeTable(),

          _sectionHeader("07. TARGETING (OF)"),
          _bodyText("You must define the target of every math operation using the [of] keyword:"),
          _bulletPoint("of all", "The most common target. Changes every set in the plan."),
          _bulletPoint("of set[n]", "Targets a specific set. Useful for 'Top Sets' or 'Back-off Sets'. \nExample: [Weight of set1 + 10 . ]"),
          _bulletPoint("of set(this)", "The 'Current Set'. Only used inside REPEAT loops."),

          _sectionHeader("08. THE FORGE INTERFACE"),
          _bodyText("The Protocol Forge editor uses 'Live Telemetry' to guide you. The colors tell you if the 'Brain' of the app understands your words."),
          _colorGuideRow("CYAN", "Logic Keywords: These are the bones of the language."),
          _colorGuideRow("ORANGE", "Set Pointers: These tell the app where to look."),
          _colorGuideRow("GREEN", "Data: Numbers and measured values."),
          _colorGuideRow("RED", "Logic Leaks: These are typos or errors. If any word is Red, the [ENGRAVE] button will disable for safety."),

          _sectionHeader("09. MASTER TEMPLATES"),

          _exampleGroup("THE LINEAR OVERLOAD", "Classic progression for Bodybuilding."),
          _codeBlock("WHEN Reps of set1 >= 12 DO Weight of all + 2.5 OTHERWISE Weight of all ."),

          _exampleGroup("THE DROIPSET GENERATOR", "Automatic 3-stage burnout."),
          _codeBlock("REPEAT 3 DO Weight of set(this) - 10 AND Reps of set(this) + 5 ."),

          _exampleGroup("THE PLATEAU BREAKER", "Uses memory to check for progress."),
          _codeBlock("STORE Reps of set1 AS old_reps .\nWHEN Reps of set1 > old_reps DO Weight of all + 5 OTHERWISE Weight of all ."),

          _exampleGroup("THE CALISTHENICS STEP", "Progression for Pushups/Pullups."),
          _codeBlock("WHEN Reps of all >= 20 DO Reps of all + 5 ."),

          _exampleGroup("THE CHRONOS PEAK", "Progression for Planks and Holds."),
          _codeBlock("WHEN Seconds of set1 > 60 DO Seconds of all + 10 ."),

          const SizedBox(height: 100),
          const Center(child: Text("TITAN_CORE_V1.0 // END OF FILE", style: TextStyle(color: Colors.white60, fontSize: 8, letterSpacing: 4))),
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
            "Version 1.0.0 // Author: NeTRuNNeR \nStatus: System Online",
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
          const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
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
          boxShadow: [BoxShadow(color: Colors.greenAccent.withOpacity(0.02), blurRadius: 10)]
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
    Color c = Colors.white;
    if (colorName == "CYAN") c = Colors.cyanAccent;
    if (colorName == "ORANGE") c = Colors.orangeAccent;
    if (colorName == "GREEN") c = Colors.greenAccent;
    if (colorName == "RED") c = Colors.redAccent;

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

  Widget _scopeTable() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(
        children: [
          _scopeRow("BODYBUILDING", "Weight, Reps"),
          const Divider(color: Colors.white10, height: 25),
          _scopeRow("CALISTHENICS", "Reps"),
          const Divider(color: Colors.white10, height: 25),
          _scopeRow("PLANK / HOLDS", "Seconds"),
          const Divider(color: Colors.white10, height: 25),
          _scopeRow("RUNNING", "Distance"),
        ],
      ),
    );
  }

  Widget _scopeRow(String name, String vars) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(name, style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)),
        Text(vars, style: const TextStyle(color: Colors.white38, fontSize: 11, fontFamily: 'monospace')),
      ],
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