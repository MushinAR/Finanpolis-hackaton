const params = new URLSearchParams(location.search);
const STORE_KEY = "mushin.v2"; // { last, players: { alias en minúscula: perfil } }
const YEAR = 360; // 12 meses de 30 días en el reloj del juego
const START_TOKENS = params.has("tokens") ? Number(params.get("tokens")) || 0 : 500;
const DAILY_BASE = 100; // tokens de práctica por día, +10 por cada día seguido (tope +100)

// Activos ficticios del mundo del juego. tna = tasa nominal anual, every = cada cuántos días capitaliza.
const ASSETS = [
  { code: "AHRR", emoji: "🐷", name: "Ahorro Estable", kind: "TOKEN", tna: 0.06, risk: 1, every: 1, color: "--purple-hi",
    desc: "Token estable. Crece de a poquito pero casi nunca baja. Ideal para arrancar." },
  { code: "MUSH", emoji: "🍄", name: "Mushin Token", kind: "TOKEN", tna: 0.12, risk: 2, every: 1, color: "--green",
    desc: "Token de la plataforma. Te paga recompensas todos los días por tenerlo (staking)." },
  { code: "FNPE", emoji: "⚡", name: "Finanpolis Energía", kind: "ACCIÓN", tna: 0.09, risk: 2, every: 30, color: "--amber",
    desc: "Acción tokenizada. Paga dividendos cada mes y se reinvierten solos." },
  { code: "AGRO", emoji: "🌱", name: "AgroCampo", kind: "ACCIÓN", tna: 0.14, risk: 3, every: 30, color: "--cyan",
    desc: "Acción tokenizada del campo. Rinde más, pero su precio sube y baja." },
  { code: "PIXL", emoji: "👾", name: "Pixel Studios", kind: "ACCIÓN", tna: 0.2, risk: 4, every: 30, color: "--pink",
    desc: "Estudio de videojuegos. Puede crecer un montón… o tener días muy malos." },
];
const RISK_VOL = [0, 0, 0.001, 0.004, 0.009];
const RISK_TXT = ["", "MUY BAJO", "BAJO", "MEDIO", "ALTO"];

const AVATARS = ["🦊", "🐸", "🐼", "🦄", "🐙", "🤖", "🐱", "👾"];
const GOALS = [
  { id: "consola", emoji: "🎮", label: "Una consola", amt: 3000 },
  { id: "moto", emoji: "🛵", label: "Una moto", amt: 12000 },
  { id: "estudiar", emoji: "🎓", label: "Estudiar", amt: 5000 },
  { id: "viajar", emoji: "✈️", label: "Viajar", amt: 8000 },
  { id: "casa", emoji: "🏠", label: "Mi casa", amt: 50000 },
];

// Ítems que se compran con FNP. El id es el que recibe el juego en el evento item_bought.
const SHOP = [
  { id: "pizza", emoji: "🍕", name: "Pizza", price: 120, desc: "Te pone de buen humor (y deja una caja para tirar)." },
  { id: "shirt", emoji: "👕", name: "Remera nueva", price: 250, desc: "Ropa limpia, menos estrés." },
  { id: "book", emoji: "📘", name: "Libro de finanzas", price: 300, desc: "Aprendés algo nuevo y subís la felicidad." },
  { id: "lamp", emoji: "💡", name: "Lámpara", price: 600, desc: "Más luz para tu cuarto." },
  { id: "chair", emoji: "🪑", name: "Silla gamer", price: 1500, desc: "Usar la compu cansa menos." },
  { id: "bed", emoji: "🛏️", name: "Cama nueva", price: 2500, desc: "Dormís mejor y recuperás más energía." },
  { id: "console", emoji: "🕹️", name: "Consola retro", price: 3000, desc: "Diversión pura para los días libres." },
];

function defaults() {
  return {
    account: null,
    cash: START_TOKENS,
    day: 0,
    positions: [],
    history: [],
    ledger: [],
    alerts: [],
    inventory: [],
    lastClaim: -1,
    streak: 0,
    tutorialDone: false,
    goalHit: false,
    speed: 1,
    selected: "AHRR",
  };
}

const state = defaults();

const $ = (id) => document.getElementById(id);

function rnd(n) {
  return (Math.random() * 2 - 1) * n;
}

function fmt(n) {
  return Math.round(n).toString().replace(/\B(?=(\d{3})+(?!\d))/g, " ");
}

function money(n) {
  return fmt(n) + " FNP";
}

function signed(n) {
  return (n >= 0 ? "+" : "-") + money(Math.abs(n));
}

function playerKey(alias) {
  return alias.toLowerCase();
}

function validName(name) {
  return /^[A-Za-z0-9_]{3,16}$/.test(name);
}

