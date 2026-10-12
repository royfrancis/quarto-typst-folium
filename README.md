# quarto-typst-folium <span><a href="https://github.com/royfrancis/quarto-typst-folium"><img src="assets/favicon.png" style="height:30px;vertical-align:middle;"></a></span>

[![ci_badge](https://github.com/royfrancis/quarto-typst-folium/workflows/deploy/badge.svg)](https://github.com/royfrancis/quarto-typst-folium/actions?workflow=deploy)  

This is a Quarto extension that provides a Typst template for NBIS PDF reports. This is part of the Folium collection. For project website template, see [folium](https://github.com/royfrancis/folium) and for a single-page folium project report, see [folium-webpage](https://github.com/royfrancis/folium-webpage).

## Features

- Cover page with contributors grouped by role
- Customizable logo and background images
- Structured layout for NBIS reports
- Support for Font Awesome icons
  - See Font Awesome icons [here](https://fontawesome.com/search?ip=classic&ic=free-collection)

## Usage

Requires Quarto 1.8 or later. Install the extension:

```bash
# install as extension (for an existing folium project)
quarto add royfrancis/quarto-typst-folium
# install as template (for a new project, adds quarto project files)
quarto use template royfrancis/quarto-typst-folium
```

To use this extension, create a `.qmd` file and specify the format:

```yaml
format:
  folium-typst: default
```

## Configuration

The extension supplies the report layout and presentation defaults. Settings under `format.folium-typst` or `folium` override them.

The template supports the standard Quarto `title`, `subtitle`, `description` and `date` fields. Skip the `author` field as persons are specified under `nbis.contributors`.

Supply all NBIS-specific report data under `nbis`. The extension provides no defaults for this key:

```yaml
title: "Title"
subtitle: "Subtitle"
description: "Description"
date: "20 DEC 2025"

nbis:
  id: "5426"                   # Support issue ID
  contributors:
    - name: "Person A"
      email: "name@nbis.se"
      affiliation: "NBIS"
      roles: "NBIS Staff"
    - name: "Person B"
      email: "name@nbis.se"
      affiliation: "NBIS"
      roles: "NBIS Staff"
    - name: "Name"
      email: "name@email.com"
      affiliation: "Some university"
      roles: "User"
    - name: "Name"
      email: "name@email.com"
      affiliation: "Some university"
      roles: "Principal Investigator"
```

`name` is required. `email` is optional, while `affiliation` and `roles` each accept either a string or a list. Contributors without a role are grouped under `Contributor`. Role groups and people retain their order from the YAML.

The cover defaults to class `NBIS REPORT`, the bundled NBIS logo and background, a logo height of `0.8cm`, and a font size of `12pt`. Override only the presentation values you need under `folium`; every omitted value retains its extension default:

```yaml
folium:
  class: "NBIS PROJECT PLAN"
  logo:
    path: "path/to/logo.svg"
  logo-height: 1cm
  font-size: 11pt
  background:
    path: "path/to/bg.png"
```

To leave out the logo or the background image, set it to `false`:

```yaml
folium:
  logo: false
  background: false
```

Standard Quarto format options can override the extension defaults under `format.folium-typst`. Only the options you specify are changed. For example:

```yaml
format:
  folium-typst:
    papersize: us-letter
    columns: 2
    number-sections: false
    margin-left: 2cm
    margin-right: 2cm
```

To use a custom font:

```yaml
format:
  folium-typst:
    mainfont: "Lato"
    font-paths: assets/fonts  # add your own font directory here; merges with the extension's bundled fonts
```

## Documentation

See project website [here](https://royfrancis.github.io/quarto-typst-folium) for examples and documentation.

---

2026 • Roy Francis
