// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subrefnumbering: "1a",
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => numbering(subrefnumbering, n-super, quartosubfloatcounter.get().first() + 1))
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => {
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          }

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}

// typst-folium

// tabler icons
// https://typst.app/universe/package/use-tabler-icons/
#import "assets/tabler/lib.typ": *
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
#import "@preview/fontawesome:0.5.0": *

#set page(
  paper: "a4",
  margin: (x: 1.25in, y: 1.25in),
  numbering: "1",
)

#show: folium.with(
      class: [TECHNICAL REPORT],
  
      title: [Demo Report],
  
      subtitle: [Demo report],
  
      description: [This document showcases some of the in-built capabilities of quarto. It also shows the custom theme, style and usage.],
  
      id: [NBIS SUPPORT 0000],
  
      date: [18 Dec 2025],
  
      investigator: (
              (
          name: [John Doe],
          email: [john.doe\@email.com],
          org: [Some university],
        ),
              (
          name: [Jane Doe],
          email: [jane.doe\@email.com],
          org: [Another university],
        ),
              (
          name: [Jane Doe],
          email: [jane.doe\@email.com],
          org: [Another university],
        ),
          ),
  
      pi: (
              (
          name: [John Doe],
          email: [john.doe\@email.com],
          org: [Some university],
        ),
              (
          name: [Jane Doe],
          email: [jane.doe\@email.com],
          org: [Another university],
        ),
          ),
  
      analyst: (
              (
          name: [John Doe],
          email: [john.doe\@email.com],
          org: [Some university],
        ),
              (
          name: [Jane Doe],
          email: [jane.doe\@email.com],
          org: [Another university],
        ),
          ),
  
      background: (
      path: "assets/bg.png"
    ), 
  
      logo: (
      path: "assets/nbis-scilifelab.svg"
    ), 
  
      logo-height: 0.8cm,
  
      font-size: 12pt,
  )

#outline()

#pagebreak()

= Introduction
<introduction>
This is a #link("https://quarto.org/")[quarto] document that is rendered through typst into a PDF document. Working with Typst in Quarto is covered #link("https://quarto.org/docs/output-formats/typst.html")[here];. You can mostly use markdown syntax to author your document. This demo document showcases some of the common formatting options available in markdown along with some typst specific features. For some features and more control, typst code is used.

The outline at the beginning of the document is generated using the typst function #raw("`#outline()`{=typst}");. A page break is added using #raw("`#pagebreak()`{=typst}");.

= Text formatting
<text-formatting>
== Headings
<headings>
```
## Level 2 heading  
### Level 3 heading  
#### Level 4 heading  
##### Level 5 heading  
###### Level 6 heading
```

== Character styles
<character-styles>
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Markdown], [Rendered],),
  table.hline(),
  [`__Bold text__`], [#strong[Bold text];],
  [`_Italic text_`], [#emph[Italic text];],
  [`~~Strikethrough~~`], [#strike[Strikethrough];],
  [`H~2~O`], [H#sub[2];O],
  [`x^2^`], [x#super[2];],
  [`--`], [--],
  [`---`], [---],
  [`[link](r-project.org)`], [#link("r-project.org")[link];],
)
Here is how to add formatting using typst functions:

#table(
  columns: (50%, 50%),
  align: (auto,auto,),
  table.header([Typst], [Rendered],),
  table.hline(),
  [#raw("`#underline[text]`{=typst}");], [#underline[text]],
  [#raw("`#highlight[text]`{=typst}");], [#highlight[text]],
  [#raw("`H#sub[2]O`{=typst}");], [H#sub[2]O],
  [#raw("`x#super[2]`{=typst}");], [x#super[2]],
  [#raw("`#badge([badge])`{=typst}");], [#badge([badge])],
  [#raw("`#badge-primary([badge])`{=typst}");], [#badge-primary([badge])],
  [#raw("`#badge-secondary([badge])`{=typst}");], [#badge-secondary([badge])],
  [#raw("`#badge-tertiary([badge])`{=typst}");], [#badge-tertiary([badge])],
)
Here is a rectangle #raw("`#rect(width: 1cm)`{=typst}")

#rect(width: 1cm)

Let's generate some random text #raw("`#lorem(10)`{=typst}")

#lorem(10)

This text has a citation #cite(<example2024>, form: "prose");. The bibliography is listed at the end of the document.

== Blockquote
<blockquote>
```
> This is a block quote. This
> paragraph has two lines.
>
> 1. This is a list inside a block quote.
> 2. Second item.
```

#quote(block: true)[
This is a block quote. This paragraph has two lines.

+ This is a list inside a block quote.
+ Second item.
]

== Line block
<line-block>
Line block preserves spaces and new lines.

```
| This
|     block
|          preserves
|                   formatting
```

This \
~~~~block \
~~~~~~~~~preserves \
~~~~~~~~~~~~~~~~~~formatting

== Rule
<rule>
A horizontal line can be created using three or more `*` or `-`.

`***`

#horizontalrule

== Footnote
<footnote>
An example of footnote reference #footnote[That reference refers to this footnote.]

= Code formatting
<code-formatting>
Verbatim code is text formatted using monospaced font intended as code. Verbatim code can be defined inline where #raw("`date()`") looks like `date()`.

Code can also be defined inside code blocks.

````
```
date()
```
````

```
date()
```

Source code, ie; code that is highlighted or executed in a quarto document is not covered here.

= Lists
<lists>
== Unordered
<unordered>
Unordered lists are created using dashes.

#block[
#block[
```
- Bullet 1
- Bullet 2
  - Sub-bullet 2.1
  - Sub-bullet 2.2
- Bullet 3
```

]
#block[
- Bullet 1
- Bullet 2
  - Sub-bullet 2.1
  - Sub-bullet 2.2
- Bullet 3

]
]
== Ordered
<ordered>
Ordered lists are created using numbers.

#block[
#block[
```
1. Point 1
2. Point 2
3. Point 3
```

]
#block[
+ Point 1
+ Point 2
+ Point 3

]
]
== Multiple Lists
<multiple-lists>
#block[
#block[
```
::: {}
1. Point 1
2. Point 2
:::

:::{}
1. Point 1
2. Point 2
:::
```

]
#block[
#block[
+ Point 1
+ Point 2

]
#block[
+ Point 1
+ Point 2

]
]
]
= Images
<images>
Images can be inserted using plain markdown or HTML directly. Plain markdown can be embellished with custom quarto adjustments to modify aspects of the image. Clicking the image opens the image in a lightbox.

