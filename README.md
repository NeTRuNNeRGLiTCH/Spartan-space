# 🔱 Titan Log Pro: Biometric Performance Engine

Most gym apps are just digital versions of a paper notebook. They track what you *did*, but they don't understand *who you are* or *what you are capable of becoming.*

**Titan Log Pro** was built to bridge that gap. Designed for hypertrophy and strength athletes who prioritize data over guesswork, it functions as a high-fidelity training terminal. By combining recursive data structures with validated anthropometric models, it transforms raw numbers into a blueprint for systemic evolution.

---

## 🏗 System Architecture

### 1. Nested Workout Blueprints
Standard loggers use flat, rigid lists. Titan Log Pro utilizes a **Recursive Node System**. This allows you to architect your training with the same modularity used in software engineering:
*   **Global Protocols:** Define "Master Rules" for rest intervals and transition times at the plan level.
*   **Modular Folders:** Group workouts by methodology (PPL, Arnold Split) or specific training blocks.
*   **Dynamic Overrides:** Individual exercises inherit global settings by default but allow for "local shadowing"—enabling specific rest timers for heavy compounds without affecting isolation work.

### 2. Titan Telemetry (Biometrics)
The system analyzes your "biological frame" using established physiological formulas to track your standing against natural potential:
*   **The Casey Butt Model:** Calculates your theoretical muscular ceiling based on skeletal anchors (wrist and ankle circumference).
*   **Lean Tissue Density:** Tracks FFMI (Fat-Free Mass Index) to score muscularity relative to height.
*   **Bilateral Symmetry Detection:** Identifies structural "glitches." With a 0.5cm sensitivity threshold, the system flags L/R imbalances to help mitigate injury risk and compensation patterns.
*   **Performance Hexagon:** A 6-axis radar chart mapping Power (1RM), Symmetry, Growth Delta, Rarity (FFMI), Consistency, and Volume.

### 3. Execution & Recovery Engine
When the session starts, the app becomes a **Protocol State Machine** designed to keep you on schedule:
*   **Pre-Flight Briefing:** Define the session's "Operational Directive"—setting specific targets for weight, reps, or time before you lift.
*   **Intelligent Rest HUD:** Once a set is logged, the timer takes over. If you exceed your recovery window, the system enters a **"Negative State"** with periodic haptic alerts to enforce strict temporal discipline.
*   **Inheritance Logic:** Automatically adjusts rest periods depending on whether you are switching sets or moving to an entirely new exercise module.

### 4. The Relic Archive
A dedicated persistence layer that scans your training history to verify and "extract" significant milestones:
*   **Strength Tiers:** Monitors SBD (Squat/Bench/Deadlift) ratios relative to your current body weight.
*   **The Greek Convergence:** A "Master Achievement" requiring all body measurements to match classical aesthetic proportions within a strict 2.5% tolerance.
*   **Circadian Tracking:** Analyzes performance trends based on time-of-day (Dawn vs. Night sessions).

---

## 🛠 Tech Stack

*   **Frontend:** Flutter (Dart) for a high-performance, high-contrast terminal UI.
*   **Storage:** Hive (NoSQL) for ultra-fast, local-first data persistence.
*   **Data Layer:** Custom JSON-based serialization for flexible, nested workout schemas.
*   **Logic Engine:** Heuristic algorithms for auto-regulating weight increments via Pyramid and Plateau-Breaker protocols.

---

## 🚀 Initializing the System

1.  **Clone the Archive:**
    ```bash
    git clone https://github.com/NeTRuNNeRGLiTCH/Spartan-space.git
    ```
2.  **Sync Dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Launch Protocol:**
    ```bash
    flutter run --release
    ```

---
> *"In the gym, as in engineering, you cannot optimize what you do not measure."*
