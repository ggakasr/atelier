# Blocker report

Use this shape when giving up on a feasibility problem. A real blocker reported with evidence is
a valid ending; a bare "can't" is not. It does not apply to safety or policy refusals.

```
Blocker report: <task in one line>

Tried
1. <approach A>: <what I ran> -> <result / error quote / file:line>
2. <approach B (flips a constraint)>: <what I ran> -> <result>
3. <approach C>: <what I ran> -> <result>

Blocked at: <the exact step> because <fact, with evidence>
Type: real (safety | permission | physics) / false (missing info | untried)

What unlocks it: <information, access, tool or decision needed>
Done so far: <the part that is not blocked, and where it is>

You decide: <one concrete question>. Recommended: <option> because <reason>.
```

## Worked example

```
Blocker report: export the invoice list to PDF with the company logo

Tried
1. Render with the existing pdf library: ran scripts/export.js -> Error: font 'Inter' not embedded (export.js:42)
2. Flip a constraint (embed the font as a file): added fonts/Inter.ttf -> renders, but the logo is a 4-bit PNG and prints blurry
3. Other tool (headless browser print-to-PDF): ran it -> sharp, but the CI image has no Chromium

Blocked at: logo quality, because the only logo file in the repo is 120x40 px (assets/logo.png)
Type: false (missing info)

What unlocks it: an SVG or a 600 px logo
Done so far: PDF export works end to end with a text-only header (branch export-pdf)

You decide: ship the text-only header now, or wait for the logo? Recommended: ship now and add the logo later.
```
