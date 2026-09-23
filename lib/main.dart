import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

const int totalMonths = 9;
const int daysPerMonth = 30;

void main() {
  runApp(const TaalimApp());
}

/// ---------------------------------------------------------------
/// DATA MODELS
/// ---------------------------------------------------------------
class BiText {
  final String fr;
  final String ar;
  const BiText({required this.fr, required this.ar});
  factory BiText.fromJson(Map<String, dynamic> j) => BiText(fr: j['fr'] ?? '', ar: j['ar'] ?? '');
}

class MatchPair {
  final String left;
  final String right;
  const MatchPair({required this.left, required this.right});
  factory MatchPair.fromJson(Map<String, dynamic> j) => MatchPair(left: j['left'] ?? '', right: j['right'] ?? '');
}

class Exercise {
  final String type; // 'qcm', 'match', 'match_lang'
  final String? qFr;
  final String? qAr;
  final List<BiText>? options;
  final int? answer;
  final String? instructionFr;
  final String? instructionAr;
  final List<MatchPair>? pairs; // for 'match'
  final List<BiText>? langPairs; // for 'match_lang' (fr <-> ar)

  Exercise({
    required this.type,
    this.qFr,
    this.qAr,
    this.options,
    this.answer,
    this.instructionFr,
    this.instructionAr,
    this.pairs,
    this.langPairs,
  });

  factory Exercise.fromJson(Map<String, dynamic> j) {
    final type = j['type'] as String;
    if (type == 'qcm') {
      return Exercise(
        type: type,
        qFr: j['q_fr'],
        qAr: j['q_ar'],
        options: (j['options'] as List).map((o) => BiText.fromJson(o)).toList(),
        answer: j['answer'],
      );
    } else if (type == 'match') {
      return Exercise(
        type: type,
        instructionFr: j['instruction_fr'],
        instructionAr: j['instruction_ar'],
        pairs: (j['pairs'] as List).map((p) => MatchPair.fromJson(p)).toList(),
      );
    } else {
      // match_lang
      return Exercise(
        type: type,
        instructionFr: j['instruction_fr'],
        instructionAr: j['instruction_ar'],
        langPairs: (j['pairs'] as List).map((p) => BiText.fromJson(p)).toList(),
      );
    }
  }

  int get points {
    if (type == 'match') return pairs!.length;
    if (type == 'match_lang') return langPairs!.length;
    return 1;
  }
}

/// content[month][level][subject] = List<Exercise>
Map<int, Map<String, Map<String, List<Exercise>>>> allContent = {};

Future<void> loadAllContent() async {
  for (int m = 1; m <= totalMonths; m++) {
    try {
      final raw = await rootBundle.loadString('assets/content/month_$m.json');
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final Map<String, Map<String, List<Exercise>>> monthMap = {};
      for (final level in ['cp1', 'cp2']) {
        final Map<String, List<Exercise>> subjMap = {};
        for (final subject in ['lecture', 'calcul']) {
          final List<dynamic> list = data[level]?[subject] ?? [];
          subjMap[subject] = list.map((e) => Exercise.fromJson(e)).toList();
        }
        monthMap[level] = subjMap;
      }
      allContent[m] = monthMap;
    } catch (_) {
      allContent[m] = {
        'cp1': {'lecture': [], 'calcul': []},
        'cp2': {'lecture': [], 'calcul': []},
      };
    }
  }
}

/// ---------------------------------------------------------------
/// UNLOCK LOGIC
/// ---------------------------------------------------------------
Future<int> getUnlockedMonth() async {
  final prefs = await SharedPreferences.getInstance();
  String? startStr = prefs.getString('taalim_start_date');
  DateTime start;
  if (startStr == null) {
    start = DateTime.now();
    await prefs.setString('taalim_start_date', start.toIso8601String());
  } else {
    start = DateTime.parse(startStr);
  }
  final daysSince = DateTime.now().difference(start).inDays;
  final unlocked = (daysSince ~/ daysPerMonth) + 1;
  return unlocked.clamp(1, totalMonths);
}

