import 'package:args/args.dart';
import 'pkg.dart';
import 'dart:io' as io;

const String version = '0.0.1';

const debArchs = [
  "amd64",
  "i386",
  "arm64",
  "mipsel",
  "mips64el",
  "mips",
  "powerpc",
];

const rpmArchs = [
  "x86_64",
  "i386",
  "aarch64",
  "ppc64",
  "ppc64le",
  "mipsel",
  "mips64el",
  "mips64",
  "mips",
  "riscv64"
];
// ❯ package_cloud push Mustafif/MufiZ/fedora/39 *.rpm

const debOS = [
  "ubuntu/noble", // Ubuntu 24.04
  "ubuntu/jammy", // Ubuntu 22.04
  "debian/forky", // Debian 14
  "debian/trixie", // Debain 13
  "debian/bookworm" // Debian 12
];
const rpmOS = ["fedora/40", "fedora/39", "fedora/38", "opensuse/42.3"];

ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addFlag("download",
        abbr: 'd', negatable: false, help: "Downloads given MufiZ Version")
    ..addFlag('upload',
        abbr: 'u',
        negatable: false,
        help: "Uploads given MufiZ Deb/RPM Packages")
    ..addFlag(
      'version',
      negatable: false,
      abbr: 'v',
      help: 'Print the tool version.',
    );
}

void printUsage(ArgParser argParser) {
  print('Usage: dart mufiz_pkg.dart <flags> [arguments]');
  print(argParser.usage);
}

List<String> rpmOSArgs(String os) =>
    ["/c", "package_cloud", "push", "Mustafif/MufiZ/$os", "./rpm/*.rpm"];
List<String> debOSArgs(String os) =>
    ["/c", "package_cloud", "push", "Mustafif/MufiZ/$os", "./deb/*.deb"];

Future<void> upload() async {
  for (var os in debOS) {
    final _ = io.Process.runSync("cmd", debOSArgs(os));
  }

  for (var os in rpmOS) {
    final _ = io.Process.runSync("cmd", rpmOSArgs(os));
  }

  print("Finished Uploading!");
}

void main(List<String> arguments) async {
  final ArgParser argParser = buildParser();
  try {
    final ArgResults results = argParser.parse(arguments);
    // Process the parsed arguments.
    if (results.wasParsed('help')) {
      printUsage(argParser);
      return;
    }
    if (results.wasParsed('version')) {
      print('mufiz_pkg version: $version');
      return;
    }

    if (results.wasParsed("download")) {
      final version = results.rest.first;

      for (var arch in rpmArchs) {
        print("Downloading RPM package for $arch");
        final rpm = RPM(arch, version);
        await rpm.download();
      }

      for (var arch in debArchs) {
        print("Downloading DEB package for $arch");
        final deb = Deb(arch, version);
        await deb.download();
      }

      print("Finished Downloading!");
    }

    if (results.wasParsed('upload')) {
      await upload();
    }
  } on FormatException catch (e) {
    // Print usage information if an invalid argument was provided.
    print(e.message);
    print('');
    printUsage(argParser);
  }
}
