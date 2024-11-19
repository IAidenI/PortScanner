import '../export.dart';

class Scanner {
  static final List<String> _portOpen = [];
  static bool _cancelRequest = false;
  static Duration _elapsed = Duration.zero;
  static int _portNumber = 0;
  static int _networkLength = 0;
  static final List<String> _ipPresent = [];

  // Getters
  static List<String> getPortOpen() => _portOpen;
  static Duration? getExecuteTime() => _elapsed;
  static int getPortNumber() => _portNumber;
  static List<String> getIpPresent() => _ipPresent;
  static int getIpNumber() => _networkLength;

  // Setters
  static void setPortOpen(String data) => _portOpen.add(data);

  // Methods
  /*
    =-=-=-=-=-=-=-=-=-=-
    =-= SCAN AVEC IP =-=
    =-=-=-=-=-=-=-=-=-=-
  */
  static Future<void> start(
      String ipAddress, int startPort, int endPort) async {
    final stopwatch = Stopwatch()..start();

    for (int port = startPort; port <= endPort; port++) {
      // Vérifie si une annulation a été demandée
      if (_cancelRequest) {
        resetCancelRequest();
        break;
      }

      bool isOpen = await isPortOpen(ipAddress, port);
      if (isOpen) {
        setPortOpen("Port $port : OUVERT\n");
      }
    }

    stopwatch.stop();
    _elapsed = stopwatch.elapsed;
  }

  static Future<void> paralleleStart(String ipAddress, int startPort,
      int endPort, int segments, bool useCommonPort) async {
    final stopwatch = Stopwatch()..start();
    if (useCommonPort) {
      _portNumber = commonPort.length;
      // Diviser la liste des ports courants en segments
      int segmentSize = (commonPort.length / segments).ceil();
      List<Future<void>> tasks = [];

      for (int i = 0; i < segments; i++) {
        // Définir le segment de ports
        int segmentStartIndex = i * segmentSize;
        int segmentEndIndex = segmentStartIndex + segmentSize;

        // Vérifie les limites de la liste
        if (segmentStartIndex >= commonPort.length) break;
        if (segmentEndIndex > commonPort.length) {
          segmentEndIndex = commonPort.length;
        }

        // Extraire les ports du segment
        List<int> segmentPorts =
            commonPort.sublist(segmentStartIndex, segmentEndIndex);

        // Ajouter la tâche de scan pour ce segment
        tasks.add(_scanPortsList(ipAddress, segmentPorts));
      }

      // Attendre toutes les tâches ou une annulation
      await Future.any([
        Future.wait(tasks), // Attends que toutes les tâches se terminent
        _cancelMonitor(), // Surveillance de l'annulation
      ]);
    } else {
      _portNumber = endPort - startPort + 1;
      int segmentsSize = ((endPort - startPort + 1) / segments).ceil();
      List<Future<void>> tasks = [];

      // Ajoute les tâches pour chaque segment
      for (int i = 0; i < segments; i++) {
        int segmentStart = startPort + i * segmentsSize;
        int segmentEnd = (segmentStart + segmentsSize - 1);
        if (segmentEnd > endPort) {
          segmentEnd = endPort;
        }

        if (segmentStart <= endPort) {
          tasks.add(_scanSegment(ipAddress, segmentStart, segmentEnd));
        }
      }

      // Attends que toutes les tâches soient terminées ou annulées
      await Future.any([
        Future.wait(tasks), // Attends que toutes les tâches se terminent
        _cancelMonitor(), // Surveillance de l'annulation
      ]);
    }

    stopwatch.stop();
    _elapsed = stopwatch.elapsed;
  }

  static Future<void> _scanSegment(
      String ipAddress, int startPort, int endPort) async {
    for (int port = startPort; port <= endPort; port++) {
      if (_cancelRequest) {
        // Si l'annulation est demandée, on sort de la boucle
        return;
      }
      bool isOpen = await isPortOpen(ipAddress, port);
      if (isOpen) {
        setPortOpen("Port $port : OUVERT\n");
      }
    }
  }

  static Future<void> _scanPortsList(String ipAddress, List<int> ports) async {
    for (int port in ports) {
      if (_cancelRequest) {
        // Si l'annulation est demandée, on sort de la boucle
        return;
      }
      bool isOpen = await isPortOpen(ipAddress, port);
      if (isOpen) {
        setPortOpen("Port $port : OUVERT\n");
      }
    }
  }

  static Future<bool> isPortOpen(String ipAddress, int port,
      {Duration timeout = const Duration(milliseconds: 200)}) async {
    try {
      Socket socket = await Socket.connect(ipAddress, port, timeout: timeout);
      socket.destroy();
      return true;
    } catch (e) {
      return false; // Retourne "false" si la connexion échoue
    }
  }

