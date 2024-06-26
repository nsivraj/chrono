import 'package:clock_app/common/logic/show_select.dart';
import 'package:clock_app/common/types/list_filter.dart';
import 'package:clock_app/common/types/list_item.dart';
import 'package:clock_app/common/types/select_choice.dart';
import 'package:clock_app/common/widgets/card_container.dart';
import 'package:clock_app/common/widgets/list/action_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ListFilterChip<Item extends ListItem> extends StatelessWidget {
  const ListFilterChip({
    super.key,
    required this.listFilter,
    required this.onChange,
  });

  final ListFilter<Item> listFilter;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    TextTheme textTheme = theme.textTheme;

    return CardContainer(
      color: listFilter.isSelected ? colorScheme.primary : null,
      onTap: () {
        listFilter.isSelected = !listFilter.isSelected;
        onChange();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(
          listFilter.displayName(context),
          style: textTheme.headlineSmall?.copyWith(
            color: listFilter.isSelected
                ? colorScheme.onPrimary
                : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class ListFilterActionChip<Item extends ListItem> extends StatelessWidget {
  const ListFilterActionChip({
    super.key,
    required this.actions,
    required this.activeFilterCount,
  });

  final List<ListFilterAction> actions;
  final int activeFilterCount;

  void _showPopupMenu(BuildContext context) async {
    await showModalBottomSheet<List<int>>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      builder: (BuildContext context) {
        return ActionBottomSheet(
          title: AppLocalizations.of(context)!.filterActions,
          actions: actions,
          // description: description,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    TextTheme textTheme = theme.textTheme;

    return CardContainer(
      color: colorScheme.primary,
      onTap: () {
        _showPopupMenu(context);
        // listFilter.isSelected = !listFilter.isSelected;
        // onChange();
      },
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: 8.0, right: 6.0, top: 6.0, bottom: 6.0),
            child: Icon(
              Icons.filter_list_rounded,
              color: colorScheme.onPrimary,
              size: 20,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Text(
              activeFilterCount.toString(),
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.onPrimary.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ListFilterSelectChip<Item extends ListItem> extends StatelessWidget {
  final FilterSelect<Item> listFilter;
  final VoidCallback onChange;

  const ListFilterSelectChip({
    super.key,
    required this.listFilter,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    TextTheme textTheme = theme.textTheme;
    bool isFirstSelected = listFilter.selectedIndex == 0;

    void showSelect() async {
      showSelectBottomSheet(context, (List<int>? selectedIndices) {
        listFilter.selectedIndex =
            selectedIndices?[0] ?? listFilter.selectedIndex;
        onChange();
      },
          title: listFilter.displayName(context),
          description: "",
          getChoices: () => listFilter.filters
              .map((e) =>
                  SelectChoice(name: e.displayName(context), value: e.id))
              .toList(),
          getCurrentSelectedIndices: () => [listFilter.selectedIndex],
          multiSelect: false);
    }

    return CardContainer(
      color: isFirstSelected ? null : colorScheme.primary,
      onTap: showSelect,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 8.0, bottom: 8.0, left: 16.0, right: 2.0),
            child: Text(
              isFirstSelected
                  ? listFilter.displayName(context)
                  : listFilter.selectedFilter.displayName(context),
              style: textTheme.headlineSmall?.copyWith(
                  color: isFirstSelected
                      ? colorScheme.onSurface
                      : colorScheme.onPrimary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 2.0, right: 8.0),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isFirstSelected
                  ? colorScheme.onSurface.withOpacity(0.6)
                  : colorScheme.onPrimary.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class ListFilterMultiSelectChip<Item extends ListItem> extends StatelessWidget {
  final FilterMultiSelect<Item> listFilter;
  final VoidCallback onChange;

  const ListFilterMultiSelectChip({
    super.key,
    required this.listFilter,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    TextTheme textTheme = theme.textTheme;
    List<int> selectedIndices = listFilter.selectedIndices;
    bool isSelected = selectedIndices.isNotEmpty;

    void showSelect() async {
      showSelectBottomSheet(context, (List<int>? newSelectedIndices) {
        listFilter.selectedIndices =
            newSelectedIndices ?? listFilter.selectedIndices;
        onChange();
      },
          title: listFilter.displayName(context),
          description: "",
          getChoices: () => listFilter.filters
              .map((e) =>
                  SelectChoice(name: e.displayName(context), value: e.id))
              .toList(),
          getCurrentSelectedIndices: () => selectedIndices,
          multiSelect: true);
    }

    return CardContainer(
      color: isSelected ? colorScheme.primary : null,
      onTap: showSelect,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 8.0, bottom: 8.0, left: 16.0, right: 2.0),
            child: Text(
              !isSelected
                  ? listFilter.displayName(context)
                  : listFilter.selectedIndices.length == 1
                      ? listFilter.selectedFilters[0].displayName(context)
                      : "${listFilter.selectedIndices.length} selected",
              style: textTheme.headlineSmall?.copyWith(
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 2.0, right: 8.0),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isSelected
                  ? colorScheme.onPrimary.withOpacity(0.6)
                  : colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class ListSortChip<Item extends ListItem> extends StatelessWidget {
  final List<ListSortOption> sortOptions;
  final Function(int) onChange;
  final int selectedIndex;

  const ListSortChip({
    super.key,
    required this.sortOptions,
    required this.onChange,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    TextTheme textTheme = theme.textTheme;
    bool isFirstSelected = selectedIndex == 0;

    void showSelect() async {
      showSelectBottomSheet(context, (List<int>? selectedIndices) {
        onChange(selectedIndices?[0] ?? selectedIndex);
      },
          title: AppLocalizations.of(context)!.sortGroup,
          description: "",
          getChoices: () => sortOptions
              .map((e) => SelectChoice(
                  name: e.displayName(context), value: e.getLocalizedName))
              .toList(),
          getCurrentSelectedIndices: () => [selectedIndex],
          multiSelect: false);
    }

    return CardContainer(
      // color: isFirstSelected ? null : colorScheme.primary,
      onTap: showSelect,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 8.0, bottom: 8.0, left: 16.0, right: 2.0),
            child: Text(
              "${AppLocalizations.of(context)!.sortGroup}${isFirstSelected ? "" : ": ${sortOptions[selectedIndex].displayName(context)}"}",
              style: textTheme.headlineSmall
                  ?.copyWith(color: colorScheme.onSurface),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 2.0, right: 8.0),
            child: Icon(Icons.keyboard_arrow_down_rounded,
                color: colorScheme.onSurface.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}
