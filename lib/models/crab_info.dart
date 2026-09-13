class CrabInfo {
  final String common;
  final String scientific;
  final String local;
  final String description;
  final String habitat;
  final String characteristics;
  final String edibility;
  final String risk;
  final String handling;
  final String firstAid;
  final String? seasonality;

  const CrabInfo({
    required this.common,
    required this.scientific,
    required this.local,
    required this.description,
    required this.habitat,
    required this.characteristics,
    required this.edibility,
    required this.risk,
    required this.handling,
    required this.firstAid,
    this.seasonality,
  });
}