function wait(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

function asset(code) {
  return ASSETS.find((a) => a.code === code);
}

function posValue(p) {
  return p.value + p.accrued;
}

function invested() {
  return state.positions.reduce((s, p) => s + p.invested, 0);
}

function portfolio() {
  return state.positions.reduce((s, p) => s + posValue(p), 0);
}

function total() {
  return state.cash + portfolio();
}

function interest() {
  return portfolio() - invested();
}

// tasa promedio ponderada de todo el patrimonio (la plata en billetera no rinde)
function effectiveRate() {
  const t = total();
  if (!t) return 0;
  return state.positions.reduce((s, p) => s + asset(p.code).tna * posValue(p), 0) / t;
}

function dateLabel(day) {
  const y = Math.floor(day / YEAR) + 1;
  const m = Math.floor((day % YEAR) / 30) + 1;
  const d = (day % 30) + 1;
  return `AÑO ${y} · MES ${m} · DÍA ${d}`;
}

function cssVar(name) {
  return getComputedStyle(document.documentElement).getPropertyValue(name).trim();
}

/* PERSISTENCIA */

function readStore() {
  try {
    const s = JSON.parse(localStorage.getItem(STORE_KEY));
    if (s && s.players) return s;
  } catch (e) {}
  return { last: "", players: {} };
}

function writeStore(s) {
  try {
    localStorage.setItem(STORE_KEY, JSON.stringify(s));
  } catch (e) {}
}

function save() {
  if (!state.account) return;
  const { account, cash, day, positions, history, ledger, inventory, lastClaim, streak, tutorialDone, goalHit } = state;
  const s = readStore();
  s.players[playerKey(account.alias)] = {
    account, cash, day, positions, history, ledger, inventory, lastClaim, streak, tutorialDone, goalHit,
  };
  s.last = account.alias;
  writeStore(s);
}

// Carga un perfil guardado (o deja el estado limpio si no existe).
function loadProfile(alias) {
  const saved = readStore().players[playerKey(alias)];
  Object.assign(state, defaults(), saved || {});
  posSig = null;
  return Boolean(saved);
}

function deleteProfile(alias) {
  const s = readStore();
  delete s.players[playerKey(alias)];
  if (playerKey(s.last || "") === playerKey(alias)) s.last = "";
  writeStore(s);
}

/* SIMULACIÓN */

function pushAlert(msg) {
  state.alerts.unshift(`[D${state.day + 1}] ${msg}`);
  state.alerts = state.alerts.slice(0, 8);
}

function advanceDay() {
  state.day += 1;
  state.positions.forEach((p) => {
    const a = asset(p.code);
    p.accrued += p.value * (a.tna / YEAR);
    if (state.day % a.every === 0) {
      p.value += p.accrued;
      p.accrued = 0;
    }
    p.value *= 1 + rnd(RISK_VOL[a.risk]);
  });
  state.history.push(total());
  state.history = state.history.slice(-180);

  if (state.day % 30 === 0 && state.positions.length) {
    const g = interest();
    pushAlert(g >= 0
      ? `🦉 Pasó un mes. Tus inversiones ya generaron ${money(g)} solas.`
      : `🦉 Mes movido: vas ${signed(g)}. Los activos con riesgo suben y bajan, paciencia.`);
  }
  checkGoal();
}

function advanceDays(n) {
  for (let i = 0; i < n; i++) advanceDay();
  render();
  save();
}

function checkGoal() {
  if (!state.account || state.goalHit) return;
  if (total() >= state.account.goal.amt) {
    state.goalHit = true;
    pushAlert(`🎉 ¡LLEGASTE A TU META: ${state.account.goal.emoji} ${state.account.goal.label}!`);
    Bridge.emit("goal_reached", { goal: state.account.goal, total: total() });
  }
}

function logOp(op, code, amount, tx) {
  state.ledger.unshift({ day: state.day + 1, op, code, amount, hash: tx.hash });
  state.ledger = state.ledger.slice(0, 30);
}

let busy = false;

async function invest(code, amount) {
  amount = Math.floor(amount);
  if (busy || !state.account) return false;
  if (!(amount > 0)) return say("Poné un monto mayor a 0.");
  if (amount > state.cash) return say("No te alcanzan los tokens de la billetera.");
  busy = true;
  const tx = await Stellar.submit({ type: "invest", code, amount, from: state.account.publicKey });
  busy = false;
  const first = state.positions.length === 0;
  state.cash -= amount;
  let p = state.positions.find((x) => x.code === code);
  if (!p) {
    p = { code, invested: 0, value: 0, accrued: 0 };
    state.positions.push(p);
  }
  p.invested += amount;
  p.value += amount;
  logOp("INVERTIR", code, amount, tx);
  const a = asset(code);
  pushAlert(`Invertiste ${money(amount)} en ${a.emoji} ${code}.`);
  if (first) pushAlert("🦉 ¡Primera inversión! Ahora dejá que el tiempo haga su magia.");
  if (a.risk >= 4) pushAlert(`🦉 ${code} es de riesgo ALTO. Tip: no pongas todo en un solo lugar.`);
  Bridge.emit("invest", { code, amount, tx: tx.hash });
  Bridge.emit("tokens_changed", { tokens: state.cash });
  save();
  render();
  return true;
}

async function withdraw(code) {
  const p = state.positions.find((x) => x.code === code);
  if (busy || !p) return false;
  busy = true;
  const amount = Math.floor(posValue(p));
  const tx = await Stellar.submit({ type: "withdraw", code, amount, to: state.account.publicKey });
  busy = false;
  state.positions = state.positions.filter((x) => x !== p);
  state.cash += amount;
  logOp("RETIRAR", code, amount, tx);
  pushAlert(`Retiraste ${money(amount)} de ${code} (${signed(amount - p.invested)}).`);
  pushAlert("🦉 Ojo: los tokens que sacás dejan de crecer.");
  Bridge.emit("withdraw", { code, amount, tx: tx.hash });
  Bridge.emit("tokens_changed", { tokens: state.cash });
  save();
  render();
  return true;
}

function dailyReward() {
  const streak = state.lastClaim === state.day - 1 ? state.streak + 1 : 1;
  return { streak, amount: DAILY_BASE + Math.min(streak - 1, 10) * 10 };
}

function canClaim() {
  return state.lastClaim < state.day;
}

async function claimDaily() {
  if (busy || !state.account || !canClaim()) return false;
  busy = true;
  const { streak, amount } = dailyReward();
  const tx = await Stellar.submit({ type: "daily", amount, to: state.account.publicKey });
  busy = false;
  state.cash += amount;
  state.lastClaim = state.day;
  state.streak = streak;
  logOp("DIARIO", "FNP", amount, tx);
  pushAlert(`🪙 Reclamaste ${money(amount)}. ${streak > 1 ? `¡Racha de ${streak} días!` : ""}`);
  if (streak === 1 && !state.positions.length) pushAlert("🦉 Tip: si invertís tus tokens diarios, crecen solos.");
  Bridge.emit("daily_claimed", { amount, streak, tx: tx.hash });
  Bridge.emit("tokens_changed", { tokens: state.cash });
  save();
  render();
  return true;
}

async function buy(id) {
  const item = SHOP.find((x) => x.id === id);
  if (busy || !state.account || !item) return false;
  if (item.price > state.cash) return say(`Te faltan ${money(item.price - state.cash)} para ${item.name}. ¡Invertí y esperá!`);
  busy = true;
  const tx = await Stellar.submit({ type: "buy", item: id, amount: item.price, from: state.account.publicKey });
  busy = false;
  state.cash -= item.price;
  state.inventory.push({ id, day: state.day + 1 });
  logOp("COMPRA", item.id.toUpperCase(), item.price, tx);
  pushAlert(`🛒 Compraste ${item.emoji} ${item.name}. ¡Ya está en tu casa del juego!`);
  Bridge.emit("item_bought", { id, name: item.name, price: item.price, tx: tx.hash });
  Bridge.emit("tokens_changed", { tokens: state.cash });
  save();
  render();
  return true;
}

function say(msg) {
  pushAlert("🦉 " + msg);
  termPrint(msg);
  render();
  return false;
}

/* GRÁFICOS */

function drawLine(canvas, data) {
  const ctx = canvas.getContext("2d");
  const w = canvas.width;
  const h = canvas.height;
  ctx.fillStyle = cssVar("--panel-deep");
  ctx.fillRect(0, 0, w, h);
  if (data.length < 2) return;
  const min = Math.min(...data);
  const max = Math.max(...data);
  ctx.strokeStyle = cssVar("--green");
  ctx.lineWidth = 2;
  ctx.beginPath();
  data.forEach((v, i) => {
    const x = (i / (data.length - 1)) * (w - 4) + 2;
    const y = h - 4 - ((v - min) / (max - min || 1)) * (h - 8);
    if (i === 0) ctx.moveTo(x, y);
    else ctx.lineTo(x, y);
  });
  ctx.stroke();
}

function drawAlloc(canvas) {
  const ctx = canvas.getContext("2d");
  const parts = state.positions.map((p) => ({ c: cssVar(asset(p.code).color), v: posValue(p) }));
  parts.push({ c: cssVar("--purple-dim"), v: state.cash });
  const sum = parts.reduce((a, b) => a + b.v, 0) || 1;
  ctx.fillStyle = cssVar("--panel-deep");
  ctx.fillRect(0, 0, canvas.width, canvas.height);
  let x = 4;
  parts.forEach((p) => {
    const w = Math.round((p.v / sum) * (canvas.width - 8));
    if (w < 1) return;
    ctx.fillStyle = p.c;
    ctx.fillRect(x, 8, Math.max(1, w - 2), canvas.height - 16);
    x += w;
  });
}

function drawCalc(canvas, rows) {
  const ctx = canvas.getContext("2d");
  const w = canvas.width;
  const h = canvas.height;
  ctx.fillStyle = cssVar("--panel-deep");
  ctx.fillRect(0, 0, w, h);
  const max = Math.max(...rows.map((r) => r.bal), 1);
  const bw = (w - 8) / rows.length;
  rows.forEach((r, i) => {
    const x = Math.round(4 + i * bw);
    const bwi = Math.max(2, Math.round(bw) - 2);
    const hPut = Math.round((Math.min(r.put, r.bal) / max) * (h - 8));
    const hAll = Math.round((r.bal / max) * (h - 8));
    ctx.fillStyle = cssVar("--purple");
    ctx.fillRect(x, h - 4 - hPut, bwi, hPut);
    ctx.fillStyle = cssVar("--green");
    ctx.fillRect(x, h - 4 - hAll, bwi, hAll - hPut);
  });
}

/* RENDER */

function render() {
  if (!state.account) return;
  const acc = state.account;
  $("game-clock").textContent = dateLabel(state.day);
  $("user-chip").textContent = acc.avatar + " " + acc.alias;

  $("kpi-total").textContent = money(total());
  $("kpi-invested").textContent = money(invested());
  const g = interest();
  const gEl = $("kpi-interest");
  gEl.textContent = signed(g);
  gEl.className = g >= 0 ? "up" : "down";
  $("kpi-cash").textContent = money(state.cash);

  renderGoal();

  $("alloc-list").innerHTML =
    state.positions
      .map((p) => {
        const a = asset(p.code);
        return `<li><span><i class="sw" style="background:var(${a.color})"></i>${a.emoji} ${a.code}</span><span>${money(posValue(p))}</span></li>`;
      })
      .join("") +
    `<li><span><i class="sw" style="background:var(--purple-dim)"></i>💵 BILLETERA</span><span>${money(state.cash)}</span></li>`;

  $("alert-feed").innerHTML = state.alerts.map((a) => `<li>${a}</li>`).join("");

  $("inv-avail").textContent = money(state.cash);
  renderPreview();
  renderPositions();
  renderDaily();
  renderShop();

  $("wallet-addr").textContent = acc.publicKey;
  $("wallet-net").textContent = Stellar.network;
  $("bal-list").innerHTML =
    `<li><span>🪙 FNP (práctica)</span><strong>${money(state.cash)}</strong></li>` +
    state.positions
      .map((p) => {
        const a = asset(p.code);
        return `<li><span>${a.emoji} ${a.code}</span><strong>${money(posValue(p))}</strong></li>`;
      })
      .join("");

  $("ledger-body").innerHTML = state.ledger
    .map(
      (t) =>
        `<tr><td>${t.day}</td><td>${t.op}</td><td>${t.code}</td><td>${money(t.amount)}</td><td title="${t.hash}">${t.hash.slice(0, 8)}…</td></tr>`
    )
    .join("");

  drawLine($("chart-equity"), state.history);
  drawAlloc($("chart-alloc"));
}

function renderGoal() {
  const goal = state.account.goal;
  const t = total();
  const pct = Math.min(100, (t / goal.amt) * 100);
  $("goal-head").textContent = `${goal.emoji} ${goal.label}`;
  $("goal-bar").style.width = pct.toFixed(1) + "%";
  $("goal-txt").textContent = `${money(t)} de ${money(goal.amt)} (${pct.toFixed(1)}%)`;
  let eta;
  if (t >= goal.amt) eta = "¡LLEGASTE! 🎉";
  else {
    const r = effectiveRate();
    if (r <= 0) eta = "🌱 Si invertís tus tokens, empiezan a crecer solos.";
    else {
      const m = Math.ceil(Math.log(goal.amt / t) / Math.log(1 + r / 12));
      eta = m > 600
        ? "A este ritmo tardarías muchísimo. Probá invertir más 😉"
        : `A este ritmo llegás en ~${Math.floor(m / 12)} años y ${m % 12} meses.`;
    }
  }
  $("goal-eta").textContent = eta;
}

function renderDaily() {
  const btn = $("btn-claim");
  const ready = canClaim();
  const { streak, amount } = dailyReward();
  btn.disabled = !ready;
  btn.classList.toggle("glow", ready);
  btn.textContent = ready ? `RECLAMAR ${money(amount)}` : "VOLVÉ MAÑANA";
  $("daily-txt").textContent = ready
    ? "¡Tus tokens de práctica del día están listos!"
    : "Ya reclamaste hoy. Mañana (en el juego) hay más.";
  const shown = ready ? streak - 1 : state.streak;
  $("daily-streak").textContent = shown > 0 ? `🔥 RACHA: ${shown} ${shown === 1 ? "DÍA" : "DÍAS"}` : "";
}

let shopBuilt = false;
function renderShop() {
  const list = $("shop-list");
  if (!shopBuilt) {
    shopBuilt = true;
    list.innerHTML = SHOP.map(
      (it) => `<li class="shop-item" data-item="${it.id}">
        <span class="shop-emoji">${it.emoji}</span>
        <span class="shop-info"><strong>${it.name}</strong><small>${it.desc}</small><em data-f="owned"></em></span>
        <button type="button" class="btn mini" data-buy="${it.id}">${money(it.price)}</button>
      </li>`
    ).join("");
  }
  $("shop-avail").textContent = money(state.cash);
  SHOP.forEach((it) => {
    const row = list.querySelector(`[data-item="${it.id}"]`);
    const owned = state.inventory.filter((x) => x.id === it.id).length;
    row.querySelector('[data-f="owned"]').textContent = owned ? `TENÉS ${owned}` : "";
    row.querySelector("[data-buy]").classList.toggle("ghost", it.price > state.cash);
  });
}

function renderAssets() {
  $("asset-list").innerHTML = ASSETS.map((a) => {
    const dots = [1, 2, 3, 4].map((i) => `<i class="${i <= a.risk ? "on" : ""}"></i>`).join("");
    return `<li><button type="button" class="asset ${a.code === state.selected ? "on" : ""}" data-code="${a.code}" aria-pressed="${a.code === state.selected}">
      <span class="asset-emoji">${a.emoji}</span>
      <span class="asset-name">${a.code}<span class="badge">${a.kind}</span><small>${a.name}</small></span>
      <span class="asset-rate">${(a.tna * 100).toFixed(0)}% TNA<span class="risk" title="Riesgo ${RISK_TXT[a.risk]}">${dots}</span></span>
    </button></li>`;
  }).join("");
  const a = asset(state.selected);
  $("sel-code").textContent = `${a.emoji} ${a.code}`;
  $("asset-detail").textContent =
    `${a.desc} Riesgo ${RISK_TXT[a.risk]}. Capitaliza ${a.every === 1 ? "todos los días" : "todos los meses"}.`;
  renderPreview();
}

function project(a, amount, years) {
  const n = YEAR / a.every;
  return amount * Math.pow(1 + a.tna / n, n * years);
}

function renderPreview() {
  const a = asset(state.selected);
  const amt = Number($("inv-amt").value) || 0;
  $("inv-preview").textContent = amt > 0
    ? `En 1 año ≈ ${money(project(a, amt, 1))} · En 5 años ≈ ${money(project(a, amt, 5))}${a.risk >= 3 ? " (puede variar)" : ""}`
    : "";
}

let posSig = null;
function renderPositions() {
  const body = $("pos-body");
  const sig = state.positions.map((p) => p.code).join(",");
  if (sig !== posSig) {
    posSig = sig;
    body.innerHTML = state.positions.length
      ? state.positions
          .map((p) => {
            const a = asset(p.code);
            return `<tr data-code="${p.code}"><td>${a.emoji} ${a.code}</td><td data-f="inv"></td><td data-f="val"></td><td data-f="int"></td><td><button type="button" class="btn mini sell" data-withdraw="${p.code}">RETIRAR</button></td></tr>`;
          })
          .join("")
      : `<tr><td colspan="5" class="empty">Todavía no invertiste. Elegí un activo arriba 👆</td></tr>`;
  }
  state.positions.forEach((p) => {
    const row = body.querySelector(`[data-code="${p.code}"]`);
    const g = posValue(p) - p.invested;
    row.querySelector('[data-f="inv"]').textContent = money(p.invested);
    row.querySelector('[data-f="val"]').textContent = money(posValue(p));
    const c = row.querySelector('[data-f="int"]');
    c.textContent = signed(g);
    c.className = g >= 0 ? "up" : "down";
  });
}

function renderChain() {
  $("chain-height").textContent = String(Stellar.height());
  $("block-list").innerHTML = Stellar.recent()
    .map((b) => `<li>#${b.seq} ${b.hash.slice(0, 12)}…<span>${b.ops} OPS</span></li>`)
    .join("");
}

function calc() {
  const P = Math.max(0, Number($("c-cap").value) || 0);
  const M = Math.max(0, Number($("c-month").value) || 0);
  const r = Math.max(0, Number($("c-rate").value) || 0) / 100;
  const years = Math.min(50, Math.max(1, Math.round(Number($("c-years").value) || 1)));
  const n = Number($("c-freq").value);
  const f = Math.pow(1 + r / n, n / 12);
  let bal = P;
  let put = P;
  const rows = [];
  for (let m = 1; m <= years * 12; m++) {
    bal = (bal + M) * f;
    put += M;
    if (m % 12 === 0) rows.push({ put, bal });
  }
  $("c-total").textContent = money(bal);
  $("c-put").textContent = money(put);
  $("c-int").textContent = money(bal - put);
  drawCalc($("chart-calc"), rows);
  return { bal, put };
}

/* NAVEGACIÓN Y TIEMPO */

function showView(id) {
  document.querySelectorAll(".view").forEach((v) => v.classList.remove("active"));
  document.querySelectorAll(".dock-btn").forEach((b) => b.classList.remove("active"));
  $("view-" + id).classList.add("active");
  document.querySelector(`[data-view="${id}"]`).classList.add("active");
}

// Con ?clock=game el calendario lo avanza el juego (advance_days): el reloj propio queda apagado.
const GAME_CLOCK = params.get("clock") === "game";
if (GAME_CLOCK) document.getElementById("speed-ctl").classList.add("hidden");

function setSpeed(s) {
  if (GAME_CLOCK) s = 0;
  state.speed = s;
  document.querySelectorAll("#speed-ctl button").forEach((b) => {
    b.classList.toggle("on", Number(b.dataset.speed) === s);
  });
}

let loopsStarted = false;
function startLoops() {
  if (loopsStarted) return;
  loopsStarted = true;
  setInterval(() => {
    if (!state.speed) return;
    for (let i = 0; i < state.speed; i++) advanceDay();
    render();
    save();
  }, 1000);
  setInterval(() => {
    Stellar.closeLedger();
    renderChain();
  }, 5000);
}

/* BOOT */

const BOOT = [
  "MUSHIN BIOS 2.0  1998-2026",
  "CPU: PIXEL 386DX @ 40MHz",
  "MEM: 640K OK",
  "DETECTANDO HDD... OK",
  "CARGANDO MUSHIN.AR KERNEL",
  "CONECTANDO A STELLAR TESTNET (SIM)...",
  "MODULO INTERES COMPUESTO OK",
  "ENTRANDO AL TERMINAL FINANCIERO...",
];

function boot() {
  $("game-click").classList.add("hidden");
  if (loopsStarted && state.account) {
    $("os").classList.remove("hidden");
    setSpeed(state.speedBeforeOff ?? 1);
    return;
  }
  const bootEl = $("boot");
  bootEl.classList.remove("hidden");
  const log = $("boot-log");
  log.textContent = "";
  let i = 0;
  const iv = setInterval(() => {
    log.textContent += BOOT[i] + "\n";
    i += 1;
    if (i >= BOOT.length) {
      clearInterval(iv);
      setTimeout(() => {
        bootEl.classList.add("hidden");
        // El juego puede mandar el nombre del personaje: entra directo sin preguntar.
        const player = (params.get("player") || "").trim();
        if (validName(player)) login(player);
        else showLogin();
      }, 400);
    }
  }, 220);
}

function powerOff() {
  state.speedBeforeOff = state.speed;
  setSpeed(0);
  save();
  $("os").classList.add("hidden");
  $("game-click").classList.remove("hidden");
  Bridge.emit("exit", { tokens: state.cash, total: total() });
}

function enterOS() {
  $("login").classList.add("hidden");
  $("signup").classList.add("hidden");
  $("os").classList.remove("hidden");
  if (!state.history.length) state.history.push(total());
  if (!state.alerts.length) pushAlert(`🦉 ¡Te damos la bienvenida, ${state.account.alias}!`);
  setSpeed(state.speed);
  showView("dash");
  renderAssets();
  calc();
  render();
  renderChain();
  $("term-out").textContent = "";
  termPrint("MUSHIN OS 2.0  escribí help para ver comandos");
  startLoops();
  Bridge.emit("opened", { alias: state.account.alias, tokens: state.cash, total: total() });
  if (!state.tutorialDone) startTour();
}

/* INGRESO CON NOMBRE DE JUGADOR */

function showLogin() {
  $("os").classList.add("hidden");
  $("signup").classList.add("hidden");
  $("login").classList.remove("hidden");
  const store = readStore();
  const players = Object.values(store.players).map((p) => p.account);
  $("login-saved").classList.toggle("hidden", players.length === 0);
  $("login-list").innerHTML = players
    .map(
      (a) => `<li><button type="button" class="pick player" data-player="${a.alias}">${a.avatar} ${a.alias}</button><button type="button" class="btn ghost mini" data-del="${a.alias}" aria-label="Borrar a ${a.alias}">✕</button></li>`
    )
    .join("");
  $("login-name").value = store.last || "";
  $("login-err").textContent = "";
  $("login-name").focus();
}

function login(name) {
  if (!validName(name)) {
    $("login-err").textContent = "Usá de 3 a 16 letras, números o _.";
    return;
  }
  if (loadProfile(name)) enterOS();
  else showSignup(name);
}

function switchPlayer() {
  save();
  setSpeed(0);
  Object.assign(state, defaults(), { speed: 0 });
  showLogin();
}

/* ALTA DE CUENTA */

const SU_TIPS = [
  "¡Sos nuevo acá! Soy Mushi 🦉. Elegí cómo te van a ver.",
  "Tener una meta ayuda un montón. ¿Para qué querés juntar tokens?",
  "Estoy creando tu billetera en Stellar… ¡ya casi!",
];
const su = { step: 1, alias: "", avatar: null, goal: null };

function showSignup(alias) {
  su.alias = alias;
  su.avatar = null;
  su.goal = null;
  $("login").classList.add("hidden");
  $("signup").classList.remove("hidden");
  $("su-name").textContent = "// " + alias;
  $("su-avatars").innerHTML = AVATARS.map(
    (a) => `<button type="button" class="pick" data-avatar="${a}" aria-pressed="false">${a}</button>`
  ).join("");
  $("su-goals").innerHTML = GOALS.map(
    (g) => `<button type="button" class="pick" data-goal="${g.id}" aria-pressed="false"><span>${g.emoji}</span>${g.label}</button>`
  ).join("");
  setSuStep(1);
}

function setSuStep(n) {
  su.step = n;
  document.querySelectorAll(".su-step").forEach((el) => {
    el.classList.toggle("hidden", Number(el.dataset.step) !== n);
  });
  $("signup-step").textContent = n <= 2 ? `${n}/2` : "";
  $("su-back").classList.toggle("hidden", n === 3);
  $("su-next").textContent = n === 2 ? "CREAR CUENTA" : n === 3 ? "ENTRAR" : "SIGUIENTE";
  $("su-next").disabled = n === 3;
  $("signup-tip").textContent = SU_TIPS[n - 1];
  $("su-err").textContent = "";
}

function pick(container, attr, value) {
  container.querySelectorAll(".pick").forEach((b) => {
    const on = b.dataset[attr] === value;
    b.classList.toggle("on", on);
    b.setAttribute("aria-pressed", String(on));
  });
}

async function createAccount() {
  setSuStep(3);
  const log = $("su-log");
  log.textContent = "";
  const line = (t) => {
    log.textContent += t + "\n";
  };
  const alias = su.alias;
  const amt = Math.round(Number($("su-goal-amt").value));
  line("GENERANDO LLAVES ED25519...");
  await wait(400);
  line("CREANDO CUENTA EN STELLAR " + Stellar.network + "...");
  const res = await Stellar.createAccount();
  await wait(300);
  line("BONO DE BIENVENIDA: " + money(state.cash));
  await wait(400);
  line("TRUSTLINES: FNP " + ASSETS.map((a) => a.code).join(" "));
  await wait(400);
  line("\nCUENTA LISTA ✔\n" + res.publicKey);
  state.account = { alias, avatar: su.avatar, goal: { ...su.goal, amt }, publicKey: res.publicKey };
  logOp("CREAR CUENTA", "-", 0, res.tx);
  save();
  Bridge.emit("account_created", { alias, avatar: su.avatar, publicKey: res.publicKey, goal: state.account.goal });
  $("signup-tip").textContent = `¡Listo, ${alias}! Tu billetera ya existe. Entrá y te muestro cómo funciona todo.`;
  $("su-next").disabled = false;
  $("su-next").focus();
}

function signupNext() {
  const err = $("su-err");
  if (su.step === 1) {
    if (!su.avatar) {
      err.textContent = "Elegí un avatar.";
      return;
    }
    setSuStep(2);
  } else if (su.step === 2) {
    if (!su.goal) {
      err.textContent = "Elegí una meta.";
      return;
    }
    if (!(Number($("su-goal-amt").value) >= 100)) {
      err.textContent = "La meta tiene que ser de al menos 100 FNP.";
      return;
    }
    createAccount();
  } else if (su.step === 3 && state.account) {
    enterOS();
  }
}

/* TUTORIAL CON MUSHI */

const TOUR = [
  { view: "dash", target: null,
    text: (a) => `¡Hola ${a.alias}! Soy Mushi 🦉 y te voy a enseñar a que tus tokens trabajen por vos con interés compuesto. ¿Vamos?` },
  { target: ".dock",
    text: () => "Este es el menú. Cada botón abre una app de la compu: INICIO, INVERTIR, TIENDA, CALCULAR, WALLET, RED y TERM." },
  { view: "dash", target: "#daily-win",
    text: () => "Todos los días del juego te doy tokens FNP para practicar. Si reclamás varios días seguidos, la racha 🔥 te da más." },
  { view: "dash", target: "#kpi-row",
    text: () => "Acá ves tu PATRIMONIO (todo lo que tenés), lo que INVERTISTE y los INTERESES que ganaste sin hacer nada." },
  { view: "dash", target: "#goal-win",
    text: (a) => `Esta es tu meta: ${a.goal.emoji} ${a.goal.label}. Te voy a ir diciendo cuánto te falta para llegar.` },
  { view: "invest", target: "#asset-list",
    text: () => "En INVERTIR elegís dónde poner tus FNP: tokens o acciones tokenizadas en Stellar. Mirá la TNA (cuánto rinde por año) y los cuadraditos de RIESGO." },
  { view: "invest", target: "#invest-win",
    text: () => "Escribí cuánto querés invertir y tocá INVERTIR. Abajo te muestro cuánto podrías tener en 1 y en 5 años." },
  { view: "shop", target: "#shop-win",
    text: () => "Con lo que ganás comprás cosas para tu personaje en la TIENDA. Tip: si esperás a que tus inversiones crezcan, te alcanza para más." },
  { view: "calc", target: "#calc-win",
    text: () => "El truco del interés compuesto: ganás intereses sobre tus intereses, como una bola de nieve ❄️. Cambiá los números y mirá cómo crece con los años." },
  { view: "wallet", target: "#wallet-card",
    text: () => "Esta es tu billetera de Stellar. Tus tokens viven acá y cada movimiento queda registrado con su código (hash)." },
  GAME_CLOCK
    ? { view: "dash", target: "#game-clock",
        text: () => "El tiempo lo maneja Finanpolis: cada día que pasa en el juego, tus inversiones suman intereses." }
    : { view: "dash", target: "#speed-ctl",
        text: () => "El tiempo del juego corre solo y cada día tus inversiones suman intereses. Con ⏸ 1x 7x 30x lo pausás o lo acelerás." },
  { target: "#help-btn",
    text: () => "Si te perdés, tocá ? y repasamos. Tip: arrancá con algo de riesgo bajo y dejalo crecer. ¡A invertir! 🚀" },
];
let tourIdx = -1;
let speedBeforeTour = 1;

function startTour() {
  tourIdx = 0;
  speedBeforeTour = state.speed || 1;
  setSpeed(0);
  $("coach").classList.remove("hidden");
  showStep();
}

function showStep() {
  const s = TOUR[tourIdx];
  if (s.view) showView(s.view);
  $("coach-text").textContent = s.text(state.account);
  $("coach-count").textContent = `${tourIdx + 1}/${TOUR.length}`;
  $("coach-prev").classList.toggle("hidden", tourIdx === 0);
  $("coach-next").textContent = tourIdx === TOUR.length - 1 ? "¡DALE!" : "SIGUIENTE";
  const el = s.target && document.querySelector(s.target);
  if (el) el.scrollIntoView({ block: "nearest" });
  requestAnimationFrame(placeSpot);
  $("coach-next").focus();
}

function placeSpot() {
  if (tourIdx < 0) return;
  const s = TOUR[tourIdx];
  const spot = $("coach-spot");
  const box = $("coach-box");
  const el = s.target && document.querySelector(s.target);
  box.classList.remove("top", "bottom", "center");
  if (!el) {
    spot.classList.add("none");
    box.classList.add("center");
    return;
  }
  const r = el.getBoundingClientRect();
  const pad = 6;
  spot.classList.remove("none");
  spot.style.left = r.left - pad + "px";
  spot.style.top = r.top - pad + "px";
  spot.style.width = r.width + pad * 2 + "px";
  spot.style.height = r.height + pad * 2 + "px";
  box.classList.add(r.top + r.height / 2 > innerHeight / 2 ? "top" : "bottom");
}

function endTour() {
  tourIdx = -1;
  $("coach").classList.add("hidden");
  state.tutorialDone = true;
  setSpeed(speedBeforeTour);
  save();
  showView("dash");
  Bridge.emit("tutorial_done");
}

/* TERMINAL */

function termPrint(line) {
  const out = $("term-out");
  out.textContent += line + "\n";
  out.scrollTop = out.scrollHeight;
}

function handleTerm(cmd) {
  const parts = cmd.trim().split(/\s+/);
  const c = (parts[0] || "").toLowerCase();
  if (!c) return;
  termPrint("> " + cmd);
  if (c === "help") {
    termPrint("comandos: saldo, reclamar, activos, invertir <COD> <monto>, retirar <COD>,");
    termPrint("          tienda, comprar <item>, calc <capital> <tna%> <años>,");
    termPrint("          velocidad <0|1|7|30>, tutorial, clear");
  } else if (c === "reclamar") {
    claimDaily().then((ok) => termPrint(ok ? "recompensa diaria cobrada" : "ya reclamaste hoy"));
  } else if (c === "tienda") {
    SHOP.forEach((it) => termPrint(`${it.id.padEnd(8)} ${money(it.price).padStart(10)}  ${it.name}`));
  } else if (c === "comprar") {
    const id = (parts[1] || "").toLowerCase();
    if (!SHOP.some((x) => x.id === id)) return termPrint("item desconocido. probá: tienda");
    buy(id).then((ok) => ok && termPrint("compra ok"));
  } else if (c === "saldo") {
    termPrint(`billetera ${money(state.cash)} | invertido ${money(invested())} | intereses ${signed(interest())}`);
  } else if (c === "activos") {
    ASSETS.forEach((a) => termPrint(`${a.code}  ${(a.tna * 100).toFixed(0)}% TNA  riesgo ${RISK_TXT[a.risk]}  ${a.name}`));
  } else if (c === "invertir") {
    const code = (parts[1] || "").toUpperCase();
    if (!asset(code)) return termPrint("activo desconocido. probá: activos");
    invest(code, Number(parts[2])).then((ok) => ok && termPrint(`ok: ${money(Number(parts[2]))} en ${code}`));
  } else if (c === "retirar") {
    const code = (parts[1] || "").toUpperCase();
    withdraw(code).then((ok) => termPrint(ok ? "retiro ok" : "no tenés ese activo"));
  } else if (c === "calc") {
    const [P, r, t] = parts.slice(1).map(Number);
    if (!(P >= 0 && r >= 0 && t > 0)) return termPrint("uso: calc 10000 10 5");
    termPrint(`${money(P)} al ${r}% por ${t} años = ${money(P * Math.pow(1 + r / 100 / 12, 12 * t))} (capitaliza mensual)`);
  } else if (c === "velocidad") {
    const s = Number(parts[1]);
    if (![0, 1, 7, 30].includes(s)) return termPrint("uso: velocidad 0|1|7|30");
    setSpeed(s);
    termPrint("velocidad " + s + "x");
  } else if (c === "tutorial") startTour();
  else if (c === "clear") $("term-out").textContent = "";
  else termPrint("comando desconocido. escribí help");
}

/* EVENTOS */

$("monitor").addEventListener("click", boot);
$("signup-form").addEventListener("submit", (e) => {
  e.preventDefault();
  signupNext();
});
$("su-back").addEventListener("click", () => {
  if (su.step === 1) showLogin();
  else setSuStep(su.step - 1);
});
$("login-form").addEventListener("submit", (e) => {
  e.preventDefault();
  login($("login-name").value.trim());
});
$("login-list").addEventListener("click", (e) => {
  const p = e.target.closest("[data-player]");
  if (p) return login(p.dataset.player);
  const d = e.target.closest("[data-del]");
  if (d && confirm(`¿Borrar a ${d.dataset.del} y todo su progreso?`)) {
    deleteProfile(d.dataset.del);
    showLogin();
  }
});
$("user-chip").addEventListener("click", switchPlayer);
$("btn-claim").addEventListener("click", claimDaily);
$("shop-list").addEventListener("click", (e) => {
  const b = e.target.closest("[data-buy]");
  if (b) buy(b.dataset.buy);
});
$("su-avatars").addEventListener("click", (e) => {
  const b = e.target.closest("[data-avatar]");
  if (!b) return;
  su.avatar = b.dataset.avatar;
  pick($("su-avatars"), "avatar", su.avatar);
});
$("su-goals").addEventListener("click", (e) => {
  const b = e.target.closest("[data-goal]");
  if (!b) return;
  su.goal = GOALS.find((g) => g.id === b.dataset.goal);
  pick($("su-goals"), "goal", su.goal.id);
  $("su-goal-amt").value = su.goal.amt;
});

document.querySelector(".dock").addEventListener("click", (e) => {
  const b = e.target.closest("[data-view]");
  if (b) showView(b.dataset.view);
});
$("asset-list").addEventListener("click", (e) => {
  const b = e.target.closest("[data-code]");
  if (!b) return;
  state.selected = b.dataset.code;
  renderAssets();
});
$("inv-amt").addEventListener("input", renderPreview);
document.querySelector(".quick").addEventListener("click", (e) => {
  const b = e.target.closest("[data-pct]");
  if (!b) return;
  $("inv-amt").value = Math.floor(state.cash * Number(b.dataset.pct));
  renderPreview();
});
$("btn-invest").addEventListener("click", () => invest(state.selected, Number($("inv-amt").value)));
$("pos-body").addEventListener("click", (e) => {
  const b = e.target.closest("[data-withdraw]");
  if (b) withdraw(b.dataset.withdraw);
});
$("calc-form").addEventListener("input", calc);
$("calc-form").addEventListener("submit", (e) => e.preventDefault());
$("speed-ctl").addEventListener("click", (e) => {
  const b = e.target.closest("[data-speed]");
  if (b) setSpeed(Number(b.dataset.speed));
});
$("term-form").addEventListener("submit", (e) => {
  e.preventDefault();
  const input = $("term-in");
  handleTerm(input.value);
  input.value = "";
});
$("start-btn").addEventListener("click", () => showView("dash"));
$("power-btn").addEventListener("click", powerOff);
$("help-btn").addEventListener("click", startTour);

$("coach-next").addEventListener("click", () => {
  if (tourIdx >= TOUR.length - 1) endTour();
  else {
    tourIdx += 1;
    showStep();
  }
});
$("coach-prev").addEventListener("click", () => {
  tourIdx = Math.max(0, tourIdx - 1);
  showStep();
});
$("coach-skip").addEventListener("click", endTour);
document.addEventListener("keydown", (e) => {
  if (tourIdx >= 0 && e.key === "Escape") endTour();
});
window.addEventListener("resize", placeSpot);

/* API PARA EL JUEGO */

// El juego puede premiar al personaje con tokens (ej: por trabajar en la compu).
Bridge.on("add_tokens", (d) => {
  if (!state.account) return;
  state.cash = Math.max(0, state.cash + (Number(d.amount) || 0));
  if (d.reason) pushAlert(`🪙 +${money(d.amount)}: ${String(d.reason).slice(0, 40)}`);
  render();
  save();
});
Bridge.on("advance_days", (d) => state.account && advanceDays(Math.max(0, Math.floor(Number(d.days) || 0))));
Bridge.on("open_tutorial", () => state.account && startTour());

window.mushin = {
  advanceDays: (days) => Bridge.receive({ target: "mushin", type: "advance_days", data: { days } }),
  addTokens: (amount, reason) => Bridge.receive({ target: "mushin", type: "add_tokens", data: { amount, reason } }),
  openTutorial: () => state.account && startTour(),
  snapshot: () => ({
    alias: state.account && state.account.alias,
    tokens: state.cash,
    invested: invested(),
    total: total(),
    day: state.day,
    inventory: state.inventory,
  }),
};

if (params.has("reset")) {
  try {
    localStorage.removeItem(STORE_KEY);
    localStorage.removeItem("mushin.v1");
  } catch (e) {}
  location.replace(location.pathname);
} else if (params.has("boot")) boot();
