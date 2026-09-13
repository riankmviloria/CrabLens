import '../../models/crab_info.dart';

class CrabDatabase {
  static const Map<String, CrabInfo> crabs = {
    // ============================================================
    // SAFE / COMMERCIAL CRABS
    // ============================================================

    'Scylla serrata': CrabInfo(
      common: 'Alimango',
      scientific: 'Scylla serrata',
      local: 'Alimango, Ayama',
      description:
          'A large mud crab commonly found in mangrove areas and estuaries.',
      habitat: 'Mangroves, estuaries, and muddy coastal areas.',
      characteristics: 'Dark green shell with large, powerful claws.',
      edibility: 'SAFE / COMMERCIAL',
      risk: 'Low toxicity / physical risk from claws.',
      handling: 'Handle the claws carefully.',
      firstAid:
          'For injuries, clean the wound and seek medical attention if necessary.',
    ),

    'Scylla olivacea': CrabInfo(
      common: 'Orange Mud Crab',
      scientific: 'Scylla olivacea',
      local: 'Alimango (Pulahan), Ayama',
      description:
          'A mud crab with a brown-orange shell commonly associated with mangrove environments.',
      habitat: 'Mangroves and estuarine environments.',
      characteristics: 'Brown-orange shell and large claws.',
      edibility: 'SAFE / COMMERCIAL',
      risk: 'Physical risk from claws.',
      handling: 'Handle the claws carefully.',
      firstAid:
          'For injuries, clean the wound and seek medical attention if necessary.',
    ),

    'Scylla tranquebarica': CrabInfo(
      common: 'Purple Mud Crab',
      scientific: 'Scylla tranquebarica',
      local: 'Alimango (in Nipa palm), Ayama',
      description:
          'A large mud crab with dark purple to green coloration and powerful claws.',
      habitat: 'Mangroves and nipa-associated coastal environments.',
      characteristics: 'Dark purple or green coloration with large claws.',
      edibility: 'SAFE / COMMERCIAL',
      risk: 'Physical risk from claws.',
      handling: 'Handle the claws carefully.',
      firstAid:
          'For injuries, clean the wound and seek medical attention if necessary.',
    ),

    'Portunus pelagicus': CrabInfo(
      common: 'Alimasag',
      scientific: 'Portunus pelagicus',
      local: 'Alimasag',
      description:
          'A swimming crab with blue coloration and paddle-like rear legs.',
      habitat: 'Shallow sandy coastal waters.',
      characteristics:
          'Blue legs and paddle-like rear legs used for swimming.',
      edibility: 'SAFE / COMMERCIAL',
      risk: 'Non-toxic / physical risk from claws.',
      handling: 'Handle carefully because the claws can cause injury.',
      firstAid:
          'For injuries, clean the wound and seek medical attention if necessary.',
    ),

    'Portunus sanguinolentus': CrabInfo(
      common: 'Three-Spot Crab',
      scientific: 'Portunus sanguinolentus',
      local: 'Alimasag (3 balls), Three-Spotted Crab',
      description:
          'A swimming crab distinguished by three prominent reddish spots on its shell.',
      habitat: 'Coastal marine waters.',
      characteristics: 'Three distinctive red spots on the shell.',
      edibility: 'SAFE / COMMERCIAL',
      risk: 'Physical risk from claws.',
      handling: 'Handle carefully because of the claws.',
      firstAid:
          'For injuries, clean the wound and seek medical attention if necessary.',
    ),

    'Ranina ranina': CrabInfo(
      common: 'Spanner Crab',
      scientific: 'Ranina ranina',
      local: 'Curacha',
      description:
          'A distinctive red crab with a body shape resembling a frog.',
      habitat: 'Sandy marine environments.',
      characteristics: 'Red coloration and frog-like body shape.',
      edibility: 'SAFE / COMMERCIAL',
      risk: 'Physical handling risk.',
      handling: 'Handle carefully.',
      firstAid:
          'For injuries, clean the wound and seek medical attention if necessary.',
    ),

    'Charybdis feriata': CrabInfo(
      common: 'Crucifix Crab',
      scientific: 'Charybdis feriata',
      local: 'Not specified',
      description:
          'A swimming crab recognized by a distinctive cross-like marking on its shell.',
      habitat: 'Coastal marine environments.',
      characteristics:
          'Distinctive crucifix or cross marking on the shell.',
      edibility: 'SAFE / COMMERCIAL',
      risk: 'Physical risk from claws.',
      handling: 'Handle carefully.',
      firstAid:
          'For injuries, clean the wound and seek medical attention if necessary.',
    ),

    'Thalamita crenata': CrabInfo(
      common: 'Mangrove Crab',
      scientific: 'Thalamita crenata',
      local: 'Banhaway',
      description:
          'A small greenish crab associated with mangrove environments.',
      habitat: 'Mangroves and shallow coastal areas.',
      characteristics:
          'Small greenish crab commonly found around mangroves.',
      edibility: 'SAFE / COMMERCIAL',
      risk: 'Physical handling risk.',
      handling: 'Handle carefully.',
      firstAid:
          'For injuries, clean the wound and seek medical attention if necessary.',
    ),

    // ============================================================
    // DANGEROUS / POISONOUS CRABS
    // ============================================================

    'Lophozozymus pictor': CrabInfo(
      common: 'Mosaic Crab',
      scientific: 'Lophozozymus pictor',
      local: 'Calintugas',
      description:
          'A strikingly patterned reef crab with a red and white mosaic-like shell.',
      habitat:
          'Coral reefs and rocky shores in the Indo-Pacific and Philippines.',
      characteristics: 'Bright mosaic shell pattern.',
      edibility: 'DANGEROUS / POISONOUS',
      risk: 'Highly toxic.',
      handling: 'Avoid handling and do not consume.',
      firstAid:
          'If poisoning is suspected, seek emergency medical attention immediately.',
      seasonality: 'Year-round in reef environments.',
    ),

    'Atergatis floridus': CrabInfo(
      common: 'Floral Egg Crab',
      scientific: 'Atergatis floridus',
      local: 'Liod / Kaligmata',
      description:
          'A smooth, oval-shaped reef crab with a distinctive floral-like pattern.',
      habitat: 'Shallow coral reefs and rocky shorelines.',
      characteristics:
          'Smooth shell with a characteristic floral-like pattern.',
      edibility: 'DANGEROUS / POISONOUS',
      risk: 'Neurotoxic.',
      handling: 'Avoid handling and do not consume.',
      firstAid:
          'If poisoning is suspected, seek emergency medical attention immediately.',
      seasonality: 'Year-round in reef environments.',
    ),

    'Zosimus aeneus': CrabInfo(
      common: 'Devil Crab',
      scientific: 'Zosimus aeneus',
      local: 'Devil Crab / Killer Crab',
      description:
          'A reef crab with a distinctive lumpy shell and brownish blotches.',
      habitat: 'Shallow coral reefs and rocky crevices.',
      characteristics:
          'Lumpy carapace with prominent brownish markings.',
      edibility: 'DANGEROUS / POISONOUS',
      risk: 'Contains paralytic neurotoxins.',
      handling: 'Avoid handling and do not consume.',
      firstAid:
          'If poisoning is suspected, seek emergency medical attention immediately.',
      seasonality: 'Year-round in reef environments.',
    ),

    'Platypodia granulosa': CrabInfo(
      common: 'Xanthid Crab',
      scientific: 'Platypodia granulosa',
      local: 'Reef Crab / Spotted Pebble Crab',
      description:
          'A small reef crab with a shell covered in small granular bumps.',
      habitat: 'Shallow coral reefs and rocky crevices.',
      characteristics:
          'Granular shell texture and reddish-brown to orange coloration.',
      edibility: 'DANGEROUS / POISONOUS',
      risk: 'Poisonous.',
      handling: 'Avoid handling and do not consume.',
      firstAid:
          'If poisoning is suspected, seek emergency medical attention immediately.',
    ),

    'Carpilius maculatus': CrabInfo(
      common: 'Seven Eleven Crab',
      scientific: 'Carpilius maculatus',
      local: 'Spotted Pebble Crab',
      description:
          'A reef crab characterized by prominent spots on its shell.',
      habitat: 'Rocky shores and reef environments.',
      characteristics: 'Distinctive spotted shell.',
      edibility: 'DANGEROUS / POTENTIALLY TOXIC',
      risk: 'Potentially toxic.',
      handling: 'Avoid consuming unless positively identified as safe.',
      firstAid:
          'If poisoning is suspected, seek emergency medical attention immediately.',
    ),
  };

  static CrabInfo? getCrab(String scientificName) {
    return crabs[scientificName];
  }

  static List<CrabInfo> getAllCrabs() {
    return crabs.values.toList();
  }
}