== Using Markdown
<using-markdown>
Using regular markdown.

```
![](assets/typst.png)
```

#box(image("assets/typst.png"))

The dimensions are based on image and/or fill up the entire available space. You can control the dimension as shown below.

```
![This is a caption](assets/typst.png){width=30%}  
```

#figure([
#box(image("assets/typst.png", width: 30.0%))
], caption: figure.caption(
position: bottom, 
[
This is a caption
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)


This image above is now 30% of it's original width.

=== Figure layout
<figure-layout>
```
::: {#fig-mylabel layout-ncol=2}
![Caption for figure 1](assets/typst.png){width="40%"}

![Caption for figure 2](assets/typst.png){width="40%"}

These figures are interesting.
:::
```

#quarto_super(
kind: 
"quarto-float-fig"
, 
caption: 
[
These figures are interesting.
]
, 
label: 
<fig-mylabel>
, 
position: 
bottom
, 
supplement: 
"Figure"
, 
subrefnumbering: 
"1a"
, 
subcapnumbering: 
"(a)"
, 
[
#grid(columns: 2, gutter: 2em,
  [
#block[
#figure([
#box(image("assets/typst.png", width: 40.0%))
], caption: figure.caption(
position: bottom, 
[
Caption for figure 1
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)


]
],
  [
#block[
#figure([
#box(image("assets/typst.png", width: 40.0%))
], caption: figure.caption(
position: bottom, 
[
Caption for figure 2
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)


]
],
)
]
)
More figure options and layouts are described #link("https://quarto.org/docs/authoring/figures.html")[here];. Cross referencing described #link("https://quarto.org/docs/authoring/cross-references.html")[here];.

== Using Typst
<using-typst>
````
```{=typst} 
#image("assets/typst.png", width: 30%)
```
````

#image("assets/typst.png", width: 30%)
````
```{=typst} 
#figure(
  image("assets/typst.png", width: 30%),
  caption: [This is the typst logo.]
)
```
````

#figure(
  image("assets/typst.png", width: 30%),
  caption: [This is the typst logo.]
)
For more information on figures, see #link("https://quarto.org/docs/authoring/figures.html")[here];. Images generated through code is not covered here.

= Math expressions
<math-expressions>
Some examples of rendering equations.

```
$e^{i\pi} + 1 = 0$
```

$e^(i pi) + 1 = 0$

```
$$\frac{E \times X^2 \prod I}{2+7} = 432$$
```

$ frac(E times X^2 product I, 2 + 7) = 432 $

```
$$\sum_{i=1}^n X_i$$
```

$ sum_(i = 1)^n X_i $

```
$$\int_0^{2\pi} \sin x~dx$$
```

$ integral_0^(2 pi) sin x med d x $

```
$\left( \sum_{i=1}^{n}{i} \right)^2 = \left( \frac{n(n-1)}{2}\right)^2 = \frac{n^2(n-1)^2}{4}$
```

