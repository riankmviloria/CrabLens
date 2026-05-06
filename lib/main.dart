import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math'; 
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- FIGMA COLOR PALETTE ---
const Color kPrimaryRed = Color(0xFFD32F2F);
const Color kDarkText = Color(0xFF212121);
const Color kAccentBlue = Color(0xFF607D8B);
const Color kBgGray = Color(0xFFF5F5F5);

// --- 1. SPECIES DATABASE ---
final Map<String, Map<String, String>> crabDatabase = {
    "Platypodia granulosa": {
    "common": "Xanthid Crab",
    "scientific": "Platypodia granulosa",
    "local": "Spotted Pebble crab",
    "description": "A small, fan-shaped crab with a shell covered in tiny, sand-like bumps (granules). Usually reddish-brown or orange.",
    "habitat": "Shallow coral reefs and rocky crevices.",
    "characteristics": "Features 'crested' legs with very thin, blade-like edges. Part of the toxic Xanthidae family.",
    "edibility": "DEADLY POISONOUS - DO NOT EAT",
    "risk": "EXTREME NEUROTOXICITY (Contains Saxitoxin).",
    "handling": "DO NOT TOUCH. Toxins are heat-stable and cannot be neutralized by cooking or boiling.",
    "firstAid": "INGESTION EMERGENCY: Rush to the hospital immediately for respiratory support.",
  },
  "Atergatis floridus": {
    "common": "Floral Egg Crab",
    "scientific": "Atergatis floridus",
    "local": "Liod / Kaligmata",
    "description": "Smooth, oval-shaped carapace, typically greenish-brown with a beautiful lace-like or 'floral' white pattern.",
    "habitat": "Shallow coral reefs and rocky shorelines throughout the Philippines.",
    "characteristics": "The shell is very smooth to the touch, resembling an egg. It is slow-moving and often found hiding under rocks.",
    "edibility": "DEADLY POISONOUS - DO NOT EAT",
    "risk": "EXTREME NEUROTOXICITY (Tetrodotoxin & Saxitoxin)",
    "handling": "DO NOT TOUCH. Toxins are present in the flesh and skin mucus.",
    "firstAid": "INGESTION EMERGENCY. Rush to the hospital for life support (ventilator). No known antidote exists.",
    "seasonality": "Year-round in reef environments."
  },
  "Zosimus aeneus": {
    "common": "Toxic Reef Crab",
    "local": "Devil crab / Killer crab",
    "scientific": "Zosimus aeneus",
    "description": "A brownish crab covered in prominent chocolate-brown or reddish-brown blotches separated by pale lines. Its shell is bumpy and 'lumpy' in texture.",
    "habitat": "Found in shallow coral reefs and rocky crevices across the Indo-Pacific and the Philippines.",
    "characteristics": "Distinctive 'lumpy' carapace. Unlike edible crabs, it is slow-moving and does not hide as aggressively.",
    "edibility": "DEADLY POISONOUS (Never Ingest)",
    "risk": "EXTREME - Contains high concentrations of neurotoxins (Saxitoxin and Tetrodotoxin).",
    "handling": "DO NOT TOUCH. Toxins can be absorbed through skin breaks or mucus membranes.",
    "firstAid": "INGESTION IS A MEDICAL EMERGENCY. Induce vomiting and RUSH to a hospital for mechanical ventilation. There is no antidote.",
    "seasonality": "Year-round in reef environments."
  },
  "Scylla serrata": {
    "common": "Giant Mud Crab",
    "local": "Alimango",
    "description": "Large, dark green to black crab with massive, powerful claws.",
    "habitat": "Mangrove swamps and estuaries.",
    "characteristics": "9 sharp teeth on each side of the shell.",
    "edibility": "Highly Edible (Premium Delicacy)",
    "risk": "Low Toxicity / High Physical Risk (Pinching)",
    "handling": "Extremely dangerous claws. Use tongs.",
    "firstAid": "Clean with antiseptic, apply pressure.",
  },
  "Portunus pelagicus": {
    "common": "Blue Swimming Crab",
    "local": "Alimasag",
    "description": "Mottled blue (males) or sandy brown (females) with white spots.",
    "habitat": "Shallow sandy coastal waters.",
    "characteristics": "Back legs are paddles for swimming.",
    "edibility": "Highly Edible (Sweet meat)",
    "risk": "Non-toxic",
    "handling": "Fast and aggressive.",
    "firstAid": "Standard antiseptic care.",
  },
    "Lophozozymus pictor": {
    "common": "Mosaic Reef Crab",
    "local": "Calintugas",
    "description": "A strikingly beautiful crab with a red and white 'mosaic' pattern.",
    "habitat": "Coral reefs and rocky shores; Indo-Pacific/Philippines.",
    "characteristics": "Smooth, fan-shaped carapace with distinct red/orange patches.",
    "edibility": "DEADLY POISONOUS (Never Ingest)",
    "risk": "EXTREME - Contains heat-resistant neurotoxins.",
    "handling": "DO NOT TOUCH. Do not cook or eat.",
    "firstAid": "If ingested: RUSH to the hospital immediately.",
    "seasonality": "Year-round in reef environments."
  },
};

