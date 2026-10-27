// Code Wise Academy: builds the 9 wireframe screens as editable Figma frames,
// with colour styles, reusable components and prototype links.
// Colours and copy match lib/theme/app_theme.dart and the Flutter screens.

const W = 360;
const H = 800;
const M = 16; // side margin
const CW = W - M * 2; // content width (328)

const C = {
  black: '#111111',
  card: '#2A2A2A',
  cardLight: '#3A3A3A',
  border: '#666666',
  yellow: '#F5C518',
  white: '#FFFFFF',
  grey: '#AAAAAA',
  green: '#2ECC71',
  greenBg: '#173D28',
  red: '#E74C3C',
  code: '#000000',
  placeholder: '#555555',
};

const STYLE_NAMES = {
  black: 'Black (background)',
  card: 'Card',
  cardLight: 'Card light',
  border: 'Border',
  yellow: 'Yellow (primary)',
  white: 'White',
  grey: 'Grey text',
  green: 'Green (correct)',
  greenBg: 'Green background',
  red: 'Red (log out)',
  code: 'Code background',
};

let MONO = { family: 'Roboto Mono', style: 'Regular' };
const REG = { family: 'Inter', style: 'Regular' };
const MED = { family: 'Inter', style: 'Medium' };
const BOLD = { family: 'Inter', style: 'Bold' };

const styleIds = {}; // hex -> paint style id
const pending = []; // async style bindings to await at the end

function rgb(hex) {
  const n = parseInt(hex.slice(1), 16);
  return { r: ((n >> 16) & 255) / 255, g: ((n >> 8) & 255) / 255, b: (n & 255) / 255 };
}

function paint(hex) {
  return { type: 'SOLID', color: rgb(hex) };
}

function setFill(node, hex) {
  if (!hex) {
    node.fills = [];
    return;
  }
  node.fills = [paint(hex)];
  if (styleIds[hex]) pending.push(node.setFillStyleIdAsync(styleIds[hex]));
}

function setStroke(node, hex, weight) {
  node.strokes = [paint(hex)];
  node.strokeWeight = weight || 1;
  node.strokeAlign = 'INSIDE';
  if (styleIds[hex]) pending.push(node.setStrokeStyleIdAsync(styleIds[hex]));
}

function rect(parent, o) {
  const r = figma.createRectangle();
  r.name = o.name || 'Rectangle';
  r.resize(o.w, o.h);
  r.x = o.x;
  r.y = o.y;
  r.cornerRadius = o.r || 0;
  setFill(r, o.fill);
  if (o.stroke) setStroke(r, o.stroke, o.sw);
  parent.appendChild(r);
  return r;
}

function ellipse(parent, o) {
  const e = figma.createEllipse();
  e.name = o.name || 'Circle';
  e.resize(o.w, o.h || o.w);
  e.x = o.x;
  e.y = o.y;
  setFill(e, o.fill);
  if (o.stroke) setStroke(e, o.stroke, o.sw);
  parent.appendChild(e);
  return e;
}

function line(parent, x, y, w, hex) {
  return rect(parent, { name: 'Divider', x, y, w, h: 1, fill: hex || C.card });
}

// Text. o.w makes it a fixed-width box (needed for centre/right alignment and wrapping).
function text(parent, str, o) {
  const t = figma.createText();
  t.fontName = o.font || (o.bold ? BOLD : o.medium ? MED : REG);
  t.characters = str;
  t.fontSize = o.size || 14;
  t.name = o.name || str.slice(0, 30);
  setFill(t, o.color || C.white);
  if (o.ls) t.letterSpacing = { value: o.ls, unit: 'PERCENT' };
  if (o.lh) t.lineHeight = { value: o.lh, unit: 'PERCENT' };
  if (o.w) {
    t.textAutoResize = 'HEIGHT';
    t.resize(o.w, t.height);
    t.textAlignHorizontal = o.align || 'LEFT';
  }
  t.x = o.x;
  t.y = o.y;
  parent.appendChild(t);
  return t;
}

