import 'package:flutter/material.dart';
import 'dart:math';
import 'workout_log.dart';

class Relic {
  final String id;
  final String title;
  final String description;
  final String requirement;
  final IconData icon;
  final Color color;
  final bool Function(List<WorkoutLog> logs, Map<String, dynamic> bodyData) isUnlocked;

  Relic({
    required this.id,
    required this.title,
    required this.description,
    required this.requirement,
    required this.icon,
    required this.color,
    required this.isUnlocked,
  });

  static double _val(dynamic v) => (v is num) ? v.toDouble() : 0.0;

  static bool checkPerfection(Map<String, dynamic> data) {
    double wrist = _val(data['wrist']);
    double knee = _val(data['knee']);
    double height = _val(data['height']);
    if (wrist <= 0 || knee <= 0 || height <= 0) return false;

    Map<String, double> targets = {
      'chest': wrist * 6.5,
      'neck': wrist * 2.5,
      'bicepL': wrist * 2.5,
      'bicepR': wrist * 2.5,
      'calfL': wrist * 2.5,
      'calfR': wrist * 2.5,
      'thighL': knee * 1.75,
      'thighR': knee * 1.75,
      'waist': height * 0.45,
    };

    for (var entry in targets.entries) {
      double actual = _val(data[entry.key]);
      if (actual <= 0) return false;
      double diff = (actual - entry.value).abs();
      if (diff > (entry.value * 0.025)) return false;
    }
    return true;
  }

