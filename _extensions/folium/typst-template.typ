// typst-folium
// (fontawesome is imported in typst-show.typ)

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
#let color-callout-border = rgb("#DEE2E6")
#let color-primary = rgb("#95B540") // accent: borders, highlights, decoration
#let color-primary-strong = rgb("#567318") // text and fills, 5.4:1 against white
#let color-secondary = rgb("#BDD775")
#let color-tertiary = rgb("#E9F2D1")
#let color-tertiary-light = rgb("#F4F8E8")

// corner radius, used by callouts, code blocks and block quotes
#let corner-radius = 4.5pt

#let default-font-size = 12pt
#let default-font = "Lato"
#set par(leading: 0.7em)

// badge
#let badge-primary(content) = box(
  fill: color-primary,
  inset: (x: 4pt, y: 4pt),
  baseline: 4pt,
  radius: 3pt,
  stroke: none,
  text(size: 0.8em, weight: 600, fill: color-text, content),
)

#let badge-secondary(content) = box(
  fill: color-secondary,
  inset: (x: 4pt, y: 4pt),
  baseline: 4pt,
  radius: 3pt,
  stroke: none,
  text(size: 0.8em, weight: 600, fill: color-text, content),
)

#let badge-tertiary(content) = box(
  fill: color-tertiary,
  inset: (x: 4pt, y: 4pt),
  baseline: 4pt,
  radius: 3pt,
  stroke: none,
  text(size: 0.8em, weight: 600, fill: color-text, content),
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

// Pandoc emits block quotes as #quote(block: true)[...]
#show quote.where(block: true): it => block(
  width: 100%,
  inset: (x: 1.25em, y: 0.75em),
  fill: color-tertiary-light,
  radius: (left: 0pt, right: corner-radius),
  stroke: (left: 0.25em + color-primary),
  text(size: 0.92em, it.body),
)

// Code blocks. Quarto's raw block rule sets a 2pt radius, which this overrides.
// Pandoc's highlighting definitions (`Skylighting`) pass the same 2pt radius to
// the block explicitly, and a `set` rule does not override an explicit
// argument, so that block is rebuilt with the corner radius.
#show raw.where(block: true): set block(radius: corner-radius)
#show block.where(radius: 2pt): it => {
  let fields = it.fields()
  let body = fields.remove("body")
  fields.radius = corner-radius
  // `below` is a synthesized field, see `block_with_new_content` in definitions.typ
  let below = fields.at("below", default: auto)
  if below == auto {
    let _ = fields.remove("below", default: none)
  } else {
    fields.below = below.abs
  }
  block.with(..fields)(body)
}

#let horizontalrule = line(
  length: 100%,
  stroke: 1pt + color-secondary,
)

// Inline code. `highlight` is used rather than `box` because a box cannot
// break across lines: a long span would jump to the next line as a unit and
// leave a gap, and trailing punctuation would land beside its first line.
// `highlight` only paints behind the text and reserves no space, so the
// padding is real horizontal space (`h`) outside plus an equal `extent`.
#let inline-code(content) = {
  h(3pt)
  highlight(fill: color-code, radius: 3pt, extent: 3pt, content)
  h(3pt)
}

// Callout icons are Font Awesome Free 6.5.1 (CC BY 4.0,
// https://fontawesome.com/license/free), the important icon is custom. Each is
// drawn in the color of its callout.
#let callout-icon-height = 11pt
#let callout-svg(color, view-box, path, fill-rule: "nonzero") = image(
  bytes("<svg xmlns=\"http://www.w3.org/2000/svg\" fill=\"" + color.to-hex() + "\" viewBox=\"" + view-box + "\"><path fill-rule=\"" + fill-rule + "\" d=\"" + path + "\"/></svg>"),
  height: callout-icon-height,
)

