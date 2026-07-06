import 'dart:io';

void main(List<String> args) {
  final double threshold = args.isNotEmpty ? double.parse(args[0]) : 90.0;
  final File lcovFile = File('coverage/lcov.info');

  if (!lcovFile.existsSync()) {
    print(
      'Error: coverage/lcov.info not found. Please run "flutter test --coverage" first.',
    );
    exit(1);
  }

  final List<String> lines = lcovFile.readAsLinesSync();
  int totalLh = 0;
  int totalLf = 0;

  int currentLh = 0;
  int currentLf = 0;
  String? currentFile;
  final Map<String, List<int>> fileCoverage = {};

  for (final String line in lines) {
    final String trimmed = line.trim();
    if (trimmed.startsWith('SF:')) {
      currentFile = trimmed.substring(3);
      currentLh = 0;
      currentLf = 0;
    } else if (trimmed.startsWith('LH:')) {
      currentLh = int.parse(trimmed.substring(3));
    } else if (trimmed.startsWith('LF:')) {
      currentLf = int.parse(trimmed.substring(3));
    } else if (trimmed == 'end_of_record') {
      if (currentFile != null) {
        fileCoverage[currentFile] = [currentLh, currentLf];
        totalLh += currentLh;
        totalLf += currentLf;
      }
    }
  }

  print('=' * 80);
  print('Line Coverage Verification Report');
  print('=' * 80);
  print(
    '${"File".padRight(50)} | ${"Hits".padLeft(6)} | ${"Lines".padLeft(6)} | ${"Coverage".padLeft(8)}',
  );
  print('-' * 80);

  final List<String> sortedFiles = fileCoverage.keys.toList()..sort();
  for (final String file in sortedFiles) {
    final List<int> stats = fileCoverage[file]!;
    final int lh = stats[0];
    final int lf = stats[1];
    final double pct = lf > 0 ? (lh / lf) * 100 : 100.0;

    // Simplify file path path relative to workspace
    final String displayFile = file.replaceAll(
      Directory.current.path + '/',
      '',
    );
    print(
      '${displayFile.padRight(50)} | ${lh.toString().padLeft(6)} | ${lf.toString().padLeft(6)} | ${pct.toStringAsFixed(2).padLeft(7)}%',
    );
  }

  print('=' * 80);
  final double totalPct = totalLf > 0 ? (totalLh / totalLf) * 100 : 0.0;
  print(
    '${"TOTAL".padRight(50)} | ${totalLh.toString().padLeft(6)} | ${totalLf.toString().padLeft(6)} | ${totalPct.toStringAsFixed(2).padLeft(7)}%',
  );
  print('=' * 80);
  print('Target threshold: ${threshold.toStringAsFixed(2)}%');

  if (totalPct < threshold) {
    print(
      'FAIL: Code coverage is below threshold! (Actual: ${totalPct.toStringAsFixed(2)}% < Target: ${threshold.toStringAsFixed(2)}%)',
    );
    exit(1);
  } else {
    print(
      'SUCCESS: Code coverage meets threshold! (Actual: ${totalPct.toStringAsFixed(2)}% >= Target: ${threshold.toStringAsFixed(2)}%)',
    );
    exit(0);
  }
}
