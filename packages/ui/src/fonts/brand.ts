import localFont from "next/font/local";

/**
 * AfrikaBurn brand face as `--font-brand` (globals.css → `--font-sans`).
 * Self-hosted latin woff2 — no Google Fonts fetch at `next build`.
 */
export const brandFont = localFont({
  src: [
    {
      path: "../../fonts/montserrat/montserrat-latin-500-normal.woff2",
      weight: "500",
      style: "normal",
    },
    {
      path: "../../fonts/montserrat/montserrat-latin-600-normal.woff2",
      weight: "600",
      style: "normal",
    },
    {
      path: "../../fonts/montserrat/montserrat-latin-700-normal.woff2",
      weight: "700",
      style: "normal",
    },
    {
      path: "../../fonts/montserrat/montserrat-latin-800-normal.woff2",
      weight: "800",
      style: "normal",
    },
  ],
  variable: "--font-brand",
  display: "swap",
});
