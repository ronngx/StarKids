# Bundled fonts

These original WOFF2 subsets were downloaded by Next.js 15.4.9's
`next/font/google` integration and copied from this project's existing production
build. They replace build-time network downloads; no glyphs or font files were
modified. Content-hashed filenames are retained so CSS references stay stable.

- **Noto Sans SC**, normal, weights 400, 500, 600 and 700.
  Upstream: https://fonts.google.com/specimen/Noto+Sans+SC
  Source/license: https://github.com/google/fonts/tree/main/ofl/notosanssc
  Local license: `Noto-Sans-SC-OFL.txt`.
- **ZCOOL KuaiLe**, normal, weight 400.
  Upstream: https://fonts.google.com/specimen/ZCOOL+KuaiLe
  Source/license: https://github.com/google/fonts/tree/main/ofl/zcoolkuaile
  Local license: `ZCOOL-KuaiLe-OFL.txt`.

Both fonts are distributed under the SIL Open Font License 1.1. Keep the license
files with the fonts when redistributing. `src/app/fonts.css` retains the
original `unicode-range` rules, `font-display: swap`, and fallback metrics so
browsers request only the subsets needed by the page.
The two Latin subsets are preloaded in `src/app/layout.tsx`, as they were with
`next/font/google`. `next.config.ts` gives the content-hashed WOFF2 files an
immutable one-year browser cache.

To update fonts, obtain a new set from the upstream sources and update both the
WOFF2 files, matching `@font-face` rules, and preload links in the root layout.
Update the licenses as needed and
verify Chinese text and all four body text weights before deployment.
