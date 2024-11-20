import '../export.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  String ipAddress = "127.0.0.1";
  int subNetMask = 24;
  int portStart = 0;
  int portEnd = 65535;
  int segments = 20;

  List<String> portOpen = [];
  List<String> ipPresent = [];
  Device phone = Device();

  bool isMenu = true;
  bool isScanning = false;
  bool showInfo = false;
  bool useCommonPort = true;
  String scanType = "";

  int _selectedIndex = 0;
  String messagePing = "L'appareil existe.";

  final List<String> _texts = [
    "Scanner les ports ouverts",
    "Scanner les IP sur un réseau",
    "Vérifier si un appareil est présent",
    "Informations sur le téléphone"
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Widgets spécifiques pour chaque section
  Widget _buildSectionContent() {
    if (isScanning) {
      return Build.loadingWidget();
    }

    switch (_selectedIndex) {
      case 0: // Ports
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Build.portScanSection(portOpen),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Popup.showIpPortDialog(context, ipAddress, portStart, portEnd,
                      segments, useCommonPort, _startScan);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 196, 61, 220),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: const Text(
                  "Effectuer un scan",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      case 1: // IP
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Build.ipScanSection(ipPresent),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Popup.showListIpDialog(
                      context, ipAddress, subNetMask, segments, _startListScan);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 196, 61, 220),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: const Text(
                  "Effectuer un scan",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      case 2: // Ping
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Build.pingSection(ipAddress, messagePing),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Popup.showPingDialog(context, ipAddress, _updatePingSection);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 196, 61, 220),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: const Text(
                  "Effectuer un ping",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      case 3: // Profil
        return Build.profileSection(phone);
      default:
        return Center(
          child: Text(
            _texts[_selectedIndex],
            style: const TextStyle(fontSize: 24, color: Colors.white),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradientDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      boxShadow: const [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 8,
          offset: Offset(4, 4),
        ),
      ],
      gradient: LinearGradient(
        colors: [
          Colors.purple.withOpacity(0.8),
          Colors.deepPurple.withOpacity(0.5),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: Container(
          decoration: gradientDecoration,
          child: AppBar(
            title: Text(
              _selectedIndex == 3 ? "Profil" : _texts[_selectedIndex],
              style: const TextStyle(color: Colors.white),
            ),
            foregroundColor: Colors.white,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: _buildSectionContent(),
      bottomNavigationBar: Container(
        decoration: gradientDecoration.copyWith(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.yellowAccent,
          unselectedItemColor: Colors.white70,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.network_check),
              label: "Ports",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.devices),
              label: "IP",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.wifi_tethering),
              label: "Ping",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: "Profil",
            ),
          ],
        ),
      ),
    );
  }

  /*
    =-=-=-=-=-=-=-=-=-=-=-=
    =-= AUTRES METHODES =-=
    =-=-=-=-=-=-=-=-=-=-=-=
  */
  void _updatePingSection(String newIp, String message) {
    setState(() {
      ipAddress = newIp;
      messagePing = message;
      Build.pingSection(ipAddress, message);
    });
  }

  Future<void> _startScan() async {
    setState(() {
      scanType = "ipPort"; // Type de scan
      isMenu = false;
      isScanning = true;
      showInfo = false;
    });

    Scanner.resetCancelRequest();

    await Scanner.paralleleStart(
        ipAddress, portStart, portEnd, segments, useCommonPort);

    setState(() {
      isScanning = false;
      portOpen = Scanner.getPortOpen();
      portOpen = portOpen.toSet().toList();
      showInfo = true;
    });
  }

  Future<void> _startListScan(String ipMask, String segmentInput) async {
    setState(() {
      scanType = "listIp";
      isMenu = false;
      isScanning = true;
      showInfo = false;
    });

    Scanner.resetCancelRequest();

    final inputParts = ipMask.split('/');
    if (inputParts.length == 2) {
      ipAddress = inputParts[0];
      subNetMask = int.parse(inputParts[1]);
      segments = int.tryParse(segmentInput) ?? segments;

      await Scanner.balayageIPParallele(ipAddress, subNetMask, segments);

      setState(() {
        isScanning = false;
        ipPresent = Scanner.getIpPresent();
        ipPresent = ipPresent.toSet().toList();
        showInfo = true;
      });
    }
  }
}
