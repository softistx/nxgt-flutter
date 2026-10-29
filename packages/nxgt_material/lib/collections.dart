/// Search and collections of records: [SearchField], a search input with a
/// debounced `onChanged`; [PagedList], a list loaded page by page; and
/// [ResponsiveTable], a data table that becomes cards on a compact window.
///
/// Built on Material 3 (`TextField`, `ListView`, `DataTable`), under intent
/// names.
library;

import 'package:nxgt_material/collections.dart'
    show PagedList, ResponsiveTable, SearchField;
import 'package:nxgt_material/nxgt_material.dart'
    show PagedList, ResponsiveTable, SearchField;

export 'src/collections/paged_list.dart';
export 'src/collections/responsive_table.dart';
export 'src/collections/search_field.dart';
export 'src/collections/table_column.dart';
