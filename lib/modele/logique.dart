import '../export.dart';

class Scanner {
  static final List<String> _portOpen = [];
  static bool _cancelRequest = false;
  static Duration _elapsed = Duration.zero;

  // Getters
  static List<String> getPortOpen() => _portOpen;
  static Duration? getExecuteTime() => _elapsed;

  // Setters
  static void setPortOpen(String data) => _portOpen.add(data);

  // Methods
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

  static Future<void> paralleleStart(
      String ipAddress, int startPort, int endPort, int segments) async {
    final stopwatch = Stopwatch()..start();
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

class Device {
  // Name
  String _name = "";
  String _model = "";

  // IP
  String _localIP = "";
  String _publicIP = "";

  // System
  String _kernelName = "";
  int _kernelBits = 0;
  String _kernelVersion = "";
  String _userName = "";
  int _ram = 0;
  int _coresNumber = 0;

  Device() {
    _name = "Unknow";
    _model = "Unknow";
    _localIP = "Unknow";
    _publicIP = "Unknow";
    _kernelName = "Unknow";
    _kernelVersion = "Unknow";
    _userName = "Unknow";
    initialize();
  }

  // Getters
  String getName() => _name;
  String getModel() => _model;
  String getLocalIP() => _localIP;
  String getPublicIP() => _publicIP;
  String getKernelName() => _kernelName;
  int getKernelBits() => _kernelBits;
  String getKernelVersion() => _kernelVersion;
  String getUserName() => _userName;
  int getRAM() => _ram;
  int getCoresNumber() => _coresNumber;

  // Methods
  void initialize() {
    getDeviceInfo();
    getIPAddress();
    getSystemInfo();
  }

  Future<void> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (defaultTargetPlatform == TargetPlatform.android) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      _name = androidInfo.model;
      _model = androidInfo.brand;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      _name = _model = iosInfo.name;
    }
  }

  Future<void> getIPAddress() async {
    // Get local IP
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4) {
          _localIP = addr.address;
        }
      }
    }

    // Get public IP
    final response = await get(Uri.parse('https://api.ipify.org'));
    if (response.statusCode == 200) {
      _publicIP = response.body;
    }
  }

  void getSystemInfo() {
    _ram = SysInfo.getTotalPhysicalMemory() ~/ (1024 * 1024 * 1024);
    _coresNumber = SysInfo.processors.length;
    _kernelName = SysInfo.kernelName;
    _kernelBits = SysInfo.kernelBitness;
    _kernelVersion = SysInfo.kernelVersion;
    _userName = SysInfo.userName;
  }
}
