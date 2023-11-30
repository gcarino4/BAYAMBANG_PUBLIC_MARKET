class UsernameSingleton {
  static final UsernameSingleton _instance = UsernameSingleton._internal();

  factory UsernameSingleton() {
    return _instance;
  }

  UsernameSingleton._internal();

  String username = ''; // Initialize with an empty string

  void reset() {
    username = '';
  }
}

class TerminalIdSingleton {
  static final TerminalIdSingleton _instance = TerminalIdSingleton._internal();

  factory TerminalIdSingleton() {
    return _instance;
  }

  TerminalIdSingleton._internal();

  String terminalId = ''; // Initialize with an empty string
}

class IpAddressSingleton {
  static final IpAddressSingleton _instance = IpAddressSingleton._internal();

  factory IpAddressSingleton() {
    return _instance;
  }

  IpAddressSingleton._internal();

  String ipAddress = ''; // Initialize with an empty string
}

// class IpAddressSingleton {
//   static final IpAddressSingleton _instance = IpAddressSingleton._internal();
//
//   String? _ipAddress;
//
//   factory IpAddressSingleton() {
//     return _instance;
//   }
//
//   IpAddressSingleton._internal();
//
//   String? get ipAddress => _ipAddress;
//
//   set ipAddress(String? value) {
//     _ipAddress = value;
//   }
// }

class TrxnoSingleton {
  static final TrxnoSingleton _instance = TrxnoSingleton._internal();

  factory TrxnoSingleton() {
    return _instance;
  }

  TrxnoSingleton._internal();

  int trxno = 0; // Initialize with 0

  void reset() {
    trxno = 0;
  }

}

// class VendorcodeSingleton {
//   static final VendorcodeSingleton _instance = VendorcodeSingleton._internal();
//
//   factory VendorcodeSingleton() {
//     return _instance;
//   }
//
//   VendorcodeSingleton._internal();
//
//   int qrcode = 0; // Initialize with 0
// }
