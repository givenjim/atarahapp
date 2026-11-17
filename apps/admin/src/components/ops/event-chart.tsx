import { chartSummary, formatCount, type EventChart } from '@/lib/ops';

const W = 320;
const H = 140;
const L = 34;
const R = 6;
const T = 8;
const B = 20;

/**
 * One event's daily counts as a bar chart in inline SVG: zero-based axis, a single series colour from the design
 * tokens (so it follows light and dark), a text summary in place of the picture, a title on each bar and the same
 * numbers in a table.
 */
export function EventChartCard({ chart }: { chart: EventChart }) {
  const n = chart.days.length;
  const plotW = W - L - R;
  const plotH = H - T - B;
  const slot = n > 0 ? plotW / n : plotW;
  const barW = Math.max(1, slot - (slot > 6 ? 2 : 0.5));
  const y = (v: number) => T + plotH - (v / chart.max) * plotH;
  const mid = chart.max / 2;
  const first = chart.days[0]?.day;
  const last = chart.days[n - 1]?.day;

  return (
    <li className="card chart">
      <div className="chart-head">
        <h3 className="section-title">{chart.label}</h3>
        <span className="chart-total">{formatCount(chart.total)}</span>
      </div>
      <p className="muted" style={{ margin: 0, fontSize: '0.8125rem' }}>
        {formatCount(chart.activeMemberDays)} member-days with this event
      </p>
      <svg viewBox={`0 0 ${W} ${H}`} role="img" aria-label={chartSummary(chart)}>
        {[0, mid, chart.max].map((v) => (
          <g key={v}>
            <line className={v === 0 ? 'axis' : 'grid'} x1={L} x2={W - R} y1={y(v)} y2={y(v)} />
            <text className="tick" x={L - 4} y={y(v) + 3} textAnchor="end">
              {Number.isInteger(v) ? v : v.toFixed(1)}
            </text>
          </g>
        ))}
        {chart.days.map((d, i) =>
          d.events > 0 ? (
            <rect
              key={d.day}
              className="bar"
              x={L + i * slot + (slot - barW) / 2}
              y={y(d.events)}
              width={barW}
              height={T + plotH - y(d.events)}
              rx={barW > 4 ? 2 : 0}
            >
              <title>{`${d.day}: ${d.events} events, ${d.actors} members`}</title>
            </rect>
          ) : null,
        )}
        {first ? (
          <text className="tick" x={L} y={H - 5} textAnchor="start">
            {first}
          </text>
        ) : null}
        {last && last !== first ? (
          <text className="tick" x={W - R} y={H - 5} textAnchor="end">
            {last}
          </text>
        ) : null}
      </svg>
      <details>
        <summary>View as table</summary>
        <div className="scroll">
          <table>
            <caption className="sr-only-text">{`${chart.label} by day`}</caption>
            <thead>
              <tr>
                <th scope="col">Day</th>
                <th scope="col">Events</th>
                <th scope="col">Members</th>
              </tr>
            </thead>
            <tbody>
              {chart.days.map((d) => (
                <tr key={d.day}>
                  <th scope="row" style={{ fontWeight: 400 }}>
                    {d.day}
                  </th>
                  <td>{d.events}</td>
                  <td>{d.actors}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </details>
    </li>
  );
}