// Colours part of a text node, e.g. "WISE" in "CODE WISE".
function colourRange(t, part, hex, bold) {
  const start = t.characters.indexOf(part);
  if (start < 0) return;
  t.setRangeFills(start, start + part.length, [paint(hex)]);
  if (bold) t.setRangeFontName(start, start + part.length, BOLD);
}

function triangle(parent, x, y, w, h, hex) {
  const p = figma.createVector();
  p.name = 'Play';
  p.vectorPaths = [{ windingRule: 'NONZERO', data: `M 0 0 L ${w} ${h / 2} L 0 ${h} Z` }];
  p.x = x;
  p.y = y;
  setFill(p, hex);
  parent.appendChild(p);
  return p;
}

function eyeIcon(parent, x, y) {
  const g = [];
  g.push(ellipse(parent, { name: 'Eye', x, y, w: 16, h: 10, stroke: C.grey, sw: 1.5 }));
  g.push(ellipse(parent, { name: 'Pupil', x: x + 5.5, y: y + 2.5, w: 5, fill: C.grey }));
  return figma.group(g, parent);
}

function lockIcon(parent, x, y) {
  const g = [];
  g.push(rect(parent, { name: 'Shackle', x: x + 2, y, w: 8, h: 8, r: 4, stroke: C.grey, sw: 1.5 }));
  g.push(rect(parent, { name: 'Body', x, y: y + 5, w: 12, h: 9, r: 2, fill: C.grey }));
  const grp = figma.group(g, parent);
  grp.name = 'Lock';
  return grp;
}

function frame(name, x) {
  const f = figma.createFrame();
  f.name = name;
  f.resize(W, H);
  f.x = x;
  f.y = 0;
  f.cornerRadius = 0;
  f.clipsContent = true;
  setFill(f, C.black);
  figma.currentPage.appendChild(f);
  // Status bar
  text(f, '9:41', { x: M, y: 8, size: 11, color: C.grey, name: 'Time' });
  rect(f, { name: 'Battery', x: W - M - 18, y: 10, w: 18, h: 8, r: 2, fill: C.grey });
  return f;
}

function progressBar(parent, x, y, w, pct, h) {
  h = h || 8;
  const track = rect(parent, { name: 'Track', x, y, w, h, r: h / 2, fill: C.cardLight });
  const fill = rect(parent, { name: 'Fill', x, y, w: Math.max(h, w * pct), h, r: h / 2, fill: C.yellow });
  const g = figma.group([track, fill], parent);
  g.name = 'Progress bar ' + Math.round(pct * 100) + '%';
  return g;
}

function logo(parent, x, y, size) {
  const box = rect(parent, { name: 'Logo box', x, y, w: size, h: size, r: size * 0.2, fill: C.yellow });
  const t = text(parent, '</>', {
    x,
    y: 0,
    w: size,
    align: 'CENTER',
    size: size * 0.38,
    bold: true,
    color: C.black,
    name: 'Logo code',
  });
  t.y = y + (size - t.height) / 2;
  const g = figma.group([box, t], parent);
  g.name = 'Logo';
  return g;
}

function appBar(parent, title, leading, trailing) {
  const lead = text(parent, leading || '←', { x: M, y: 38, size: 20, bold: true, color: C.yellow, name: 'Back' });
  text(parent, title, { x: 48, y: 40, size: 18, bold: true, name: 'App bar title' });
  if (trailing) text(parent, trailing, { x: W - M - 60, y: 44, w: 60, align: 'RIGHT', size: 12, color: C.grey, name: 'Step' });
  line(parent, 0, 80, W);
  return lead;
}

function plainHeader(parent, title) {
  text(parent, title, { x: M, y: 40, size: 18, bold: true, name: 'Header title' });
  line(parent, 0, 80, W);
}

