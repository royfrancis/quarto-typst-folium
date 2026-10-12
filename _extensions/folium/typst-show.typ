// fontawesome
// https://github.com/duskmoon314/typst-fontawesome
// Imported here rather than in typst-template.typ because Quarto injects its own
// `@preview/fontawesome` import into the header (whenever a callout is used),
// which sits between the two partials and would otherwise shadow this copy.
#import "$folium-assets.fontawesome$/lib.typ".replace("\\", ""): *

#show: folium.with(
  $if(folium.class)$
    class: [$folium.class$],
  $endif$

  $if(title)$
    title: [$title$],
  $endif$

  $if(subtitle)$
    subtitle: [$subtitle$],
  $endif$

  $if(description)$
    description: [$description$],
  $endif$

  $if(nbis.id)$
    id: [$nbis.id$],
  $endif$

  $if(date)$
    date: [$date$],
  $endif$

  $if(nbis.contributors)$
    contributors: (
      $for(nbis.contributors)$
        (
          $if(it.name)$
          name: [$it.name$],
          $endif$
          $if(it.email)$
          email: [$it.email$],
          $endif$
          $if(it.affiliation)$
          affiliation: (
            $for(it.affiliation)$
              [$it$],
            $endfor$
          ),
          $endif$
          $if(it.roles)$
          roles: (
            $for(it.roles)$
              [$it$],
            $endfor$
          ),
          $endif$
        ),
      $endfor$
    ),
  $endif$

  $if(folium.background)$
    background: (
      path: "$folium.background.path$"
    ), 
  $endif$

  $if(folium.logo)$
    logo: (
      path: "$folium.logo.path$"
    ), 
  $endif$

  $if(folium.logo-height)$
    logo-height: $folium.logo-height$,
  $endif$

  $if(folium.font-size)$
    font-size: $folium.font-size$,
  $endif$

  $if(mainfont)$
    mainfont: "$mainfont$",
  $endif$

  $if(lang)$
    lang: "$lang$",
  $endif$

  $if(region)$
    region: "$region$",
  $endif$

  $if(section-numbering)$
    sectionnumbering: "$section-numbering$",
  $endif$
)
