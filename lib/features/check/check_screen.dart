import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_info.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/analysis_result.dart';
import '../../data/models/enums.dart';
import '../../data/repositories/analysis_repository.dart';
import '../../data/repositories/content_repository.dart';
import '../../shared/widgets/common.dart';
import '../../core/utils/responsive.dart';

/// 06–07 Cek Iklan — tempel teks atau tempel link.
class CheckScreen extends StatefulWidget {
  const CheckScreen({super.key, this.initialMode = 0});

  /// 0 = Tempel Teks, 1 = Tempel Link.
  final int initialMode;

  @override
  State<CheckScreen> createState() => _CheckScreenState();
}

class _CheckScreenState extends State<CheckScreen> {
  late InputMode _mode = widget.initialMode == 1 ? InputMode.link : InputMode.text;
  final _text = TextEditingController();
  final _name = TextEditingController();
  final _url = TextEditingController();
  AdSource _source = AdSource.shopee;

  bool _fetching = false;
  String? _linkError;
  LinkPreview? _preview;

  @override
  void initState() {
    super.initState();
    _text.addListener(_refresh);
    _url.addListener(() {
      // Link berubah → pratinjau lama tidak berlaku lagi.
      setState(() {
        if (_preview?.url != _url.text.trim()) _preview = null;
        _linkError = null;
      });
    });
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _text.dispose();
    _name.dispose();
    _url.dispose();
    super.dispose();
  }

  bool get _canAnalyze => switch (_mode) {
        InputMode.text => _text.text.trim().length >= AppInfo.minInputLength,
        InputMode.link => _preview != null,
      };