function codeBox(parent, x, y, w, code) {
  const lines = code.split('\n').length;
  const h = 24 + lines * 19;
  rect(parent, { name: 'Code box', x, y, w, h, r: 8, fill: C.code, stroke: '#333333', sw: 1 });
  text(parent, code, { x: x + 12, y: y + 12, size: 12.5, font: MONO, color: C.yellow, lh: 150, name: 'Code' });
  return h;
}

// ---------- Components ----------

function findText(node, name) {
  return node.findOne((n) => n.type === 'TEXT' && n.name === name);
}

function buildComponents(x, y) {
  const page = figma.currentPage;
  const board = figma.createFrame();
  board.name = 'Components';
  board.x = x;
  board.y = y;
  board.resize(760, 420);
  setFill(board, '#1E1E1E');
  page.appendChild(board);
  text(board, 'Components', { x: 24, y: 20, size: 20, bold: true });

  function comp(name, cx, cy, w, h) {
    const c = figma.createComponent();
    c.name = name;
    c.resize(w, h);
    c.x = cx;
    c.y = cy;
    c.fills = [];
    board.appendChild(c);
    return c;
  }

  function centredLabel(c, str, hex, size) {
    const t = text(c, str, { x: 0, y: 0, w: c.width, align: 'CENTER', size: size || 15, bold: true, color: hex, name: 'Label' });
    t.y = (c.height - t.height) / 2;
    t.constraints = { horizontal: 'STRETCH', vertical: 'CENTER' };
    return t;
  }

  const primary = comp('Button / Yellow', 24, 70, CW, 48);
  setFill(primary, C.yellow);
  primary.cornerRadius = 10;
  centredLabel(primary, 'BUTTON', C.black);

  const outline = comp('Button / Outline', 24, 134, CW, 48);
  outline.cornerRadius = 10;
  setStroke(outline, C.yellow, 2);
  centredLabel(outline, 'Button', C.yellow);

  const field = comp('Text field', 24, 198, CW, 48);
  field.cornerRadius = 10;
  setStroke(field, C.border, 1.5);
  const ph = text(field, 'Placeholder', { x: 14, y: 15, size: 14, color: C.grey, name: 'Placeholder' });
  ph.constraints = { horizontal: 'MIN', vertical: 'CENTER' };

  const card = comp('Course card', 24, 262, CW, 96);
  card.cornerRadius = 12;
  setFill(card, C.card);
  setStroke(card, C.cardLight, 1);
  rect(card, { name: 'Image', x: 10, y: 10, w: 76, h: 76, r: 8, fill: C.cardLight });
  text(card, 'IMG', { x: 10, y: 40, w: 76, align: 'CENTER', size: 11, color: C.grey, name: 'Image label' });
  text(card, 'Course title', { x: 100, y: 18, size: 15, bold: true, name: 'Title' });
  text(card, 'Beginner · 24 lessons', { x: 100, y: 42, size: 11.5, color: C.grey, name: 'Meta' });
  text(card, '★ 4.8', { x: 100, y: 62, size: 11.5, color: C.grey, name: 'Rating' });

  const nav = comp('Bottom nav', 380, 70, W, 64);
  setFill(nav, C.black);
  line(nav, 0, 0, W, C.card);
  const tabs = ['Home', 'My Learning', 'Profile'];
  tabs.forEach((label, i) => {
    const tab = figma.createFrame();
    tab.name = 'Tab / ' + label;
    tab.resize(W / 3, 64);
    tab.x = (W / 3) * i;
    tab.y = 0;
    tab.fills = [];
    nav.appendChild(tab);
    rect(tab, { name: 'Icon', x: W / 6 - 9, y: 12, w: 18, h: 18, r: 4, fill: C.placeholder });
    text(tab, label, { x: 0, y: 36, w: W / 3, align: 'CENTER', size: 11, color: C.grey, name: 'Tab label' });
  });

  return { primary, outline, field, card, nav, board };
}

