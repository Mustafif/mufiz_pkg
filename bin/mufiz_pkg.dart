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

List<String> rpmOSArgs(String os, String version) {
  if (io.Platform.isWindows) {
    return [
      "/c",
      "package_cloud",
      "push",
      "Mustafif/MufiZ/$os",
      "./rpm/*$version*.rpm"
    ];
  } else {
    // linux
    return [
      "-c",
      "package_cloud",
      "push",
      "Mustafif/MufiZ/$os",
      "./rpm/*$version*.rpm"
    ];
  }
}

List<String> debOSArgs(String os, String version) {
  if (io.Platform.isWindows) {
    return [
      "/c",
      "package_cloud",
      "push",
      "Mustafif/MufiZ/$os",
      "./deb/*$version*.deb"
    ];
  } else {
    // linux
    return [
      "-c",
      "package_cloud",
      "push",
      "Mustafif/MufiZ/$os",
      "./deb/*$version*.deb"
    ];
  }
}

Future<void> upload(String version) async {
  String cmd;
  if (io.Platform.isWindows) {
    cmd = "cmd";
  } else {
    cmd = "sh";
  }
  for (var os in debOS) {
    final _ = io.Process.run(cmd, debOSArgs(os, version));
  }

  for (var os in rpmOS) {
    final _ = io.Process.run(cmd, rpmOSArgs(os, version));
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
      final version = results.rest.first;
      await upload(version);
    }
  } on FormatException catch (e) {
    // Print usage information if an invalid argument was provided.
    print(e.message);
    print('');
    printUsage(argParser);
  }
}
