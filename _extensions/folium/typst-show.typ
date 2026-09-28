#show: folium.with(
  $if(nbis.class)$
    class: [$nbis.class$],
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

  $if(nbis.background)$
    background: (
      path: "$nbis.background.path$"
    ), 
  $endif$

  $if(nbis.logo)$
    logo: (
      path: "$nbis.logo.path$"
    ), 
  $endif$

  $if(nbis.logo-height)$
    logo-height: $nbis.logo-height$,
  $endif$

  $if(nbis.font-size)$
    font-size: $nbis.font-size$,
  $endif$

  $if(mainfont)$
    mainfont: "$mainfont$",
  $endif$
)