// --- DAILY FACTS LIST ---
final List<String> crabFacts = [
  "Toxic crabs like the 'Floral Egg Crab' contain heat-stable toxins. Boiling them does NOT make them safe to eat.",
  "The Alimango (Mud Crab) can survive out of water for days if its gills stay moist.",
  "Xanthid crabs are often called 'rubble crabs' because they hide in coral debris.",
  "The toxins in some reef crabs are the same as those found in Pufferfish (Tetrodotoxin).",
  "Blue Swimming Crabs (Alimasag) use their rear paddle-like legs to swim sideways very quickly.",
  "The 'Devil Crab' (Zosimus aeneus) is so toxic that even the water it is boiled in can become lethal.",
  "Crabs have a 'decapod' structure, meaning they have 10 legs, including their claws.",
  "The shell of a crab is actually an external skeleton called an exoskeleton."
];

void main() => runApp(const CrabLensApp());

class CrabLensApp extends StatelessWidget {
  const CrabLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CrabLens AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: kPrimaryRed,
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryRed),
        useMaterial3: true,
        scaffoldBackgroundColor: kBgGray,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/icon/app_icon.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100, color: kPrimaryRed),
              ),
            ),
            const SizedBox(height: 20),
            const Text('CrabLens', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: kDarkText, letterSpacing: 1.2)),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: kPrimaryRed),
          ],
        ),
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  final GlobalKey<HistoryScreenState> _historyKey = GlobalKey<HistoryScreenState>();
  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CrabLens', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: kPrimaryRed,
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(key: _homeKey), 
          HistoryScreen(key: _historyKey)
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: kPrimaryRed,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) _historyKey.currentState?.loadHistory();
          if (index == 0) _homeKey.currentState?.loadRecentScans();
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final String _apiKey = "USE_YOUR_GOOGLE_VISION_API_KEY";
  late String _currentFact;
  List<String> _recentImages = [];

  @override
  void initState() {
    super.initState();
    _currentFact = crabFacts[Random().nextInt(crabFacts.length)];
    loadRecentScans();
  }

  Future<void> loadRecentScans() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyStrings = prefs.getStringList('scan_history') ?? [];
    setState(() {
      _recentImages = historyStrings
          .map((item) => jsonDecode(item)['imagePath'] as String)
          .toList()
          .reversed.take(4).toList();
    });
  }

  Future<void> _saveToHistory(String path, String species, bool isToxic) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList('scan_history') ?? [];
    history.add(jsonEncode({
      'species': species,
      'imagePath': path,
      'isToxic': isToxic,
      'date': "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
    }));
    await prefs.setStringList('scan_history', history);
    loadRecentScans();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Good Day!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kDarkText)),
          const Text('Identify crab species and check safety.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(color: kAccentBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: kAccentBlue.withOpacity(0.3))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [Icon(Icons.lightbulb, color: Colors.orange, size: 24), SizedBox(width: 8), Text("Did you know?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kAccentBlue))]),
              const SizedBox(height: 8),
              Text(_currentFact, style: const TextStyle(fontSize: 14, color: kDarkText)),
            ]),
          ),
          const SizedBox(height: 25),
          Row(children: [
            Expanded(child: _actionCard(context, "Capture", Icons.camera_alt, ImageSource.camera)),
            const SizedBox(width: 15),
            Expanded(child: _actionCard(context, "Upload", Icons.cloud_upload, ImageSource.gallery)),
          ]),
          const SizedBox(height: 30),
          const Text('Recent Scans', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          _recentImages.isEmpty 
          ? const Center(child: Text("No recent scans.", style: TextStyle(color: Colors.grey)))
          : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
              itemCount: _recentImages.length,
              itemBuilder: (context, index) => Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 2)]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(_recentImages[index]), fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.broken_image, color: Colors.grey)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _actionCard(BuildContext context, String title, IconData icon, ImageSource source) {
    return InkWell(
      onTap: () => _handleImage(context, source),
      child: Container(
        height: 100,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 4)]),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: kPrimaryRed, size: 32), const SizedBox(height: 5), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: kDarkText))]),
      ),
    );
  }

