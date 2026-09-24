# quarto-typst-folium

This is a Quarto extension that provides a Typst template for NBIS PDF reports.

## Features

- Cover page with detailed author roles (investigator, PI, analyst)
- Customizable logo and background images
- Structured layout for NBIS reports
- Support for FontAwesome icons
  - See fontawesome icons [here](https://fontawesome.com/search?ip=classic&ic=free-collection)

## Usage

Install the extension:

```bash
quarto use template royfrancis/quarto-typst-folium
```

To use this extension, create a `.qmd` file and specify the format:

```yaml
format:
  folium-typst: default
```

## Configuration

The template supports the standard Quarto `title`, `subtitle`, `description` and `date` fields. Skip the `author` field as persons are specified under the `folium` key.

Additional configuration is provided under the `folium` key:

```yaml
title: "Title"
subtitle: "Subtitle"
description: "Description"
date: "20 DEC 2025"

folium:
  id: "5426"                   # Support issue ID
  class: "REPORT"              # e.g., REPORT, PROJECT PLAN 
  logo: 
     path: "path/to/logo.svg"    # Path to the logo image
  background: 
     path: "path/to/bg.png"      # Path to the background image
     
  # Roles: investigator, pi, analyst
  # Each can be a single person or a list of persons.
  # Supports about 3-4 persons per role
  investigator:                 # Researchers involved
    - name: "Name"
      email: "email@example.com"
      org: "Organization"
    
  pi:                           # Principal Investigators
    - name: "PI Name"
      email: "pi@example.com"
      org: "Organization"
    
  analyst:                      # NBIS Bioinformaticians
    - name: "Analyst Name"
      email: "analyst@example.com"
      org: "Organization"
    - name: "Analyst Name"
      email: "analyst@example.com"
      org: "Organization"
    - name: "Analyst Name"
      email: "analyst@example.com"
      org: "Organization"
```

## Example

See `index.qmd` for a complete example.

## Acknowledgements

- Thanks to Typst packages for [FontAwesome icons](https://typst.app/universe/package/fontawesome/)

---

2026 • Roy Francis
