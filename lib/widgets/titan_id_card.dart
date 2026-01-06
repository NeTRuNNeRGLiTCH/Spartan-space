import 'package:flutter/material.dart';

class TitanIdCard extends StatelessWidget {
  final Map<String, dynamic> bodyData;
  final String combatClass;
  final Color classColor;
  final double ffmi;
  final String chassis;
  final String rarity;

  const TitanIdCard({
    super.key,
    required this.bodyData,
    required this.combatClass,
    required this.classColor,
    required this.ffmi,
    required this.chassis,
    required this.rarity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      height: 300,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: classColor.withOpacity(0.5), width: 2),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(Icons.shield_outlined, size: 200, color: classColor.withOpacity(0.03)),
          ),

          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 120,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Icon(Icons.person, size: 80, color: classColor.withOpacity(0.5)),
                    ),
                    const SizedBox(height: 15),
                    Text("STATUS: VERIFIED",
                        style: TextStyle(color: classColor, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    const SizedBox(height: 5),
                    const Text("TITAN ASSET ID: 0x8821",
                        style: TextStyle(color: Colors.white24, fontSize: 6, fontWeight: FontWeight.bold)),
                  ],
                ),

                const SizedBox(width: 30),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(combatClass,
                          style: TextStyle(color: classColor, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
                      const Text("CLASS ASSIGNMENT",
                          style: TextStyle(color: Colors.white24, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 3)),

                      const SizedBox(height: 20),

                      _rowStat("SYSTEM FFMI", ffmi.toStringAsFixed(1)),
                      _rowStat("CHASSIS TIER", chassis),
                      _rowStat("SYSTEM RARITY", "$rarity%"),
                      _rowStat("SYNC STATUS", "OPTIMIZED"),

                      const Spacer(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("DATA ARCHIVE: TITAN_LOG_V2", style: TextStyle(color: Colors.white10, fontSize: 6, fontWeight: FontWeight.bold)),
                              Text("ENCRYPTED VIA RSA-4096", style: TextStyle(color: Colors.white10, fontSize: 6, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Icon(Icons.qr_code_2, color: classColor.withOpacity(0.3), size: 40),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}