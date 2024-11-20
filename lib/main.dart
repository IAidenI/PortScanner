import 'export.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyScanner());
}

class MyScanner extends StatelessWidget {
  const MyScanner({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Scanner",
      home: Scaffold(
        body: Stack(
          children: [
            // Image de fond
            Center(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/fond_violet.jpeg"),
                    fit: BoxFit.cover, // Coupe l'image et la centre
                  ),
                ),
              ),
            ),
            // Image animée (respiration)
            const Center(
              child: BreathingEye(),
            ),
            // Test widget avec fonctionnalités
            const Positioned.fill(
              child: Menu(), // Ce widget sera au-dessus des images
            ),
          ],
        ),
      ),
    );
  }
}
