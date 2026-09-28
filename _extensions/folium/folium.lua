function Div(el)
  if el.classes:includes('article') then
    local blocks = pandoc.List({
      pandoc.RawBlock('typst', '#article[')
    })
    blocks:extend(el.content)
    blocks:insert(pandoc.RawBlock('typst', ']\n'))
    return blocks
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

-- Quarto parses metadata as markdown, so an "@word" pattern (an email,
-- a mention) is read as a pandoc citation and fails
-- compilation when the document has no bibliography. Reconstitute the
-- literal "@id" text instead. Only metadata is touched, so real citations
-- in the document body are unaffected.
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

function Meta(meta)
  return neutralize_meta(meta)
end
