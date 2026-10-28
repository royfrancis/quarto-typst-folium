-- Quarto's Typst writer ignores the callout appearance, so a simple callout
-- would be drawn like the default one, with a header and the default title.
-- This runs at post-ast, where the Callout node carries the resolved
-- appearance (`appearance="minimal"` is a simple callout without an icon, and
-- the `callout-appearance` document option is already applied), and hands
-- simple callouts to `callout-simple` in typst-template.typ.
--
-- Callouts with an id are left to Quarto: a cross-referenced callout needs the
-- numbered title that only the default layout has, and Quarto wraps it in the
-- figure that the reference points to. Margin callouts are left alone too,
-- since Quarto places them in the margin.
local function is_margin(callout)
  for _, class in ipairs(callout.attr.classes) do
    if class == "column-margin" or class == "aside" then
      return true
    end
  end
  return false
end

function Callout(callout)
  if FORMAT ~= "typst" or callout.appearance ~= "simple" then
    return nil
  end
  if callout.attr.identifier ~= "" or is_margin(callout) then
    return nil
  end

  local title = quarto.utils.as_inlines(callout.title)
  local has_title = pandoc.utils.stringify(title) ~= ""
  local call = '#callout-simple(kind: "' .. tostring(callout.type) ..
    '", icon: ' .. tostring(callout.icon ~= false) ..
    ', title: ' .. (has_title and '[' or 'none, body: [')

  local blocks = pandoc.Blocks({ pandoc.RawBlock("typst", call) })
  if has_title then
    blocks:insert(pandoc.Plain(title))
    blocks:insert(pandoc.RawBlock("typst", '], body: ['))
  end
  blocks:extend(quarto.utils.as_blocks(callout.content))
  blocks:insert(pandoc.RawBlock("typst", '])'))
  return blocks
end
