import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

class Package {
  String arch;
  String version;

  Package(this.arch, this.version);

  String link() {
    // Implement in subclasses
    return '';
  }

  String fileName() {
    // Implement in subclasses
    return '';
  }

  Future<void> download() async {
    var client = http.Client();
    var resp = await client.get(Uri.parse(link()));
    if (resp.statusCode == 200) {
      try {
        var file = File(fileName());
        file.writeAsBytes(resp.bodyBytes);
      } catch (e) {
        print("Error: $e");
      }
    } else {
      print("Request for $arch failed!");
      return;
    }
  }
}

class RPM extends Package {
  RPM(String arch, String version) : super(arch, version);

  @override
  String link() {
    return "https://github.com/Mustafif/MufiZ/releases/download/v$version/mufiz-$version-1.$arch.rpm";
  }

  @override
  String fileName() {
    return "rpm/mufiz-$version-1.$arch.rpm";
  }
}

class Deb extends Package {
  Deb(String arch, String version) : super(arch, version);

  @override
  String link() {
    return "https://github.com/Mustafif/MufiZ/releases/download/v$version/mufiz_${version}_$arch.deb";
  }

  @override
  String fileName() {
    return "deb/mufiz_${version}_$arch.deb";
  }
}
