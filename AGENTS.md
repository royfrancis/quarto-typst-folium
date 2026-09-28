# AGENTS.md

A Quarto extension (`folium-typst` format) providing a Typst template for NBIS PDF reports: cover page with contributors grouped by role, logo, background image, FontAwesome icons.

## Commands

```bash
quarto render reports/demo.qmd   # exercises most markdown/Typst features
quarto render index.qmd          # minimal example matching the README
```

No build system, linter, or test suite — verify changes by rendering both and inspecting the PDF. Set `keep-typ: true` in a report's `format.folium-typst` key to also emit the intermediate `.typ` file, useful for seeing what the filters/template partials actually produced before Typst compiles it.

## Architecture

`_extensions/folium/_extension.yml` registers the `typst` format's `template-partials` (`typst-template.typ`, `typst-show.typ`), a `filters` entry (`folium.lua`), and a default `font-paths` pointing at the extension's own bundled fonts. Any `.qmd` with `format: folium-typst` pulls all of this in automatically — **the extension is self-contained under `_extensions/folium/`** (fonts and the FontAwesome Typst package live there too, not at the repo root), so it works whether installed via `quarto add` or `quarto use template`.

Rendering pipeline:

1. **`folium.lua`** runs first. It wraps inline Pandoc `Code` nodes in `#inline-code[...]`, wraps `.article`-classed divs in `#article[...]` raw Typst, and neutralizes any `Cite` AST nodes found in metadata back into literal `@id` text. Inline code must be wrapped at the AST boundary rather than with a global `show raw.where(block: false)` rule because Pandoc's `Skylighting` code blocks use non-block `raw` elements for individual tokens. Quarto parses metadata as Markdown, so a contributor email or `@mention` would otherwise be read as a pandoc citation and fail compilation when there's no bibliography. This only touches metadata; real citations in the document body are untouched.
2. **`typst-show.typ`** is the per-document entry point Pandoc generates into: it calls `#show: folium.with(...)`, translating YAML frontmatter (`title`, `subtitle`, `description`, `date`, `mainfont`, and everything under `nbis:` — `class`, `id`, `contributors`, `background`, `logo`, `logo-height`, `font-size`) into Typst function arguments.
3. **`typst-template.typ`** defines the `folium(...)` function and styling: color palette, heading/table/callout/badge styles, and the two-stage layout — `setup-cover-page` (background + logo) → `pagebreak()` → `setup-body-page` (numbered pages with an `id` header).

Key invariant: `nbis.contributors` is a list of objects with a required `name` and optional `email`, `affiliation`, and `roles`. `affiliation` and `roles` can each be a scalar or list. `folium(...)` groups contributors by role in first-seen order, defaults missing roles to `Contributor`, and computes a shared grid width from the largest role group.

Free-text fields (title, names, emails, etc.) don't need manual escaping in Typst — Pandoc already escapes them correctly for the target format when it substitutes `$var$`. Don't reintroduce a Typst-side `sanitize()`; it can't see raw strings by the time they reach `typst-template.typ` (they arrive as already-escaped Typst content), so it would be dead code.

`assets/` (background image, logo, site styling) is demo/site-only content — not required for the extension to function in a consuming project. Fonts and the vendored FontAwesome Typst package live under `_extensions/folium/` instead.

## General

Do not execute git. Leave it to the user to manage.