// --- IMAGE HANDLING & IDENTIFICATION LOGIC ---
Future<void> _handleImage(BuildContext context, ImageSource source) async {
  final picker = ImagePicker();
  final image = await picker.pickImage(source: source, maxWidth: 800);
  if (image == null) return;

  showDialog(
    context: context,
    builder: (_) => const Center(
      child: CircularProgressIndicator(color: kPrimaryRed),
    ),
  );

  try {
    final bytes = await File(image.path).readAsBytes();

    final body = jsonEncode({
      "requests": [
        {
          "image": {"content": base64Encode(bytes)},
          "features": [
            {"type": "WEB_DETECTION"},
            {"type": "LABEL_DETECTION"}
          ]
        }
      ]
    });

    final response = await http.post(
      Uri.parse('https://vision.googleapis.com/v1/images:annotate?key=$_apiKey'),
      body: body,
    );

    if (context.mounted) Navigator.pop(context);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // 🔍 DEBUG LOG
      String prettyJson = const JsonEncoder.withIndent('  ').convert(data);
      debugPrint("========== FULL VISION API LOG ==========");
      debugPrint(prettyJson);
      debugPrint("=========================================");

      final responses = data['responses'][0];

      // ✅ FIXED KEYS
      List labels = responses['labelAnnotations'] ?? [];
      List entities = responses['webDetection']?['webEntities'] ?? [];

      // 🔥 COMBINE ALL TEXT
      List<String> allTexts = [];

      for (var l in labels) {
        allTexts.add((l['description'] ?? "").toLowerCase());
      }

      for (var e in entities) {
        allTexts.add((e['description'] ?? "").toLowerCase());
      }

      debugPrint("ALL TEXTS: $allTexts");

      // 🔥 SCORING SYSTEM
      int mudScore = 0;
      int blueScore = 0;
      int toxicScore = 0;

      for (var text in allTexts) {

        // --- TOXIC ---
        if (text.contains("floridus") || text.contains("atergatis")) toxicScore += 5;
        if (text.contains("zosimus") || text.contains("aeneus")) toxicScore += 5;
        if (text.contains("granulosa") || text.contains("platypodia")) toxicScore += 5;
        if (text.contains("xanthid") || text.contains("reef crab")) toxicScore += 3;

        // --- ALIMANGO (Mud Crab) ---
        if (text.contains("mud")) mudScore += 2;
        if (text.contains("mangrove")) mudScore += 2;
        if (text.contains("scylla")) mudScore += 3;
        if (text.contains("dungeness")) mudScore += 1;

        // --- ALIMASAG (Blue Crab) ---
        if (text.contains("blue")) blueScore += 2;
        if (text.contains("swimming")) blueScore += 2;
        if (text.contains("portunus")) blueScore += 3;
        if (text.contains("pelagicus")) blueScore += 3;
      }

      debugPrint("Scores => Mud:$mudScore Blue:$blueScore Toxic:$toxicScore");

      String detectedSpecies = "Unknown Crab";
      String confidence = "N/A";

      String combinedText = allTexts.join(" ");

      // 🔥 FINAL DECISION

      if (toxicScore >= 5) {
        if (combinedText.contains("floridus") || combinedText.contains("floral egg")) {
          detectedSpecies = "Atergatis floridus";
        } else if (combinedText.contains("zosimus")) {
          detectedSpecies = "Zosimus aeneus";
        } else {
          detectedSpecies = "Platypodia granulosa";
        }
        confidence = "High (Toxic Match)";
      }
      else if (mudScore > blueScore && mudScore >= 2) {
        detectedSpecies = "Scylla serrata";
        confidence = "High (Mud Crab)";
      }
      else if (blueScore >= 2) {
        detectedSpecies = "Portunus pelagicus";
        confidence = "High (Blue Crab)";
      }
      else if (entities.isNotEmpty) {
        detectedSpecies = entities[0]['description'] ?? "Unknown";
        double rawScore = entities[0]['score'] ?? 0.0;
        confidence = "${(rawScore * 100).toStringAsFixed(1)}%";
      }

      // 👉 SHOW RESULT (your existing UI)
      _showResult(context, image.path, detectedSpecies, confidence);
    }
  } catch (e) {
    if (context.mounted) Navigator.pop(context);
    debugPrint("ERROR: $e");
  }
}
void _showResult(BuildContext context, String path, String species, String confidence) {
  String correctedName = species;
  String lowerSpecies = species.toLowerCase();
  bool isDeadly = false;
  bool isEdible = false;

  // --- RE-MAPPING & SAFETY CHECK ---
  if (lowerSpecies.contains("scylla") || lowerSpecies.contains("mud crab") || lowerSpecies.contains("alimango")) {
    correctedName = "Scylla serrata";
    isDeadly = false;
    isEdible = true;
  } else if (lowerSpecies.contains("portunus") || lowerSpecies.contains("blue swimming") || lowerSpecies.contains("alimasag")) {
    correctedName = "Portunus pelagicus";
    isDeadly = false;
    isEdible = true;
  } else if (lowerSpecies.contains("zosimus") || lowerSpecies.contains("aeneus")) {
    correctedName = "Zosimus aeneus";
    isDeadly = true;
  } else if (lowerSpecies.contains("floridus") || lowerSpecies.contains("atergatis")) {
    correctedName = "Atergatis floridus";
    isDeadly = true;
  } else if (lowerSpecies.contains("granulosa") || lowerSpecies.contains("platypodia")) {
    correctedName = "Platypodia granulosa";
    isDeadly = true;
  } else if (lowerSpecies.contains("pictor") || lowerSpecies.contains("mosaic")) {
    correctedName = "Lophozozymus pictor";
    isDeadly = true;
  }

  // --- DATABASE & BUTTON VISIBILITY ---
  final bool isInDatabase = crabDatabase.containsKey(correctedName);
  final entry = crabDatabase[correctedName] ?? {};
  
  // If not in DB, override the display names to "Unknown"
  String localDisplayName = isInDatabase ? (entry['local'] ?? correctedName) : "Unknown Species";
  String scientificDisplayName = isInDatabase ? correctedName : "Unrecognized by System";

  _saveToHistory(path, correctedName, isDeadly);

  if (isDeadly) {
    HapticFeedback.vibrate();
    Future.delayed(const Duration(milliseconds: 400), () => HapticFeedback.vibrate());
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      // Green background for edible, Red for toxic, White/Grey for Unknown
      backgroundColor: isDeadly ? Colors.red.shade900 : (isEdible ? Colors.green.shade50 : Colors.grey.shade100),
      title: Text(
        isDeadly ? "⚠️ TOXIC SPECIES" : (isEdible ? "✅ EDIBLE SPECIES" : "Scan Result"),
        style: TextStyle(color: isDeadly ? Colors.white : Colors.black),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // BIG DISPLAY NAME
          Text(
            localDisplayName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: isDeadly ? Colors.yellow : (isEdible ? Colors.green.shade800 : Colors.black54),
            ),
          ),
          const SizedBox(height: 5),
          // SCIENTIFIC NAME (Only shown if recognized)
          Text(
            scientificDisplayName,
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: isDeadly ? Colors.white70 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 15),
          if (isDeadly)
            const Text(
              "POISONOUS: DO NOT CONSUME",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            )
          else if (isEdible)
            const Text(
              "SAFE TO EAT",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            )
          else
            const Text(
              "Species not in database.\nConsult an expert before consuming.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black87, fontStyle: FontStyle.italic),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Close", style: TextStyle(color: isDeadly ? Colors.white70 : Colors.grey)),
        ),
        // ONLY show "View Full Specs" if the species is recognized in your database
        if (isInDatabase) 
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDeadly ? Colors.yellow : (isEdible ? Colors.green : kPrimaryRed),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => CrabDetailScreen(
                  speciesName: correctedName,
                  imagePath: path,
                  confidence: confidence,
                ),
              ));
            },
            child: Text(
              "View Full Specs",
              style: TextStyle(color: isDeadly ? Colors.black : Colors.white),
            ),
          ),
      ],
    ),
  );
}}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  HistoryScreenState createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() { super.initState(); loadHistory(); }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyStrings = prefs.getStringList('scan_history') ?? [];
    setState(() { _history = historyStrings.map((item) => jsonDecode(item) as Map<String, dynamic>).toList().reversed.toList(); });
  }

  @override
  Widget build(BuildContext context) {
    return _history.isEmpty ? const Center(child: Text("No history yet.")) : ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        return Card(
          child: ListTile(
            leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(item['imagePath']), width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_,__,___)=>const Icon(Icons.image))),
            title: Text(item['species'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(item['date']),
            trailing: Icon(item['isToxic'] ? Icons.warning : Icons.check_circle, color: item['isToxic'] ? Colors.red : Colors.green),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CrabDetailScreen(speciesName: item['species'], imagePath: item['imagePath'], confidence: "From History"))),
          ),
        );
      },
    );
  }
}

