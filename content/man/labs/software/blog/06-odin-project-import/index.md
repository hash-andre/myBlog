---
title: "06 — Importing and reviewing The Odin Project notes"
description: "A content import where technical review mattered as much as Markdown cleanup"
date: 2026-08-29T23:40:00+02:00
show_in_posts: true
weight: 70
---

## Scope

The Odin Project import contained three double-wrapped Notion exports:

```text
1.zip -> Basic HTML
2.zip -> Basic CSS & Flexbox
3.zip -> Basic Javascript
```

The existing `foundations/index.md` was only a placeholder that asked for future
content. Keeping it beside the real articles would create a misleading empty
entry, so it was replaced by three numbered leaf bundles:

```text
content/man/labs/software/odin-project/
├── _index.md
├── 00-basic-html/
├── 01-basic-css-flexbox/
└── 02-basic-javascript/
```

## Resource import

The archives contained 51 images in total:

- 4 for HTML;
- 38 for CSS and Flexbox;
- 9 for JavaScript.

Every image was visually inspected in a contact sheet before it was named. This
avoided guessing from Notion's generic numbering. Examples include:

```text
image.png     -> relative-and-absolute-paths.png
image 17.png  -> align-items-values.png
image 3.png   -> event-loop.png
```

The final validation found 51 source resources and the same 51 resources in the
published Odin bundles, with no missing or unused file.

## Preserve the author's learning path

These notes were not rewritten as an impersonal reference manual. Their value
comes from the order in which a concept was encountered:

1. state the practical problem;
2. build a mental model;
3. show a small example;
4. identify a failure or edge case;
5. connect the detail to a larger mechanism.

The English and Italian were corrected where grammar obscured meaning, but the
explanations remain direct and incremental. The goal is not to hide the learning
process. It is to make that process reliable enough to revisit later.

## HTML review

The HTML article was expanded and corrected around:

- the role of `<!doctype html>`;
- `lang`, character encoding, viewport metadata, and `<title>`;
- absolute and relative URL resolution;
- `target="_blank"` with `noopener` and `noreferrer`;
- useful `alt` text rather than filename repetition;
- unitless HTML `width` and `height` attributes;
- intrinsic dimensions and layout shift;
- `srcset` and `sizes` instead of a universal “double pixels for Retina” rule.

## CSS review

Several statements needed semantic correction rather than copy editing.

### Multi-class selector

The raw selector contained a space:

```css
.alert_text .severe_alert { ... }
```

That selects a descendant. The example HTML put both classes on one element, so
the correct selector is:

```css
.alert_text.severe_alert { ... }
```

### Cascade

Inheritance was described as the third tie-breaker after specificity and source
order. That is not the correct model. Origin, importance, and cascade layers are
considered before specificity; inheritance supplies a value only when the
element has no applicable declaration for an inherited property.

### Margin collapsing

Two positive adjacent vertical margins do not add together. When they collapse,
the result is normally the larger margin. The article now distinguishes this
from Flexbox and Grid contexts, where that block-flow behavior does not apply in
the same way.

### Flexbox

The review corrected several common beginner traps:

- flex properties do not “inherit” from the container;
- only direct children become flex items;
- items have more controls than the `flex` shorthand;
- `flex-direction` defines the main axis;
- `justify-content` uses the main axis and `align-items` the cross axis;
- `align-content` distributes multiple lines, not individual items;
- `flex: 1` is normally expanded to `1 1 0%`;
- `order` changes visual order and can diverge from reading or focus order.

## JavaScript review

The JavaScript article contained the largest number of executable examples, so
syntax review and conceptual review were both necessary.

### Executable errors repaired

- `PI` was declared but `pi` was read.
- bold Markdown markers had been exported inside code.
- two `const cats` and two `const sum` declarations shared one scope.
- the event example used `event.input.value` instead of
  `event.target.value`.
- `document.querySelectorAll` contained Markdown emphasis inside the method
  name.
- HTML and JavaScript were mixed in single language fences.
- FizzBuzz evaluated only the input number instead of printing `1` through the
  requested limit.

### Runtime concepts corrected

- `±(2^53 - 1)` is the safe integer range, not the complete range of `number`.
- JavaScript passes every argument by value; an object's copied value is a
  reference, which explains visible mutation without inventing pass-by-reference
  semantics.
- a `NodeList` is not an array, although modern NodeLists support methods such
  as `forEach()`.
- `onclick` targets the selected element; its limitation is a single property
  handler, not that it automatically selects every button.
- promise reactions use the microtask queue, while timers and UI events use task
  queues; they are not all one callback queue.
- `fetch()` does not reject merely because the server returns `404` or `500`, so
  examples check `response.ok`.

### npm behavior checked against current documentation

The original comment said:

```bash
npm config set min-release-age=3
```

would block releases younger than three years. Current npm documentation defines
the value in **days**, so it means three days. The note now also explains that a
release-age window can delay an urgent security fix and does not replace a
lockfile, audit, or dependency review.

The description of `npx` was updated too: current `npx` is an interface to
`npm exec`; it can use a local package or, after a prompt, place a requested
package in the npm cache for execution.

## Markdown and accessibility review

Across all three articles:

- the front matter title owns `<h1>` and body headings start at `##`;
- raw URLs have descriptive labels;
- `<aside>` remnants were removed;
- code fence languages match their content;
- image alt text explains the figure;
- duplicate captions were removed;
- Notion UUIDs and `%20` paths were eliminated;
- every article received a date, weight, description, and
  `show_in_posts: true`.

## Verification result

After the import, the clean Hugo build reported:

```text
Pages:          50
Non-page files: 104
```

The three Odin articles appeared in their directory, in `/posts/`, and in RSS.
The source/output checks reported no missing image, unused imported resource,
raw URL, Notion path, unbalanced code fence, or diff whitespace error.

References used for version-sensitive corrections:

- [npm configuration: `min-release-age`](https://docs.npmjs.com/using-npm/config/)
- [npm exec and npx](https://docs.npmjs.com/cli/npm-exec/)
- [MDN: `Number.MAX_SAFE_INTEGER`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number/MAX_SAFE_INTEGER)
- [MDN: Fetch](https://developer.mozilla.org/en-US/docs/Web/API/Window/fetch)
