import 'package:args/args.dart';
import 'download.dart';

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

ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Show additional command output.',
    )
    ..addFlag("download",
        negatable: false, help: "Downloads given MufiZ Version")
    ..addFlag('upload', negatable: false, help: "Uploads given MufiZ Version")
    ..addFlag(
      'version',
      negatable: false,
      help: 'Print the tool version.',
    );
}

void printUsage(ArgParser argParser) {
  print('Usage: dart mufiz_pkg.dart <flags> [arguments]');
  print(argParser.usage);
}

void main(List<String> arguments) async {
  final ArgParser argParser = buildParser();
  try {
    final ArgResults results = argParser.parse(arguments);
    bool verbose = false;

    // Process the parsed arguments.
    if (results.wasParsed('help')) {
      printUsage(argParser);
      return;
    }
    if (results.wasParsed('version')) {
      print('mufiz_pkg version: $version');
      return;
    }
    if (results.wasParsed('verbose')) {
      verbose = true;
    }

    if (results.wasParsed("download")) {
      final version = results.rest.first;

      for (var arch in rpmArchs) {
        final rpm = RPM(arch, version);
        await rpm.save();
      }

      for (var arch in debArchs) {
        final deb = Deb(arch, version);
        await deb.save();
      }
    }

    // Act on the arguments provided.
    // print('Positional arguments: ${results.rest}');
    // if (verbose) {
    //   print('[VERBOSE] All arguments: ${results.arguments}');
    // }
  } on FormatException catch (e) {
    // Print usage information if an invalid argument was provided.
    print(e.message);
    print('');
    printUsage(argParser);
  }
}
