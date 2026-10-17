// Capa Stellar SIMULADA.
// Tiene la misma forma (async) que tendrá la integración real, así se reemplaza sin tocar la UI:
//   createAccount -> crear/fondear cuenta en Horizon testnet (Friendbot o backend del juego)
//   submit        -> armar y enviar la transacción con @stellar/stellar-sdk (o un contrato Soroban)
// Nunca se genera ni se guarda una clave secreta en el cliente.
const Stellar = (() => {
  const B32 = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
  let ledger = 51842000 + Math.floor(Math.random() * 1000);
  const recent = [];
  let pending = 0;

  function publicKey() {
    let s = "G";
    for (let i = 0; i < 55; i++) s += B32[(Math.random() * 32) | 0];
    return s;
  }

  function txHash() {
    let h = "";
    for (let i = 0; i < 64; i++) h += ((Math.random() * 16) | 0).toString(16);
    return h;
  }

  function wait(ms) {
    return new Promise((r) => setTimeout(r, ms));
  }

  function closeLedger() {
    ledger += 1;
    recent.unshift({ seq: ledger, ops: pending + ((Math.random() * 40) | 0), hash: txHash() });
    recent.length = Math.min(recent.length, 10);
    pending = 0;
  }

  for (let i = 0; i < 6; i++) closeLedger();

  return {
    network: "TESTNET (SIM)",

    async createAccount() {
      await wait(300);
      pending += 1;
      return { publicKey: publicKey(), tx: { hash: txHash(), ledger: ledger + 1 } };
    },

    async submit(op) {
      await wait(120);
      pending += 1;
      return { hash: txHash(), ledger: ledger + 1, op };
    },

    closeLedger,
    height: () => ledger,
    recent: () => recent,
  };
})();
