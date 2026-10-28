## Changelog

### v0.2.0

- Styling follows the folium website: darker green links, bold level 2 headings, and rounded corners on callouts, code blocks and block quotes
- Block quotes have a light green background and a green left border, with square left corners and rounded right corners
- Code blocks have rounded corners, including syntax-highlighted ones
- Callout headers keep the color of the callout type, and notes use the brand green; icons and titles are in the text color; the border is thinner and lighter
- New icon for important callouts, replacing the skull
- Callout icons are vertically centered on the title text; they sat above its center before
- The gap between a callout icon and its title is smaller and the same in every callout; default titles had an extra space before
- `appearance="simple"` callouts show the icon beside the text with no header or default title, and `appearance="minimal"` callouts show only the text; a title is shown only when one is given
- The `callout-appearance` document option is honored
- Added `folium-callout.lua`, which passes the callout appearance on to Typst
- Cross-referenced callouts and callouts in the margin keep the default layout, whatever their appearance
- A callout without a type (`.callout`) is a simple callout and no longer shows the title "None"

### v0.1.0

- Separated presentation settings under `folium` from report data under `nbis`
- Added recursive extension defaults for partial `folium` overrides
- Removed extension defaults from `nbis`; users provide all NBIS report data
- Font Awesome assets defined under `folium-assets` key in extension
- Vendored Font Awesome now takes precedence over the copy Quarto injects for callouts, so the same icon set is used in every document
- `logo: false` and `background: false` under `folium` leave out the logo and background image
- Section numbers are applied with Typst's built-in heading numbering; `number-sections: false` turns them off
- Removed the `toc` and `toc-depth` defaults, which the template never used; add a contents page with `#outline()`
- `lang` and `region` are passed on to Typst, and the PDF title is set from `title`
- Block quotes are styled through Typst's `quote` element
- Cross-referenceable callouts (ids such as `nte-…`) keep their icon and title, which were dropped before
- Inline code breaks across lines like ordinary text; it was drawn in an unbreakable box before, which left gaps and misplaced trailing punctuation
- Text size classes `.largest`, `.larger`, `.large`, `.small`, `.smaller` and `.smallest` work in PDF output
- Removed the unused `.article` div handler
- Logo position follows the page margin when it is set with `x`/`y`, `inside` or `rest`
- Header, footer and badge text scale with `font-size`; the template default font size is 12pt, matching the extension default
- Demo reports are included when the project is installed as a template
- Minimum Quarto version is 1.8.0

### v0.0.2

- Updated configuration files for font paths and installation instructions
- Default format settings are defined in the extension itself
- Background image, logo and related settings are also included in the extension

### v0.0.1

- 28-Sep-2026
- Contributors shortcode added (since replaced by contributors rendered from `nbis.contributors`)
- Fonts Lato and Font Awesome are included
- Added documentation website