class CrabDetailScreen extends StatelessWidget {
  final String speciesName, imagePath, confidence;
  const CrabDetailScreen({super.key, required this.speciesName, required this.imagePath, required this.confidence});

  @override
  Widget build(BuildContext context) {
    final entry = crabDatabase.entries.firstWhere(
      (e) => e.key == speciesName || speciesName.toLowerCase().contains(e.key.toLowerCase()),
      orElse: () => MapEntry(speciesName, {
        "common": speciesName,
        "description": "Information not available in offline database.",
        "habitat": "Unknown",
        "characteristics": "Unknown",
        "risk": "Unknown",
        "handling": "Use caution.",
        "firstAid": "Consult medical professionals."
      }),
    );

    final info = entry.value;
    bool isToxic = info['edibility']?.contains("DEADLY") ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Species Details"), backgroundColor: Colors.white, foregroundColor: kDarkText, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.file(File(imagePath), width: double.infinity, height: 220, fit: BoxFit.cover)),
            const SizedBox(height: 25),
            Text(entry.key, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: kPrimaryRed)),
            const SizedBox(height: 8),
            _idBadge("Common", info['common'] ?? "Unknown"),
            _idBadge("Local", info['local'] ?? "Not specified"),
            const SizedBox(height: 10),
            Text("AI Confidence: $confidence", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            const Divider(height: 40),
            _infoBlock(Icons.description, "Description", info['description']!),
            _infoBlock(Icons.map, "Habitat", info['habitat'] ?? "Unknown"),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isToxic ? Colors.red.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isToxic ? kPrimaryRed : Colors.green),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("🚨 SAFETY & HANDLING", style: TextStyle(fontWeight: FontWeight.bold, color: isToxic ? kPrimaryRed : Colors.green.shade800)),
                  const SizedBox(height: 8),
                  Text("Risk: ${info['risk'] ?? 'Unknown'}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("Handling: ${info['handling'] ?? 'Caution'}"),
                  Text("First Aid: ${info['firstAid'] ?? 'Consult medical professionals'}"),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _idBadge(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Text("$label: ", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _infoBlock(IconData icon, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, color: kPrimaryRed, size: 20), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))]),
        const SizedBox(height: 5),
        Text(content, style: const TextStyle(fontSize: 15, color: Colors.black87)),
      ]),
    );
  }
}
