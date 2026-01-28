import 'package:flutter/material.dart';

enum BusGroup { beeNetwork, london }

typedef BusGroupRecord = ({List<String> operators, BusGroup t, String color});
final List<BusGroupRecord> busGroupMap = [
  (
    operators: ["BNVB", "BNSM", "BNML", "BNGN", "BNFM", "BNDB", "METL"],
    t: BusGroup.beeNetwork,
    color: "#FFE051",
  ),
  (
    operators: [
      "TFLO",
      "TRAM",
      "MGBA",
      "LVBH",
      "LUTD",
      "LULD",
      "LSOV",
      "LONC",
      "LGEN",
      "LDLR",
      "IFSC",
      "GAHL",
      "FLON",
      "ELBG",
      "CLKL",
      "BTRI",
      "AWAN",
      "AVLO",
      "ABLO",
    ],
    t: BusGroup.london,
    color: "#FF0000",
  ),
];

class ServiceNumber extends StatelessWidget {
  final String lineName;
  final String? operator;

  const ServiceNumber({super.key, required this.lineName, this.operator});

  @override
  Widget build(BuildContext context) {
    BusGroupRecord? record =
        operator == null
            ? null
            : busGroupMap
                .where((x) => x.operators.contains(operator))
                .firstOrNull;

    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color:
            record != null
                ? colorFromHex(record.color)
                : Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        lineName,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

Color colorFromHex(String hex) {
  hex = hex.replaceFirst('#', '');
  if (hex.length == 6) {
    hex = 'FF$hex';
  }
  return Color(int.parse(hex, radix: 16));
}
