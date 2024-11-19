import '../export.dart';

class Device {
  // Name
  String _name = "";
  String _model = "";

  // IP
  String _localIP = "";
  String _publicIP = "";
  String _subnetMask = "";

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
  String getSubnetMask() => _subnetMask;
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
