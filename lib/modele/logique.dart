import '../export.dart';

class Scanner {
  static final List<String> _portOpen = [];
  static bool _cancelRequest = false;
  static Duration? _elapsed;

  // Getters
  static List<String> getPortOpen() => _portOpen;
  static Duration? getExecuteTime() => _elapsed;

  // Setters
  static void setPortOpen(String data) => _portOpen.add(data);

  // Methods
  static Future<void> start(
      String ipAddress, int startPort, int endPort) async {
    final stopwatch = Stopwatch()..start();

    // vérifie pour toute la plage de port si un port est ouvert
    for (int port = startPort; port <= endPort; port++) {
      bool isOpen = await isPortOpen(ipAddress, port);
      // Si une demande d'annulement du scan à eu lieu alors arreter
      if (_cancelRequest) {
        reserCancelrequest();
        break;
      }

      // Ajoute à la liste des ports ouvert le port acctuelle si il est ouvert
      if (isOpen) {
        Scanner.setPortOpen("Port $port : OUVERT\n");
      }
    }

    stopwatch.stop();
    _elapsed = stopwatch.elapsed;
  }

  static Future<bool> isPortOpen(String ipAddress, int port,
      {Duration timeout = const Duration(milliseconds: 200)}) async {
    try {
      Socket socket = await Socket.connect(ipAddress, port,
          timeout: timeout); // Se connecte à l'ip et le port
      socket.destroy(); // Si la connexion est fait la détruit directement
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> paralleleStart(
      String ipAddress, int startPort, int endPort, int segments) async {
    final stopwatch = Stopwatch()..start();
    int segmentsSize = ((endPort - startPort + 1) / segments)
        .ceil(); // Divise la plage par le nombre de segement pour avoir la taille d'un segment
    List<Future<void>> tasks = [];

    for (int i = 0; i < segments; i++) {
      int segmentStart =
          startPort + i * segmentsSize; // Début de la plage pour ce segment
      int segmentEnd = (segmentStart + segmentsSize - 1)
          .clamp(segmentStart, endPort); // Fin de la plage pour ce segment

      if (segmentStart <= endPort) {
        tasks.add(Scanner.start(ipAddress, segmentStart,
            segmentEnd)); // Ajoute le scan du segment à la liste des tâches
      }
    }

    await Future.wait(tasks); // Attends que toutes les tâches soit fini
    stopwatch.stop();
    _elapsed = stopwatch.elapsed;
  }

  static void cancelScan() {
    _cancelRequest = true;
  }

  static void reserCancelrequest() {
    _cancelRequest = false;
  }
}