Future<DateTime> getMonthUnlockDate(int month) async {
  final prefs = await SharedPreferences.getInstance();
  final startStr = prefs.getString('taalim_start_date');
  final start = startStr != null ? DateTime.parse(startStr) : DateTime.now();
  return start.add(Duration(days: (month - 1) * daysPerMonth));
}

/// ---------------------------------------------------------------
/// BILINGUAL UI STRINGS (static labels shown FR + AR together)
/// ---------------------------------------------------------------
class B {
  static const homeTitleFr = "Apprendre en s'amusant";
  static const homeTitleAr = "تعلّم وأنت تلعب";
  static const homeSubFr = "Choisis ton niveau";
  static const homeSubAr = "اختر مستواك";
  static const cp1Fr = "CP1";
  static const cp1Ar = "الأولى ابتدائي";
  static const cp1HintFr = "Première année";
  static const cp1HintAr = "السنة الأولى";
  static const cp2Fr = "CP2";
  static const cp2Ar = "الثانية ابتدائي";
  static const cp2HintFr = "Deuxième année";
  static const cp2HintAr = "السنة الثانية";
  static const chooseMonthFr = "Choisis un mois";
  static const chooseMonthAr = "اختر شهرًا";
  static const monthFr = "Mois";
  static const monthAr = "الشهر";
  static const lockedFr = "Se débloque le";
  static const lockedAr = "يُفتح في";
  static const chooseSubjectFr = "Choisis une matière";
  static const chooseSubjectAr = "اختر مادة";
  static const lectureFr = "Lecture";
  static const lectureAr = "القراءة";
  static const calculFr = "Calcul";
  static const calculAr = "الحساب";
  static const bestFr = "Meilleur score : ";
  static const bestAr = "أفضل نتيجة: ";
  static const noScoreFr = "Pas encore essayé";
  static const noScoreAr = "لم تجرب بعد";
  static const questionFr = "Question";
  static const questionAr = "سؤال";
  static const correctFr = "Bravo, bonne réponse !";
  static const correctAr = "أحسنت، إجابة صحيحة!";
  static const incorrectFr = "Pas tout à fait, réessaie !";
  static const incorrectAr = "ليست صحيحة، حاول مجددًا!";
  static const nextFr = "Continuer";
  static const nextAr = "متابعة";
  static const seeResultFr = "Voir mon résultat";
  static const seeResultAr = "شاهد نتيجتي";
  static const resultTitleFr = "Résultat";
  static const resultTitleAr = "النتيجة";
  static const homeFr = "Accueil";
  static const homeAr = "الرئيسية";
  static const retryFr = "Recommencer";
  static const retryAr = "إعادة المحاولة";
  static const noContentFr = "Contenu à venir bientôt !";
  static const noContentAr = "المحتوى قادم قريبًا!";

  static String resultText(int s, int t) => "Tu as obtenu $s sur $t !  •  لقد حصلت على $s من $t!";
}

/// Renders a French line and an Arabic line together, stacked.
class BiLabel extends StatelessWidget {
  final String fr;
  final String ar;
  final double frSize;
  final double arSize;
  final FontWeight weight;
  final Color color;
  final TextAlign align;