function place(parent, component, x, y, w) {
  const inst = component.createInstance();
  parent.appendChild(inst);
  inst.x = x;
  inst.y = y;
  if (w) inst.resize(w, inst.height);
  return inst;
}

function button(parent, comp, label, x, y, w) {
  const b = place(parent, comp, x, y, w);
  findText(b, 'Label').characters = label;
  b.name = label;
  return b;
}

function field(parent, comp, placeholder, y, eye) {
  const f = place(parent, comp, M, y);
  findText(f, 'Placeholder').characters = placeholder;
  f.name = 'Field / ' + placeholder;
  if (eye) eyeIcon(parent, M + CW - 30, y + 19);
  return f;
}

function courseCard(parent, comp, y, title, meta, rating) {
  const c = place(parent, comp, M, y);
  findText(c, 'Title').characters = title;
  findText(c, 'Meta').characters = meta;
  const r = findText(c, 'Rating');
  r.characters = '★ ' + rating;
  r.setRangeFills(0, 1, [paint(C.yellow)]);
  c.name = 'Course card / ' + title;
  return c;
}

function bottomNav(parent, comp, active) {
  const n = place(parent, comp, 0, H - 64);
  const tab = n.findOne((x) => x.name === 'Tab / ' + active);
  tab.findOne((x) => x.name === 'Icon').fills = [paint(C.yellow)];
  const label = tab.findOne((x) => x.name === 'Tab label');
  label.fills = [paint(C.yellow)];
  label.fontName = BOLD;
  return n;
}

// ---------- Screens ----------

function splash(x) {
  const f = frame('01 Splash', x);
  logo(f, (W - 110) / 2, 230, 110);
  const t = text(f, 'CODE WISE', { x: 0, y: 366, w: W, align: 'CENTER', size: 30, bold: true, name: 'Wordmark' });
  colourRange(t, 'WISE', C.yellow);
  text(f, 'ACADEMY', { x: 0, y: 406, w: W, align: 'CENTER', size: 15, medium: true, ls: 40, name: 'Academy' });
  text(f, 'Learn to code, one lesson at a time', { x: 0, y: 440, w: W, align: 'CENTER', size: 13, color: '#DDDDDD', name: 'Tagline' });
  progressBar(f, 86, 520, 188, 0.45, 6);
  return f;
}

function signUp(x, k) {
  const f = frame('02 Sign Up', x);
  logo(f, M, 46, 58);
  text(f, 'Create account', { x: M, y: 122, size: 26, bold: true, name: 'Title' });
  text(f, 'Start learning to code today', { x: M, y: 158, size: 13, color: C.grey, name: 'Subtitle' });
  field(f, k.field, 'Full name', 196);
  field(f, k.field, 'Email', 256);
  field(f, k.field, 'Password', 316, true);
  field(f, k.field, 'Confirm password', 376, true);
  rect(f, { name: 'Checkbox', x: M, y: 442, w: 16, h: 16, r: 3, stroke: C.yellow, sw: 1.5 });
  text(f, 'I agree to the Terms & Privacy', { x: 42, y: 442, size: 12, name: 'Terms' });
  const go = button(f, k.primary, 'SIGN UP', M, 478);
  const link = text(f, 'Already have an account? Log in', { x: 0, y: 548, w: W, align: 'CENTER', size: 13, color: C.grey, name: 'Log in link' });
  colourRange(link, 'Log in', C.yellow, true);
  return { f, go, link };
}

