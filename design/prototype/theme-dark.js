(function () {
  if (window.AtarahDark) return;
  const rgb = h => { h = h.replace('#', ''); if (h.length === 3) h = h.split('').map(c => c + c).join(''); return 'rgb(' + parseInt(h.slice(0, 2), 16) + ', ' + parseInt(h.slice(2, 4), 16) + ', ' + parseInt(h.slice(4, 6), 16) + ')'; };
  const mk = o => { const m = {}; for (const k in o) m[rgb(k)] = o[k]; return m; };
  // Dark tokens (Midnight/Indigo-derived): Night #0F0D2B, Surface #17153F, Raised #1F1C55
  const BG = mk({
    '#17153F': '#2A2478', '#1F1C55': '#2A2478', '#2A2478': '#3828C3',
    '#EFEDFF': '#25215E', '#E7E4FF': '#2C2870', '#F8F7FF': '#1C1A4A', '#F2F0FF': '#231F5A', '#EEEDFB': '#221F55', '#F6F5FC': '#1C1A4A',
    '#FDE8EF': '#3A1838', '#FDE3EC': '#2E1533', '#FFF1E5': '#3A2420', '#FFF6EC': '#33221F', '#FFE8D6': '#2E1E22', '#e9f8ee': '#0F3A2A',
    '#f2f1f6': '#24223F', '#dcdbe6': '#34325A', '#cfccdf': '#4A4870',
    '#f1f0f7': '#1C1A4A', '#f4f3f9': '#1C1A4A', '#f3f2f9': '#1C1A4A', '#e7e5f2': '#25225E', '#e9e7f4': '#25225E',
    '#ecebf4': '#2A2766', '#e4e2ef': '#322F6E', '#f0eff6': '#221F4D', '#f2f1f8': '#221F4D'
  });
  const GRAD = Object.assign({}, BG, mk({ '#ffffff': '#0F0D2B', '#17153F': '#1F1C55', '#1F1C55': '#2A2478', '#2A2478': '#3828C3' }));
  const TX = mk({
    '#17153F': '#F6F5FC', '#2c2a50': '#DCD9F2', '#4a4868': '#B9B6D6', '#77758f': '#9592B8', '#a3a1b8': '#75729A',
    '#5145D8': '#9A8DFF', '#3F34B8': '#B8AFFF', '#7968FF': '#9A8DFF', '#C4245A': '#F04478', '#B5530C': '#FF8A32',
    '#16784a': '#5FD39A', '#1f9d55': '#3CC17A', '#c9c7d6': '#5A5880'
  });
  const BD = mk({
    '#ecebf4': '#2A2766', '#e4e2ef': '#322F6E', '#f0eff6': '#221F4D', '#f2f1f8': '#221F4D', '#E7E4FF': '#34307A', '#EFEDFF': '#2C2870',
    '#B8AFFF': '#4A43A0', '#cfccdf': '#4A4870', '#ffffff': '#0F0D2B', '#dcdbe6': '#34325A'
  });
  const WHITE = rgb('#fff');
  const swapIn = (s, map) => s.replace(/rgba?\([^)]*\)/g, m => map[m] || m);
  const isGlass = bg => { const m = /rgba\(255, 255, 255, ([\d.]+)\)/.exec(bg); return m && parseFloat(m[1]) >= 0.6; };
  const LOGO = [['atarah-logo-notagline-color.svg', 'atarah-logo-notagline-reversed.svg'], ['atarah-logo-primary-color.svg', 'atarah-logo-primary-reversed.svg']];
  const SIDES = ['borderTopColor', 'borderRightColor', 'borderBottomColor', 'borderLeftColor'];

  function darkFor(el, prop, v) {
    const s = el.style;
    if (!v) return v;
    if (prop === 'backgroundColor') {
      if (v === WHITE) return (s.borderTopStyle && s.borderTopStyle !== 'none') || (s.borderLeftStyle && s.borderLeftStyle !== 'none') || s.boxShadow ? '#17153F' : '#0F0D2B';
      return BG[v] || v;
    }
    if (prop === 'backgroundImage') return v.indexOf('gradient') > -1 ? swapIn(v, GRAD).replace(/,\s*(initial|none)\b/g, '') : v;
    if (prop === 'color') return isGlass(s.backgroundColor) ? v : (TX[v] || v);
    if (prop === 'boxShadow') return swapIn(v, BD);
    return BD[v] || v; // borders
  }
  const PROPS = ['backgroundColor', 'backgroundImage', 'color', 'boxShadow'].concat(SIDES);

  function proc(el, on) {
    if (el.nodeType !== 1 || el.closest('[data-nodark]')) return;
    const st = el.__atD || (el.__atD = { o: {}, a: {} });
    const s = el.style;
    for (const p of PROPS) {
      const cur = s[p];
      if (on) {
        if (!cur || cur === st.a[p]) continue;
        const d = darkFor(el, p, cur);
        if (d === cur && st.o[p] !== undefined && p === 'backgroundImage') { st.a[p] = cur; continue; }
        st.o[p] = cur;
        if (d !== cur) { s[p] = d; st.a[p] = s[p]; } else { st.a[p] = cur; }
      } else if (st.o[p] !== undefined) {
        if (cur === st.a[p] || p === 'backgroundImage') s[p] = st.o[p];
        delete st.o[p]; delete st.a[p];
      }
    }
    // text on white glass pills must stay dark
    if (on && isGlass(s.backgroundColor) && !s.color) { s.color = '#17153F'; st.glass = s.color; }
    if (!on && st.glass && s.color === st.glass) { s.color = ''; st.glass = null; }
    if (el.tagName === 'IMG') {
      const src = el.getAttribute('src') || '';
      for (const [l, d] of LOGO) {
        if (on && src.endsWith(l)) { el.__atSrc = src; el.setAttribute('src', src.replace(l, d)); }
        if (!on && el.__atSrc && src.endsWith(d)) { el.setAttribute('src', el.__atSrc); el.__atSrc = null; }
      }
    }
  }
  function each(node, fn) { if (node.nodeType === 1) { fn(node); if (node.shadowRoot && node.tagName !== 'LC-I') each(node.shadowRoot, fn); } for (const c of node.children || []) each(c, fn); }
  let OBS = null;
  function walk(root, on) { each(root, el => { proc(el, on); if (el.shadowRoot && el.tagName !== 'LC-I' && OBS && !el.shadowRoot.__atObs) { el.shadowRoot.__atObs = 1; OBS(el.shadowRoot); } }); }

  const state = new WeakMap();
  window.AtarahDark = {
    set(root, on) {
      if (!root) return;
      let r = root.__atR;
      if (!r) {
        r = { on: false, q: new Set(), raf: 0 };
        r.mo = new MutationObserver(ms => {
          if (!r.on) return;
          for (const m of ms) {
            if (m.type === 'attributes') r.q.add(m.target);
            else m.addedNodes.forEach(n => { if (n.nodeType === 1) r.q.add(n); });
          }
          if (!r.raf) r.raf = setTimeout(() => { r.raf = 0; if (!r.on) { r.q.clear(); return; } const q = [...r.q]; r.q.clear(); q.forEach(n => n.isConnected && walk(n, true)); }, 0);
        });
        const opts = { subtree: true, childList: true, attributes: true, attributeFilter: ['style', 'src'] };
        r.mo.observe(root, opts);
        OBS = n => r.mo.observe(n, opts);
        root.__atR = r;
      }
      if (r.on === on) { if (on) walk(root, true); return; }
      r.on = on;
      root.style.colorScheme = on ? 'dark' : '';
      if (!on && r.raf) { clearTimeout(r.raf); r.raf = 0; r.q.clear(); }
      walk(root, on);
    }
  };
})();