$(sum_(i = 1)^n i)^2 = (frac(n (n - 1), 2))^2 = frac(n^2 (n - 1)^2, 4)$

```
$\begin{eqnarray} X & \sim & \mathrm{N}(0,1)\\ Y & \sim & \chi^2_{n-p}\\ R & \equiv & X/Y \sim t_{n-p} \end{eqnarray}$
```

$X & tilde.op & upright(N) (0 \, 1)\
Y & tilde.op & chi_(n - p)^2\
R & equiv & X \/ Y tilde.op t_(n - p)$

```
$\begin{eqnarray} P(|X-\mu| > k) & = & P(|X-\mu|^2 > k^2)\\ & \leq & \frac{\mathbb{E}\left[|X-\mu|^2\right]}{k^2}\\ & \leq & \frac{\mathrm{Var}[X]}{k^2} \end{eqnarray}$
```

$P (lr(|X - mu|) > k) & = & P (lr(|X - mu|)^2 > k^2)\
 & lt.eq & frac(bb(E) [lr(|X - mu|)^2], k^2)\
 & lt.eq & frac(upright(V a r) [X], k^2)$

= Tables
<tables>
For simple cases, tables can be manually created in markdown.

```
|speed|dist|
|-----|----|
|4    |   2|
|4    |  10|
|7    |   4|
```

#table(
  columns: 2,
  align: (auto,auto,),
  table.header([speed], [dist],),
  table.hline(),
  [4], [2],
  [4], [10],
  [7], [4],
)
Table caption and numbering can be added as such:

```
|speed|dist|
|-----|----|
|4    |   2|
|4    |  10|
|7    |   4|

: These are exciting results. {#tbl-mylabel}
```

#figure([
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([speed], [dist],),
  table.hline(),
  [4], [2],
  [4], [10],
  [7], [4],
)
], caption: figure.caption(
position: top, 
[
These are exciting results.
]), 
kind: "quarto-float-tbl", 
supplement: "Table", 
)
<tbl-mylabel>


Tables can also be generated through code which is not covered here.

More information about #link("https://quarto.org/docs/authoring/tables.html")[tables];.

= Icons
<icons>
== Fontawesome
<fontawesome>
To use #link("https://fontawesome.com/search?m=free")[fontawesome] icons as shortcodes, quarto extension #link("https://github.com/quarto-ext/fontawesome")[fontawesome] needs to be installed.

Icons can be placed using shortcodes.

`{{< fa lightbulb >}}` \
`{{< fa exclamation >}}` \
`{{< fa clipboard-list >}}` \
`{{< fa comments >}}` \
`{{< fa desktop >}}` \
`{{< fa cloud >}}` \
`{{< fa check >}}` \
`{{< fa times >}}` \
`{{< fa skull >}}` \
`{{< fa skull size=2x >}}` \
`{{< fa brands github >}}`

== FontAwesome icons
<fontawesome-icons>
#link("https://fontawesome.com/search?ip=classic&ic=free-collection")[FontAwesome icons] are made available in this template. FA6 and FA7 are supported. For more details on the Typst package that enables this, see #link("https://typst.app/universe/package/fontawesome/")[here];.

