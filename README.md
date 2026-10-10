# Budget Planner

A Flutter build of the `UI_Budget_Planner_Light_mode` Figma file, structured
around GetX.

## Layout

```
lib/
├── api/                 network layer (ApiClient + BudgetApi)
├── getx_controller/     one controller per screen area
├── models/              plain data models
├── preferences/         SharedPreferences wrapper
├── screen/
│   ├── lunch/           splash + onboarding
│   ├── auth/            login, create account, pin, success
│   ├── bottom_nav_bar/  the four-tab shell
│   ├── home/            home, all actions, expense details
│   ├── operation/       add operation, its pickers and the time sheet
│   ├── category/        category list + add category
│   ├── tips/            tips grid + article
│   ├── profile/         profile form
│   ├── setting/         settings
│   └── about/           about
├── utils/               colours, type, dimens, assets, theme, routes
├── utils_lan/           English and Arabic strings
├── widget/              shared widgets
└── main.dart
```

## Running

```sh
flutter pub get
flutter run
```

## Testing

```sh
flutter test                                  # the suite, 189 tests
flutter test --tags capture \
  test/screen/golden_capture_test.dart        # render every screen at 414x896
```

The capture pass writes a render-tree dump per screen to `build/screens/`,
which is a faster way to check a layout against the Figma board than walking a
simulator screen by screen. It is tagged so it stays out of the normal run.

`test/design/` is the part worth knowing about: it pins the measurements, the
type ramp and the palette to the values in the Figma file, and fails if a
screen starts hardcoding a colour instead of using a token.

## Design tokens

`lib/utils/app_colors.dart`, `app_text_styles.dart` and `app_dimens.dart` hold
every colour, type step, radius and shadow, all read out of the Figma file
rather than estimated. Nothing else in the app hardcodes a value — and
`test/design/color_usage_test.dart` fails the build if anything starts to.

The values that matter most, for reference:

| | |
| --- | --- |
| Primary | `#472FC8`, on a 30pt pill |
| Text | `#0D0E56` over `#7B7C98` over `#B9BACE` |
| Money | out `#F33720`, in `#00BEA1` |
| Type | Montserrat, 15/23 for body, 20/24.4 for headings |
| Cards | white at 8pt radius, separated by an `#E9E7F1` shadow rather than a grey fill |

## Pulling from Figma

The Figma MCP server is capped at 20 calls a month on a Starter plan, so there
are two routes that do not touch it. Either one produces the same thing: the
real colours, the real typeface and the real artwork.

### Without a token — export from the Figma UI

Select the frames in Figma, **Export → SVG**, then point the importer at
whatever came out:

```sh
python3 tool/figma_import.py ~/Downloads/export.zip --dry-run   # look first
python3 tool/figma_import.py ~/Downloads/export.zip
```

An SVG export carries its colours as hex and its type as `font-family`, so the
importer reads both straight out of the source, writes them to
`build/figma/observed.json` ordered by how often each is used, and files the
artwork under the slugs `lib/utils/app_assets.dart` already expects. It is
idempotent — running it twice changes nothing.

If Figma outlined the text on export, the font will not come through; read the
family off any text layer's right-hand panel instead.

### With a token — the REST API

Its quota is separate from the MCP server's. Generate one at
**figma.com/settings → Security → Personal access tokens** with
`File content: Read`:

```sh
echo figd_your_token > .figma_token     # already gitignored
python3 tool/figma_pull.py              # tree + exact palette and type ramp
python3 tool/figma_assets.py            # icons as SVG, illustrations as PNG
```

`figma_pull.py` writes `build/figma/styles.json`, listing every colour and text
style in the file ordered by how often it is used — that is what the token
files above should be reconciled against. `figma_assets.py` fills `assets/`
with names that already match `lib/utils/app_assets.dart`.

Either way, finish with `flutter test test/design` to confirm nothing went
missing.

## Artwork

Everything in `assets/` is exported from the Figma file. The illustrations in
particular are the designer's originals, several hundred vector paths each.

`tool/figma_render.py` draws them locally from the cached document tree, so a
full re-export costs one API call rather than dozens and never trips the image
endpoint's rate limit:

```sh
python3 tool/figma_pull.py      # refresh the tree
python3 tool/figma_render.py    # redraw everything, offline
```

`AppSvg` falls back to a soft block for an asset that is genuinely missing
rather than throwing, and `test/screen/screen_assets_test.dart` fails if any
screen ever hits that fallback.
# budget_planner
