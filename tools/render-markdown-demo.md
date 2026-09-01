# render-markdown.nvim demo

A tour of everything render-markdown.nvim renders with this configuration.
Move the cursor onto any element: anti-conceal shows its raw form under the
cursor. Press `<leader>mm` to flip the whole file back to raw Markdown.
Headings use the `inline` position, so icons start at the left edge.

## Headings

Every level, one through six:

### Level three

#### Level four

##### Level five

###### Level six

## Paragraph and inline styles

A regular paragraph with **bold**, *italic*, `inline code`,
==inline highlight==, and a [named link](https://neovim.io). Inline code keeps
its background in prose: run `:checkhealth render-markdown` at any time.

## Code blocks

Blocks get a background, a language icon (mini.icons), and padding:

```lua
local function greet(name)
	return "Hello, " .. name
end
print(greet("render-markdown"))
```

```python
def greet(name: str) -> str:
    return f"Hello, {name}"
```

A block without a language renders with no icon:

```
plain fenced text, no language icon above
```

## Thematic break

---

## Lists

Bullets cycle icons per level (`●`, `○`, `◆`, `◇`):

- first level
  - second level
    - third level, still left-aligned
- back to the first level

Ordered lists renumber with their own icons:

1. ordered one
2. ordered two
3. ordered three

## Checkboxes

- [x] done
- [ ] not done
- [-] custom "todo" state from the plugin defaults

## Quotes

> A single-line block quote.
>
> > A nested quote inside it.

## Callouts

GitHub flavour:

> [!NOTE]
> Highlights information that users should take into account.

> [!TIP]
> Optional information to help a user be more successful.

> [!IMPORTANT]
> Crucial information necessary for users to succeed.

> [!WARNING]
> Critical content demanding immediate user attention.

> [!CAUTION]
> Negative potential consequences of an action.

Obsidian flavour:

> [!QUESTION]
> An Obsidian-style callout, rendered with its own icon.

> [!INFO]
> Another Obsidian default; both flavours ship out of the box.

## Tables

Borders, alignment indicators, and padded cells:

| Left          | Center | Right |
| :------------ | :----: | ----: |
| a             |   b    |     c |
| a longer cell |   x    |     y |

## Links

- Bare web URL, matched by the plugin's custom `web` pattern: https://github.com
- Autolink in angle brackets: <https://neovim.io>
- Email autolink: <someone@example.com>
- Image, rendered with the image icon: ![demo screenshot](screenshot.png)
- Wiki link: [[some-page]]
- Footnote reference, superscripted: see the footnote[^1]

[^1]: The footnote body, rendered inline.

## HTML comments

The next line is an HTML comment, concealed because the `html` parser is
installed:

<!-- this text is hidden while rendered -->

## LaTeX (disabled in this setup)

This configuration turns `latex` off (no parser, no converter), so formulas
show raw on purpose. Inline: $E = mc^2$. Block:

$$
\int_0^1 x^2 \, dx = \frac{1}{3}
$$

## Completion playground

Pause after typing on the empty items below; the plugin's in-process LSP
server completes checkboxes and callouts through mini.completion:

-

>

## What is not shown here

- YAML frontmatter rendering: disabled (`yaml = { enabled = false }`).
- Org indent mode: off by default; enable with `indent.enabled = true`.
