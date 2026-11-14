import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/features.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../services/purchase_service.dart';

/// Why the sheet was opened: shown as a short line above the perks.
enum ProReason { counters, stats, settings }

/// Purchase sheet "Twin'Am Pro" (one-time purchase).
Future<void> showProSheet(BuildContext context, {ProReason reason = ProReason.settings}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _ProSheet(reason: reason),
  );
}

/// Free users can create up to [kFreeCounterLimit] counters. Existing counters
/// above the limit (created before Pro existed) are kept, only new ones are blocked.
bool canCreateCounter({required bool isPro, required int counterCount}) =>
    isPro || counterCount < kFreeCounterLimit;

/// Opens the "new counter" screen, or the Pro sheet when the free limit is reached.
void openCreateCounter(BuildContext context, int counterCount) {
  final pro = context.read<PurchaseService>().isPro;
  if (!canCreateCounter(isPro: pro, counterCount: counterCount)) {
    showProSheet(context, reason: ProReason.counters);
    return;
  }
  Navigator.of(context).pushNamed('/create');
}

class _ProSheet extends StatelessWidget {
  final ProReason reason;

  const _ProSheet({required this.reason});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context.watch<SettingsProvider>().locale);
    final p = context.watch<PurchaseService>();
    final scheme = Theme.of(context).colorScheme;

    if (p.isPro) {
      // Purchase done: close the sheet.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.translate('proActive'))),
          );
        }
      });
    }

    final reasonText = switch (reason) {
      ProReason.counters => l10n
          .translate('proLimitCounters')
          .replaceAll('{n}', '$kFreeCounterLimit'),
      ProReason.stats => l10n.translate('proLimitStats'),
      ProReason.settings => null,
    };

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              // Anneau aux couleurs des jumeaux : évite l'effet « disque blanc » en mode sombre
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.35),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/happy-avatar.jpeg',
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.translate('proTitle'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.translate('proSubtitle'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: scheme.onSurface.withValues(alpha: 0.6)),
            ),
            if (reasonText != null) ...[
              const SizedBox(height: 14),
              Text(
                reasonText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
            const SizedBox(height: 18),
            _Perk(icon: Icons.all_inclusive_rounded, text: l10n.translate('proPerkCounters')),
            _Perk(icon: Icons.insights_rounded, text: l10n.translate('proPerkStats')),
            _Perk(icon: Icons.favorite_rounded, text: l10n.translate('proPerkSupport')),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: p.canBuy ? p.buy : null,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: p.busy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      p.price != null
                          ? l10n.translate('proBuy').replaceAll('{price}', p.price!)
                          : l10n.translate('proBuyNoPrice'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
            ),
            if (!p.storeAvailable || (p.price == null && !p.busy))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.translate('proStoreUnavailable'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.error, fontSize: 12),
                ),
              ),
            TextButton(
              onPressed: p.busy ? null : p.restore,
              child: Text(l10n.translate('proRestore')),
            ),
          ],
        ),
      ),
    );
  }
}

class _Perk extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Perk({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF2196F3)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