function login(x, k) {
  const f = frame('03 Login', x);
  logo(f, M, 76, 58);
  text(f, 'Welcome back', { x: M, y: 152, size: 26, bold: true, name: 'Title' });
  text(f, 'Log in to continue learning', { x: M, y: 188, size: 13, color: C.grey, name: 'Subtitle' });
  field(f, k.field, 'Email', 232);
  field(f, k.field, 'Password', 292, true);
  text(f, 'Forgot password?', { x: M, y: 352, w: CW, align: 'RIGHT', size: 12, medium: true, color: C.yellow, name: 'Forgot password' });
  const go = button(f, k.primary, 'LOG IN', M, 386);
  line(f, 100, 465, 66, C.border);
  line(f, 194, 465, 66, C.border);
  text(f, 'or', { x: 0, y: 456, w: W, align: 'CENTER', size: 12, color: C.grey, name: 'or' });
  const google = button(f, k.outline, 'Continue with Google', M, 484);
  const link = text(f, 'New here? Create account', { x: 0, y: 566, w: W, align: 'CENTER', size: 13, color: C.grey, name: 'Create account link' });
  colourRange(link, 'Create account', C.yellow, true);
  return { f, go, google, link };
}

function catalog(x, k) {
  const f = frame('04 Course Catalog', x);
  text(f, 'Hi, Student 👋', { x: M, y: 36, size: 12, color: C.grey, name: 'Greeting' });
  text(f, 'What will you code today?', { x: M, y: 52, size: 20, bold: true, name: 'Title' });
  ellipse(f, { name: 'Avatar', x: W - M - 40, y: 34, w: 40, fill: C.placeholder });
  const search = field(f, k.field, 'Search courses', 96);
  findText(search, 'Placeholder').characters = '      Search courses';
  ellipse(f, { name: 'Search icon', x: M + 14, y: 112, w: 11, stroke: C.grey, sw: 1.5 });
  const handle = rect(f, { name: 'Search handle', x: M + 24, y: 121, w: 6, h: 1.5, fill: C.grey });
  handle.rotation = -45;
  const chips = [['All', 42], ['Python', 66], ['Dart', 50], ['JavaScript', 86], ['SQL', 48]];
  let cx = M;
  chips.forEach(([label, w], i) => {
    rect(f, { name: 'Chip / ' + label, x: cx, y: 156, w, h: 28, r: 14, fill: i === 0 ? C.yellow : null, stroke: i === 0 ? null : C.border, sw: 1 });
    text(f, label, { x: cx, y: 163, w, align: 'CENTER', size: 11.5, bold: i === 0, color: i === 0 ? C.black : C.white, name: label });
    cx += w + 6;
  });
  text(f, 'Popular courses', { x: M, y: 200, size: 15, bold: true, name: 'Section' });
  const first = courseCard(f, k.card, 228, 'Python for Beginners', 'Beginner · 24 lessons', '4.8');
  courseCard(f, k.card, 336, 'Flutter & Dart Basics', 'Beginner · 30 lessons', '4.7');
  courseCard(f, k.card, 444, 'JavaScript Essentials', 'Intermediate · 28 lessons', '4.6');
  bottomNav(f, k.nav, 'Home');
  return { f, first };
}

function details(x, k) {
  const f = frame('05 Course Details', x);
  const back = appBar(f, 'Course details');
  rect(f, { name: 'Banner', x: 0, y: 81, w: W, h: 175, fill: C.cardLight });
  text(f, 'COURSE BANNER IMAGE', { x: 0, y: 162, w: W, align: 'CENTER', size: 12, color: C.grey, name: 'Banner label' });
  text(f, 'Python for Beginners', { x: M, y: 272, size: 22, bold: true, name: 'Course title' });
  const meta = text(f, 'Beginner · 24 lessons · 6 hours · ★ 4.8', { x: M, y: 306, size: 12, color: C.grey, name: 'Meta' });
  colourRange(meta, '★ 4.8', C.yellow);
  text(f, 'Learn variables, loops, functions and lists by writing real code in every lesson.', {
    x: M, y: 330, w: CW, size: 12.5, color: '#CCCCCC', lh: 140, name: 'Description',
  });
  text(f, 'Lessons', { x: M, y: 382, size: 15, bold: true, name: 'Section' });
  rect(f, { name: 'Lessons card', x: M, y: 408, w: CW, h: 132, r: 10, fill: C.card, stroke: C.cardLight, sw: 1 });
  const rows = ['1. Hello, Python', '2. Variables & Types', '3. Loops'];
  rows.forEach((label, i) => {
    const ry = 408 + i * 44;
    if (i > 0) line(f, M, ry, CW, C.cardLight);
    if (i < 2) {
      triangle(f, M + 14, ry + 16, 11, 12, C.yellow);
      text(f, label, { x: M + 36, y: ry + 14, size: 13, name: label });
    } else {
      lockIcon(f, M + 14, ry + 14);
      text(f, label, { x: M + 36, y: ry + 14, size: 13, color: C.grey, name: label + ' (locked)' });
    }
  });
  const enrol = button(f, k.primary, 'ENROL NOW', M, 556);
  return { f, back, enrol };
}

