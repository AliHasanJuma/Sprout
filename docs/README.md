# Sprout — Marketing Landing Page

A static, production-ready marketing site for **Sprout**, a Bahrain-first community marketplace mobile app. Built as plain `index.html` + CSS + JS (no build step, no framework runtime) so it can be hosted directly on GitHub Pages.

The visual language is taken straight from the Sprout Design System (Figma + Brand Guidelines): the lime-on-teal palette, the SF Pro type stack, the pill buttons, and the lime "Bow" header that's central to the in-app look.

---

## Preview locally

From this folder:

```bash
python3 -m http.server 8000
```

Then open http://localhost:8000.

You can also just double-click `index.html` — every asset path is relative, no server is strictly required.

---

## Deploy to GitHub Pages

1. **Push this folder to GitHub.** The simplest path is a dedicated repo where `index.html` sits at the repo root.
2. In the repo settings → **Pages**, enable Pages from the `main` branch root (`/`).
3. The included `.nojekyll` file disables Jekyll processing so paths like `/assets/img/...` work exactly as-is.
4. After ~1 minute, your site will be live at `https://<user>.github.io/<repo>/`.

If instead you want to host the landing page from a subfolder of an existing repo, use the **Pages → "Deploy from a branch"** option pointed at `/docs`. Rename or symlink this folder to `docs/` before pushing.

---

## Three things you'll likely want to swap before shipping

The page is honest about what it doesn't have yet. Search the codebase for `TODO` to find every placeholder:

| TODO | Where | What to replace |
|---|---|---|
| Waitlist endpoint | `index.html` (`<form id="waitlist-form">`) and `assets/js/main.js` | Plug in a Formspree / Mailchimp / Resend URL. The current submit handler is a pure-frontend stub. |
| OG image | `index.html` (`og:image`, `twitter:image`) and `assets/img/og-image.svg` | Replace the placeholder SVG with a 1200×630 PNG exported from a real branded mock. |
| Real social URLs | `index.html` footer | The IG / X / LinkedIn icons currently link to `#`. |
| Footer legal links | `index.html` footer | Privacy / Terms / Contact currently link to `#`. |
| Logo asset paths | `index.html` `<header>` and footer | Already wired to `/assets/img/logos/logo-dark-green.svg` and `logo-neon-green.svg`. If you swap the logo set, update those references. |

---

## Theme variants

Three themes are wired up via body classes, each implemented as a scoped set of CSS custom properties:

| Class | What it looks like |
|---|---|
| `theme-lime-on-white` *(default)* | White page, lime accents, dark-teal text. The cleanest, most retail-feeling option. |
| `theme-teal-dominant` | Dark-teal sections dominate, lime accents pop. Bolder and more editorial. |
| `theme-cream` | Pale-lime (`#EFF8C5`) page background, lime CTAs, dark-teal text. Warmer, softer feel. |

Pick a theme by toggling the body class, or use the **Theme** picker pinned top-right of the live page. Choice persists to `localStorage`.

```html
<body class="theme-cream"> <!-- example -->
```

---

## Density variants

Three density classes adjust section padding and display-type sizes. Toggle via the **Density** widget under the theme picker, or set the body class manually:

| Class | When to use |
|---|---|
| `density-tight` | Compact section padding & smaller display sizes — useful for very long pages or denser screenshots. |
| *(no class)* | **Medium** — the default, balanced for marketing scrolling. |
| `density-long` | Generous padding & bigger display sizes — gives an editorial/agency feel for short pages. |

```html
<body class="theme-lime-on-white density-tight">
```

---

## Hero variants

The brief asked for three hero treatments to choose from. All three are stacked vertically on the live page (each labelled in the variant tag bar) so you can compare them at a glance:

- **Variant A — Centered, dual phones below.** Big centered headline, CTAs, then two phone mockups fanned beneath. Reads like a clean app launch.
- **Variant B — Split: text left, phones right.** Classic SaaS layout. Text and CTAs sit on the left; two phone mockups overlap on the right.
- **Variant C — Bow header + phones overlap.** Lime "Bow" wave fills the top of the page (matching the in-app `_BowClipper`), headline sits on it, and phones overlap the wave's curved edge.

When you've picked a winner, delete the other two `<section class="hero-section hero-X">` blocks and the surrounding `.hero-variant-tag` dividers from `index.html`.

---

## Project structure

```
docs/
├── index.html            ← Page markup. Inline SVG sprite at the top, all sections in semantic <section>s.
├── assets/
│   ├── css/styles.css    ← Tokens + themes + density + every component.
│   ├── js/main.js        ← Theme picker, density toggle, mobile menu, waitlist form stub, smooth-scroll fallback.
│   ├── img/
│   │   ├── logos/        ← 4 logo SVGs from the design system (black / dark-green / neon-green / white).
│   │   ├── icons/        ← 11 stroke-style 24×24 icons from the design system.
│   │   ├── illustrations/ ← 14 line-art Artboard SVGs from the brand pack.
│   │   ├── raster/       ← Brand PNG illustrations (seller-picture, growth, new-badge, etc.).
│   │   └── og-image.svg  ← Placeholder Open Graph image. TODO: replace with PNG.
│   └── icons/favicon.svg ← Inline-style SVG favicon.
├── README.md             ← This file.
└── .nojekyll             ← Tells GitHub Pages to serve /assets/ paths verbatim.
```

---

## Notes on the design

- **Illustrations are placeholders.** The 14 brand line-art SVGs from the design system are wired in as decorative accents in the "Why Sprout", "Featured shelves", and "Why Bahrain first" sections. If the brand team hands over final illustrations, drop them into `assets/img/illustrations/` with the same filenames and they'll appear automatically.
- **Phone mockups are pure CSS/HTML.** No images, no third-party mockup generators. The "Bow" header inside each phone uses the same lime fill and concave curve as the in-app `_BowClipper` (drawn here with a CSS mask).
- **No web fonts loaded.** The page uses the system SF Pro stack — renders natively on Apple devices and falls back cleanly elsewhere. Per the brief.
- **Accessibility:** single `<h1>`, real heading hierarchy, all interactive elements keyboard-reachable, 4.5:1 colour contrast on body copy, `prefers-reduced-motion` respected, `aria-hidden` on decorative SVG sprites, `aria-pressed` on toggles.
- **The page is honest.** Sprout does not handle in-app payments or delivery in the MVP — the copy says exactly that. There's no fake "We shipped 10,000 orders" hype.

---

## Browser support

Targets modern evergreen browsers (Chrome, Edge, Firefox, Safari, mobile Safari, Samsung Internet). The page uses CSS custom properties, `clamp()`, `aspect-ratio`, `mask-image`, and SVG sprites — all well-supported on browsers from the last ~3 years. There's no IE11 fallback.