  static List<Relic> get database => [
    Relic(
      id: 'master_key',
      title: 'ARCHITECT OF PERFECTION',
      description: 'The Greek Convergence achieved. Total structural harmony.',
      requirement: 'MATCH ALL IDEAL PROPORTIONS (2.5% TOLERANCE)',
      icon: Icons.vpn_key,
      color: Colors.redAccent,
      isUnlocked: (logs, data) => checkPerfection(data),
    ),
    Relic(
      id: 'bench_titan',
      title: 'BENCH PRESS: TITAN',
      description: 'Elite upper body propulsion. Gravity is a suggestion.',
      requirement: 'BENCH PRESS 1.5X BODYWEIGHT',
      icon: Icons.fitness_center,
      color: Colors.amber,
      isUnlocked: (logs, data) {
        double w = _val(data['weight']);
        double maxB = 0;
        for (var l in logs) {
          if (l.exerciseName.toLowerCase().contains("bench press")) {
            for (var s in l.performedSets) {
              if (s.weight > maxB) maxB = s.weight;
            }
          }
        }
        return w > 0 && (maxB / w) >= 1.5;
      },
    ),
    Relic(
      id: 'hydraulic_drive',
      title: 'SQUAT: TITAN',
      description: 'System foundation capable of extreme structural load.',
      requirement: 'SQUAT 2.0X BODYWEIGHT',
      icon: Icons.expand,
      color: Colors.orangeAccent,
      isUnlocked: (logs, data) {
        double w = _val(data['weight']);
        double maxS = 0;
        for (var l in logs) {
          if (l.exerciseName.toLowerCase().contains("squat")) {
            for (var s in l.performedSets) {
              if (s.weight > maxS) maxS = s.weight;
            }
          }
        }
        return w > 0 && (maxS / w) >= 2.0;
      },
    ),
    Relic(
      id: 'earth_reaper',
      title: 'DEADLIFT: TITAN',
      description: 'Total pull capacity has bypassed natural limitations.',
      requirement: 'DEADLIFT 2.5X BODYWEIGHT',
      icon: Icons.straighten,
      color: Colors.deepPurpleAccent,
      isUnlocked: (logs, data) {
        double w = _val(data['weight']);
        double maxD = 0;
        for (var l in logs) {
          if (l.exerciseName.toLowerCase().contains("deadlift")) {
            for (var s in l.performedSets) {
              if (s.weight > maxD) maxD = s.weight;
            }
          }
        }
        return w > 0 && (maxD / w) >= 2.5;
      },
    ),
    Relic(
      id: 'v_taper_gold',
      title: 'APOLLO SYNC',
      description: 'Shoulder width suggests elite genetic-muscular harmony.',
      requirement: 'SHOULDER / WAIST RATIO > 1.6',
      icon: Icons.change_history,
      color: Colors.cyanAccent,
      isUnlocked: (logs, data) {
        double s = _val(data['shoulders']);
        double w = _val(data['waist']);
        return (s > 0 && w > 0) && (s / w >= 1.6);
      },
    ),
    Relic(
      id: 'perfect_symmetry',
      title: 'EQUILIBRIUM',
      description: 'System balance achieved. Zero bilateral drift detected.',
      requirement: 'L/R IMBALANCE < 0.2CM ACROSS LIMBS',
      icon: Icons.adjust,
      color: Colors.tealAccent,
      isUnlocked: (logs, data) {
        List<String> pairs = ["bicep", "fore", "thigh", "calf"];
        for (var p in pairs) {
          double l = _val(data['${p}L']);
          double r = _val(data['${p}R']);
          if (l > 0 && r > 0 && (l - r).abs() > 0.2) return false;
        }
        return _val(data['bicepL']) > 0;
      },
    ),
    Relic(
      id: 'morning_star',
      title: 'MORNING STAR',
      description: 'System operational before typical initialization.',
      requirement: 'LOG A SESSION BEFORE 6:00 AM',
      icon: Icons.wb_sunny,
      color: Colors.yellow,
      isUnlocked: (logs, data) => logs.any((l) => l.date.hour < 6),
    ),
    Relic(
      id: 'night_crawler',
      title: 'NIGHT CRAWLER',
      description: 'Training confirmed during low-circadian cycles.',
      requirement: 'LOG A SESSION AFTER 10:00 PM',
      icon: Icons.nights_stay,
      color: Colors.indigoAccent,
      isUnlocked: (logs, data) => logs.any((l) => l.date.hour >= 22),
    ),
    Relic(
      id: 'megaton_lift',
      title: 'THE MEGATON',
      description: 'Cumulative system tonnage has bypassed 1,000,000 kg.',
      requirement: 'LIFETIME TONNAGE > 1,000,000 KG',
      icon: Icons.factory,
      color: Colors.deepOrange,
      isUnlocked: (logs, data) {
        double total = 0;
        for (var l in logs) {
          for (var s in l.performedSets) {
            total += (s.weight * s.value);
          }
        }
        return total >= 1000000;
      },
    ),
    Relic(
      id: 'centurion',
      title: 'THE CENTURION',
      description: 'System capability for extreme rep endurance.',
      requirement: '100+ REPS IN A SINGLE SESSION',
      icon: Icons.shield,
      color: Colors.blueGrey,
      isUnlocked: (logs, data) {
        Map<String, int> daily = {};
        for (var l in logs) {
          String d = "${l.date.year}-${l.date.month}-${l.date.day}";
          int r = 0;
          for (var s in l.performedSets) {
            r += s.value;
          }
          daily[d] = (daily[d] ?? 0) + r;
        }
        return daily.values.any((r) => r >= 100);
      },
    ),
    Relic(
      id: 'hypertrophy_master',
      title: 'GROWTH ARCHITECT',
      description: 'Perfect utilization of hypertrophy rep ranges.',
      requirement: '50 CONSECUTIVE SETS IN 8-12 RANGE',
      icon: Icons.auto_graph,
      color: Colors.greenAccent,
      isUnlocked: (logs, data) {
        int streak = 0;
        List<WorkoutLog> sorted = List.from(logs)..sort((a,b) => a.date.compareTo(b.date));
        for (var l in sorted) {
          for (var s in l.performedSets) {
            if (s.value >= 8 && s.value <= 12) {
              streak++;
              if (streak >= 50) return true;
            } else {
              streak = 0;
            }
          }
        }
        return false;
      },
    ),
    Relic(
      id: 'titan_singularity',
      title: 'TITAN SINGULARITY',
      description: 'Approaching the natural human biological ceiling.',
      requirement: 'FFMI > 24.0',
      icon: Icons.star,
      color: Colors.redAccent,
      isUnlocked: (logs, data) {
        double h = _val(data['height']);
        double w = _val(data['weight']);
        double bf = _val(data['bf']);
        if (h <= 0 || w <= 0) return false;
        double leanMass = w * (1 - (bf / 100.0));
        double ffmi = (leanMass / pow(h / 100.0, 2)) + (6.3 * (1.8 - (h / 100.0)));
        return ffmi >= 24.0;
      },
    ),
    Relic(
      id: 'genesis_complete',
      title: 'GENESIS COMPLETE',
      description: 'Initialization complete. User is no longer a beginner.',
      requirement: 'LOG 50+ DIFFERENT EXERCISES',
      icon: Icons.hub,
      color: Colors.white70,
      isUnlocked: (logs, data) => logs.map((l) => l.exerciseName).toSet().length >= 50,
    ),
    Relic(
      id: 'wing_protocol_bronze',
      title: 'WING PROTOCOL: BRONZE',
      description: 'Latissimus activation suggests basic vertical pull capability.',
      requirement: 'LOG 15+ REPS OF PULL-UPS',
      icon: Icons.airplanemode_active,
      color: Colors.lightBlue,
      isUnlocked: (logs, data) {
        for (var l in logs) {
          if (l.exerciseName.toLowerCase().contains("pull up")) {
            for (var s in l.performedSets) {
              if (s.value >= 15) return true;
            }
          }
        }
        return false;
      },
    ),
    Relic(
      id: 'weighted_ascension',
      title: 'WEIGHTED ASCENSION',
      description: 'System can pull external mass beyond biological weight.',
      requirement: 'WEIGHTED PULL-UP > 20KG',
      icon: Icons.vertical_align_top,
      color: Colors.cyan,
      isUnlocked: (logs, data) {
        for (var l in logs) {
          if (l.exerciseName.toLowerCase().contains("pull up")) {
            for (var s in l.performedSets) {
              if (s.weight >= 20) return true;
            }
          }
        }
        return false;
      },
    ),
    Relic(
      id: 'dip_dominance',
      title: 'TRICEP OVERDRIVE',
      description: 'Upper foundation output in vertical pressing is elite.',
      requirement: 'WEIGHTED DIP > 40KG',
      icon: Icons.keyboard_double_arrow_down,
      color: Colors.tealAccent,
      isUnlocked: (logs, data) {
        for (var l in logs) {
          if (l.exerciseName.toLowerCase().contains("dip")) {
            for (var s in l.performedSets) {
              if (s.weight >= 40) return true;
            }
          }
        }
        return false;
      },
    ),
    Relic(
      id: 'strength_velocity_1',
      title: 'STRENGTH VELOCITY',
      description: 'System shows a consistent upward trajectory in load handling.',
      requirement: 'ADD 10KG TO BENCH IN 30 DAYS',
      icon: Icons.speed,
      color: Colors.greenAccent,
      isUnlocked: (logs, data) {
        var benchLogs = logs.where((l) => l.exerciseName.toLowerCase().contains("bench press")).toList();
        if (benchLogs.length < 2) return false;
        benchLogs.sort((a, b) => a.date.compareTo(b.date));
        double start = benchLogs.first.performedSets.map((s) => s.weight).reduce(max);
        double end = benchLogs.last.performedSets.map((s) => s.weight).reduce(max);
        return (end - start) >= 10 && benchLogs.last.date.difference(benchLogs.first.date).inDays <= 30;
      },
    ),
    Relic(
      id: 'high_frequency_pulse',
      title: 'HIGH-FREQUENCY PULSE',
      description: 'System has been activated with extreme frequency.',
      requirement: 'TRAIN 6 DAYS IN A SINGLE WEEK',
      icon: Icons.waves,
      color: Colors.pinkAccent,
      isUnlocked: (logs, data) {
        if (logs.length < 6) return false;
        List<WorkoutLog> sorted = List.from(logs)..sort((a, b) => a.date.compareTo(b.date));
        for (int i = 0; i < sorted.length - 5; i++) {
          if (sorted[i + 5].date.difference(sorted[i].date).inDays <= 7) return true;
        }
        return false;
      },
    ),
    Relic(
      id: 'titan_neck_archive',
      title: 'CERVICAL ANCHOR',
      description: 'Upper cervical support has reached high-impact safety thresholds.',
      requirement: 'NECK MEASUREMENT > 42CM',
      icon: Icons.shield,
      color: Colors.blueGrey,
      isUnlocked: (logs, data) => _val(data['neck']) >= 42,
    ),
    Relic(
      id: 'forearm_glitch_detected',
      title: 'GRIP MASTER',
      description: 'Lower limb extremity density is a statistical anomaly.',
      requirement: 'FOREARMS > 36CM',
      icon: Icons.pan_tool,
      color: Colors.orangeAccent,
      isUnlocked: (logs, data) => _val(data['foreL']) >= 36 || _val(data['foreR']) >= 36,
    ),
    Relic(
      id: 'quad_zilla',
      title: 'QUAD-DRIVE ACTIVE',
      description: 'Lower chassis volume has bypassed standard athletic baselines.',
      requirement: 'THIGHS > 65CM',
      icon: Icons.whatshot,
      color: Colors.redAccent,
      isUnlocked: (logs, data) => _val(data['thighL']) >= 65 || _val(data['thighR']) >= 65,
    ),
    Relic(
      id: 'dawn_breaker',
      title: 'DAWN BREAKER',
      description: 'System initialization recorded before sunrise.',
      requirement: '5 WORKOUTS LOGGED BEFORE 5:30 AM',
      icon: Icons.wb_twilight,
      color: Colors.amberAccent,
      isUnlocked: (logs, data) {
        return logs.where((l) => l.date.hour < 5 || (l.date.hour == 5 && l.date.minute < 30)).length >= 5;
      },
    ),
    Relic(
      id: 'solar_peak',
      title: 'SOLAR OVERDRIVE',
      description: 'Training confirmed during maximum solar intensity.',
      requirement: '10 WORKOUTS BETWEEN 12PM - 2PM',
      icon: Icons.sunny,
      color: Colors.orange,
      isUnlocked: (logs, data) {
        return logs.where((l) => l.date.hour >= 12 && l.date.hour <= 14).length >= 10;
      },
    ),
    Relic(
      id: 'marathon_engine',
      title: 'MARATHON ENGINE',
      description: 'Aerobic energy systems have achieved high-level sustainability.',
      requirement: 'SINGLE SESSION DISTANCE > 10,000M',
      icon: Icons.directions_run,
      color: Colors.lightGreenAccent,
      isUnlocked: (logs, data) {
        for (var l in logs) {
          for (var s in l.performedSets) {
            if (s.value >= 10000) return true;
          }
        }
        return false;
      },
    ),
    Relic(
      id: 'sprinter_core',
      title: 'SPRINT CORE',
      description: 'High-power output recorded in aerobic movement.',
      requirement: 'MOVE 1000M IN UNDER 4 MINUTES',
      icon: Icons.bolt,
      color: Colors.yellowAccent,
      isUnlocked: (logs, data) {
        return logs.any((l) => l.exerciseName.toLowerCase().contains("run") &&
            l.performedSets.any((s) => s.value >= 1000));
      },
    ),
    Relic(
      id: 'unbroken_year',
      title: 'THE IRON YEAR',
      description: 'System has maintained operational status for one solar cycle.',
      requirement: 'WORKOUT LOGGED IN 12 CONSECUTIVE MONTHS',
      icon: Icons.auto_awesome_motion,
      color: Colors.white,
      isUnlocked: (logs, data) {
        if (logs.isEmpty) return false;
        Set<String> months = logs.map((l) => "${l.date.year}-${l.date.month}").toSet();
        return months.length >= 12;
      },
    ),
    Relic(
      id: 'data_monolith',
      title: 'DATA MONOLITH',
      description: 'Archive contains a massive quantity of biological feedback.',
      requirement: 'LOG 2,000 TOTAL PERFORMED SETS',
      icon: Icons.storage,
      color: Colors.blueGrey,
      isUnlocked: (logs, data) {
        int total = 0;
        for (var l in logs) {
          total += l.performedSets.length;
        }
        return total >= 2000;
      },
    ),
    Relic(
      id: 'apex_predator',
      title: 'APEX HYBRID',
      description: 'Rare combination of extreme strength and cardiovascular endurance.',
      requirement: '150KG SQUAT + 10KM RUN IN HISTORY',
      icon: Icons.workspace_premium,
      color: Colors.amber,
      isUnlocked: (logs, data) {
        bool hasSquat = false;
        bool hasRun = false;
        for (var l in logs) {
          if (l.exerciseName.toLowerCase().contains("squat") &&
              l.performedSets.any((s) => s.weight >= 150)) {
            hasSquat = true;
          }
          if (l.exerciseName.toLowerCase().contains("run") &&
              l.performedSets.any((s) => s.value >= 10000)) {
            hasRun = true;
          }
        }
        return hasSquat && hasRun;
      },
    ),
    Relic(
      id: 'stone_statue',
      title: 'STONE STATUE',
      description: 'Core stability has surpassed standard duration thresholds.',
      requirement: 'LOG A 300-SECOND PLANK',
      icon: Icons.hourglass_full,
      color: Colors.brown,
      isUnlocked: (logs, data) {
        for (var l in logs) {
          if (l.exerciseName.toLowerCase().contains("plank")) {
            for (var s in l.performedSets) {
              if (s.value >= 300) return true;
            }
          }
        }
        return false;
      },
    ),
    Relic(
      id: 'iron_grip_static',
      title: 'HANG TIME',
      description: 'Grip strength allows for prolonged suspension.',
      requirement: 'LOG A 120-SECOND DEAD HANG',
      icon: Icons.pan_tool_alt,
      color: Colors.orange,
      isUnlocked: (logs, data) {
        for (var l in logs) {
          if (l.exerciseName.toLowerCase().contains("hang")) {
            for (var s in l.performedSets) {
              if (s.value >= 120) return true;
            }
          }
        }
        return false;
      },
    ),
    Relic(
      id: 'volume_tier_master',
      title: 'THE OVERSEER',
      description: 'Total lifetime volume suggest a high-capacity biological engine.',
      requirement: 'LIFETIME TONNAGE > 5,000,000 KG',
      icon: Icons.blur_on,
      color: Colors.red,
      isUnlocked: (logs, data) {
        double total = 0;
        for (var l in logs) {
          for (var s in l.performedSets) {
            total += (s.weight * s.value);
          }
        }
        return total >= 5000000;
      },
    ),
    Relic(
      id: 'deload_logic',
      title: 'RECOVERY SCIENTIST',
      description: 'System longevity confirmed through intentional intensity shifts.',
      requirement: 'LOG A SESSION WITH 50% USUAL WEIGHTS',
      icon: Icons.science,
      color: Colors.lightBlueAccent,
      isUnlocked: (logs, data) {
        return logs.length > 30;
      },
    ),
    Relic(
      id: 'bone_density_alpha',
      title: 'DENSE ARCHITECTURE',
      description: 'Lean mass compared to joint size indicates extreme tissue density.',
      requirement: 'LEAN MASS / (WRIST+ANKLE) > 2.0',
      icon: Icons.settings_brightness,
      color: Colors.purple,
      isUnlocked: (logs, data) {
        double w = _val(data['weight']);
        double bf = _val(data['bf']);
        double wrist = _val(data['wrist']);
        double ankle = _val(data['ankle']);
        if (wrist <= 0 || ankle <= 0) return false;
        double lean = w * (1 - (bf / 100));
        return (lean / (wrist + ankle)) >= 2.0;
      },
    ),
    Relic(
      id: 'one_plate_club',
      title: 'ONE-PLATE CLUB',
      description: 'First major milestone in horizontal pressing.',
      requirement: 'BENCH PRESS 60KG',
      icon: Icons.looks_one,
      color: Colors.grey,
      isUnlocked: (logs, data) {
        for (var l in logs) {
          if (l.exerciseName.toLowerCase().contains("bench")) {
          for (var s in l.performedSets) {
            if (s.weight >= 60) return true;
          }
        }
        }
        return false;
      },
    ),
    Relic(
      id: 'two_plate_club',
      title: 'TWO-PLATE CLUB',
      description: 'Advanced structural output recorded.',
      requirement: 'BENCH PRESS 100KG',
      icon: Icons.looks_two,
      color: Colors.blueAccent,
      isUnlocked: (logs, data) {
        for (var l in logs) {
          if (l.exerciseName.toLowerCase().contains("bench")) {
          for (var s in l.performedSets) {
            if (s.weight >= 100) return true;
          }
        }
        }
        return false;
      },
    ),
    Relic(
      id: 'three_plate_club',
      title: 'THREE-PLATE CLUB',
      description: 'Mastery of the barbell. System is elite.',
      requirement: 'BENCH PRESS 140KG',
      icon: Icons.looks_3,
      color: Colors.orangeAccent,
      isUnlocked: (logs, data) {
        for (var l in logs) {
          if (l.exerciseName.toLowerCase().contains("bench")) {
          for (var s in l.performedSets) {
            if (s.weight >= 140) return true;
          }
        }
        }
        return false;
      },
    ),
    Relic(
      id: 'single_limb_master',
      title: 'UNILATERAL SYNC',
      description: 'No significant deviation between left and right limb output.',
      requirement: 'L/R STRENGTH DEVIATION < 5%',
      icon: Icons.sync_alt,
      color: Colors.cyan,
      isUnlocked: (logs, data) => logs.length > 5,
    ),
    Relic(
      id: 'immortal_status',
      title: 'THE IMMORTAL',
      description: 'Biological degradation has been halted. Final synchronization achieved.',
      requirement: 'LOG 1,000 WORKOUTS + MASTER PERFECTION',
      icon: Icons.all_inclusive,
      color: Colors.red,
      isUnlocked: (logs, data) => logs.length >= 1000 && checkPerfection(data),
    ),
  ];
}

class CustomRelic extends Relic {
  final String targetExercise;
  final double targetWeight;

  CustomRelic({
    required super.id,
    required super.title,
    required super.description,
    required super.requirement,
    required super.icon,
    required super.color,
    required this.targetExercise,
    required this.targetWeight,
  }) : super(
    isUnlocked: (logs, data) {
      for (var l in logs) {
        if (l.exerciseName.toLowerCase() == targetExercise.toLowerCase()) {
          for (var s in l.performedSets) {
            if (s.weight >= targetWeight) return true;
          }
        }
      }
      return false;
    },
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'description': description,
    'requirement': requirement, 'icon': icon.codePoint,
    'color': color.value, 'targetEx': targetExercise, 'targetW': targetWeight,
  };

  factory CustomRelic.fromJson(Map<String, dynamic> json) => CustomRelic(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    requirement: json['requirement'],
    icon: Icons.workspace_premium,
    color: Color(json['color']),
    targetExercise: json['targetEx'],
    targetWeight: (json['targetW'] as num).toDouble(),
  );
}