  const BiLabel({
    super.key,
    required this.fr,
    required this.ar,
    this.frSize = 16,
    this.arSize = 16,
    this.weight = FontWeight.w800,
    this.color = AppColors.ink,
    this.align = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align == TextAlign.center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(fr, textAlign: align, style: TextStyle(fontWeight: weight, fontSize: frSize, color: color)),
        const SizedBox(height: 2),
        Directionality(
          textDirection: TextDirection.rtl,
          child: Text(ar, textAlign: align, style: TextStyle(fontWeight: weight, fontSize: arSize, color: color.withValues(alpha: 0.8))),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------
/// BRAND COLORS
/// ---------------------------------------------------------------
class AppColors {
  static const bg = Color(0xFFEAF6FF);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF1B2A4A);
  static const inkSoft = Color(0xFF4C5E82);
  static const lecture = Color(0xFFFF9F1C);
  static const lectureSoft = Color(0xFFFFE7C2);
  static const calcul = Color(0xFF2EC4B6);
  static const calculSoft = Color(0xFFCFF3F0);
  static const cp1 = Color(0xFFE84855);
  static const cp2 = Color(0xFF7A5CFA);
  static const success = Color(0xFF2EC4B6);
  static const error = Color(0xFFE84855);
  static const locked = Color(0xFFB7C3DA);

  // Couleurs du drapeau tchadien
  static const chadBlue = Color(0xFF002664);
  static const chadYellow = Color(0xFFFECB00);
  static const chadRed = Color(0xFFC60C30);
  static const chadCycle = [chadBlue, chadYellow, chadRed];
  static const chadTextOn = [Colors.white, ink, Colors.white]; // texte lisible selon le fond
}

/// ---------------------------------------------------------------
/// ROOT APP
/// ---------------------------------------------------------------
class TaalimApp extends StatelessWidget {
  const TaalimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TAALIM_IA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.ink),
      ),
      home: const SplashLoader(),
    );
  }
}

class SplashLoader extends StatefulWidget {
  const SplashLoader({super.key});
  @override
  State<SplashLoader> createState() => _SplashLoaderState();
}

class _SplashLoaderState extends State<SplashLoader> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await loadAllContent();
    await getUnlockedMonth(); // ensures start date is recorded
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(child: CircularProgressIndicator(color: AppColors.ink)),
    );
  }
}

/// ---------------------------------------------------------------
/// TOP BAR (shared, bilingual brand)
/// ---------------------------------------------------------------
class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(14)),
          alignment: Alignment.center,
          child: const Text('📚', style: TextStyle(fontSize: 22)),
        ),
        const SizedBox(width: 10),
        const Text('TAALIM_IA', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: AppColors.ink)),
      ],
    );
  }
}

class BackBtn extends StatelessWidget {
  final VoidCallback onTap;
  const BackBtn({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: const SizedBox(width: 40, height: 40, child: Icon(Icons.chevron_left, color: AppColors.ink)),
      ),
    );
  }
}

