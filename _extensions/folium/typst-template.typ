// typst-folium

// fontawesome
// https://github.com/duskmoon314/typst-fontawesome
#import "assets/fontawesome/lib.typ": *

// sanitize text values by escaping special characters
#let sanitize(value) = if value == none { [] } else {
  if type(value) == str {
    value.replace("@", "\\@")
  } else {
    value
  }
}

// accepts a color literal (color) or string (e.g., "#1D293D") and returns a usable color
#let parse-color(value, fallback) = {
  if value == none {
    return fallback
  }
  if type(value) == color {
    return value
  }
  if type(value) == str {
    let cleaned = value.replace("\\#", "#").trim()
    if cleaned.starts-with("#") {
      return rgb(cleaned)
    }
  }
  fallback
}

// colors
#let color-black-dark = rgb("#262626")
#let color-black-medium = rgb("#525252")
#let color-black-light = rgb("#A1A1A1")
#let color-black-lighter = rgb("#F5F5F5")

#let color-text = color-black-dark
#let color-code = rgb("#E4E4E7")
#let color-primary = rgb("#95B540")
#let color-secondary = rgb("#BDD775")
#let color-tertiary = rgb("#E9F2D1")

#let default-font-size = 11pt
#set text(font: "Lato", fill: color-text, size: default-font-size)
#set par(leading: 0.7em)

// badge
#let badge-primary(content) = box(
  fill: color-primary,
  inset: (x: 4pt, y: 4pt),
  baseline: 4pt,
  radius: 3pt,
  stroke: none,
  text(size: default-font-size * 0.8, weight: 600, fill: color-text, content),
)

#let badge-secondary(content) = box(
  fill: color-secondary,
  inset: (x: 4pt, y: 4pt),
  baseline: 4pt,
  radius: 3pt,
  stroke: none,
  text(size: default-font-size * 0.8, weight: 600, fill: color-text, content),
)

#let badge-tertiary(content) = box(
  fill: color-tertiary,
  inset: (x: 4pt, y: 4pt),
  baseline: 4pt,
  radius: 3pt,
  stroke: none,
  text(size: default-font-size * 0.8, weight: 600, fill: color-text, content),
)
#let badge = badge-secondary

// table
#show table.cell.where(y: 0): set text(weight: 700)
#let table-frame(width, color) = (x, y) => (
  left: (width + 1pt) + white,
  right: (width + 1pt) + white,
  top: if y < 2 { (width + 0.5pt) + color } else { 0pt },
  bottom: width + color,
)
#set table(
  fill: (_, y) => if calc.odd(y) { color-black-lighter },
  stroke: table-frame(0.5pt, color-black-light),
)

#let blockquote(body) = [
  #set text(size: 0.92em)
  #block(
    inset: (left: 1.5em, top: 0.2em, bottom: 0.2em),
    stroke: (left: 4pt + color-secondary),
  )[#body]
]

#let horizontalrule = line(
  length: 100%,
  stroke: 1pt + color-secondary,
)

// callout
#let callout(
  body: [],
  title: "Callout",
  background_color: color-tertiary,
  icon: none,
  icon_color: color-black-dark,
  body_background_color: white,
) = {
  block(
    breakable: false,
    fill: background_color,
    stroke: (paint: icon_color, thickness: 0.3pt),
    width: 100%,
    block(
      inset: 1pt,
      width: 100%,
      below: 0pt,
      block(
        fill: background_color,
        width: 100%,
        inset: 5pt,
      )[
        #box(pad(right: 0.2em, text(fill: icon_color, icon)))
        #text(weight: 700, fill: icon_color)[#title]
      ],
    )
      + if (body != []) {
        block(
          inset: 1pt,
          width: 100%,
          block(
            fill: body_background_color,
            width: 100%,
            inset: 8pt,
            body,
          ),
        )
      },
  )
}

// header/footer text style
#let hf = content => text(size: default-font-size * 0.8, fill: color-black-light, tracking: 0.08em, content)

// outline
#set outline(title: pad(bottom: 1em, "Contents"))

// cover page setup
#let setup-cover-page(
  background,
  logo,
  logo-height,
  content,
) = {
  let logo-block = if logo == none { none } else {
    context {
      let m = page.margin
      let margin-left = if m == auto { 2.5cm } else if type(m) == dictionary { m.at("left", default: 2.5cm) } else { m }
      let margin-top = if m == auto { 2.5cm } else if type(m) == dictionary { m.at("top", default: 2.5cm) } else { m }
      place(
        dx: margin-left,
        dy: margin-top,
        image(logo.path, height: logo-height),
      )
    }
  }

  set page(
    background: if background != none {
      place(center + top, image(background.path, height: 100%, width: 100%, fit: "cover"))
    },
    foreground: logo-block,
    footer: none,
  )

  content
}

// body page setup
#let setup-body-page(
  id,
  color-secondary,
  content,
) = {
  set page(
    number-align: right,
    foreground: none,
    header: if id != none {
      context {
        let idbox = box(hf(id))
        stack(
          dir: ttb,
          spacing: 1fr,
          align(right, rect(width: measure(idbox).width, height: 4pt, fill: color-secondary)),
          align(right, idbox),
        )
      }
    },
    footer: context align(right, hf([
      PAGE #counter(page).display("1/1", both: true)
    ])),
  )
  content
}

