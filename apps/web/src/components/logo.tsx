/* eslint-disable @next/next/no-img-element -- static brand SVG, served as-is */
/** The Atarah logo without the brand line (full colour; the public holding page always uses the light appearance). */
export function Logo({ width = 130 }: { width?: number }) {
  return (
    <img
      className="logo"
      src="/brand/atarah-logo-notagline-color.svg"
      alt="Atarah"
      width={width}
      height={Math.round(width * (233.7 / 897.6))}
    />
  );
}