function lesson(x, k) {
  const f = frame('06 Lesson Player', x);
  const back = appBar(f, 'Lesson 2 of 24');
  rect(f, { name: 'Video', x: 0, y: 81, w: W, h: 195, fill: C.cardLight });
  triangle(f, 142, 160, 30, 34, C.yellow);
  text(f, 'VIDEO', { x: 184, y: 170, size: 12, color: C.grey, name: 'Video label' });
  rect(f, { name: 'Video track', x: 0, y: 276, w: W, h: 6, fill: C.placeholder });
  rect(f, { name: 'Video progress', x: 0, y: 276, w: 126, h: 6, fill: C.yellow });
  text(f, 'Variables & Types', { x: M, y: 300, size: 20, bold: true, name: 'Lesson title' });
  text(f, 'A variable stores a value. Python works out the type for you.', {
    x: M, y: 332, w: CW, size: 12.5, color: '#CCCCCC', lh: 140, name: 'Lesson text',
  });
  const h = codeBox(f, M, 378, CW, 'name = "Ada"\nage = 21\nprint(name, age)');
  text(f, 'Try changing the values and predict what will print.', { x: M, y: 378 + h + 14, w: CW, size: 12.5, color: '#CCCCCC', name: 'Hint' });
  const start = button(f, k.primary, 'START EXERCISE  →', M, 512);
  text(f, '← Previous', { x: M, y: 582, size: 12.5, color: C.grey, name: 'Previous' });
  const next = text(f, 'Next lesson →', { x: M, y: 582, w: CW, align: 'RIGHT', size: 12.5, medium: true, color: C.yellow, name: 'Next lesson' });
  return { f, back, start, next };
}

function exercise(x, k) {
  const f = frame('07 Coding Exercise', x);
  const close = appBar(f, 'Exercise', '✕', '2 / 5');
  progressBar(f, M, 96, CW, 0.4, 6);
  text(f, 'What will this code print?', { x: M, y: 118, size: 16, bold: true, name: 'Question' });
  codeBox(f, M, 150, CW, 'x = 3\ny = x * 2\nprint(y + 1)');
  const options = ['6', '7', '8', 'Error'];
  options.forEach((label, i) => {
    const oy = 248 + i * 56;
    const right = label === '7';
    rect(f, { name: 'Option / ' + label, x: M, y: oy, w: CW, h: 46, r: 8, fill: right ? C.greenBg : null, stroke: right ? C.green : C.border, sw: right ? 1.5 : 1 });
    ellipse(f, { name: 'Radio', x: M + 14, y: oy + 15, w: 16, fill: right ? C.green : null, stroke: right ? null : C.grey, sw: 1.5 });
    text(f, label, { x: M + 42, y: oy + 14, size: 14, name: label });
  });
  rect(f, { name: 'Feedback card', x: M, y: 478, w: CW, h: 62, r: 10, fill: C.greenBg, stroke: C.green, sw: 1.5 });
  text(f, '✓ Correct!', { x: M + 14, y: 489, size: 14, bold: true, color: C.green, name: 'Correct' });
  text(f, 'y is 6, so y + 1 prints 7.', { x: M + 14, y: 513, size: 11.5, color: '#DDDDDD', name: 'Explanation' });
  const cont = button(f, k.primary, 'CONTINUE', M, 556);
  return { f, close, cont };
}

