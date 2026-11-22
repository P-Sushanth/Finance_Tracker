import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import '../budget/budget_controller.dart';
import '../budget/budget_repository.dart';

class BackupService {
  final BudgetRepository _repository;

  BackupService([BudgetRepository? repository])
      : _repository = repository ?? BudgetRepository();

  /// Generates full database backup as a JSON string.
  Future<String> generateJsonBackup() async {
    final data = await _repository.exportAllData();
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }

  /// Generates all transactions export as a CSV string.
  Future<String> generateCsvExport() async {
    return await _repository.exportTransactionsCsv();
  }

  /// Exports full database backup as a file and triggers the OS share sheet.
  Future<void> exportAndShareJson() async {
    final jsonStr = await generateJsonBackup();
    final now = DateTime.now();
    final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    final fileName = 'finance_tracker_backup_$timestamp.json';

    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            Uint8List.fromList(utf8.encode(jsonStr)),
            mimeType: 'application/json',
            name: fileName,
          ),
        ],
        subject: 'Finance Tracker JSON Backup',
        text: 'Offline backup export from Personal Finance Tracker.',
      ),
    );
  }

  /// Exports transactions to CSV file and triggers the OS share sheet.
  Future<void> exportAndShareCsv() async {
    final csvStr = await generateCsvExport();
    final now = DateTime.now();
    final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    final fileName = 'finance_tracker_transactions_$timestamp.csv';

    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            Uint8List.fromList(utf8.encode(csvStr)),
            mimeType: 'text/csv',
            name: fileName,
          ),
        ],
        subject: 'Finance Tracker Transactions CSV',
        text: 'Exported transactions report from Personal Finance Tracker.',
      ),
    );
  }

  /// Validates and restores data directly from JSON string.
  Future<bool> restoreFromJsonString(String jsonContent, BudgetController controller) async {
    try {
      final decoded = json.decode(jsonContent);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Expected JSON object root');
      }

      final success = await _repository.restoreAllData(decoded);
      if (success) {
        await controller.loadBudgetData();
      }
      return success;
    } catch (e) {
      debugPrint('BackupService restore error: $e');
      rethrow;
    }
  }
}
