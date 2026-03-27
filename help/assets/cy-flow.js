// Register dagre layout
if (window.cytoscape && window.dagre) {
  cytoscape.use(window.cytoscapeDagre);
}

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('cy');
  if (!container || !window.cytoscape) return;

  const cy = cytoscape({
    container,
    // AUTOGEN:BEGIN elements
    // (do not edit by hand)
    elements: {
      nodes: [
        { data: { id: 'A', label: 'A-example' } },
        { data: { id: 'B', label: 'B-example' } },
        { data: { id: 'C', label: 'C-example' } }
      ],
      edges: [
        { data: { id: 'e1', source: 'A', target: 'B', types: ['calls','reads'] } },
        { data: { id: 'e2', source: 'B', target: 'C', types: ['reads'] } },
        { data: { id: 'e4', source: 'A', target: 'C', types: ['calls'] } }
      ]
    },
    // AUTOGEN:END elements
    style: [
      {
        selector: 'node',
        style: {
          'label': 'data(label)',
          'text-wrap': 'wrap',
          'text-valign': 'center',
          'text-halign': 'center'
        }
      },
      {
        selector: 'edge',
        style: {
          'curve-style': 'bezier',
          'control-point-step-size': 40,       // space parallel edges
          'target-arrow-shape': 'triangle',
          'source-arrow-shape': 'triangle',    // two-headed
          'label': 'data(label)'
        }
      },
      // Anything with .hidden is removed from view AND from layout calculations
      { selector: '.hidden', style: { 'display': 'none' } }
    ]
  });

  // ---------- Helpers ----------
  /*
  function relayout() {
    let layout;
    try {
      layout = cy.layout({
        name: 'dagre',
        rankDir: 'LR',
        animate: true,
        animationDuration: 300,
        padding: 20
      });
    } catch {
      layout = cy.layout({
        name: 'breadthfirst',
        directed: true,
        animate: true,
        animationDuration: 300,
        padding: 20
      });
    }
    layout.run();
    cy.fit(undefined, 20);
  }

  function relayoutTwice() {
    relayout();
    setTimeout(relayout, 50);
  }*/

  function relayout(visibleOnly = true) {
    const eles = visibleOnly ? cy.elements(':visible') : cy.elements();
    let layout;
    try {
      layout = eles.layout({ name: 'dagre', rankDir: 'LR', animate: true, animationDuration: 300, padding: 20 });
    } catch {
      layout = eles.layout({ name: 'breadthfirst', directed: true, animate: true, animationDuration: 300, padding: 20 });
    }
    layout.run();
    //cy.fit(visibleOnly ? eles : undefined, 20);
    fitVisibleNodes()
  }

  function relayoutTwice() {
    relayout(true);
    setTimeout(() => relayout(true), 50);
  }


  // Ensure every edge has a display label
  function computeEdgeLabels() {
    cy.edges().forEach(e => {
      if (e.data('label')) return;
      const tags = getEdgeTags(e);
      if (tags.length) e.data('label', tags.join(', '));
    });
  }

  function nodeVisible(n) { return !n.hasClass('hidden'); }

  // Support either data.types (array) or data.type (string)
  function getEdgeTags(e) {
    const arr = e.data('types');
    if (Array.isArray(arr)) return arr;
    const t = e.data('type');
    return t ? [t] : [];
  }

  // Collect all tag names present on edges
  function allTagsFromEdges() {
    const s = new Set();
    cy.edges().forEach(e => getEdgeTags(e).forEach(t => s.add(t)));
    return s;
  }

  // ---------- Edge tag visibility model (pressed = visible) ----------
  const tagButtons = document.querySelectorAll('[data-edge-tag]');
  const enabledEdgeTags = new Set(
    Array.from(tagButtons)
      .filter(b => b.getAttribute('aria-pressed') === 'true')
      .map(b => b.dataset.edgeTag)
  );
  // If no buttons exist, default to "all tags enabled"
  if (tagButtons.length === 0) {
    allTagsFromEdges().forEach(t => enabledEdgeTags.add(t));
  }

  function isTagEnabled(tag) { return enabledEdgeTags.has(tag); }

  function updateEdgeVisibility() {
    cy.edges().forEach(e => {
      const srcV = nodeVisible(e.source());
      const tgtV = nodeVisible(e.target());
      const tagOK = getEdgeTags(e).some(isTagEnabled);
      e.toggleClass('hidden', !(srcV && tgtV && tagOK));
    });
  }


  // Fit to visible NODES only (edges can bloat the bbox)
  function fitVisibleNodes(padding = 12, animate = true) {
    const nodes = cy.nodes(':visible');
    const target = nodes.length ? nodes : cy.elements(':visible');
    const doFit = () => cy.fit(target, padding);
    if (animate) {
      requestAnimationFrame(() => {
        cy.animate({ fit: { eles: target, padding }, duration: 300, easing: 'ease' });
      });
    } else {
      doFit();
    }
  }

  // Pretty layout: dagre on connected, then place orphans to the RIGHT, then fit
  function relayoutPretty() {
    const visEles  = cy.elements(':visible');
    const visNodes = cy.nodes(':visible');
    if (visEles.length === 0) { cy.resize(); cy.fit(cy.elements(), 20); return; }

    const connected = visNodes.filter(n => n.connectedEdges(':visible').length > 0);
    const orphans   = visNodes.filter(n => n.connectedEdges(':visible').length === 0);

    const dagreEles = connected.length
      ? connected.union(connected.connectedEdges(':visible'))
      : visEles;

    let main;
    try {
      main = dagreEles.layout({ name: 'dagre', rankDir: 'LR', animate: true, animationDuration: 300, padding: 20 });
    } catch {
      main = dagreEles.layout({ name: 'breadthfirst', directed: true, animate: true, animationDuration: 300, padding: 20 });
    }

    main.on('layoutstop', () => {
      const preset = placeOrphansRight(connected, orphans);   // <— right-side placement

      const afterAll = () => {
        cy.resize();
        fitVisibleNodes(10, true); // nodes-only fit
      };

      if (preset) {
        preset.on('layoutstop', afterAll);
        preset.run(); // run after binding the event
      } else {
        afterAll();
      }
    });

    main.run();
  }

  // Place orphan nodes on a grid to the RIGHT of the connected graph (or centered if none)
  function placeOrphansRight(connectedNodes, orphans) {
    if (orphans.length === 0) return null;

    // Where to anchor the grid:
    // - If we have a connected subgraph, anchor just to its RIGHT edge.
    // - If not, center in the viewport (nothing to be “right of”).
    let anchorX, anchorY;
    if (connectedNodes.length > 0) {
      const bb = connectedNodes.boundingBox({ includeLabels: true });
      anchorX = (bb.x1 + bb.x2) / 2; // bb.x1; // x center       //bb.x2 // + 100;                  // 100px to the RIGHT of main graph
      anchorY = bb.y2 + 50 //cy.height() //(bb.y1 + bb.y2) / 2; //(bb.y1 + bb.y2) //(bb.y1 + bb.y2) / 2;          // vertically centered with main graph
      
    } else {
      const ext = cy.extent();
      anchorX = (ext.x1 + ext.x2) / 2;        // center if only orphans exist
      anchorY = (ext.y1 + ext.y2) / 2;
    }

    // Grid sizing — prefer more rows if viewport is short
    const count     = orphans.length;
    const spacingX  = 120;   // horizontal gap between columns
    const spacingY  = 90;    // vertical gap between rows
    // mainBB.h // full height of window
    // cy.height()
    const maxRows   = Math.max(1, Math.floor(cy.height() / spacingY) - 1);
    const rows      = Math.min(maxRows, Math.ceil(Math.sqrt(count)));

    const cols      = Math.ceil(count / rows);

    // Compute target positions (columns expand to the RIGHT of anchorX; rows centered around anchorY)
    const positions = {};
    orphans.forEach((n, i) => {
      const col = Math.floor(i / rows);                      // fill down the column first
      const row = i % rows;
      const x = anchorX + (col - (cols - 1) / 2) * spacingX; // center grid around anchorX
      //const x = anchorX + col * spacingX;                    // move rightward by columns
      const y = anchorY + row * spacingY;                      // stack rows downward
      //const y = anchorY + (row - (rows - 1) / 2) * spacingY; // center rows around anchorY
      positions[n.id()] = { x, y };
    });

    orphans.unlock(); // harmless if already unlocked

    // Use preset so we control exact positions
    return orphans.layout({
      name: 'preset',
      positions: node => positions[node.id()],
      fit: false,
      animate: true,
      animationDuration: 220
    });
  }



  

  // ---------- Wire up buttons ----------

  // Node toggle buttons (pressed = visible)
  document.querySelectorAll('[data-node]').forEach(btn => {
    btn.addEventListener('click', () => {
      const id = btn.dataset.node;
      const node = cy.$id(id);
      const willShow = btn.getAttribute('aria-pressed') !== 'true';
      btn.setAttribute('aria-pressed', String(willShow));
      node.toggleClass('hidden', !willShow);
      updateEdgeVisibility();
      relayoutPretty();
      //relayoutPretty();
    });
  });

  // Edge tag toggle buttons (pressed = visible)
  tagButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      const tag = btn.dataset.edgeTag;
      const willEnable = btn.getAttribute('aria-pressed') !== 'true';
      btn.setAttribute('aria-pressed', String(willEnable));
      if (willEnable) enabledEdgeTags.add(tag);
      else enabledEdgeTags.delete(tag);
      updateEdgeVisibility();
      relayoutPretty();
      //relayoutPretty();
    });
  });

  // Nodes: All On / All Off (optional controls)
  document.getElementById('nodes-all-on')?.addEventListener('click', () => {
    cy.nodes().removeClass('hidden');
    document.querySelectorAll('[data-node]').forEach(b => b.setAttribute('aria-pressed', 'true'));
    updateEdgeVisibility();
    relayoutPretty();
    //relayoutPretty();
  });
  document.getElementById('nodes-all-off')?.addEventListener('click', () => {
    cy.nodes().addClass('hidden');
    cy.edges().addClass('hidden');
    document.querySelectorAll('[data-node]').forEach(b => b.setAttribute('aria-pressed', 'false'));
    relayoutPretty();
    //relayoutPretty();
  });

  // Edge tags: All On / All Off (optional controls)
  document.getElementById('edges-all-on')?.addEventListener('click', () => {
    enabledEdgeTags.clear();
    const tags = tagButtons.length ? Array.from(tagButtons).map(b => b.dataset.edgeTag)
                                   : Array.from(allTagsFromEdges());
    tags.forEach(t => enabledEdgeTags.add(t));
    tagButtons.forEach(b => b.setAttribute('aria-pressed', 'true'));
    updateEdgeVisibility();
    relayoutPretty();
    
    relayoutPretty();
  });
  document.getElementById('edges-all-off')?.addEventListener('click', () => {
    enabledEdgeTags.clear();
    tagButtons.forEach(b => b.setAttribute('aria-pressed', 'false'));
    updateEdgeVisibility();
    relayoutPretty();
    
    relayoutPretty();
  });

  // after toggles
  if (typeof updateEdgeVisibility === 'function') updateEdgeVisibility();
    relayoutPretty();
    //relayoutPretty();

  // Prettyfy the layout 
  document.getElementById('prettify-layout')?.addEventListener('click', () => {
    if (typeof updateEdgeVisibility === 'function') updateEdgeVisibility();
    relayoutPretty();
    //relayoutPretty();
  });



  // ---------- Init ----------
  computeEdgeLabels();
  updateEdgeVisibility();
  //relayoutTwice();
  relayoutPretty();
});