#let callout-note-icon(color) = callout-svg(color, "0 0 512 512", "M256 512A256 256 0 1 0 256 0a256 256 0 1 0 0 512zM216 336h24V272H216c-13.3 0-24-10.7-24-24s10.7-24 24-24h48c13.3 0 24 10.7 24 24v88h8c13.3 0 24 10.7 24 24s-10.7 24-24 24H216c-13.3 0-24-10.7-24-24s10.7-24 24-24zm40-208a32 32 0 1 1 0 64 32 32 0 1 1 0-64z")
#let callout-tip-icon(color) = callout-svg(color, "0 0 384 512", "M272 384c9.6-31.9 29.5-59.1 49.2-86.2l0 0c5.2-7.1 10.4-14.2 15.4-21.4c19.8-28.5 31.4-63 31.4-100.3C368 78.8 289.2 0 192 0S16 78.8 16 176c0 37.3 11.6 71.9 31.4 100.3c5 7.2 10.2 14.3 15.4 21.4l0 0c19.8 27.1 39.7 54.4 49.2 86.2H272zM192 512c44.2 0 80-35.8 80-80V416H112v16c0 44.2 35.8 80 80 80zM112 176c0 8.8-7.2 16-16 16s-16-7.2-16-16c0-61.9 50.1-112 112-112c8.8 0 16 7.2 16 16s-7.2 16-16 16c-44.2 0-80 35.8-80 80z")
#let callout-warning-icon(color) = callout-svg(color, "0 0 512 512", "M256 512A256 256 0 1 0 256 0a256 256 0 1 0 0 512zm0-384c13.3 0 24 10.7 24 24V264c0 13.3-10.7 24-24 24s-24-10.7-24-24V152c0-13.3 10.7-24 24-24zM224 352a32 32 0 1 1 64 0 32 32 0 1 1 -64 0z")
#let callout-caution-icon(color) = callout-svg(color, "0 0 512 512", "M256 32c14.2 0 27.3 7.5 34.5 19.8l216 368c7.3 12.4 7.3 27.7.2 40.1S486.3 480 472 480H40c-14.3 0-27.6-7.7-34.7-20.1s-7-27.8 .2-40.1l216-368C228.7 39.5 241.8 32 256 32zm0 128c-13.3 0-24 10.7-24 24V296c0 13.3 10.7 24 24 24s24-10.7 24-24V184c0-13.3-10.7-24-24-24zm32 224a32 32 0 1 0 -64 0 32 32 0 1 0 64 0z")
// the exclamation mark is a hole in the square, which needs the even-odd rule
#let callout-important-icon(color) = callout-svg(color, "0 0 512 512", "M64 0h384a64 64 0 0 1 64 64v384a64 64 0 0 1-64 64H64a64 64 0 0 1-64-64V64A64 64 0 0 1 64 0zM256 112a32 32 0 0 1 32 32v128a32 32 0 0 1-64 0V144a32 32 0 0 1 32-32zM256 336a40 40 0 1 1 0 80a40 40 0 1 1 0-80z", fill-rule: "evenodd")

// The callout type is recognised by the color Quarto passes as `icon_color`.
// As in styles.scss, the note follows the brand and the other types keep their
// colors; the icon and the title take the type color shifted 10% toward black,
// and the note header is the brand color tinted 90% toward white.
#let callout-types = (
  note: (quarto-color: rgb("#0758E5"), icon: callout-note-icon),
  tip: (quarto-color: rgb("#00A047"), icon: callout-tip-icon),
  caution: (quarto-color: rgb("#FC5300"), icon: callout-caution-icon),
  warning: (quarto-color: rgb("#EB9113"), icon: callout-warning-icon),
  important: (quarto-color: rgb("#CC1914"), icon: callout-important-icon),
)

#let callout-icon-scale = 10%
#let callout-header-scale = 90%
#let shade-color(c, amount) = color.mix((black, amount), (c, 100% - amount), space: rgb)
#let tint-color(c, amount) = color.mix((white, amount), (c, 100% - amount), space: rgb)

#let callout-type(icon-color) = {
  let hit = callout-types.pairs().find(pair => pair.last().quarto-color == icon-color)
  if hit == none { none } else { hit.first() }
}

// Gap between a callout icon and its title or body.
#let callout-icon-gap = 0.35em

// The icon sits in a slot as wide as it is tall, so a title starts at the same
// place whatever the proportions of the icon, and is centered on the cap
// height of the text beside it. Text lines are only as tall as the cap height
// (8.6pt for Lato at 12pt), so an icon aligned to the baseline would stand
// above the text's center.
#let callout-icon-box(icon) = context {
  let cap = measure([H]).height
  box(
    width: callout-icon-height + callout-icon-gap,
    baseline: (callout-icon-height - cap) / 2,
    box(width: callout-icon-height, align(center, icon)),
  )
}

// Quarto passes a default title as `[\nNote\n]`; the leading space would widen
// the gap after the icon, so spaces at either end are dropped. The result is
// still plain content, and an empty title is left as it is.
#let trim-title(title) = {
  if type(title) != content or not title.has("children") { return title }
  let parts = title.children
  while parts.len() > 0 and parts.first().func() == [ ].func() { parts = parts.slice(1) }
  while parts.len() > 0 and parts.last().func() == [ ].func() { parts = parts.slice(0, -1) }
  if parts.len() == 0 { title } else { parts.join() }
}

// callout
//
// Quarto's cross-reference show rule (definitions.typ) rebuilds callouts that
// have an id by position: the title block must hold the icon (optional) and
// the title as its only children, and the title must be plain content, because
// Quarto's `empty()` helper reads a styled element as an empty title. The bold
// title style is therefore applied by a show rule on the title block, marked
// with an imperceptible corner radius that nothing else uses, instead of
// wrapping the title in `text()`. Quarto copies the block's fields when it
// rebuilds it, so the marker survives. For the same reason the title color
// travels on the title block as the paint of an invisible zero-width stroke,
// which the show rule reads back.
#let callout-title-marker = 0.01pt
#show block.where(radius: callout-title-marker): it => {
  set text(weight: 700, fill: it.stroke.paint)
  it
}