/// ---------------------------------------------------------------
/// HOME SCREEN — pick level
/// ---------------------------------------------------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TopBar(),
              const SizedBox(height: 24),
              const BiLabel(fr: B.homeTitleFr, ar: B.homeTitleAr, frSize: 26, arSize: 22),
              const SizedBox(height: 6),
              const BiLabel(fr: B.homeSubFr, ar: B.homeSubAr, frSize: 15, arSize: 14, weight: FontWeight.w600, color: AppColors.inkSoft),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _LevelCard(
                      color: AppColors.cp1,
                      emoji: '🌱',
                      nameFr: B.cp1Fr,
                      nameAr: B.cp1Ar,
                      hintFr: B.cp1HintFr,
                      hintAr: B.cp1HintAr,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MonthScreen(level: 'cp1'))),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _LevelCard(
                      color: AppColors.cp2,
                      emoji: '🌟',
                      nameFr: B.cp2Fr,
                      nameAr: B.cp2Ar,
                      hintFr: B.cp2HintFr,
                      hintAr: B.cp2HintAr,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MonthScreen(level: 'cp2'))),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final Color color;
  final String emoji;
  final String nameFr, nameAr, hintFr, hintAr;
  final VoidCallback onTap;

  const _LevelCard({
    required this.color,
    required this.emoji,
    required this.nameFr,
    required this.nameAr,
    required this.hintFr,
    required this.hintAr,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 14),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 38)),
              const SizedBox(height: 10),
              BiLabel(fr: nameFr, ar: nameAr, frSize: 22, arSize: 18, color: Colors.white, align: TextAlign.center),
              const SizedBox(height: 4),
              BiLabel(fr: hintFr, ar: hintAr, frSize: 13, arSize: 12, weight: FontWeight.w600, color: Colors.white70, align: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------
/// MONTH SCREEN — pick month (locked/unlocked)
/// ---------------------------------------------------------------
class MonthScreen extends StatefulWidget {
  final String level;
  const MonthScreen({super.key, required this.level});

  @override
  State<MonthScreen> createState() => _MonthScreenState();
}

class _MonthScreenState extends State<MonthScreen> {
  int unlockedMonth = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final u = await getUnlockedMonth();
    setState(() => unlockedMonth = u);
  }

  @override
  Widget build(BuildContext context) {
    final levelName = widget.level == 'cp1' ? B.cp1Fr : B.cp2Fr;
    final levelNameAr = widget.level == 'cp1' ? B.cp1Ar : B.cp2Ar;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TopBar(),
              const SizedBox(height: 10),
              Row(
                children: [
                  BackBtn(onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 10),
                  BiLabel(fr: levelName, ar: levelNameAr, frSize: 18, arSize: 15),
                ],
              ),
              const SizedBox(height: 8),
              const BiLabel(fr: B.chooseMonthFr, ar: B.chooseMonthAr, frSize: 15, arSize: 14, weight: FontWeight.w600, color: AppColors.inkSoft),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  itemCount: totalMonths,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0,
                  ),
                  itemBuilder: (context, i) {
                    final month = i + 1;
                    final unlocked = month <= unlockedMonth;
                    return _MonthCard(
                      month: month,
                      unlocked: unlocked,
                      onTap: () async {
                        if (!unlocked) {
                          final date = await getMonthUnlockDate(month);
                          final dateStr = "${date.day}/${date.month}/${date.year}";
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${B.lockedFr} $dateStr  •  ${B.lockedAr} $dateStr')),
                            );
                          }
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SubjectScreen(level: widget.level, month: month)),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthCard extends StatelessWidget {
  final int month;
  final bool unlocked;
  final VoidCallback onTap;

  const _MonthCard({required this.month, required this.unlocked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: unlocked ? AppColors.surface : AppColors.locked.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: unlocked ? AppColors.ink.withValues(alpha: 0.08) : Colors.transparent, width: 2),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!unlocked) const Icon(Icons.lock, color: AppColors.locked, size: 22),
              if (unlocked) Text('$month', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 26, color: AppColors.ink)),
              const SizedBox(height: 4),
              Text(B.monthFr, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: unlocked ? AppColors.inkSoft : AppColors.locked)),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------
/// SUBJECT SCREEN
/// ---------------------------------------------------------------
class SubjectScreen extends StatefulWidget {
  final String level;
  final int month;
  const SubjectScreen({super.key, required this.level, required this.month});

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  String? bestLecture;
  String? bestCalcul;

  @override
  void initState() {
    super.initState();
    _loadBests();
  }

  Future<void> _loadBests() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bestLecture = prefs.getString('taalim_best_${widget.level}_m${widget.month}_lecture');
      bestCalcul = prefs.getString('taalim_best_${widget.level}_m${widget.month}_calcul');
    });
  }

  @override
  Widget build(BuildContext context) {
    final levelName = widget.level == 'cp1' ? B.cp1Fr : B.cp2Fr;
    final levelNameAr = widget.level == 'cp1' ? B.cp1Ar : B.cp2Ar;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TopBar(),
              const SizedBox(height: 10),
              Row(
                children: [
                  BackBtn(onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 10),
                  BiLabel(fr: '$levelName · ${B.monthFr} ${widget.month}', ar: '$levelNameAr · ${B.monthAr} ${widget.month}', frSize: 17, arSize: 14),
                ],
              ),
              const SizedBox(height: 8),
              const BiLabel(fr: B.chooseSubjectFr, ar: B.chooseSubjectAr, frSize: 15, arSize: 14, weight: FontWeight.w600, color: AppColors.inkSoft),
              const SizedBox(height: 16),
              _SubjectCard(
                color: AppColors.lectureSoft,
                emoji: '🔤',
                nameFr: B.lectureFr,
                nameAr: B.lectureAr,
                bestText: bestLecture != null ? '${B.bestFr}$bestLecture' : B.noScoreFr,
                onTap: () => _openGame(context, 'lecture'),
              ),
              const SizedBox(height: 16),
              _SubjectCard(
                color: AppColors.calculSoft,
                emoji: '🔢',
                nameFr: B.calculFr,
                nameAr: B.calculAr,
                bestText: bestCalcul != null ? '${B.bestFr}$bestCalcul' : B.noScoreFr,
                onTap: () => _openGame(context, 'calcul'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openGame(BuildContext context, String subject) {
    final exercises = allContent[widget.month]?[widget.level]?[subject] ?? [];
    if (exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('${B.noContentFr}  •  ${B.noContentAr}')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameScreen(level: widget.level, month: widget.month, subject: subject)),
    ).then((_) => _loadBests());
  }
}

class _SubjectCard extends StatelessWidget {
  final Color color;
  final String emoji;
  final String nameFr, nameAr, bestText;
  final VoidCallback onTap;

  const _SubjectCard({required this.color, required this.emoji, required this.nameFr, required this.nameAr, required this.bestText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(16)),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 34)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BiLabel(fr: nameFr, ar: nameAr, frSize: 19, arSize: 16),
                    const SizedBox(height: 2),
                    Text(bestText, style: const TextStyle(fontSize: 13, color: AppColors.inkSoft)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------
/// GAME SCREEN
/// ---------------------------------------------------------------
class GameScreen extends StatefulWidget {
  final String level;
  final int month;
  final String subject;

  const GameScreen({super.key, required this.level, required this.month, required this.subject});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<Exercise> exercises;
  int index = 0;
  int score = 0;
  int maxScore = 0;
  bool answeredCurrent = false;
  int? selectedOption;
  int? correctOption;

  int? selectedLeftIndex;
  Set<int> matchedIndices = {};
  List<int> wrongFlashRight = [];
  late List<int> shuffledRightOrder;

  @override
  void initState() {
    super.initState();
    exercises = allContent[widget.month]![widget.level]![widget.subject]!;
    maxScore = exercises.fold(0, (sum, ex) => sum + ex.points);
    _setupCurrentExercise();
  }

  void _setupCurrentExercise() {
    answeredCurrent = false;
    selectedOption = null;
    correctOption = null;
    selectedLeftIndex = null;
    matchedIndices = {};
    final ex = exercises[index];
    final n = ex.type == 'match' ? ex.pairs!.length : (ex.type == 'match_lang' ? ex.langPairs!.length : 0);
    if (n > 0) {
      final order = List<int>.generate(n, (i) => i);
      order.shuffle();
      shuffledRightOrder = order;
    }
  }

  void _answerQcm(int i) {
    if (answeredCurrent) return;
    final ex = exercises[index];
    setState(() {
      answeredCurrent = true;
      selectedOption = i;
      correctOption = ex.answer;
      if (i == ex.answer) score++;
    });
  }

  void _tapLeft(int i) {
    if (matchedIndices.contains(i)) return;
    setState(() => selectedLeftIndex = i);
  }

  void _tapRight(int i) {
    if (matchedIndices.contains(i) || selectedLeftIndex == null) return;
    final total = exercises[index].type == 'match' ? exercises[index].pairs!.length : exercises[index].langPairs!.length;
    if (selectedLeftIndex == i) {
      setState(() {
        matchedIndices.add(i);
        selectedLeftIndex = null;
        score++;
        if (matchedIndices.length == total) answeredCurrent = true;
      });
    } else {
      setState(() => wrongFlashRight = [i]);
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) setState(() => wrongFlashRight = []);
      });
    }
  }

  Future<void> _next() async {
    if (!answeredCurrent) return;
    if (index < exercises.length - 1) {
      setState(() {
        index++;
        _setupCurrentExercise();
      });
    } else {
      await _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'taalim_best_${widget.level}_m${widget.month}_${widget.subject}';
    final prevBest = prefs.getInt('${key}_raw') ?? 0;
    if (score > prevBest) {
      await prefs.setInt('${key}_raw', score);
      await prefs.setString(key, '$score/$maxScore');
    }
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(level: widget.level, month: widget.month, subject: widget.subject, score: score, maxScore: maxScore),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final levelName = widget.level == 'cp1' ? B.cp1Fr : B.cp2Fr;
    final subjectName = widget.subject == 'lecture' ? B.lectureFr : B.calculFr;
    final ex = exercises[index];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  BackBtn(onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 10),
                  Text('$levelName · $subjectName', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.ink)),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [BoxShadow(color: AppColors.ink.withValues(alpha: 0.10), blurRadius: 14, offset: const Offset(0, 4))],
                  ),
                  child: Text('${B.questionFr} ${index + 1}/${exercises.length}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.ink)),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: List.generate(exercises.length, (i) {
                  Color c = i < index ? AppColors.success : (i == index ? AppColors.ink : const Color(0xFFDCE6F5));
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 8,
                      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(6)),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(color: AppColors.ink.withValues(alpha: 0.15), blurRadius: 34, offset: const Offset(0, 14))],
                    ),
                    child: ex.type == 'qcm' ? _buildQcm(ex) : _buildMatch(ex),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: answeredCurrent ? _next : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: BiLabel(
                    fr: index == exercises.length - 1 ? B.seeResultFr : B.nextFr,
                    ar: index == exercises.length - 1 ? B.seeResultAr : B.nextAr,
                    frSize: 16,
                    arSize: 13,
                    color: Colors.white,
                    align: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQcm(Exercise ex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BiLabel(fr: ex.qFr!, ar: ex.qAr!, frSize: 19, arSize: 16),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.0,
          children: List.generate(ex.options!.length, (i) {
            Color bg = AppColors.chadCycle[i % 3];
            Color border = bg;
            Color textColor = AppColors.chadTextOn[i % 3];
            double borderWidth = 0;
            if (answeredCurrent) {
              if (i == correctOption) {
                bg = AppColors.success;
                border = AppColors.success;
                textColor = Colors.white;
              } else if (i == selectedOption) {
                bg = AppColors.error;
                border = AppColors.error;
                textColor = Colors.white;
              } else {
                bg = Colors.white.withValues(alpha: 0.45);
                border = const Color(0xFFE3EAF6);
                textColor = AppColors.ink;
                borderWidth = 2;
              }
            }
            final opt = ex.options![i];
            return Material(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _answerQcm(i),
                child: Container(
                  decoration: BoxDecoration(border: Border.all(color: border, width: borderWidth), borderRadius: BorderRadius.circular(16)),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: BiLabel(fr: opt.fr, ar: opt.ar, frSize: 15, arSize: 13, color: textColor, align: TextAlign.center),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        if (answeredCurrent)
          Text(
            selectedOption == correctOption ? B.correctFr : B.incorrectFr,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: selectedOption == correctOption ? AppColors.success : AppColors.error),
          ),
      ],
    );
  }

  Widget _buildMatch(Exercise ex) {
    final isLang = ex.type == 'match_lang';
    final total = isLang ? ex.langPairs!.length : ex.pairs!.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BiLabel(fr: ex.instructionFr ?? '', ar: ex.instructionAr ?? '', frSize: 15, arSize: 13, weight: FontWeight.w700, color: AppColors.inkSoft),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: List.generate(total, (i) {
                  final label = isLang ? ex.langPairs![i].fr : ex.pairs![i].left;
                  final matched = matchedIndices.contains(i);
                  final selected = selectedLeftIndex == i;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _matchButton(label: label, matched: matched, selected: selected, wrong: false, onTap: () => _tapLeft(i), rtl: false, colorIndex: i),
                  );
                }),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: List.generate(shuffledRightOrder.length, (pos) {
                  final i = shuffledRightOrder[pos];
                  final label = isLang ? ex.langPairs![i].ar : ex.pairs![i].right;
                  final matched = matchedIndices.contains(i);
                  final wrong = wrongFlashRight.contains(i);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _matchButton(label: label, matched: matched, selected: false, wrong: wrong, onTap: () => _tapRight(i), rtl: isLang, colorIndex: pos),
                  );
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (answeredCurrent) Text(B.correctFr, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.success)),
      ],
    );
  }

  Widget _matchButton({required String label, required bool matched, required bool selected, required bool wrong, required VoidCallback onTap, required bool rtl, int colorIndex = 0}) {
    Color bg = AppColors.chadCycle[colorIndex % 3];
    Color border = bg;
    Color textColor = AppColors.chadTextOn[colorIndex % 3];
    double borderWidth = 0;
    if (matched) {
      bg = AppColors.success;
      border = AppColors.success;
      textColor = Colors.white;
    } else if (wrong) {
      bg = AppColors.error;
      border = AppColors.error;
      textColor = Colors.white;
    } else if (selected) {
      bg = const Color(0xFFEEF2FB);
      border = AppColors.ink;
      textColor = AppColors.ink;
      borderWidth = 3;
    }
    final text = Text(label, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: textColor));
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: matched ? null : onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(border: Border.all(color: border, width: borderWidth), borderRadius: BorderRadius.circular(16)),
          alignment: Alignment.center,
          child: rtl ? Directionality(textDirection: TextDirection.rtl, child: text) : text,
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------
/// RESULT SCREEN
/// ---------------------------------------------------------------
class ResultScreen extends StatefulWidget {
  final String level;
  final int month;
  final String subject;
  final int score;
  final int maxScore;

