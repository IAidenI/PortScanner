import '../export.dart';

class BreathingEye extends StatefulWidget {
  const BreathingEye({super.key});

  @override
  State<BreathingEye> createState() => _BreathingEyeState();
}

class _BreathingEyeState extends State<BreathingEye>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true); // Répète l'animation en alternant

    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: child,
        );
      },
      child: Container(
        width: 300, // Largeur de l'image
        height: 300, // Hauteur de l'image
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/nmap_logo.png"), // Deuxième image
            fit: BoxFit.contain, // Affiche l'image sans la déformer
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
