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

  $if(folium.id)$
    id: [$folium.id$],
  $endif$

  $if(date)$
    date: [$date$],
  $endif$

  $if(folium.investigator)$
    investigator: (
      $for(folium.investigator)$
        (
          name: [$it.name$],
          email: [$it.email$],
          org: [$it.org$],
        ),
      $endfor$
    ),
  $endif$

  $if(folium.pi)$
    pi: (
      $for(folium.pi)$
        (
          name: [$it.name$],
          email: [$it.email$],
          org: [$it.org$],
        ),
      $endfor$
    ),
  $endif$

  $if(folium.analyst)$
    analyst: (
      $for(folium.analyst)$
        (
          name: [$it.name$],
          email: [$it.email$],
          org: [$it.org$],
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
)
