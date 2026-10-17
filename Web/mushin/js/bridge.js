// Puente con el juego (Godot).
// Salida: postMessage al padre (iframe / export web) y window.ipc (WebView tipo godot-wry).
// Entrada: mensajes { target: "mushin", type, data } por postMessage,
// o llamadas directas a window.mushin.* desde JavaScriptBridge.eval().
const Bridge = (() => {
  const handlers = {};

  function emit(type, data = {}) {
    const msg = { source: "mushin", type, data };
    try {
      if (window.ipc && window.ipc.postMessage) window.ipc.postMessage(JSON.stringify(msg));
    } catch (e) {}
    try {
      if (window.parent !== window) window.parent.postMessage(msg, "*");
    } catch (e) {}
  }

  function on(type, fn) {
    handlers[type] = fn;
  }

  function receive(msg) {
    if (msg && msg.target === "mushin" && handlers[msg.type]) handlers[msg.type](msg.data || {});
  }

  window.addEventListener("message", (e) => {
    let m = e.data;
    if (typeof m === "string") {
      try {
        m = JSON.parse(m);
      } catch (err) {
        return;
      }
    }
    receive(m);
  });

  return { emit, on, receive };
})();
