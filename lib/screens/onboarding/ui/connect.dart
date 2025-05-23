import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segmented_button_slide/segmented_button_slide.dart';

import 'package:linkdy/screens/onboarding/ui/sliver_top_bar.dart';
import 'package:linkdy/screens/onboarding/provider/connect.provider.dart';
import 'package:linkdy/screens/onboarding/provider/onboarding.provider.dart';
import 'package:linkdy/widgets/section_label.dart';

import 'package:linkdy/constants/enums.dart';
import 'package:linkdy/i18n/strings.g.dart';

class OnboardingConnect extends ConsumerWidget {
  const OnboardingConnect({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: OnboardingSliverTopBar(
                    icon: Icons.login_rounded,
                    title: t.onboarding.createConnection,
                  ),
                ),
                SliverList.list(
                  children: const [
                    _ConnectForm(),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FilledButton(
                onPressed: () => ref.read(onboardingProvider.notifier).previousPage(),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back_rounded),
                    const SizedBox(width: 8),
                    Text(t.onboarding.previous),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: ref.watch(connectProvider).validValues ? () => ref.read(connectToServerProvider) : null,
                icon: const Icon(Icons.login_rounded),
                label: Text(t.onboarding.connect),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConnectForm extends ConsumerWidget {
  const _ConnectForm();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(connectProvider);

    final connectionMethod = ConnectionMethod.values[provider.method];

    final connectionString =
        "${connectionMethod.name}://${provider.ipDomainController.text}${provider.portController.text != '' ? ':${provider.portController.text}' : ""}${provider.pathController.text}";

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                t.onboarding.createConnectionSubtitle,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          margin: const EdgeInsets.only(top: 30, left: 24, right: 24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Theme.of(context).colorScheme.primary),
          ),
          child: Text(
            connectionString,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500),
          ),
        ),
        SectionLabel(
          label: t.onboarding.serverDetails,
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 24),
        ),
        SegmentedButtonSlide(
          entries: const [
            SegmentedButtonSlideEntry(label: "HTTP"),
            SegmentedButtonSlideEntry(label: "HTTPS"),
          ],
          selectedEntry: provider.method,
          onChange: ref.read(connectProvider.notifier).setConnectionMethod,
          colors: SegmentedButtonSlideColors(
            barColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            backgroundSelectedColor: Theme.of(context).colorScheme.primary,
            foregroundSelectedColor: Theme.of(context).colorScheme.onPrimary,
            foregroundUnselectedColor: Theme.of(context).colorScheme.onSurface,
            hoverColor: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textOverflow: TextOverflow.ellipsis,
          fontSize: 14,
          height: 40,
          margin: const EdgeInsets.symmetric(
            horizontal: 24,
          ),
        ),
        const SizedBox(height: 30),
        TextFormField(
          controller: provider.ipDomainController,
          onChanged: ref.read(connectProvider.notifier).validateIpDomain,
          autocorrect: false,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.link_rounded),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            errorText: provider.ipDomainError,
            labelText: t.onboarding.ipAddressOrDomain,
            helperText: t.onboarding.required,
          ),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: provider.portController,
          onChanged: ref.read(connectProvider.notifier).validatePort,
          autocorrect: false,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.tag_rounded),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            errorText: provider.portError,
            labelText: t.onboarding.port,
          ),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: provider.pathController,
          onChanged: ref.read(connectProvider.notifier).validatePath,
          autocorrect: false,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.route_rounded),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            errorText: provider.pathError,
            labelText: t.onboarding.path,
          ),
        ),
        SectionLabel(
          label: t.onboarding.authentication,
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 24),
        ),
        TextFormField(
          controller: provider.tokenController,
          onChanged: ref.read(connectProvider.notifier).validateToken,
          autocorrect: false,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.key_rounded),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            errorText: provider.tokenError,
            labelText: t.onboarding.token,
            helperText: t.onboarding.required,
          ),
          obscureText: true,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: provider.testConnection == null ? () => ref.read(connectProvider.notifier).testConnection() : null,
          style: ButtonStyle(
            foregroundColor: provider.testConnection == LoadStatus.loaded
                ? const WidgetStatePropertyAll(Colors.green)
                : provider.testConnection == LoadStatus.error
                    ? const WidgetStatePropertyAll(Colors.red)
                    : null,
            backgroundColor: provider.testConnection == LoadStatus.loaded
                ? WidgetStatePropertyAll(Colors.green.withOpacity(0.15))
                : provider.testConnection == LoadStatus.error
                    ? WidgetStatePropertyAll(Colors.red.withOpacity(0.15))
                    : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (provider.testConnection == null) Text(t.bookmarks.addBookmark.validateUrl),
              if (provider.testConnection == LoadStatus.loading) ...[
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 8),
                Text(t.onboarding.testingConnection),
              ],
              if (provider.testConnection == LoadStatus.loaded) ...[
                const Icon(Icons.check_circle_rounded),
                const SizedBox(width: 8),
                Text(t.onboarding.connectionServerEstablished),
              ],
              if (provider.testConnection == LoadStatus.error) ...[
                const Icon(Icons.error_rounded),
                const SizedBox(width: 8),
                Text(t.onboarding.connectionServerFailed),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