function progress(x, k) {
  const f = frame('08 Progress Dashboard', x);
  plainHeader(f, 'My Learning');
  const stats = [['🔥 5', 'day streak'], ['18', 'lessons done'], ['86%', 'quiz score']];
  stats.forEach(([num, label], i) => {
    const sx = M + i * 112;
    rect(f, { name: 'Stat / ' + label, x: sx, y: 100, w: 104, h: 74, r: 10, fill: C.card, stroke: C.cardLight, sw: 1 });
    text(f, num, { x: sx, y: 112, w: 104, align: 'CENTER', size: 24, bold: true, color: C.yellow, name: 'Number' });
    text(f, label, { x: sx, y: 148, w: 104, align: 'CENTER', size: 11, color: C.grey, name: label });
  });
  rect(f, { name: 'Continue card', x: M, y: 190, w: CW, h: 112, r: 12, fill: C.yellow });
  text(f, 'CONTINUE LEARNING', { x: M + 14, y: 204, size: 10.5, bold: true, ls: 4, color: C.black, name: 'Eyebrow' });
  text(f, 'Python · Lesson 3: Loops', { x: M + 14, y: 222, size: 16, bold: true, color: C.black, name: 'Current lesson' });
  const resumeBox = rect(f, { name: 'Resume bg', x: M + 14, y: 256, w: 92, h: 32, r: 6, fill: C.black });
  const resumeText = text(f, 'Resume ▶', { x: M + 14, y: 264, w: 92, align: 'CENTER', size: 12.5, bold: true, color: C.yellow, name: 'Resume label' });
  const resume = figma.group([resumeBox, resumeText], f);
  resume.name = 'Resume button';
  text(f, 'My courses', { x: M, y: 320, size: 15, bold: true, name: 'Section' });
  const courses = [['Python for Beginners', 0.5, '12 of 24 lessons'], ['Flutter & Dart Basics', 0.2, '6 of 30 lessons']];
  courses.forEach(([title, pct, meta], i) => {
    const cy = 348 + i * 90;
    rect(f, { name: 'Course progress / ' + title, x: M, y: cy, w: CW, h: 78, r: 10, fill: C.card, stroke: C.cardLight, sw: 1 });
    text(f, title, { x: M + 14, y: cy + 14, size: 14, bold: true, name: 'Title' });
    text(f, Math.round(pct * 100) + '%', { x: M, y: cy + 14, w: CW - 14, align: 'RIGHT', size: 14, bold: true, color: C.yellow, name: 'Percent' });
    progressBar(f, M + 14, cy + 38, CW - 28, pct, 6);
    text(f, meta, { x: M + 14, y: cy + 52, size: 11, color: C.grey, name: 'Meta' });
  });
  bottomNav(f, k.nav, 'My Learning');
  return { f, resume };
}

function profile(x, k) {
  const f = frame('09 Profile', x);
  plainHeader(f, 'Profile');
  ellipse(f, { name: 'Avatar', x: (W - 92) / 2, y: 104, w: 92, fill: C.placeholder, stroke: C.yellow, sw: 3 });
  text(f, 'Student Name', { x: 0, y: 212, w: W, align: 'CENTER', size: 20, bold: true, name: 'Name' });
  text(f, 'student@email.com', { x: 0, y: 242, w: W, align: 'CENTER', size: 12.5, color: C.grey, name: 'Email' });
  const edit = button(f, k.outline, 'Edit profile', (W - 154) / 2, 272, 154);
  edit.resize(154, 38);
  findText(edit, 'Label').fontSize = 13;
  const rows = ['My certificates', 'Notifications', 'Settings', 'Help & support'];
  rect(f, { name: 'Settings card', x: M, y: 334, w: CW, h: rows.length * 56, r: 10, fill: C.card, stroke: C.cardLight, sw: 1 });
  rows.forEach((label, i) => {
    const ry = 334 + i * 56;
    if (i > 0) line(f, M, ry, CW, C.cardLight);
    rect(f, { name: 'Icon', x: M + 14, y: ry + 16, w: 24, h: 24, r: 5, fill: C.placeholder });
    text(f, label, { x: M + 50, y: ry + 19, size: 14, name: label });
    text(f, '›', { x: M + CW - 26, y: ry + 15, size: 18, color: C.grey, name: 'Chevron' });
  });
  const logout = button(f, k.outline, 'Log out', M, 574);
  logout.strokes = [paint(C.red)];
  findText(logout, 'Label').fills = [paint(C.red)];
  bottomNav(f, k.nav, 'Profile');
  return { f, logout };
}

