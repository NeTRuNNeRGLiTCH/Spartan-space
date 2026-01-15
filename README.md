# TITAN LOG PRO v2.1.0 🛡️
### Advanced Human Performance & Biometric Intelligence System

**Titan Log Pro** is a tactical execution environment designed for high-level athletes and biohackers. While standard gym apps act as digital notebooks, Titan Log Pro operates as a **Kinanthropometric Expert System**, using advanced mathematical models and a custom logic engine to dictate the path of physical evolution.

---

## 🚀 THE TITAN ADVANTAGE: WHY THIS IS DIFFERENT

Most fitness apps track data. Titan Log Pro **interprets** it.

### 1. Scientific Bodybuilding HUD
Unlike basic trackers, Titan Log Pro implements elite-tier physiological formulas:
- **Physique Archetyping:** Calculates **FFMI (Fat-Free Mass Index)** and assigns users to "Combat Classes" (Genesis, Peak, Hybrid, Paragon, Titan) based on tissue density.
- **Symmetry Telemetry:** Uses logarithmic delta analysis of limb proportions to detect bilateral imbalances.
- **Genetic Potential Modeling:** Implements joint-to-height ratios to calculate theoretical muscular limits based on skeletal frame density.

### 2. TitanScript: Autonomous Programming
The app features a custom-built **Domain Specific Language (DSL)** that allows for "Smart Overload." You don't just log a set; the engine executes your personalized protocol to calculate your *next* session's targets in real-time.
- **Interpretive Core:** Handles nested logic (WHEN/DO/OTHERWISE) and iterative loops (REPEAT).
- **Auto-Regulation:** The app automatically adjusts intensity and volume based on session compliance.

### 3. The Relic Vault (Gamified Excellence)
A milestone system based on historical data and biological thresholds.
- **Data-Driven Achievements:** Unlock "Relics" like *The Megaton* (1,000,000kg lifetime volume) or *Apollo Sync* (Elite shoulder-to-waist ratios).
- **The Greek Convergence:** A perfection-check algorithm that monitors if your proportions match the "Golden Era" ideal (2.5% tolerance).

### 4. Titan ID: Tactical Data Export
Generate and share your biometric credentials.
- **Visual Identity:** Export a "Titan ID Card" containing your FFMI, Chassis Tier, and Class Assignment.
- **Verification:** Uses a specialized screenshot service to create high-fidelity shareable tactical summaries.

---

## 🛠️ ARCHITECTURAL OVERVIEW

The application is built on a high-performance **C++ backed NoSQL architecture**, optimized for speed and offline reliability.

### The Controller Layer (The Brains)
- **BodyVisualizerController:** Manages complex radar charts and structural evolution bars.
- **SessionController:** A real-time state machine managing rest timers, haptic feedback, and performance logging.
- **ProtocolController:** The IDE for TitanScript, featuring real-time syntax highlighting and lexical validation.
- **MeasurementsController:** Handles biometric input and automates the **U.S. Navy Body Fat formula** and BMI calculations.

### Performance & Memory Tiering
To maintain 60FPS on low-resource hardware, the app utilizes **Manual Memory Paging**:
- **Hot Tier:** 31-day active window for high-speed logging.
- **Cold Tier:** Archive data is paged on-demand (Titan Sync) and automatically deloaded after 60 seconds to maintain a zero-lag footprint.

---

## 🏗️ TECH STACK
- **Framework:** Flutter (Dart)
- **Database:** ObjectBox (High-performance NoSQL with C-API bindings)
- **Graphics:** CustomPainter for Radar Polygons and Equilibrium charts.
- **Interpreter:** Custom Recursive-Descent Lexer & Parser.

---

## 📜 EXAMPLE TITANSCRIPT v2.1.0
```text
WHEN Reps of all >= 12 DO
  Weight of all + 2.5 .
OTHERWISE
  REPEAT 2 DO
    Weight of set(this) + 1.25 .
END .