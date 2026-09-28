// typst-folium

// fontawesome
// https://github.com/duskmoon314/typst-fontawesome
#import "/_extensions/folium/assets/fontawesome/lib.typ": *

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

#let resource-path(path) = path.replace("\\", "")

// colors
#let color-black-dark = rgb("#262626")
#let color-black-medium = rgb("#525252")
#let color-black-light = rgb("#A1A1A1")
#let color-black-lighter = rgb("#F5F5F5")

#let color-text = color-black-dark
#let color-code = rgb("#E4E4E7")
#let color-caption = rgb("#496985")
#let color-callout-text = rgb("#1C2833")
#let color-callout-border = rgb("#C0C0C0")
#let color-primary = rgb("#95B540")
#let color-secondary = rgb("#BDD775")
#let color-tertiary = rgb("#E9F2D1")

#let default-font-size = 11pt
#let default-font = "Lato"
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

#show figure.caption: set text(size: 0.9em, fill: color-caption)

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

#let inline-code(content) = box(
  fill: color-code,
  inset: (x: 4pt, y: 1pt),
  radius: 3pt,
  stroke: none,
  content,
)

#let callout-svg(view-box, path) = image(
  bytes("<svg xmlns=\"http://www.w3.org/2000/svg\" fill=\"#1c2833\" viewBox=\"" + view-box + "\"><path d=\"" + path + "\"/></svg>"),
  height: 11pt,
)

#let callout-note-icon = callout-svg("0 0 512 512", "M256 512A256 256 0 1 0 256 0a256 256 0 1 0 0 512zM216 336h24V272H216c-13.3 0-24-10.7-24-24s10.7-24 24-24h48c13.3 0 24 10.7 24 24v88h8c13.3 0 24 10.7 24 24s-10.7 24-24 24H216c-13.3 0-24-10.7-24-24s10.7-24 24-24zm40-208a32 32 0 1 1 0 64 32 32 0 1 1 0-64z")
#let callout-tip-icon = callout-svg("0 0 384 512", "M272 384c9.6-31.9 29.5-59.1 49.2-86.2l0 0c5.2-7.1 10.4-14.2 15.4-21.4c19.8-28.5 31.4-63 31.4-100.3C368 78.8 289.2 0 192 0S16 78.8 16 176c0 37.3 11.6 71.9 31.4 100.3c5 7.2 10.2 14.3 15.4 21.4l0 0c19.8 27.1 39.7 54.4 49.2 86.2H272zM192 512c44.2 0 80-35.8 80-80V416H112v16c0 44.2 35.8 80 80 80zM112 176c0 8.8-7.2 16-16 16s-16-7.2-16-16c0-61.9 50.1-112 112-112c8.8 0 16 7.2 16 16s-7.2 16-16 16c-44.2 0-80 35.8-80 80z")
#let callout-warning-icon = callout-svg("0 0 512 512", "M256 512A256 256 0 1 0 256 0a256 256 0 1 0 0 512zm0-384c13.3 0 24 10.7 24 24V264c0 13.3-10.7 24-24 24s-24-10.7-24-24V152c0-13.3 10.7-24 24-24zM224 352a32 32 0 1 1 64 0 32 32 0 1 1 -64 0z")
#let callout-caution-icon = callout-svg("0 0 512 512", "M256 32c14.2 0 27.3 7.5 34.5 19.8l216 368c7.3 12.4 7.3 27.7.2 40.1S486.3 480 472 480H40c-14.3 0-27.6-7.7-34.7-20.1s-7-27.8 .2-40.1l216-368C228.7 39.5 241.8 32 256 32zm0 128c-13.3 0-24 10.7-24 24V296c0 13.3 10.7 24 24 24s24-10.7 24-24V184c0-13.3-10.7-24-24-24zm32 224a32 32 0 1 0 -64 0 32 32 0 1 0 64 0z")
#let callout-important-icon = callout-svg("0 0 512 512", "M416 398.9c58.5-41.1 96-104.1 96-174.9C512 100.3 397.4 0 256 0S0 100.3 0 224c0 70.7 37.5 133.8 96 174.9c0 .4 0 .7 0 1.1v64c0 26.5 21.5 48 48 48h48V464c0-8.8 7.2-16 16-16s16 7.2 16 16v48h64V464c0-8.8 7.2-16 16-16s16 7.2 16 16v48h48c26.5 0 48-21.5 48-48V400c0-.4 0-.7 0-1.1zM96 256a64 64 0 1 1 128 0A64 64 0 1 1 96 256zm256-64a64 64 0 1 1 0 128 64 64 0 1 1 0-128z")

