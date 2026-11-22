import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../backup/backup_service.dart';
import '../backup/update_service.dart';
import '../budget/budget_controller.dart';

class SettingsScreen extends StatefulWidget {
  final BudgetController controller;
  final BackupService? backupService;
  final UpdateService? updateService;

  const SettingsScreen({
    super.key,
    required this.controller,
    this.backupService,
    this.updateService,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final BackupService _backupService;
  late final UpdateService _updateService;

  bool _isCheckingUpdate = false;
  bool _isExporting = false;
  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    _backupService = widget.backupService ?? BackupService();
    _updateService = widget.updateService ?? UpdateService();
  }

  Future<void> _handleExportJson() async {
    setState(() => _isExporting = true);
    try {
      await _backupService.exportAndShareJson();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('JSON Backup generated successfully.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.terracotta,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _handleExportCsv() async {
    setState(() => _isExporting = true);
    try {
      await _backupService.exportAndShareCsv();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CSV Transactions export generated successfully.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.terracotta,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _handleRestoreFile() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (files.isEmpty) return;

      final content = await files.first.xFile.readAsString();
      if (!mounted) return;
      _confirmAndRestore(content);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File selection failed: $e'),
            backgroundColor: AppColors.terracotta,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _confirmAndRestore(String jsonContent) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Restore Backup', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: const Text(
          'Restoring from this backup will replace current records with the contents of the backup file. Proceed?',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondaryLight)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.terracotta,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              setState(() => _isRestoring = true);
              try {
                await _backupService.restoreFromJsonString(jsonContent, widget.controller);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Backup restored successfully.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Restore failed: $e'),
                      backgroundColor: AppColors.terracotta,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } finally {
                if (mounted) setState(() => _isRestoring = false);
              }
            },
            child: const Text('Restore', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCheckForUpdates() async {
    setState(() => _isCheckingUpdate = true);
    try {
      final info = await _updateService.checkForUpdate();
      if (!mounted) return;

      if (info.isUpdateAvailable) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surfaceLight,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.system_update_rounded, color: AppColors.sage, size: 22),
                const SizedBox(width: 8),
                const Text('Update Available', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A new version (${info.latestVersionName}) is available to install.',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  info.releaseNotes,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Later', style: TextStyle(color: AppColors.textSecondaryLight)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sage,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Download URL: ${info.apkUrl}'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('Download APK', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('App is up to date (v1.0.0).'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update check: Offline or server unreachable.'),
            backgroundColor: AppColors.textSecondaryLight,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCheckingUpdate = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Data Safety', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // Section 1: Data Sovereignty & Backup
            _SectionHeader(title: 'DATA SOVEREIGNTY & BACKUP'),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFE5E2D9)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _SettingsActionTile(
                      icon: Icons.file_download_outlined,
                      iconColor: AppColors.sage,
                      title: 'Export JSON Backup',
                      subtitle: 'Full database export of envelopes, transactions, and goals.',
                      isLoading: _isExporting,
                      onTap: _handleExportJson,
                    ),
                    const Divider(height: 16, color: Color(0xFFEAE8E0)),
                    _SettingsActionTile(
                      icon: Icons.table_chart_outlined,
                      iconColor: AppColors.charcoal,
                      title: 'Export CSV Transactions',
                      subtitle: 'Spreadsheet-compatible CSV file for Google Sheets / Excel.',
                      isLoading: _isExporting,
                      onTap: _handleExportCsv,
                    ),
                    const Divider(height: 16, color: Color(0xFFEAE8E0)),
                    _SettingsActionTile(
                      icon: Icons.file_upload_outlined,
                      iconColor: AppColors.terracotta,
                      title: 'Restore Backup (JSON)',
                      subtitle: 'Select an existing JSON backup file to restore records.',
                      isLoading: _isRestoring,
                      onTap: _handleRestoreFile,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Section 2: Budget & Cycle Preferences
            _SectionHeader(title: 'PREFERENCES & CYCLE'),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFE5E2D9)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cycle Reset Day',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Resets every ${controller.cycleStartDay}th of month',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F4F0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: controller.cycleStartDay,
                              items: [1, 5, 10, 15, 20, 25, 28].map((day) {
                                return DropdownMenuItem<int>(
                                  value: day,
                                  child: Text('$day', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) controller.setCycleStartDay(val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Section 3: App Version & Updates
            _SectionHeader(title: 'APP UPDATES'),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFE5E2D9)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Personal Finance Tracker',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                            ),
                            Text(
                              'Version 1.0.0 (Build 1)',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.charcoal,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _isCheckingUpdate ? null : _handleCheckForUpdates,
                          icon: _isCheckingUpdate
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('Check Updates', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}

class _SettingsActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isLoading;
  final VoidCallback onTap;

  const _SettingsActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: isLoading ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryLight),
                  ),
                ],
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.charcoal),
              )
            else
              const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textSecondaryLight),
          ],
        ),
      ),
    );
  }
}
