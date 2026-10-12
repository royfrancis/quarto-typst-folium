-- Text size classes for spans, e.g. [text]{.large}. Sizes are relative to the
-- surrounding text and follow a major third scale, matching the site CSS.
local span_sizes = {
  largest = "1.953em",
  larger = "1.563em",
  large = "1.25em",
  small = "0.8em",
  smaller = "0.64em",
  smallest = "0.512em",
}

function Span(el)
  if FORMAT == "typst" then
    for _, class in ipairs(el.classes) do
      local size = span_sizes[class]
      if size then
        return {
          pandoc.RawInline("typst", "#text(size: " .. size .. ")["),
          el,
          pandoc.RawInline("typst", "]")
        }
      end
    end
  end
end

function Code(el)
  if FORMAT == "typst" then
    return {
      pandoc.RawInline("typst", "#inline-code["),
      el,
      pandoc.RawInline("typst", "]")
    }
  end
end

-- Quarto parses metadata as markdown, so a standalone "@handle" mention is
-- read as a pandoc citation and fails compilation when the document has no
-- bibliography (an email such as name@nbis.se is not affected). Reconstitute
-- the literal "@id" text instead. Only metadata is touched, so real
-- citations in the document body are unaffected.
local function neutralize_cites(el)
  return el:walk({
    Cite = function(cite)
      local out = pandoc.List({})
      for i, citation in ipairs(cite.citations) do
        if i > 1 then
          out:insert(pandoc.Str(";"))
          out:insert(pandoc.Space())
        end
        if citation.prefix and #citation.prefix > 0 then
          out:extend(citation.prefix)
          out:insert(pandoc.Space())
        end
        out:insert(pandoc.Str("@" .. citation.id))
        if citation.suffix and #citation.suffix > 0 then
          out:extend(citation.suffix)
        end
      end
      return out
    end
  })
end

local function neutralize_meta(value)
  local t = pandoc.utils.type(value)
  if t == "Inlines" or t == "Blocks" then
    return neutralize_cites(value)
  elseif t == "table" or type(value) == "table" then
    for k, v in pairs(value) do
      value[k] = neutralize_meta(v)
    end
    return value
  else
    return value
  end
end

local function is_map(value)
  return pandoc.utils.type(value) == "table"
end

local function fill_missing(target, defaults)
  if defaults == nil or not is_map(defaults) then
    return target
  end
  if target == nil then
    return defaults
  end
  if not is_map(target) then
    return target
  end
  for key, value in pairs(defaults) do
    if target[key] == nil then
      target[key] = value
    else
      target[key] = fill_missing(target[key], value)
    end
  end
  return target
end

function Meta(meta)
  meta.folium = fill_missing(meta.folium, meta["folium-defaults"])
  meta["folium-defaults"] = nil
  -- The extension supplies a default `section-numbering` pattern, but on its own
  -- that would number headings even with `number-sections: false`.
  if not PANDOC_WRITER_OPTIONS.number_sections then
    meta["section-numbering"] = nil
  end
  return neutralize_meta(meta)
end