  Future<void> _paste(TextEditingController c) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final value = data?.text?.trim();
    if (!mounted) return;
    if (value == null || value.isEmpty) {
      _snack('Papan klip kosong. Salin deskripsi produk terlebih dahulu.');
      return;
    }
    c.text = value.length > AppInfo.maxInputLength ? value.substring(0, AppInfo.maxInputLength) : value;
  }

  void _useSample() {
    final ad = context.read<ContentRepository>().demoAd;
    setState(() {
      _text.text = ad.text;
      _name.text = ad.product;
      _source = AdSource.fromId(ad.source);
    });
  }

  Future<void> _fetchLink() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _fetching = true;
      _linkError = null;
    });
    try {
      final p = await context.read<AnalysisRepository>().fetchFromLink(_url.text);
      if (mounted) setState(() => _preview = p);
    } on AnalysisException catch (e) {
      if (mounted) setState(() => _linkError = e.message);
    } finally {
      if (mounted) setState(() => _fetching = false);
    }
  }

  void _analyze() {
    FocusScope.of(context).unfocus();
    final request = switch (_mode) {
      InputMode.text => AnalysisRequest(
          text: _text.text.trim(),
          source: _source,
          productName: _name.text.trim().isEmpty ? null : _name.text.trim(),
        ),
      InputMode.link => AnalysisRequest(
          text: _preview!.description,
          source: _preview!.source,
          productName: _preview!.product,
          url: _preview!.url,
        ),
    };
    context.push(AppRoutes.analyzing, extra: request);
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cek Iklan'),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
              child: CircleIconButton(
                  icon: Icons.arrow_back_rounded, tooltip: 'Kembali', onPressed: () => context.pop(), size: 40)),
        ),
        leadingWidth: 64,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child:
                CircleIconButton(icon: Icons.help_outline_rounded, tooltip: 'Bantuan', onPressed: _showHelp, size: 40),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ResponsiveCenter(
            child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text('Apa yang ingin kamu cek?', style: t.titleLarge),
            const SizedBox(height: 4),
            Text(
              _mode == InputMode.text
                  ? 'Salin deskripsi atau caption produk dari e-commerce, lalu tempel di bawah.'
                  : 'Tempel link halaman produk. Deskripsinya akan diambil otomatis.',
              style: t.bodyMedium?.copyWith(color: AppColors.ink500),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<InputMode>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                      value: InputMode.text,
                      icon: Icon(Icons.description_outlined, size: 18),
                      label: Text('Tempel Teks')),
                  ButtonSegment(
                      value: InputMode.link, icon: Icon(Icons.link_rounded, size: 18), label: Text('Tempel Link')),
                ],
                selected: {_mode},
                onSelectionChanged: (s) => setState(() => _mode = s.first),
              ),
            ),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _mode == InputMode.text ? _textForm(t) : _linkForm(t),
            ),
          ],
        )),
      ),
      bottomNavigationBar: BottomActionBar(
        child: FilledButton.icon(
          key: const Key('analyze-button'),
          onPressed: _canAnalyze ? _analyze : null,
          icon: const Icon(Icons.auto_awesome, size: 20),
          label: const Text('Analisis Klaim'),
        ),
      ),
    );
  }

  Widget _textForm(TextTheme t) {
    final len = _text.text.length;
    final tooShort = len > 0 && _text.text.trim().length < AppInfo.minInputLength;
    return Column(key: const ValueKey('text'), crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Text('Deskripsi produk', style: t.titleSmall),
        const Spacer(),
        Text('Wajib', style: t.bodySmall?.copyWith(color: AppColors.danger)),
      ]),
      const SizedBox(height: 8),
      TextField(
        key: const Key('ad-text-field'),
        controller: _text,
        minLines: 6,
        maxLines: 9,
        maxLength: AppInfo.maxInputLength,
        textInputAction: TextInputAction.newline,
        style: t.bodyMedium?.copyWith(color: AppColors.ink900),
        decoration: InputDecoration(
          hintText: 'Contoh: Serum pemutih 100% menghilangkan flek hitam dalam 7 hari…',
          counterText: '',
          errorText: tooShort ? 'Minimal ${AppInfo.minInputLength} karakter agar hasil akurat.' : null,
        ),
      ),
      const SizedBox(height: 8),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Wrap(spacing: 8, runSpacing: 8, children: [
            _SmallAction(icon: Icons.content_paste_rounded, label: 'Tempel', onTap: () => _paste(_text)),
            _SmallAction(icon: Icons.auto_fix_high_rounded, label: 'Gunakan contoh', onTap: _useSample),
            if (len > 0) _SmallAction(icon: Icons.close_rounded, label: 'Hapus', onTap: _text.clear),
          ]),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text('$len / ${AppInfo.maxInputLength}', style: t.bodySmall),
        ),
      ]),
      const SizedBox(height: 20),
      Text('Nama produk (opsional)', style: t.titleSmall),
      const SizedBox(height: 8),
      TextField(
        controller: _name,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(hintText: 'Mis. Glowé Bright Serum 7 Days'),
      ),
      const SizedBox(height: 20),
      Text('Sumber iklan', style: t.titleSmall),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final s in AdSource.values)
          ChoiceChip(
            label: Text(s.label),
            selected: _source == s,
            onSelected: (_) => setState(() => _source = s),
          ),
      ]),
      const SizedBox(height: 20),
      const InfoBanner(text: 'Analisis menilai klaim pada teks, bukan kandungan atau keamanan produk.'),
    ]);
  }

  Widget _linkForm(TextTheme t) {
    return Column(key: const ValueKey('link'), crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('Link produk', style: t.titleSmall),
      const SizedBox(height: 8),
      TextField(
        key: const Key('url-field'),
        controller: _url,
        keyboardType: TextInputType.url,
        textInputAction: TextInputAction.go,
        onSubmitted: (_) => _fetchLink(),
        decoration: InputDecoration(
          hintText: 'https://shopee.co.id/…',
          prefixIcon: const Icon(Icons.link_rounded, color: AppColors.primary600),
          errorText: _linkError,
          errorMaxLines: 2,
          suffixIcon: _url.text.isEmpty
              ? IconButton(
                  tooltip: 'Tempel',
                  icon: const Icon(Icons.content_paste_rounded),
                  onPressed: () => _paste(_url),
                )
              : IconButton(tooltip: 'Hapus', icon: const Icon(Icons.close_rounded), onPressed: _url.clear),
        ),
      ),
      const SizedBox(height: 8),
      Wrap(spacing: 8, children: [
        _SmallAction(
          icon: Icons.auto_fix_high_rounded,
          label: 'Gunakan contoh link',
          onTap: () => _url.text = context.read<ContentRepository>().demoAd.url ?? '',
        ),
      ]),
      const SizedBox(height: 16),
      if (_preview == null)
        OutlinedButton.icon(
          onPressed: _url.text.trim().isEmpty || _fetching ? null : _fetchLink,
          icon: _fetching
              ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.download_rounded, size: 20),
          label: Text(_fetching ? 'Mengambil deskripsi…' : 'Ambil Deskripsi'),
        )
      else
        _PreviewCard(preview: _preview!),
      const SizedBox(height: 16),
      const InfoBanner(
        text: 'Klaira hanya membaca teks deskripsi publik. Pada prototipe ini, pengambilan deskripsi disimulasikan.',
      ),
    ]);
  }

  void _showHelp() {
    final t = Theme.of(context).textTheme;
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Cara mengecek iklan', style: t.titleLarge),
          const SizedBox(height: 12),
          for (final (i, s) in const [
            'Buka halaman produk di Shopee, Tokopedia, atau TikTok Shop.',
            'Salin seluruh deskripsi produk, atau salin link halamannya.',
            'Tempel di Klaira, lalu tekan Analisis Klaim.',
            'Baca skor, frasa yang ditandai, dan alasannya sebelum membeli.',
          ].indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.primary600,
                  child: Text('${i + 1}', style: t.bodySmall?.copyWith(color: AppColors.surface)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(s, style: t.bodyMedium)),
              ]),
            ),
        ]),
      ),
    );
  }
}

class _SmallAction extends StatelessWidget {
  const _SmallAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.primary50,
        borderRadius: AppRadius.fullAll,
        child: InkWell(
          borderRadius: AppRadius.fullAll,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 15, color: AppColors.primary600),
              const SizedBox(width: 6),
              Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary700)),
            ]),
          ),
        ),
      );
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.preview});
  final LinkPreview preview;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.check_rounded, size: 16, color: AppColors.safe),
          const SizedBox(width: 6),
          Text('Deskripsi berhasil diambil', style: t.bodySmall?.copyWith(color: AppColors.safe)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          const IconTile(
              icon: Icons.auto_awesome, color: AppColors.accent600, background: AppColors.accent100, size: 52),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(preview.product, style: t.titleSmall),
              Text('${preview.store} · ${preview.source.label}', style: t.bodySmall),
              Text(preview.price, style: t.bodySmall),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        Text(preview.description, style: t.bodyMedium, maxLines: 3, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 6),
        Text('${preview.description.length} karakter', style: t.bodySmall),
        const SizedBox(height: AppSpacing.xs),
      ]),
    );
  }
}
