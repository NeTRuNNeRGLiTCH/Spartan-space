import 'package:flutter/material.dart';

class CodexPage extends StatelessWidget {
  const CodexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        title: const Text("TITANSCRIPT OPERATING MANUAL",
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

          _sectionHeader("01. THE INSTRUCTION PERIOD ( . )"),
          _bodyText("TitanScript operates through logic sentences. To commit an instruction to the system memory, you must finalize the thought with a space followed by a period [ . ]."),
          _bodyText("This character functions as the 'Execute' command. It separates different logical operations so the engine can process them in sequence."),
          _codeBlock("Weight of all + 5 ."),
          _bodyText("In plain English: Take the current weight of every set and add 5 units to it for the next session."),
          _warningText("THE GAP REQUIREMENT: You must ensure a space exists before the period. Writing [10.] will be interpreted as a decimal number, while [10 .] will be interpreted as a finished command."),

          _sectionHeader("02. CONDITIONAL BRANCHING (WHEN / DO)"),
          _bodyText("The [WHEN] keyword allows the engine to analyze your performance and make autonomous decisions. Logic is only applied if the specified threshold is met."),
          _bodyText("Syntax: WHEN [Performance Metric] DO [Action] OTHERWISE [Fallback] ."),
          _codeBlock("WHEN Reps of set1 >= 12 DO Weight of all + 2.5 OTHERWISE Weight of all ."),
          _bodyText("In plain English: If I managed to perform 12 or more repetitions in my first set today, increase the weight for all sets by 2.5 in the next session. If I failed that target, keep the weight exactly the same."),
          _bodyText("By using OTHERWISE, you ensure the system has a fallback plan, preventing unauthorized changes to your blueprint."),

          _sectionHeader("03. ITERATIVE LOOPS (REPEAT)"),
          _bodyText("The [REPEAT] command is designed for high-speed routine generation. It allows you to program multiple sets with a single sentence of logic."),
          _bodyText("When using REPEAT, you gain access to the dynamic pointer [set(this)]. This word transforms into set1, set2, set3, etc., automatically as the loop progresses."),
          _codeBlock("REPEAT 3 DO Weight of set(this) + 5 ."),
          _bodyText("In plain English: For the next three sets, increase the weight by 5 units progressively."),
          _bodyText("This is the most efficient way to build pyramids or progressive overload cycles without writing individual lines for every set."),

          _sectionHeader("04. PARALLEL ACTIONS (AND)"),
          _bodyText("TitanScript allows you to modify multiple biometrics within a single logical block. Use the [AND] keyword to chain actions together."),
          _codeBlock("REPEAT 3 DO Weight of set(this) + 5 AND Reps of set(this) - 2 ."),
          _bodyText("In plain English: For the next three sets, increase the weight by 5 but simultaneously decrease the target repetitions by 2."),
          _bodyText("Chaining actions allows for complex training methodologies like power-building where weight increases as volume decreases."),

          _sectionHeader("05. EPHEMERAL REGISTRY (STORE / AS)"),
          _bodyText("The [STORE] command creates a temporary 'Sticky Note' in the engine's local memory. This is used to save a performance value for comparison later in the script."),
          _codeBlock("STORE Weight of set1 AS baseline ."),
          _bodyText("Once stored, you can use the word [baseline] (or any name you choose) as a reference point for the rest of the script."),
          _codeBlock("WHEN Weight of set1 > baseline DO Reps + 1 ."),
          _bodyText("In plain English: Save my starting weight as a baseline. Later, if my current weight is higher than that baseline, add one repetition to the plan."),
          _warningText("VOLATILE MEMORY: All variables created with STORE are wiped the moment the script finishes execution. They do not persist between different exercises."),

          _sectionHeader("06. LOGIC & MATH OPERATORS"),
          _bodyText("The engine supports a full suite of mathematical and logical operators to define your evolution."),
          _bulletPoint("+ , - , * , /", "Calculation: Adds, subtracts, multiplies, or divides values."),
          _bulletPoint("> , < , =", "Comparison: Checks if values are greater, smaller, or strictly equal."),
          _bulletPoint(">= , <=", "Thresholds: Checks for 'at least' or 'no more than' levels."),
          _bulletPoint("=?", "Equality Query: specifically checks if a performance value exactly matches a target."),
          _codeBlock("WHEN Reps =? 10 DO Weight + 5 ."),

          _sectionHeader("07. ENVIRONMENT SCOPES"),
          _bodyText("The engine enforces strict scope-locking. You are only permitted to use variables that match your exercise type."),
          _scopeTable(),
          _bodyText("If you attempt to use 'Weight' in a 'Plank' script, the engine will trigger a SCOPE_ERROR and terminate the instruction for system safety."),

          _sectionHeader("08. TARGET ACQUISITION (OF)"),
          _bodyText("You must define the target of every operation using the [of] keyword. This tells the engine where to apply the logic."),
          _bulletPoint("of all", "Applies the logic to every set within the current exercise blueprint."),
          _bulletPoint("of set[n]", "Applies logic to a specific set index (e.g., set1, set2, set5)."),
          _bulletPoint("of set(this)", "Target the current set index during a REPEAT loop."),

          _sectionHeader("09. INTERFACE TELEMETRY (IDE COLORS)"),
          _bodyText("The Protocol Forge editor provides live feedback through color-coding. Use this telemetry to verify your logic is correct:"),
          _colorGuideRow("CYAN", "Logic Keywords: WHEN, DO, REPEAT, STORE, AS, OTHERWISE, AND."),
          _colorGuideRow("ORANGE", "Target Pointers: all, set1, set(this)."),
          _colorGuideRow("GREEN", "Numeric Data: Any raw number or math result."),
          _colorGuideRow("RED", "Logic Leaks: Typos or unauthorized words. Red text prevents saving."),

          _sectionHeader("10. EXECUTION TERMINATION (END)"),
          _bodyText("The [END] keyword acts as a manual return gate. It immediately stops the engine and commits the final value provided."),
          _codeBlock("WHEN Reps < 5 DO END Weight - 10 ."),
          _bodyText("In plain English: If I failed to reach 5 reps, stop everything and immediately drop the weight by 10 units."),

          _sectionHeader("11. PRACTICAL TEMPLATES"),

          _exampleGroup("THE TITAN OVERLOAD", "Classic linear bodybuilding progression."),
          _codeBlock("WHEN Reps of set1 >= 12 DO Weight of all + 2.5 OTHERWISE Weight of all ."),

          _exampleGroup("THE BURN-OUT GENERATOR", "Automatic high-volume dropset generator."),
          _codeBlock("REPEAT 3 DO Weight of set(this) - 10 AND Reps of set(this) + 5 ."),

          _exampleGroup("THE PLATEAU ANALYSIS", "Compares performance to check for stagnation."),
          _codeBlock("STORE Reps of set1 AS old_reps .\nWHEN Reps of set1 > old_reps DO Weight of all + 5 ."),

          _exampleGroup("THE SKILL STEP", "Bodyweight progression for calisthenics."),
          _codeBlock("WHEN Reps of all >= 25 DO Reps of all + 5 ."),

          const SizedBox(height: 100),
          const Center(child: Text("TITAN_CORE_V1.1 // END OF FILE", style: TextStyle(color: Colors.white10, fontSize: 8, letterSpacing: 4))),
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
            "Version 1.1.0 // Author: NeTRuNNeR \nStatus: System Online",
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
          _scopeRow("BODYBUILDING", "Variables: Weight, Reps"),
          const Divider(color: Colors.white10, height: 25),
          _scopeRow("CALISTHENICS", "Variables: Reps"),
          const Divider(color: Colors.white10, height: 25),
          _scopeRow("PLANK / HOLDS", "Variables: Seconds"),
          const Divider(color: Colors.white10, height: 25),
          _scopeRow("RUNNING", "Variables: Distance"),
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