  /*
    =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    =-= PING POUR VOIR SI      =-=
    =-= L'APPAREIL EST PRESENT =-=
    =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  */
  static Future<bool> ping(String ipAddress,
      {Duration timeout = const Duration(milliseconds: 700)}) async {
    try {
      final result =
          await Process.run('ping', ['-c', '1', ipAddress], runInShell: true)
              .timeout(timeout, onTimeout: () {
        throw TimeoutException("Le délai d'attente a été dépassé.");
      });

      if (result.stdout.toString().contains("1 received") ||
          result.stdout.toString().contains("bytes from")) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /*
    =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    =-= CONVERTIT UN URL EN SON IP =-=
    =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  */
  static Future<String> urlToIP(String url) async {
    try {
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }

      // Extraire le nom d'hôte sans protocole
      final uri = Uri.parse(url);
      final host = uri
          .host; // Récupère uniquement le nom d'hôte (ex : `www.google.com` ou `google.com`)

      // Résolution DNS
      final addresses = await InternetAddress.lookup(host);

      // Retourne la première adresse IPv4
      return addresses
          .firstWhere(
            (address) => address.type == InternetAddressType.IPv4,
            orElse: () => InternetAddress('0.0.0.0'),
          )
          .address;
    } catch (e) {
      return "";
    }
  }

  /*
    =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    =-= RECHERCHE DE TOUT LES   =-=
    =-= APPAREIL DANS UN RESEAU =-=
    =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  */
  static Future<void> balayageIPParallele(
      String reseau, int subnetMaskPrefixe, int segments) async {
    final stopwatch = Stopwatch()..start();
    String? subnetMask = cidrToMask[subnetMaskPrefixe];
    if (subnetMask != null) {
      // Calcul de l'adresse réseau de départ
      List<String> ipStart = [];
      List<String> reseauSplit = reseau.split('.');
      List<String> maskSplit = subnetMask.split('.');
      for (var i = 0; i < maskSplit.length; i++) {
        ipStart.add(
            (int.parse(reseauSplit[i]) & int.parse(maskSplit[i])).toString());
      }

      _networkLength = getNetworkLength(subnetMaskPrefixe);

      // Diviser le réseau en segments
      int segmentSize = (_networkLength / segments).ceil();
      List<Future<void>> tasks = [];

      for (int i = 0; i < segments; i++) {
        int segmentStart = i * segmentSize;
        int segmentEnd = segmentStart + segmentSize - 1;

        if (segmentStart > _networkLength) break;
        if (segmentEnd > _networkLength) {
          segmentEnd = _networkLength;
        }
        // Ajouter la tâche pour scanner un segment
        tasks.add(_scanBalayageSegment(ipStart, segmentStart, segmentEnd));
      }

      // Attendre toutes les tâches ou une annulation
      await Future.any([
        Future.wait(tasks),
        _cancelMonitor(), // Surveillance de l'annulation
      ]);
      stopwatch.stop();
      _elapsed = stopwatch.elapsed;
    }
  }

  static Future<void> _scanBalayageSegment(
      List<String> ipStart, int start, int end) async {
    int total = end - start + 1;
    int nextUpdate = 10; // Pourcentage pour la prochaine mise à jour

    for (int i = start; i <= end; i++) {
      if (_cancelRequest) {
        // Si une annulation est demandée, on sort de la boucle
        return;
      }

      // Modifier la dernière partie de l'IP pour chaque itération
      ipStart.last = i.toString();
      String ip = ipStart.join('.');

      // Vérifie si l'adresse IP répond
      bool checkIP = await ping(ip, timeout: Duration(seconds: 5));
      if (checkIP) {
        _ipPresent.add(ip);
      }
    }
  }

  static int getNetworkLength(int subnetMaskPrefixe) {
    int nombreMachines = 1 << (32 - subnetMaskPrefixe);
    return nombreMachines > 2 ? nombreMachines - 2 : 0;
  }

  /*
    =-=-=-=-=-=-=-=-=-=-=
    =-= AUTRE METHODE =-=
    =-=-=-=-=-=-=-=-=-=-=
  */
  static Future<void> _cancelMonitor() async {
    while (!_cancelRequest) {
      await Future.delayed(Duration(milliseconds: 50));
    }
  }

  static void cancelScan() {
    _cancelRequest = true;
  }

  static void resetCancelRequest() {
    _cancelRequest = false;
  }

  static void clear() {
    _portOpen.clear();
  }
}
