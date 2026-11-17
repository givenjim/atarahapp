/* eslint-disable @next/next/no-img-element -- static brand SVGs, served as-is */
/** Atarah logo without the tagline: full colour in light, reversed in dark (swapped in CSS). */
export function Logo({ width = 130 }: { width?: number }) {
  const height = Math.round(width * (233.7 / 897.6));
  return (
    <span role="img" aria-label="Atarah" style={{ display: 'block', width }}>
      <img
        className="logo logo-light"
        src="/brand/atarah-logo-notagline-color.svg"
        alt=""
        width={width}
        height={height}
      />
      <img
        className="logo logo-dark"
        src="/brand/atarah-logo-notagline-reversed.svg"
        alt=""
        width={width}
        height={height}
      />
    </span>
  );
}
