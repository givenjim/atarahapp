(function () {
  const NS = 'http://www.w3.org/2000/svg';
  const pas = n => n.split('-').map(p => p.charAt(0).toUpperCase() + p.slice(1)).join('');
  class LcI extends HTMLElement {
    static get observedAttributes() { return ['name', 'size', 'stroke', 'fill']; }
    connectedCallback() { this.style.display = 'inline-flex'; this.style.flex = 'none'; this.r(); }
    attributeChangedCallback() { if (this.isConnected) this.r(); }
    r() {
      const L = window.lucide;
      if (!L || !L.icons) { clearTimeout(this._t); this._t = setTimeout(() => this.r(), 80); return; }
      const n = this.getAttribute('name'); if (!n) return;
      let node = L.icons[pas(n)];
      if (!node) { if (this.shadowRoot) this.shadowRoot.replaceChildren(); return; }
      if (node[0] === 'svg') node = node[2];
      const s = this.getAttribute('size') || '20';
      const svg = document.createElementNS(NS, 'svg');
      const a = { width: s, height: s, viewBox: '0 0 24 24', fill: this.getAttribute('fill') || 'none', stroke: 'currentColor', 'stroke-width': this.getAttribute('stroke') || '2', 'stroke-linecap': 'round', 'stroke-linejoin': 'round', 'aria-hidden': 'true' };
      for (const k in a) svg.setAttribute(k, a[k]);
      svg.style.display = 'block';
      for (const [tag, attrs] of node) {
        const el = document.createElementNS(NS, tag);
        for (const k in attrs) el.setAttribute(k, attrs[k]);
        svg.appendChild(el);
      }
      const root = this.shadowRoot || this.attachShadow({ mode: 'open' }); root.replaceChildren(svg);
    }
  }
  if (!customElements.get('lc-i')) customElements.define('lc-i', LcI);
})();