#let callout-icon(icon, icon-color) = if icon == none {
  none
} else if icon-color == rgb("#0758E5") {
  callout-note-icon
} else if icon-color == rgb("#00A047") {
  callout-tip-icon
} else if icon-color == rgb("#FC5300") {
  callout-caution-icon
} else if icon-color == rgb("#EB9113") {
  callout-warning-icon
} else if icon-color == rgb("#CC1914") {
  callout-important-icon
} else {
  icon
}

// callout
#let callout(
  body: [],
  title: "Callout",
  background_color: color-tertiary,
  icon: none,
  icon_color: color-black-dark,
  body_background_color: white,
) = {
  let rendered-icon = callout-icon(icon, icon_color)
  block(
    breakable: false,
    fill: background_color,
    stroke: (paint: color-callout-border, thickness: 0.3pt),
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
        #if rendered-icon != none {
          box(pad(right: 0.3em, text(fill: icon_color, rendered-icon)))
        }
        #text(weight: 700, fill: color-callout-text)[#title]
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

#let single-column(body) = {
  set page(columns: 1)
  body
}

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
        image(resource-path(logo.path), height: logo-height),
      )
    }
  }

  set page(
    columns: 1,
    background: if background != none {
      place(center + top, image(resource-path(background.path), height: 100%, width: 100%, fit: "cover"))
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
  contributors: none,
  background: none,
  logo: none,
  logo-height: 0.8cm,
  font-size: default-font-size,
  mainfont: default-font,
  body,
) = {
  set text(font: mainfont, fill: color-text, size: font-size)

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

  // top-block
  let top-items = (
    if class == none { none } else {
      text(size: font-size-class, weight: 600, tracking: 0.12em, fill: color-text, class)
    },
    if title == none { none } else {
      pad(
        bottom: 5pt,
        text(size: font-size-title, weight: 600, fill: color-text, par(
          leading: font-size-title * 0.6,
          title,
        )),
      )
    },
    if description == none { none } else {
      pad(
        bottom: 5pt,
        text(size: font-size-description, fill: color-text, description),
      )
    },
  ).filter(it => it != none)

  let top-block = pad(
    place(
      bottom,
      block(
        width: 100%,
        grid(
          columns: 1fr,
          row-gutter: 18pt,
          ..top-items
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
        row-gutter: if (subtitle != none) and (date != none) { 10pt } else { 0pt },
        if subtitle == none { [] } else { text(size: font-size-subtitle, weight: 600, fill: color-text, subtitle) },
        if date == none { [] } else { text(size: font-size-h5, weight: 500, fill: color-text, date) }
      ),
    )
  }

  let to-array(v) = if v == none { () } else if type(v) == array { v } else { (v,) }

  let contributor = person => {
    let name = person.at("name", default: none)
    let email = person.at("email", default: none)
    let affiliations = to-array(person.at("affiliation", default: none))
    let details = (
      if name == none { none } else { text(weight: 600, name) },
      email,
      ..affiliations,
    ).filter(it => it != none)

    block(
      par(
        leading: font-size-base * 0.5,
        text(
          size: font-size-author-value,
          fill: color-text,
          details.join(linebreak()),
        ),
      ),
    )
  }

  let people = to-array(contributors).filter(person => person.at("name", default: none) != none)
  let contributor-roles(person) = {
    let roles = to-array(person.at("roles", default: none))
    if roles.len() == 0 { ([Contributor],) } else { roles }
  }
  let role-order = people.fold((), (roles, person) => {
    contributor-roles(person).fold(roles, (roles, role) => {
      if roles.contains(role) { roles } else { roles + (role,) }
    })
  })
  let role-people(role) = people.filter(person => contributor-roles(person).contains(role))
  let max-cols = calc.max(1, ..role-order.map(role => role-people(role).len()))

  let role-block(role) = {
    let person-blocks = role-people(role).map(contributor)
    grid(
      columns: 1fr,
      row-gutter: 10pt,
      text(
        size: font-size-author-label,
        weight: 800,
        tracking: 0.08em,
        fill: color-black-light,
        upper(role),
      ),
      grid(
        columns: (1fr,) * max-cols,
        column-gutter: 8pt,
        row-gutter: 16pt,
        ..person-blocks,
      ),
    )
  }

  let bottom-block = pad(
    place(
      top,
      block(
        grid(
          columns: 1fr,
          row-gutter: 25pt,
          ..role-order.map(role-block),
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