// folium definition
#let folium(
  class: none,
  title: none,
  subtitle: none,
  description: none,
  id: none,
  date: none,
  investigator: none,
  pi: none,
  analyst: none,
  background: none,
  logo: none,
  logo-height: 0.8cm,
  font-size: default-font-size,
  body,
) = {
  let font-size-base = font-size
  let font-size-h1 = font-size-base * 1.802
  let font-size-h2 = font-size-base * 1.602
  let font-size-h3 = font-size-base * 1.424
  let font-size-h4 = font-size-base * 1.266
  let font-size-h5 = font-size-base * 1.125
  let font-size-h6 = font-size-base

  let font-size-class = font-size-base * 1.1
  let font-size-footer = font-size-h6
  let font-size-title = font-size-h1 * 1.2
  let font-size-subtitle = font-size-h3
  let font-size-description = font-size-h5
  let font-size-id = font-size-h4
  let font-size-author-label = font-size-base * 0.8
  let font-size-author-value = font-size-base * 0.9

  show link: it => underline(text(fill: color-primary, it))
  show heading.where(level: 1): set text(size: font-size-h1, weight: 700, fill: color-text)
  show heading.where(level: 2): set text(size: font-size-h2, weight: 600, fill: color-text)
  show heading.where(level: 3): set text(size: font-size-h3, weight: 600, fill: color-text)
  show heading.where(level: 4): set text(size: font-size-h4, weight: 600, fill: color-text)
  show heading.where(level: 5): set text(size: font-size-h5, weight: 600, fill: color-text)
  show heading.where(level: 6): set text(size: font-size-h6, weight: 600, fill: color-text)
  show heading: it => {
    set block(below: 0.5em)
    it
  }

  // inline code styling (Pandoc emits inline code as raw, non-block elements)
  let inline-code = body => box(
    fill: rgb(color-code),
    inset: (x: 4pt, y: 4pt),
    baseline: 4pt,
    radius: 3pt,
    stroke: none,
    body,
  )

  show raw.where(block: false): it => inline-code(it)

  // top-block
  let top-block = pad(
    place(
      bottom,
      block(
        width: 100%,
        grid(
          columns: 1fr,
          row-gutter: 18pt,
          if class == none { [] } else {
            text(size: font-size-class, weight: 600, tracking: 0.12em, fill: color-text, sanitize(class))
          },
          if title == none { [] } else {
            pad(
              bottom: 5pt,
              text(size: font-size-title, weight: 600, fill: color-text, par(
                leading: font-size-title * 0.6,
                sanitize(title),
              )),
            )
          },
          if subtitle == none { [] } else {
            pad(
              bottom: 5pt,
              text(size: font-size-subtitle, weight: 600, fill: color-text, sanitize(subtitle)),
            )
          },
          if description == none { [] } else {
            pad(
              bottom: 5pt,
              text(size: font-size-description, fill: color-text, sanitize(description)),
            )
          }
        ),
      ),
    ),
  )

  // middle block
  let middle-block = {
    place(
      horizon + left,
      grid(
        columns: 1fr,
        row-gutter: if date != none { 10pt } else { 0pt },
        if id == none { [] } else { text(size: font-size-id, weight: 600, fill: color-text, sanitize(id)) },
        if date == none { [] } else { text(size: font-size-h5, weight: 500, fill: color-text, sanitize(date)) }
      ),
    )
  }

  let author = (label, name, email, org) => {
    if (label == none) and (name == none) and (email == none) and (org == none) { return [] }
    block(
      // fill: color-secondary,
      // radius: 4pt,
      // inset: 10pt,
      grid(
        columns: 1fr,
        row-gutter: 8pt,
        pad(
          bottom: 2pt,
          text(size: font-size-author-label, weight: 800, tracking: 0.08em, fill: color-black-light, upper(label)),
        ),
        par(
          leading: font-size-base * 0.5,
          text(size: font-size-author-value, fill: color-text, [
            #name \ #email \ #org
          ]),
        )
      ),
    )
  }

  let to-array(v) = if v == none { () } else if type(v) == array { v } else { (v,) }
  let max-cols = calc.max(1, to-array(investigator).len(), to-array(pi).len(), to-array(analyst).len())

  let role-block(role, persons) = if persons == none { [] } else {
    let people = to-array(persons)
    let person-blocks = people.map(person => author(
      role,
      sanitize(person.name),
      sanitize(person.email),
      sanitize(person.org),
    ))
    grid(
      columns: (1fr,) * max-cols,
      column-gutter: 8pt,
      row-gutter: 16pt,
      ..person-blocks
    )
  }

  let bottom-block = pad(
    place(
      top,
      block(
        grid(
          columns: 1fr,
          row-gutter: 25pt,
          role-block("Analyst", analyst),
          role-block("Investigator", investigator),
          role-block("Lead Investigator", pi),
        ),
      ),
    ),
  )

  // cover page
  setup-cover-page(
    background,
    logo,
    logo-height,
    place(
      horizon,
      grid(
        columns: 1fr,
        row-gutter: 50pt,
        top-block,
        middle-block,
        bottom-block,
      ),
    ),
  )

  // body content on new pages without background
  pagebreak()

  setup-body-page(
    id,
    color-secondary,
    body,
  )
}
