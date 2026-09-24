# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Quarto extension (`folium-typst` format) that provides a Typst template for NBIS PDF reports (cover page with investigator/PI/analyst roles, logo, background image, FontAwesome/Tabler icons).

## Commands

Render the demo/example documents (requires `quarto` and Typst on PATH):

```bash
quarto render demo.qmd
quarto render index.qmd
```

There is no build system, package manager, linter, or test suite — this is a template/filter distributed as source files that Quarto and Typst execute directly. Verify changes by rendering `demo.qmd` (exercises most markdown/Typst features) and `index.qmd` (minimal example matching the README) and inspecting the resulting PDF.

`demo.qmd` sets `keep-typ: true`, so rendering it also emits the intermediate `demo.typ` — useful for debugging what the Lua filters and template partials actually produced before Typst compiles it.

## Architecture

Quarto extension mechanics: `_extensions/folium/_extension.yml` registers the `typst` format's `template-partials` (`typst-template.typ`, `typst-show.typ`) and a `filters` entry (`folium.lua`). Any `.qmd` selecting `format: folium-typst` pulls all of these in automatically.

Rendering pipeline for a document (e.g. `index.qmd`, `demo.qmd`):

1. **Pandoc filters** run first: `folium.lua` (wraps `.article`-classed divs in `#article[...]` raw Typst) and, for `demo.qmd`, `assets/custom.lua` (injects `quarto_version`/`current_date`/`current_year`/`current_time` into document metadata for the `{{< meta ... >}}` shortcodes) plus the vendored `fontawesome` extension (`{{< fa ... >}}` shortcodes → Typst FontAwesome calls).
2. **`typst-show.typ`** is the per-document entry point Pandoc generates into: it calls `#show: folium.with(...)`, translating the document's YAML frontmatter (`title`, `subtitle`, `description`, `date`, and everything under the `folium:` key — `class`, `id`, `investigator`/`pi`/`analyst` lists, `background`, `logo`, `logo-height`, `font-size`) into Typst function arguments via Pandoc's `$if$`/`$for$` template syntax.
3. **`typst-template.typ`** defines the actual `folium(...)` function and all supporting styling: color palette, heading/table/callout/badge styles, and the two-stage page layout — `setup-cover-page` (background image + logo, no header/footer) followed by `pagebreak()` into `setup-body-page` (numbered pages with an `id` header and page-count footer). It imports icon libraries from `assets/tabler/lib.typ` and `assets/fontawesome/lib.typ` (paths are relative to the rendering document, not the extension).

Key invariant: author roles (`investigator`, `pi`, `analyst`) are each a single object or list of up to ~3-4 objects with `name`/`email`/`org`; `folium(...)` computes `max-cols` from the longest role list and lays out all three roles in a matching grid, so an empty/missing role renders as a blank grid cell rather than reflowing the others.

Text passed into the cover page (title, subtitle, description, class, id, date, author fields) goes through `sanitize()` in `typst-template.typ`, which escapes literal `@` so emails/handles don't get parsed as Typst references — extend this function rather than escaping inline if new fields need similar treatment.

`assets/`, `fonts/`, and `.quartoignore` support the example/demo documents, not the extension itself — the extension only needs `_extensions/folium/` to function in a consuming project (see README "Usage": `quarto use template royfrancis/quarto-typst-folium`).

## General

Do not execute git. Leave it to the user to manage.