  const ResultScreen({super.key, required this.level, required this.month, required this.subject, required this.score, required this.maxScore});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String? best;

  @override
  void initState() {
    super.initState();
    _loadBest();
  }

  Future<void> _loadBest() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => best = prefs.getString('taalim_best_${widget.level}_m${widget.month}_${widget.subject}'));
  }

  @override
  Widget build(BuildContext context) {
    final pct = widget.maxScore > 0 ? widget.score / widget.maxScore : 0.0;
    final starCount = pct >= 0.9 ? 3 : (pct >= 0.6 ? 2 : (pct >= 0.3 ? 1 : 0));
    final stars = List.generate(3, (i) => i < starCount ? '⭐' : '·').join(' ');

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: AppColors.ink.withValues(alpha: 0.15), blurRadius: 34, offset: const Offset(0, 14))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(stars, style: const TextStyle(fontSize: 44, letterSpacing: 6)),
                  const SizedBox(height: 8),
                  const BiLabel(fr: B.resultTitleFr, ar: B.resultTitleAr, frSize: 22, arSize: 18, align: TextAlign.center),
                  const SizedBox(height: 6),
                  Text(B.resultText(widget.score, widget.maxScore), textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: AppColors.inkSoft)),
                  if (best != null) ...[
                    const SizedBox(height: 6),
                    Text('${B.bestFr}$best', style: const TextStyle(fontSize: 13, color: AppColors.inkSoft)),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            side: const BorderSide(color: Color(0xFFE3EAF6), width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: BiLabel(fr: B.homeFr, ar: B.homeAr, frSize: 15, arSize: 12, align: TextAlign.center),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => GameScreen(level: widget.level, month: widget.month, subject: widget.subject)),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.ink,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: BiLabel(fr: B.retryFr, ar: B.retryAr, frSize: 15, arSize: 12, color: Colors.white, align: TextAlign.center),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
