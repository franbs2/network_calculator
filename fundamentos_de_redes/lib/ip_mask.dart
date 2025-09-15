//Classe com os metodos para calcular rede, broadcast e faixa de hosts!

class IpMask {
  final String ip;
  final String mask;

  IpMask({required this.ip, required this.mask});

  int ipToInt(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) {
      throw ("IP inválido (não tem 4 octetos)");
    }

    final nums = parts.map(int.parse).toList();
    if (nums.any((n) => n < 0 || n > 255)) {
      throw ("IP inválido (octeto fora de 0-255)");
    }

    return (nums[0] << 24) | (nums[1] << 16) | (nums[2] << 8) | nums[3];
  }

  String intToIp(int x) {
    return "${(x >> 24) & 255}.${(x >> 16) & 255}.${(x >> 8) & 255}.${x & 255}";
  }

  String prefixToMask(int prefix) {
    if (prefix < 0 || prefix > 32) {
      throw ("Prefixo inválido");
    }
    final mask = (0xFFFFFFFF << (32 - prefix)) & 0xFFFFFFFF;
    return intToIp(mask);
  }

  Map<String, dynamic> validateMask(String mask) {
    mask = mask.trim();

    if (mask.startsWith("/")) {
      final prefix = int.parse(mask.substring(1));
      return {"mask": prefixToMask(prefix), "prefix": prefix};
    }

    if (RegExp(r'^\d+$').hasMatch(mask)) {
      final prefix = int.parse(mask);
      return {"mask": prefixToMask(prefix), "prefix": prefix};
    }

    final maskInt = ipToInt(mask);
    final prefix = maskInt.toRadixString(2).replaceAll("0", "").length;
    final expected = (0xFFFFFFFF << (32 - prefix)) & 0xFFFFFFFF;
    if (maskInt != expected) {
      throw ("Máscara inválida");
    }
    return {"mask": mask, "prefix": prefix};
  }

  String calculateNetwork(String ip, String mask) {
    return intToIp(ipToInt(ip) & ipToInt(mask));
  }

  String calculateBroadcast(String ip, String mask) {
    final ipInt = ipToInt(ip);
    final maskInt = ipToInt(mask);
    final networkInt = ipInt & maskInt;
    final broadcastInt = networkInt | (~maskInt & 0xFFFFFFFF);
    return intToIp(broadcastInt);
  }

  List<String> calculateRange(String network, String broadcast, int prefix) {
    if (prefix == 32) return [network, network];
    if (prefix == 31) return ["Sem faixa de hosts tradicionais (/31)", ""];
    final start = ipToInt(network) + 1;
    final end = ipToInt(broadcast) - 1;
    return [intToIp(start), intToIp(end)];
  }
}
