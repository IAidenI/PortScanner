import '../export.dart';

class Build {
  // Méthode générique pour afficher une section d'informations
  static Widget _buildSection(String title, Map<String, String> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.yellowAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        ...data.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    "${entry.key}:",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: SelectableText(
                    entry.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16), // Espacement entre les sections
      ],
    );
  }

  // Méthode générique pour afficher une boîte contenant des sections
  static Widget _buildContainer(List<Widget> sections) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sections,
        ),
      ),
    );
  }

  // Méthode pour construire des sections spécifiques
  static Widget _buildCustomSection({
    required String sectionTitle,
    required Map<String, String> data,
  }) {
    return _buildContainer([_buildSection(sectionTitle, data)]);
  }

  // Méthode générique pour afficher une liste d'éléments avec un format personnalisé
  static Widget _buildListSection(String title, List<String> items,
      {String suffix = ""}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.yellowAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        ...items.map((item) {
          return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: SelectableText(
                "$item$suffix",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ));
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  // Section pour le scan des ports avec le format "Port XXXX : OPEN"
  static Widget portScanSection(List<String> portOpen) {
    // Ajout de ": OPEN" à chaque port
    return _buildContainer([
      _buildListSection("Ports ouverts", portOpen),
    ]);
  }

  // Section pour le scan IP
  static Widget ipScanSection(List<String> ipPresent) {
    return _buildContainer([
      _buildListSection("Adresses IP détectées", ipPresent,
          suffix: " : PRESENT"),
    ]);
  }

  // Section pour Ping Section
  static Widget pingSection(String ipAddress, String message) {
    final userInfo = {
      ipAddress: message,
    };
    return _buildCustomSection(
      sectionTitle: "Adresse IP",
      data: userInfo,
    );
  }

  // Section pour Profil Section
  static Widget profileSection(Device phone) {
    phone.initialize();
    final userInfo = {
      "Nom": phone.getName(),
      "Modèle": phone.getModel(),
    };
    final networkInfo = {
      "IP privé": phone.getLocalIP(),
      "IP public": phone.getPublicIP(),
    };
    final systemInfo = {
      "RAM": "${phone.getRAM()} Go",
      "Coeurs": phone.getCoresNumber().toString(),
      "Noyau":
          "${phone.getKernelName()} x${phone.getKernelBits()} - ${phone.getKernelVersion()}",
      "Username": phone.getUserName(),
    };

    return _buildContainer([
      _buildSection("Informations utilisateur", userInfo),
      _buildSection("Informations réseau", networkInfo),
      _buildSection("Informations système", systemInfo),
    ]);
  }

// Page de chargement
  static Widget loadingWidget() {
    return Stack(
      children: [
        const Positioned(
          top: 275,
          left: 0,
          right: 0,
          child: Center(
            child: CircularProgressIndicator(color: Colors.deepPurpleAccent),
          ),
        ),
        const Positioned(
          bottom: 40,
          left: 16,
          right: 16,
          child: Text(
            "Cette opération peut prendre plusieurs minutes.",
            style: TextStyle(
              fontSize: 12,
              color: Colors.white54,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