#table(
  columns: (37.5%, 62.5%),
  align: (auto,center,),
  table.header([Typst], [Rendered],),
  table.hline(),
  [#raw("`#fa-icon(\"lightbulb\")`{=typst}");], [#fa-icon("lightbulb")],
  [#raw("`#fa-icon(\"lightbulb\", solid:true)`{=typst}");], [#fa-icon("lightbulb", solid:true)],
  [#raw("`#fa-icon(\"laptop\")`{=typst}");], [#fa-icon("laptop")],
  [#raw("`#fa-icon(\"cloud\")`{=typst}");], [#fa-icon("cloud")],
  [#raw("`#fa-icon(\"github\")`{=typst}");], [#fa-icon("github")],
  [#raw("`#fa-icon(\"exclamation-circle\", size:15pt)`{=typst}");], [#fa-icon("exclamation-circle", size:15pt)],
)
== Tabler icons
<tabler-icons>
#link("https://tabler.io/icons")[Tabler icons] are made available in this template. For more details on the Typst package that enables this, see #link("https://typst.app/universe/package/use-tabler-icons/")[here];.

#table(
  columns: (37.5%, 62.5%),
  align: (auto,center,),
  table.header([Typst], [Rendered],),
  table.hline(),
  [#raw("`#tabler-icon(\"calendar\")`{=typst}");], [#tabler-icon("calendar")],
  [#raw("`#tabler-icon(\"brand-github\")`{=typst}");], [#tabler-icon("brand-github")],
  [#raw("`#tabler-icon(\"map-pin\")`{=typst}");], [#tabler-icon("map-pin")],
  [#raw("`#tabler-icon(\"location\")`{=typst}");], [#tabler-icon("location")],
  [#raw("`#tabler-icon(\"brand-mastodon\")`{=typst}");], [#tabler-icon("brand-mastodon")],
  [#raw("`#tabler-icon(\"mail\")`{=typst}");], [#tabler-icon("mail")],
  [#raw("`#text(size:20pt,tabler-icon(\"calendar\", fill:blue))`{=typst}");], [#text(size:20pt,tabler-icon("calendar", fill:blue))],
)
= Call-Outs
<call-outs>
Call-Out blocks are explained #link("https://quarto.org/docs/authoring/callouts.html")[here];.

```
::: {.callout-note}
This is a call-out.
:::

::: {.callout-warning}
This is a call-out.
:::

::: {.callout-important}
This is a call-out.
:::

::: {.callout-tip}
This is a call-out.
:::

::: {.callout-caution}
This is a call-out.
:::
```

#block[
#callout(
body: 
[
This is a call-out.

]
, 
title: 
[
Note
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
, 
body_background_color: 
white
)
]
#block[
#callout(
body: 
[
This is a call-out.

]
, 
title: 
[
Warning
]
, 
background_color: 
rgb("#fcefdc")
, 
icon_color: 
rgb("#EB9113")
, 
icon: 
fa-exclamation-triangle()
, 
body_background_color: 
white
)
]
#block[
#callout(
body: 
[
This is a call-out.

]
, 
title: 
[
Important
]
, 
background_color: 
rgb("#f7dddc")
, 
icon_color: 
rgb("#CC1914")
, 
icon: 
fa-exclamation()
, 
body_background_color: 
white
)
]
#block[
#callout(
body: 
[
This is a call-out.

]
, 
title: 
[
Tip
]
, 
background_color: 
rgb("#ccf1e3")
, 
icon_color: 
rgb("#00A047")
, 
icon: 
fa-lightbulb()
, 
body_background_color: 
white
)
]
#block[
#callout(
body: 
[
This is a call-out.

]
, 
title: 
[
Caution
]
, 
background_color: 
rgb("#ffe5d0")
, 
icon_color: 
rgb("#FC5300")
, 
icon: 
fa-fire()
, 
body_background_color: 
white
)
]
= Layout
<layout>
== Span
<span>
`[Content inside span]{style="background-color: gray"}`

#highlight(fill: gray)[Content inside span]

== Div
<div>
```
::: {style="background-color: gray"}
Content inside div
:::
```

#block(fill: gray)[
Content inside div

]
Divs can be nested like this:

```
:::: {.class}
::: {.class}
:::
::::
```

Both spans and divs support attributes in this specific order: identifiers, classes, and then key-value attributes.

`[Content inside span]{#id .class key1="val1" key2="val2"}`

== Hidden div
<hidden-div>
```
::: {.hidden}
Hidden content
:::
```

== Conditional content
<conditional-content>
```
::: {{.content-visible when-format="html"}}
Will only appear in HTML.
:::
```

```
::: {{.content-hidden when-format="html"}}
Will not appear in HTML.
:::
```

Conditional content is documented #link("https://quarto.org/docs/authoring/conditional.html")[here];.

= Shortcodes
<shortcodes>
Shortcodes are sort of like quarto functions.

Two important shortcodes are `meta` and `var`. `meta` allows to read metadata from the yaml block in the current page or from `_quarto.yml`. Here are a few examples:

`{{< meta title >}}` Demo Report

Similarly, `var` allows to read variables from `_variables.yml` if it has been defined. The `include` shortcode allows to add a child qmd document into a specific position in a qmd file.

Some of the custom shortcodes added with this template are:

`{{< meta quarto_version >}}` 1.8.25
\
`{{< meta current_date >}}` 18-12-2025 \
`{{< meta current year >}}` 2025 \
`{{< meta current time >}}` 19:30:33

Shortcodes are documented #link("https://quarto.org/docs/authoring/shortcodes.html")[here];.

= Typst blocks
<typst-blocks>
```
::: {.block fill="olive" inset="8pt" radius="4pt"}

This is a block with olive background and rounded corners.

:::
```

#block(
fill:olive,
inset:8pt,
radius:4pt,
[
This is a block with olive background and rounded corners.

])

= General tips
<general-tips>
- Use level 2 heading as the highest level

```
## Section A
```

- Add custom css under YAML if needed `css: "my-theme.css"`
- Check out the #link("https://quarto.org/")[Quarto] website
- To add a bibliography, use the following:

```
::: {#refs}
:::
```

#block[
] <refs>




#bibliography("references.bib")