#let callout(
  body: [],
  title: "Callout",
  background_color: color-tertiary,
  icon: none,
  icon_color: color-black-dark,
  body_background_color: white,
) = {
  let kind = callout-type(icon_color)
  let is-note = kind == "note"
  let accent = if is-note { color-primary } else { icon_color }
  let header-color = if is-note { tint-color(color-primary, callout-header-scale) } else { background_color }
  // a callout of an unknown type, such as the generic one, has no type color
  let tone = if kind == none { color-callout-text } else { shade-color(accent, callout-icon-scale) }
  let rendered-icon = if icon == none {
    none
  } else if kind == none {
    icon
  } else {
    (callout-types.at(kind).icon)(tone)
  }
  block(
    breakable: false,
    fill: header-color,
    stroke: 0.75pt + color-callout-border,
    radius: corner-radius,
    clip: true,
    width: 100%,
    block(
      inset: 1pt,
      width: 100%,
      below: 0pt,
      // Icon and title are adjacent, with no whitespace between them.
      block(
        fill: header-color,
        stroke: 0pt + tone,
        width: 100%,
        inset: 5pt,
        radius: callout-title-marker,
      )[#if rendered-icon != none {
          callout-icon-box(text(fill: tone, rendered-icon))
        }#trim-title(title)],
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

// A simple callout has no header: the icon and the body text sit side by side,
// all in the text color, inside the same border as the other callouts. A title,
// when there is one, takes a bold line with the icon above the body. Quarto's
// Typst writer does not pass the appearance on, so folium-callout.lua calls
// this for simple and minimal callouts (no icon: only the body).
#let callout-simple(kind: none, icon: true, title: none, body: []) = {
  let drawn = if icon and kind != none and kind in callout-types {
    (callout-types.at(kind).icon)(color-text)
  }
  block(
    breakable: false,
    stroke: 0.75pt + color-callout-border,
    radius: corner-radius,
    // the site pads 0.4em and adds 0.25rem above the first line and 0.5em below the last
    inset: (x: 0.7em, y: 0.65em),
    width: 100%,
    if title != none {
      // the body is indented to start under the title text, past the icon
      block(
        below: 0.5em,
        text(weight: 700)[#if drawn != none { callout-icon-box(drawn) }#trim-title(title)],
      ) + pad(left: if drawn != none { callout-icon-height + callout-icon-gap } else { 0pt }, body)
    } else if drawn != none {
      context {
        let cap = measure([H]).height
        grid(
          columns: (callout-icon-height + callout-icon-gap, 1fr),
          // raised so its center is the center of the first line, which is only as tall as the cap height
          move(dy: (cap - callout-icon-height) / 2, box(width: callout-icon-height, align(center, drawn))),
          body,
        )
      }
    } else {
      body
    },
  )
}

// header/footer text style
#let hf = content => text(size: 0.8em, fill: color-black-light, tracking: 0.08em, content)

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
      // A margin is a single length, auto, or a dictionary that may use any of
      // left/right/top/bottom, x/y, inside/outside or rest. Take the first key
      // present, in order of precedence.
      let margin-side(keys) = {
        if type(m) != dictionary { return if m == auto { 2.5cm } else { m } }
        let key = keys.find(k => k in m)
        if key == none or m.at(key) == auto { 2.5cm } else { m.at(key) }
      }
      let margin-left = margin-side(("left", "inside", "x", "rest"))
      let margin-top = margin-side(("top", "y", "rest"))
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
  lang: "en",
  region: none,
  sectionnumbering: none,
  body,
) = {
  set document(title: title)
  set text(font: mainfont, fill: color-text, size: font-size, lang: lang, region: region)
  set heading(numbering: sectionnumbering)

  let font-size-base = font-size
  let font-size-h1 = font-size-base * 1.802
  let font-size-h2 = font-size-base * 1.602
  let font-size-h3 = font-size-base * 1.424
  let font-size-h4 = font-size-base * 1.266
  let font-size-h5 = font-size-base * 1.125
  let font-size-h6 = font-size-base

  let font-size-class = font-size-base * 1.1
  let font-size-title = font-size-h1 * 1.2
  let font-size-subtitle = font-size-h3
  let font-size-description = font-size-h5
  let font-size-author-label = font-size-base * 0.8
  let font-size-author-value = font-size-base * 0.9

  show link: it => underline(text(fill: color-primary-strong, it))
  show heading.where(level: 1): set text(size: font-size-h1, weight: 700, fill: color-text)
  show heading.where(level: 2): set text(size: font-size-h2, weight: 700, fill: color-text)
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
