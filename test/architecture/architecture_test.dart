import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final _directivePattern = RegExp(
  r"""^\s*(?:import|export)\s+['"]([^'"]+)['"]""",
  multiLine: true,
);

const _allowedLayers = {
  'domain': {'domain'},
  'application': {'application', 'domain'},
  'data': {'data', 'domain'},
  'ui': {'ui', 'domain', 'application'},
};

void main() {
  test('source dependencies follow the architecture rules', () {
    final libraryDirectory = Directory('lib');
    expect(
      libraryDirectory.existsSync(),
      isTrue,
      reason: 'Das lib-Verzeichnis wurde nicht gefunden.',
    );

    final sourceFiles = libraryDirectory
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList();
    expect(
      sourceFiles,
      isNotEmpty,
      reason: 'Der Architekturtest konnte keine Dart-Dateien prüfen.',
    );

    final violations = <String>[];

    for (final file in sourceFiles) {
      final normalizedPath = file.path.replaceAll(r'\', '/');
      final sourcePath = normalizedPath.replaceFirst(
        RegExp(r'^(?:.*/)?lib/'),
        '',
      );
      final sourceLayer = _layerOf(sourcePath);
      if (sourceLayer == null) {
        continue;
      }

      final content = file.readAsStringSync();
      for (final match in _directivePattern.allMatches(content)) {
        final importUri = match.group(1)!;
        if (sourceLayer == 'domain' &&
            importUri.startsWith('package:') &&
            !importUri.startsWith('package:identity_client/')) {
          violations.add('$sourcePath darf $importUri nicht importieren.');
          continue;
        }

        final importedPath = _resolveInternalPath(sourcePath, importUri);
        if (importedPath == null) {
          continue;
        }

        final importedLayer = _layerOf(importedPath);
        if (!_allowedLayers[sourceLayer]!.contains(importedLayer)) {
          violations.add(
            '$sourcePath ($sourceLayer) darf '
            '$importedPath ($importedLayer) nicht importieren.',
          );
        }
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}

String? _layerOf(String path) {
  final separatorIndex = path.indexOf('/');
  if (separatorIndex == -1) {
    return null;
  }

  final layer = path.substring(0, separatorIndex);
  return _allowedLayers.containsKey(layer) ? layer : null;
}

String? _resolveInternalPath(String sourcePath, String importUri) {
  const packagePrefix = 'package:identity_client/';
  if (importUri.startsWith(packagePrefix)) {
    return importUri.substring(packagePrefix.length);
  }
  if (importUri.startsWith('dart:') || importUri.startsWith('package:')) {
    return null;
  }

  return Uri(path: sourcePath).resolve(importUri).path;
}