// ---------- Prototype ----------

function go(dest, timeout) {
  return {
    trigger: timeout ? { type: 'AFTER_TIMEOUT', timeout } : { type: 'ON_CLICK' },
    actions: [
      {
        type: 'NODE',
        destinationId: dest.id,
        navigation: 'NAVIGATE',
        transition: { type: 'DISSOLVE', easing: { type: 'EASE_OUT' }, duration: 0.3 },
        preserveScrollPosition: false,
      },
    ],
  };
}

async function link(node, dest, timeout) {
  const existing = node.reactions || [];
  await node.setReactionsAsync(existing.concat([go(dest, timeout)]));
}

// ---------- Run ----------

async function main() {
  await Promise.all([REG, MED, BOLD].map((f) => figma.loadFontAsync(f)));
  try {
    await figma.loadFontAsync(MONO);
  } catch (e) {
    MONO = REG;
  }

  const page = figma.createPage();
  page.name = 'Code Wise Academy Wireframes';
  await figma.setCurrentPageAsync(page);

  for (const key of Object.keys(STYLE_NAMES)) {
    const s = figma.createPaintStyle();
    s.name = 'Code Wise/' + STYLE_NAMES[key];
    s.paints = [paint(C[key])];
    styleIds[C[key]] = s.id;
  }

  const GAP = 80;
  const col = (i) => i * (W + GAP);
  const k = buildComponents(0, H + 120);

  const s1 = splash(col(0));
  const s2 = signUp(col(1), k);
  const s3 = login(col(2), k);
  const s4 = catalog(col(3), k);
  const s5 = details(col(4), k);
  const s6 = lesson(col(5), k);
  const s7 = exercise(col(6), k);
  const s8 = progress(col(7), k);
  const s9 = profile(col(8), k);

  await link(s1, s3.f, 2000);
  await link(s3.go, s4.f);
  await link(s3.google, s4.f);
  await link(s3.link, s2.f);
  await link(s2.go, s4.f);
  await link(s2.link, s3.f);
  await link(s4.first, s5.f);
  await link(s5.back, s4.f);
  await link(s5.enrol, s6.f);
  await link(s6.back, s5.f);
  await link(s6.start, s7.f);
  await link(s7.close, s6.f);
  await link(s7.cont, s8.f);
  await link(s8.resume, s6.f);
  await link(s9.logout, s3.f);
  // Tabs on the main bottom-nav component, so every instance navigates.
  const tabDest = { Home: s4.f, 'My Learning': s8.f, Profile: s9.f };
  for (const name of Object.keys(tabDest)) {
    await link(k.nav.findOne((n) => n.name === 'Tab / ' + name), tabDest[name]);
  }

  page.flowStartingPoints = [{ nodeId: s1.id, name: 'Code Wise demo' }];

  await Promise.all(pending);
  figma.viewport.scrollAndZoomIntoView(page.children);
  figma.closePlugin('Built 9 Code Wise Academy screens with prototype links.');
}

main().catch((e) => figma.closePlugin('Error: ' + (e && e.message ? e.message : e)));
