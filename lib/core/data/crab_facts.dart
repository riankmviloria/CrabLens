class CrabFacts {
  static const List<String> facts = [
    'Crabs can walk sideways because of the way their legs and joints are structured.',
    'Some crab species can survive in both saltwater and brackish water environments.',
    'Mangrove forests provide important habitats and nursery grounds for many crab species.',
    'Crabs use their claws for feeding, defense, and interacting with their environment.',
    'Some swimming crabs use their flattened rear legs like paddles to move through the water.',
    'Mud crabs are commonly found in mangrove areas, estuaries, and coastal environments.',
    'Blue swimming crabs are an important seafood species in many coastal communities.',
    'Crabs regularly shed their hard outer shell as they grow. This process is called molting.',
    'A crab’s shell provides protection for its body and helps reduce the risk of injury.',
    'Different crab species can be identified by characteristics such as shell shape, color, claws, and leg structure.',
  ];

  static String getRandomFact() {
    final index = DateTime.now().millisecondsSinceEpoch % facts.length;
    return facts[index];
  }
}