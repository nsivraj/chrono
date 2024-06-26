import 'package:clock_app/navigation/widgets/app_top_bar.dart';
import 'package:clock_app/settings/data/settings_schema.dart';
import 'package:clock_app/settings/types/setting_item.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsTopBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size(0, 56);

  const SettingsTopBar(
      {super.key,
      this.onSearch,
      this.showSearch = false,
      required this.title});

  final void Function(List<SettingItem> settings)? onSearch;
  final String title;
  final bool showSearch;

  @override
  State<SettingsTopBar> createState() => _SettingsTopBarState();
}

class _SettingsTopBarState extends State<SettingsTopBar> {
  final TextEditingController _filterController = TextEditingController();
  bool _searching = false;

  _SettingsTopBarState() {
    _filterController.addListener(() async {
      if (_filterController.text.isEmpty) {
        widget.onSearch?.call([]);
      } else {
        var results = extractTop<SettingItem>(
            query: _filterController.text,
            choices: [
              ...appSettings.settings,
              ...appSettings.settingPageLinks,
              ...appSettings.settingActions
            ],
            limit: 10,
            cutoff: 50,
            getter: (item) {
              // Search term includes the setting name, as well as the parent group names
              return "${item.name} ${item.path.map((group) => group.name).join(" ")} ${item.searchTags.join(" ")}";
            });

        widget.onSearch?.call(results.map((result) => result.choice).toList());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_searching) {
      return AppTopBar(
        title: TextField(
          autofocus: _filterController.text.isEmpty,
          onTapOutside: ((event) {
            FocusScope.of(context).unfocus();
          }),
          controller: _filterController,
          decoration: InputDecoration(
            border: InputBorder.none,
            focusedBorder:
                const OutlineInputBorder(borderSide: BorderSide.none),
            fillColor: Colors.transparent,
            hintText: AppLocalizations.of(context)!.searchSettingPlaceholder,
            hintStyle: Theme.of(context).textTheme.bodyLarge,
          ),
          textAlignVertical: TextAlignVertical.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        actions: [
          IconButton(
            onPressed: () {
              _filterController.clear();
              setState(() {
                _searching = false;
              });
            },
            icon: const Icon(Icons.close),
          )
        ],
      );
    } else {
      return AppTopBar(
        title: Text(
          widget.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color:
                    Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
              ),
        ),
        actions: [
          if (widget.showSearch)
            IconButton(
              onPressed: () {
                setState(() {
                  _searching = true;
                });
              },
              icon: Icon(
                Icons.search,
                color:
                    Theme.of(context).colorScheme.onBackground,
              ),
            )
        ],
      );
    }
  }
}
