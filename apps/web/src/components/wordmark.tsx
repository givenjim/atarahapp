export function Wordmark({
  size = 24,
  showTagline = true,
}: {
  size?: number;
  showTagline?: boolean;
}) {
  return (
    <div role="img" aria-label="Atarah">
      <div className="wordmark" style={{ fontSize: size }} aria-hidden="true">
        ATARA<span>H</span>
      </div>
      {showTagline ? (
        <div
          className="tagline"
          style={{ fontSize: Math.min(14, Math.max(10, size * 0.5)), marginTop: 2 }}
          aria-hidden="true"
        >
          Create · Connect · Grow
        </div>
      ) : null}
    </div>
  );
}
