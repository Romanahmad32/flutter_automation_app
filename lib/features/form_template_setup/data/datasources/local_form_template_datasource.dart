import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:automation_app/core/general_classes/exceptions/custom_exceptions.dart';
import 'package:automation_app/features/form_template_setup/domain/entities/create_form_template_request.dart';
import 'package:automation_app/features/form_template_setup/domain/entities/form_template.dart';
import 'package:path_provider_windows/path_provider_windows.dart';

abstract class LocalFormTemplateDatasource {
  Future<List<FormTemplate>> loadFormTemplates();

  Future<FormTemplate> loadFormTemplateByName(String name);

  Future<void> createFormTemplate(CreateFormTemplateRequest templateRequest);

  Future<FormTemplate> updateFormTemplate(FormTemplate template);

  Future<void> deleteFormTemplate(int id);
}

class LocalFormTemplateDatasourceImpl implements LocalFormTemplateDatasource {
  final File _documentsFile;

  LocalFormTemplateDatasourceImpl._({required File documentsFile})
    : _documentsFile = documentsFile;

  static Future<LocalFormTemplateDatasourceImpl> create(
    PathProviderWindows pathProviderWindows,
  ) async {
    final String? documentsPath = await pathProviderWindows
        .getApplicationSupportPath();
    if (documentsPath == null) {
      throw FormTemplateException('Kein Documents Ordner gefunden');
    }
    final file = File('$documentsPath/form_templates.json');
    if (!await file.exists()) {
      // Wurde die App mitten im Schreiben beendet, liegt das Original evtl. noch
      // als .bak vor (siehe _writeAll). Dann von dort wiederherstellen.
      final backup = File('${file.path}.bak');
      if (await backup.exists()) {
        await backup.rename(file.path);
      } else {
        await file.writeAsString('[]');
      }
    }

    return LocalFormTemplateDatasourceImpl._(documentsFile: file);
  }

  @override
  Future<List<FormTemplate>> loadFormTemplates() async {
    final contents = await _documentsFile.readAsString();
    try {
      final decoded = jsonDecode(contents) as List<dynamic>;
      return decoded
          .map((e) => FormTemplate.fromJson(e as Map<String, dynamic>))
          .toList();
    } on FormTemplateException {
      rethrow;
    } catch (_) {
      // Faengt FormatException (kaputtes JSON), TypeError (fehlende/falsche
      // Felder), ungueltige InputType-Werte und Cast-Fehler (z.B. Objekt statt
      // Liste) gleichermassen ab und meldet sie als saubere Domain-Exception.
      throw FormTemplateException(
        'Vorlagendatei ist beschädigt und konnte nicht gelesen werden',
      );
    }
  }

  @override
  Future<void> deleteFormTemplate(int id) async {
    final loadedTemplates = await loadFormTemplates();
    final initialLength = loadedTemplates.length;
    loadedTemplates.removeWhere((element) => element.id == id);
    if (loadedTemplates.length == initialLength) {
      throw FormTemplateException('Vorlage mit ID $id nicht gefunden');
    }
    await _writeAll(loadedTemplates);
  }

  @override
  Future<FormTemplate> loadFormTemplateByName(String name) async {
    final loadedTemplates = await loadFormTemplates();

    return loadedTemplates.firstWhere(
      (element) => element.templateName == name,
      orElse: () => throw FormTemplateException(
        'Vorlage mit dem Namen $name nicht gefunden',
      ),
    );
  }

  @override
  Future<void> createFormTemplate(
    CreateFormTemplateRequest templateRequest,
  ) async {
    final loadedTemplates = await loadFormTemplates();
    if (loadedTemplates.any(
      (element) => element.templateName == templateRequest.templateName,
    )) {
      throw FormTemplateException(
        'Vorlage mit Name ${templateRequest.templateName} existiert bereits',
      );
    }

    final newId = loadedTemplates.isEmpty
        ? 1
        : loadedTemplates.map((e) => e.id).reduce(max) + 1;

    loadedTemplates.add(
      FormTemplate(
        id: newId,
        templateName: templateRequest.templateName,
        fields: templateRequest.fields,
        wordFilePathOhneAuflistung: templateRequest.wordFilePathOhneAuflistung,
        wordFilePathMitAuflistung: templateRequest.wordFilePathMitAuflistung,
      ),
    );
    await _writeAll(loadedTemplates);
  }

  @override
  Future<FormTemplate> updateFormTemplate(FormTemplate template) async {
    final loadedTemplates = await loadFormTemplates();
    final int index = loadedTemplates.indexWhere(
      (element) => element.id == template.id,
    );
    if (index == -1) {
      throw FormTemplateException(
        'Vorlage mit ID ${template.id} nicht gefunden',
      );
    }
    if (loadedTemplates.any(
      (element) =>
          element.id != template.id &&
          element.templateName == template.templateName,
    )) {
      throw FormTemplateException(
        'Vorlage mit Name ${template.templateName} existiert bereits',
      );
    }
    loadedTemplates[index] = template;

    await _writeAll(loadedTemplates);
    return template;
  }

  static const JsonEncoder _encoder = JsonEncoder.withIndent('  ');

  Future<void> _writeAll(List<FormTemplate> templates) async {
    final tmp = File('${_documentsFile.path}.tmp');
    final backup = File('${_documentsFile.path}.bak');
    try {
      // flush: true erzwingt das Schreiben auf die Platte, bevor umbenannt wird.
      await tmp.writeAsString(_encoder.convert(templates), flush: true);

      // Auf Windows schlaegt File.rename fehl, wenn das Ziel bereits existiert.
      // Deshalb das Original erst zur Seite legen, dann tmp an seine Stelle.
      if (await _documentsFile.exists()) {
        if (await backup.exists()) await backup.delete();
        await _documentsFile.rename(backup.path);
      }
      try {
        await tmp.rename(_documentsFile.path);
      } catch (_) {
        // Letztes Umbenennen fehlgeschlagen: Original aus dem Backup zurueck.
        if (await backup.exists()) await backup.rename(_documentsFile.path);
        rethrow;
      }
      // Erfolg: Backup ist best-effort, ein Rest-.bak ist unkritisch.
      try {
        if (await backup.exists()) await backup.delete();
      } catch (_) {}
    } catch (e) {
      if (await tmp.exists()) await tmp.delete();
      rethrow;
    }
  }
}
