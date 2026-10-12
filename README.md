# Care247 Customer Search

A small Flutter app to search customers, browse results and open a customer's full details. Data comes from the supplied `db.json` served by JSON Server.

## Setup and run

**Versions:** Flutter 3.24+ (stable), Dart 3.5+. Run `flutter --version` to check.

1. Generate the platform folders (only `lib/` and `test/` are committed to keep the repo small):

   ```bash
   flutter create . --platforms=android,ios
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Start the mock API. Put the supplied `db.json` anywhere and run:

   ```bash
   npm install -g json-server
   json-server --watch db.json --port 3001
   ```

4. Run the app:

   ```bash
   flutter run
   ```

### API base URL

The base URL lives in `lib/config/env.dart` and nowhere else.

| Target | URL used |
| --- | --- |
| Android emulator | `http://10.0.2.2:3001` (picked automatically) |
| iOS simulator | `http://localhost:3001` (picked automatically) |
| Physical device | pass it in: `flutter run --dart-define=API_BASE_URL=http://192.168.1.20:3001` |

`--dart-define` overrides the default on any platform. Dart's own HTTP client is used, so no Android cleartext or iOS ATS changes are needed for debug runs against a local HTTP server.

## Architecture

```
lib/
  config/     env.dart (base URL), search_config.dart (FieldType, FieldConfig, searchConfig)
  models/     Customer, Address, Phone, Email with fromJson
  data/       customer_api.dart (HTTP + error mapping), customer_repository.dart (search/filter)
  state/      customer_search_state.dart (sealed SearchState + CustomerSearchController)
  screens/    search, results, detail
  widgets/    dynamic_search_form, dynamic_field, customer_list_item, message_view
  utils/      date helpers
```

- **Presentation** (screens, widgets) only renders state and forwards user actions.
- **State** (`CustomerSearchController`) owns the current search state and the last criteria.
- **Data** (`CustomerApi`, `CustomerRepository`) talks to the server and turns raw JSON into typed models. Network, status and parsing failures all become an `ApiException` with a user-friendly message, so the UI never sees a raw exception.

**Navigation:** plain `Navigator.push` with `MaterialPageRoute`. Three screens in a straight line didn't justify a router package. The search controller is created by the search screen and handed to the results screen, so pull-to-refresh and retry can rerun the same search.

## State management

`ChangeNotifier` + `ListenableBuilder`, both from the Flutter SDK.

Why: there is one piece of shared state (the current search) used by two screens. A provider/bloc package would add a dependency and boilerplate without solving a problem this app has.

States are a sealed class, so the results screen uses an exhaustive `switch`:

| State | Shown as |
| --- | --- |
| `SearchInitial` | nothing searched yet |
| `SearchLoading` | centered progress indicator |
| `SearchSuccess(customers)` | list with pull-to-refresh |
| `SearchEmpty` | "No customers found" message, pull-to-refresh still works |
| `SearchError(message)` | readable message with a "Try again" button |

## Configuration-driven search

`searchConfig` is a list of `FieldConfig`. `DynamicSearchForm` sorts it by `renderOrder` and creates one `TextEditingController` + `FocusNode` per `key`. `DynamicField` picks the widget from `FieldType` only (text input or date picker). On submit the form returns `Map<String, String>` of `key -> value`, which goes straight to the repository.

The repository matches each non-empty value against `Customer.searchableFields[key]` (case-insensitive, partial). Every filled field must match.

**Adding a field (e.g. Marital Status):** add one entry to `searchConfig`:

```dart
FieldConfig(
  key: 'maritalStatus',
  type: FieldType.text,
  label: 'Marital Status',
  placeholder: 'e.g. Married',
  renderOrder: 4,
),
```

That's it. The search screen, form, field widget, controller and repository don't change. `maritalStatus` is already in `searchableFields`; a brand new customer attribute would need one line there. A brand new input *type* (say a dropdown) would need a new `FieldType` value and one new branch in `DynamicField`, still nothing in the screen or form. This scenario is covered by a widget test.

## Flutter decisions

- **Lifecycle:** the form disposes all its controllers and focus nodes; the search screen disposes its controller. The date picker checks `context.mounted` after the `await`. The controller ignores results that arrive after `dispose()`, and uses a generation counter so a result from an older request (or one that finished after "Clear") never overwrites newer state.
- **Async:** API calls are `async/await` with a 10 second timeout. A new search supersedes an in-flight one, pull-to-refresh is ignored while a request is already running, and a double tap on Search can't push the results page twice.
- **Rebuilds:** only the results body listens to the controller (`ListenableBuilder`), so the app bar and search screen don't rebuild on state changes. The date field rebuilds only itself when its value changes. Sorting the config happens once in `initState`, not in `build`. Detail sections are small private widgets.
- **Lists:** `ListView.separated` builds rows lazily, each row has a `ValueKey` of the customer id.
- **Keyboard and forms:** `TextInputAction.next` moves between fields, the last one submits with the search action. Tapping outside or dragging the form dismisses the keyboard, and the form scrolls so the focused field stays visible. Date of birth is read-only and opens `showDatePicker`.
- **UX:** Material 3, 48px button height, a max form width on wider phones, a primary chip and bold text for primary phone/email, a masked secure ID with a show/hide toggle, semantic headers on detail sections.

## Trade-offs

- **Filtering is done in the repository, not via JSON Server query params.** JSON Server only does exact, case-sensitive matches out of the box (`?firstName=John`), and its partial-match syntax changed between v0.17 and v1. Fetching the list and filtering locally gives forgiving, version-independent search and lets any configured key work automatically. For a real API with thousands of records this would move server-side, and only `CustomerRepository.search` would change.
- **The date field stores `yyyy-MM-dd`** so it matches the data format directly; results and details show it as `15 Mar 1985`.
- **No caching.** Every search hits the API, which keeps results fresh and the code simple.
- **No dependency injection package.** The repository is created in `main.dart` and passed down through constructors.
- Only dependency outside the SDK is `http` (official Dart team package), used for requests and for `MockClient` in tests.

## Testing

```bash
flutter test
```

- `customer_model_test.dart`: JSON parsing, primary phone/email selection, missing lists, malformed data.
- `customer_repository_test.dart`: filtering (empty, partial, case-insensitive, combined, extra config key) and error mapping (bad status, bad body, network failure) using `MockClient`.
- `customer_search_state_test.dart`: state transitions for success, empty and error, reset during a request, and no updates after dispose.
- `dynamic_search_form_test.dart`: fields render in `renderOrder`, a new config field renders and is submitted, clear works.

## Time spent

Roughly 7 hours.
