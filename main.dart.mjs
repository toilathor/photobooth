// Compiles a dart2wasm-generated main module from `source` which can then
// be instantiated via the `instantiate` method.
//
// `source` needs to be a `Response` object (or promise thereof) e.g. created
// via the `fetch()` JS API.
export async function compileStreaming(source) {
  const builtins = {builtins: ['js-string'], importedStringConstants: ''};
  return new CompiledApp(
      await _compileStreaming(source, builtins), builtins);
}

// Compiles a dart2wasm-generated wasm module from `bytes` which is then
// instantiable via the `instantiate` method.
export async function compile(bytes) {
  const builtins = {builtins: ['js-string'], importedStringConstants: ''};
  return new CompiledApp(await WebAssembly.compile(bytes, builtins), builtins);
}

let _isCompileStreamingSupported;
async function _compileStreaming(source, builtins) {
  _isCompileStreamingSupported ??= WebAssembly.compileStreaming(
    new Response(
      new Uint8Array([0,97,115,109,1,0,0,0,1,4,1,96,0,0,2,23,1,14,119,97,115,109,58,106,115,45,115,116,114,105,110,103,4,99,97,115,116,0,0]),
      {headers: {'Content-Type': 'application/wasm'}},
    ),
    builtins,
  ).then(() => false, (e) => e instanceof WebAssembly.CompileError);
  if (await _isCompileStreamingSupported) {
    return WebAssembly.compileStreaming(source, builtins);
  }
  return WebAssembly.compile(await (await source).arrayBuffer(), builtins);
}

class CompiledApp {
  constructor(module, builtins) {
    this.module = module;
    this.builtins = builtins;
  }

  // The second argument is an options object containing:
  // `loadDeferredModules` is a JS function that takes an array of module names
  //   matching wasm files produced by the dart2wasm compiler. It also takes a
  //   callback that should be invoked for each loaded module with 2 arguments:
  //   (1) the module name, (2) the loaded module in a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`. The callback
  //   returns a Promise that resolves when the module is instantiated.
  //   loadDeferredModules should return a Promise that resolves when all the
  //   modules have been loaded and the callback promises have resolved.
  // `loadDeferredId` is a JS function that takes load ID produced by the
  //   compiler when the `use-load-ids` option is passed. Each load ID maps to
  //   one or more wasm files as specified in the emitted JSON file. It also
  //   takes a callback that should be invoked for each loaded module with 2
  //   arguments: (1) the module name, (2) the loaded module in a format
  //   supported by `WebAssembly.compile` or `WebAssembly.compileStreaming`.
  //   The callback returns a Promise that resolves when the module is
  //   instantiated.
  //   loadDeferredId should return a Promise that resolves when all the
  //   modules have been loaded and the callback promises have resolved.
  async instantiate(additionalImports, {loadDeferredModules, loadDeferredId} = {}) {
    let dartInstance;

    // Prints to the console
    function printToConsole(value) {
      if (typeof dartPrint == "function") {
        dartPrint(value);
        return;
      }
      if (typeof console == "object" && typeof console.log != "undefined") {
        console.log(value);
        return;
      }
      if (typeof print == "function") {
        print(value);
        return;
      }

      throw "Unable to print message: " + value;
    }

    // A special symbol attached to functions that wrap Dart functions.
    const jsWrappedDartFunctionSymbol = Symbol("JSWrappedDartFunction");

    function finalizeWrapper(dartFunction, wrapped) {
      wrapped.dartFunction = dartFunction;
      wrapped[jsWrappedDartFunctionSymbol] = true;
      return wrapped;
    }

    // Imports
    const dart2wasm = {
            AB: x0 => new Int16Array(x0),
      AC: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
      AD: x0 => x0.clientX,
      AE: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      AF: x0 => x0.touches,
      AG: x0 => x0.fullscreenElement,
      AH: (handle) => clearInterval(handle),
      AI: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      AJ: x0 => new Blob(x0),
      AK: x0 => x0.src,
      AL: (x0,x1) => x0.readAsArrayBuffer(x1),
      AM: x0 => x0.buffered,
      AN: x0 => x0.trustedTypes,
      AO: (x0,x1) => { x0.width = x1 },
      B: s => printToConsole(s),
      BB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI16ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      BC: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
      BD: (x0,x1,x2) => x0.addEventListener(x1,x2),
      BE: (p, s, f) => p.then(s, (e) => f(e, e === undefined)),
      BF: x0 => x0.pressure,
      BG: () => globalThis.document,
      BH: (ms, c) =>
      setInterval(() => dartInstance.exports.$invokeCallback(c), ms),
      BI: s => {
        if (/[[\]{}()*+?.\\^$|]/.test(s)) {
            s = s.replace(/[[\]{}()*+?.\\^$|]/g, '\\$&');
        }
        return s;
      },
      BJ: x0 => x0.close(),
      BK: x0 => x0.decode(),
      BL: x0 => x0.result,
      BM: x0 => x0.videoWidth,
      BN: (wasmFunction,f) => finalizeWrapper(f, function() { return wasmFunction(f,arguments.length) }),
      BO: x0 => x0.getCapabilities(),
      C: Function.prototype.call.bind(Number.prototype.toString),
      CB: x0 => new Uint16Array(x0),
      CC: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
      CD: (x0,x1,x2) => x0.setAttribute(x1,x2),
      CE: (o, i) => o[i],
      CF: x0 => x0.tiltY,
      CG: Function.prototype.call.bind(DataView.prototype.getBigInt64),
      CH: () => Date.now(),
      CI: x0 => x0.keyCode,
      CJ: x0 => x0.naturalHeight,
      CK: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      CL: x0 => globalThis.saveFilesToDevice(x0),
      CM: x0 => x0.videoHeight,
      CN: x0 => { globalThis.onGoogleLibraryLoad = x0 },
      CO: x0 => ({torch: x0}),
      D: Function.prototype.call.bind(BigInt.prototype.toString),
      DB: x0 => new Int32Array(x0),
      DC: (x0,x1) => x0.querySelector(x1),
      DD: (x0,x1) => x0.closest(x1),
      DE: o => o.length,
      DF: x0 => x0.tiltX,
      DG: Function.prototype.call.bind(DataView.prototype.setBigInt64),
      DH: x0 => x0.debugSkipFontRetryDelay,
      DI: (x0,x1) => x0.scrollIntoView(x1),
      DJ: x0 => x0.naturalWidth,
      DK: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      DL: x0 => x0.disconnect(),
      DM: x0 => x0.duration,
      DN: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      DO: (x0,x1) => x0.applyConstraints(x1),
      E: (exn) => {
        let stackString = exn.toString();
        let frames = stackString.split('\n');
        let drop = 4;
        if (frames[0].startsWith('Error')) {
            drop += 1;
        }
        return frames.slice(drop).join('\n');
      },
      EB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      EC: (x0,x1) => x0.item(x1),
      ED: (ms, c) =>
      setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
      EE: o => {
        if (o === undefined) return 1;
        var type = typeof o;
        if (type === 'boolean') return 2;
        if (type === 'number') return 3;
        if (type === 'string') return 4;
        if (o instanceof Array) return 5;
        if (ArrayBuffer.isView(o)) {
          if (o instanceof Int8Array) return 6;
          if (o instanceof Uint8Array) return 7;
          if (o instanceof Uint8ClampedArray) return 8;
          if (o instanceof Int16Array) return 9;
          if (o instanceof Uint16Array) return 10;
          if (o instanceof Int32Array) return 11;
          if (o instanceof Uint32Array) return 12;
          if (o instanceof Float32Array) return 13;
          if (o instanceof Float64Array) return 14;
          if (o instanceof DataView) return 15;
        }
        if (o instanceof ArrayBuffer) return 16;
        // Feature check for `SharedArrayBuffer` before doing a type-check.
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
            return 17;
        }
        if (o instanceof Promise) return 18;
        return 19;
      },
      EF: x0 => x0.pointerType,
      EG: (o, start, length) => new BigInt64Array(o.buffer, o.byteOffset + start, length),
      EH: x0 => x0.status,
      EI: x0 => x0.multiViewEnabled,
      EJ: (x0,x1) => { x0.src = x1 },
      EK: (x0,x1,x2) => x0.addEventListener(x1,x2),
      EL: x0 => x0.requestFullscreen(),
      EM: (x0,x1) => { x0.playsInline = x1 },
      EN: (x0,x1) => x0.prompt(x1),
      EO: (o) => Array.isArray(o) || o instanceof Array,
      F: () => new Error().stack,
      FB: x0 => new Uint32Array(x0),
      FC: x0 => x0.length,
      FD: (handle) => clearTimeout(handle),
      FE: x0 => x0.language,
      FF: x0 => x0.pointerId,
      FG: (map, o, v) => map.set(o, v),
      FH: (x0,x1,x2) => x0.set(x1,x2),
      FI: (x0,x1) => x0.replaceWith(x1),
      FJ: x0 => x0.displayHeight,
      FK: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      FL: x0 => x0.documentElement,
      FM: (x0,x1) => { x0.controls = x1 },
      FN: x0 => x0.isSkippedMoment(),
      FO: (o, t) => typeof o === t,
      G: s => JSON.stringify(s),
      GB: x0 => new Float32Array(x0),
      GC: (x0,x1) => x0.querySelectorAll(x1),
      GD: x0 => x0.maxTouchPoints,
      GE: (x0,x1,x2,x3) => x0.register(x1,x2,x3),
      GF: x0 => x0.getCoalescedEvents(),
      GG: () => new WeakMap(),
      GH: x0 => x0.arrayBuffer(),
      GI: (x0,x1) => { x0.className = x1 },
      GJ: x0 => x0.displayWidth,
      GK: x0 => x0.send(),
      GL: () => new AudioContext(),
      GM: (x0,x1) => { x0.autoplay = x1 },
      GN: x0 => x0.getDismissedReason(),
      GO: x0 => x0.torch,
      H: Function.prototype.call.bind(Number.prototype.toString),
      HB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      HC: (x0,x1) => x0.getAttribute(x1),
      HD: x0 => x0.platform,
      HE: () => globalThis.window.FinalizationRegistry,
      HF: s => s.trimLeft(),
      HG: (map, o) => map.get(o),
      HH: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof ArrayBuffer) return 1;
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
          return 2;
        }
        return 3;
      },
      HI: (x0,x1) => { x0.tabIndex = x1 },
      HJ: x0 => x0.duration,
      HK: x0 => x0.status,
      HL: x0 => x0.resume(),
      HM: (x0,x1) => { x0.width = x1 },
      HN: x0 => x0.isDismissedMoment(),
      HO: x0 => x0.stop(),
      I: Function.prototype.call.bind(String.prototype.indexOf),
      IB: x0 => new Float64Array(x0),
      IC: x0 => x0.remove(),
      ID: s => new Date(s * 1000).getTimezoneOffset() * 60,
      IE: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      IF: s => s.toUpperCase(),
      IG: x0 => x0.size,
      IH: (x0,x1) => x0.fetch(x1),
      II: (x0,x1) => { x0.action = x1 },
      IJ: (x0,x1) => ({frameIndex: x0,completeFramesOnly: x1}),
      IK: x0 => x0.response,
      IL: x0 => x0.createBufferSource(),
      IM: (x0,x1) => { x0.height = x1 },
      IN: x0 => x0.requestAccessToken(),
      IO: x0 => x0.enumerateDevices(),
      J: (s, p, i) => s.lastIndexOf(p, i),
      JB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF64ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      JC: (x0,x1) => x0.appendChild(x1),
      JD: Date.now,
      JE: x0 => new window.FinalizationRegistry(x0),
      JF: (x0,x1) => x0[x1],
      JG: () => new XMLHttpRequest(),
      JH: x0 => x0.fontFallbackBaseUrl,
      JI: (x0,x1) => { x0.method = x1 },
      JJ: (x0,x1) => x0.decode(x1),
      JK: (x0,x1,x2) => x0.setRequestHeader(x1,x2),
      JL: (x0,x1) => x0.connect(x1),
      JM: (x0,x1) => { x0.border = x1 },
      JN: (x0,x1) => x0.initTokenClient(x1),
      JO: x0 => x0.stop(),
      K: (exn) => {
        if (exn instanceof Error) {
          return exn.stack;
        } else {
          return null;
        }
      },
      KB: x0 => new ArrayBuffer(x0),
      KC: (x0,x1) => x0.append(x1),
      KD: (x0,x1) => x0.contains(x1),
      KE: (x0,x1) => x0.unregister(x1),
      KF: x0 => x0.length,
      KG: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      KH: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      KI: (x0,x1) => { x0.noValidate = x1 },
      KJ: x0 => x0.image,
      KK: (x0,x1) => { x0.responseType = x1 },
      KL: (x0,x1) => x0.start(x1),
      KM: x0 => x0.style,
      KN: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      KO: x0 => x0.label,
      L: o => o === undefined,
      LB: (x0,x1,x2) => new Uint8Array(x0,x1,x2),
      LC: (x0,x1,x2,x3) => x0.setProperty(x1,x2,x3),
      LD: (decoder, codeUnits) => decoder.decode(codeUnits),
      LE: x0 => x0.preventDefault(),
      LF: (x0,x1) => x0.exec(x1),
      LG: x0 => x0.send(),
      LH: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF64ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      LI: x0 => x0.click(),
      LJ: x0 => x0.close(),
      LK: () => new XMLHttpRequest(),
      LL: x0 => x0.destination,
      LM: (x0,x1) => { x0.id = x1 },
      LN: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      LO: x0 => x0.getSupportedConstraints(),
      M: o => String(o),
      MB: (x0,x1,x2) => new DataView(x0,x1,x2),
      MC: x0 => x0.style,
      MD: () => new TextDecoder("utf-8", {fatal: true}),
      ME: x0 => x0.parent,
      MF: x0 => x0.index,
      MG: x0 => x0.type,
      MH: (d, digits) => d.toFixed(digits),
      MI: (x0,x1) => x0.getElementsByClassName(x1),
      MJ: (x0,x1,x2,x3,x4) => ({type: x0,data: x1,premultiplyAlpha: x2,colorSpaceConversion: x3,preferAnimation: x4}),
      MK: (x0,x1,x2) => x0.open(x1,x2),
      ML: (x0,x1) => { x0.buffer = x1 },
      MM: (x0,x1) => x0.createElement(x1),
      MN: (x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10) => ({client_id: x0,callback: x1,scope: x2,include_granted_scopes: x3,prompt: x4,enable_granular_consent: x5,enable_serial_consent: x6,login_hint: x7,hd: x8,state: x9,error_callback: x10}),
      MO: x0 => x0.facingMode,
      N: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
      NB: (o, p) => o[p],
      NC: x0 => x0.debugShowSemanticsNodes,
      ND: () => new TextDecoder("utf-8", {fatal: false}),
      NE: x0 => x0.timeStamp,
      NF: x0 => x0.flags,
      NG: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      NH: (x0,x1,x2,x3) => x0.pushState(x1,x2,x3),
      NI: (x0,x1) => x0.dispatchEvent(x1),
      NJ: x0 => new window.ImageDecoder(x0),
      NK: () => {
        return typeof process != "undefined" &&
               Object.prototype.toString.call(process) == "[object process]" &&
               process.platform == "win32"
      },
      NL: (x0,x1) => x0.decodeAudioData(x1),
      NM: (x0,x1) => x0.removeAttribute(x1),
      NN: x0 => x0.message,
      NO: x0 => x0.deviceId,
      O: (x0,x1) => x0.didCreateEngineInitializer(x1),
      OB: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
      OC: o => o,
      OD: (a, i, v) => a[i] = v,
      OE: (x0,x1) => x0.hasAttribute(x1),
      OF: (a, s) => a.join(s),
      OG: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      OH: x0 => x0.history,
      OI: (x0,x1) => x0.createEvent(x1),
      OJ: x0 => x0.name,
      OK: x0 => x0.abort(),
      OL: x0 => x0.state,
      OM: (x0,x1) => { x0.currentTime = x1 },
      ON: x0 => x0.type,
      OO: x0 => x0.kind,
      P: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      PB: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
      PC: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'boolean') return 1;
        return 2;
      },
      PD: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI8ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      PE: x0 => x0.type,
      PF: (x0,x1) => x0.error(x1),
      PG: (x0,x1,x2,x3) => x0.removeEventListener(x1,x2,x3),
      PH: x0 => x0.search,
      PI: (x0,x1,x2,x3) => x0.initEvent(x1,x2,x3),
      PJ: x0 => x0.repetitionCount,
      PK: x0 => globalThis.URL.revokeObjectURL(x0),
      PL: (x0,x1,x2) => x0.insertBefore(x1,x2),
      PM: x0 => x0.currentTime,
      PN: x0 => x0.error_description,
      PO: (x0,x1) => x0.getUserMedia(x1),
      Q: (wasmFunction,f) => finalizeWrapper(f, function() { return wasmFunction(f,arguments.length) }),
      QB: o => o.byteOffset,
      QC: (x0,x1) => x0.warn(x1),
      QD: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI16ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      QE: (x0,x1) => x0.getModifierState(x1),
      QF: () => globalThis.console,
      QG: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      QH: x0 => x0.location,
      QI: x0 => x0.readText(),
      QJ: x0 => x0.frameCount,
      QK: Function.prototype.call.bind(DataView.prototype.getBigUint64),
      QL: x0 => x0.id,
      QM: (x0,x1) => { x0.playbackRate = x1 },
      QN: x0 => x0.expires_in,
      QO: (x0,x1) => ({video: x0,audio: x1}),
      R: (x0,x1) => ({initializeEngine: x0,autoStart: x1}),
      RB: o => o.buffer,
      RC: x0 => x0.console,
      RD: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      RE: x0 => x0.buttons,
      RF: s => s.trimRight(),
      RG: x0 => x0.response,
      RH: x0 => x0.pathname,
      RI: x0 => x0.clipboard,
      RJ: x0 => x0.selectedTrack,
      RK: (x0,x1) => x0.getRandomValues(x1),
      RL: x0 => x0.offsetHeight,
      RM: x0 => x0.pause(),
      RN: x0 => x0.error,
      RO: x0 => x0.mediaDevices,
      S: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      SB: Function.prototype.call.bind(DataView.prototype.getUint8),
      SC: () => globalThis.window,
      SD: (s) => +s,
      SE: x0 => x0.ctrlKey,
      SF: x0 => x0.blur(),
      SG: (x0,x1) => { x0.responseType = x1 },
      SH: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
      SI: (x0,x1) => x0.writeText(x1),
      SJ: x0 => x0.completed,
      SK: () => globalThis.crypto,
      SL: x0 => x0.offsetWidth,
      SM: x0 => x0.play(),
      SN: x0 => x0.access_token,
      SO: (x0,x1) => { x0.srcObject = x1 },
      T: x0 => new Promise(x0),
      TB: (b, o) => new DataView(b, o),
      TC: (o, c) => o instanceof c,
      TD: s => {
        if (!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(s)) {
          return NaN;
        }
        return parseFloat(s);
      },
      TE: x0 => x0.getBoundingClientRect(),
      TF: x0 => x0.button,
      TG: x0 => x0.vendor,
      TH: o => {
        const proto = Object.getPrototypeOf(o);
        return proto === Object.prototype || proto === null;
      },
      TI: x0 => x0.unlock(),
      TJ: x0 => x0.ready,
      TK: l => new DataView(new ArrayBuffer(l)),
      TL: x0 => x0.stopPropagation(),
      TM: x0 => x0.message,
      TN: (x0,x1,x2) => x0.hasGrantedAllScopes(x1,x2),
      TO: x0 => x0.getTracks(),
      U: (x0,x1,x2) => x0.call(x1,x2),
      UB: (b, o, l) => new DataView(b, o, l),
      UC: (string, token) => string.split(token),
      UD: s => s.trim(),
      UE: x0 => x0.y,
      UF: (x0,x1) => x0.prepend(x1),
      UG: x0 => x0.navigator,
      UH: o => Object.keys(o),
      UI: (x0,x1) => x0.lock(x1),
      UJ: x0 => x0.tracks,
      UK: o => o.byteLength,
      UL: x0 => x0.disabled,
      UM: (x0,x1) => x0.getElementById(x1),
      UN: () => globalThis.google.accounts.oauth2,
      UO: x0 => x0.height,
      V: (constructor, args) => {
        const factoryFunction = constructor.bind.apply(
            constructor, [null, ...args]);
        return new factoryFunction();
      },
      VB: Function.prototype.call.bind(DataView.prototype.getFloat64),
      VC: o => o instanceof Array,
      VD: x0 => x0.classList,
      VE: x0 => x0.x,
      VF: x0 => x0.parentElement,
      VG: x0 => x0.close(),
      VH: x0 => x0.state,
      VI: x0 => x0.orientation,
      VJ: () => globalThis.window.ImageDecoder,
      VK: x0 => ({type: x0}),
      VL: (x0,x1) => { x0.min = x1 },
      VM: (x0,x1,x2) => x0.setAttribute(x1,x2),
      VN: (x0,x1) => x0.initialize(x1),
      VO: x0 => x0.width,
      W: x0 => new Array(x0),
      WB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Float64Array) return 1;
        return 2;
      },
      WC: (a, i) => a[i],
      WD: x0 => x0.relatedTarget,
      WE: x0 => x0.top,
      WF: x0 => x0.innerHeight,
      WG: () => Date.now(),
      WH: x0 => x0.hash,
      WI: (x0,x1) => x0.querySelector(x1),
      WJ: (o, offsetInBytes, lengthInBytes) => {
        var dst = new ArrayBuffer(lengthInBytes);
        new Uint8Array(dst).set(new Uint8Array(o, offsetInBytes, lengthInBytes));
        return new DataView(dst);
      },
      WK: (x0,x1) => new Blob(x0,x1),
      WL: (x0,x1) => { x0.max = x1 },
      WM: (x0,x1) => x0.append(x1),
      WN: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      WO: (x0,x1,x2) => x0.setProperty(x1,x2),
      X: o => [o],
      XB: Function.prototype.call.bind(DataView.prototype.setFloat64),
      XC: a => a.length,
      XD: x0 => x0.hasFocus(),
      XE: x0 => x0.left,
      XF: x0 => x0.innerWidth,
      XG: () => typeof dartUseDateNowForTicks !== "undefined",
      XH: x0 => x0.state,
      XI: (x0,x1) => { x0.title = x1 },
      XJ: (a, s, e) => a.slice(s, e),
      XK: x0 => globalThis.URL.createObjectURL(x0),
      XL: (x0,x1) => { x0.disabled = x1 },
      XM: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      XN: (x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16) => ({client_id: x0,auto_select: x1,callback: x2,login_uri: x3,native_callback: x4,cancel_on_tap_outside: x5,prompt_parent_id: x6,nonce: x7,context: x8,state_cookie_domain: x9,ux_mode: x10,allowed_parent_origin: x11,intermediate_iframe_close_callback: x12,itp_support: x13,login_hint: x14,hd: x15,use_fedcm_for_prompt: x16}),
      XO: (x0,x1) => { x0.objectFit = x1 },
      Y: (o0, o1) => [o0, o1],
      YB: (t, s) => t.set(s),
      YC: (x0,x1) => x0.test(x1),
      YD: x0 => x0.shiftKey,
      YE: x0 => x0.scrollTop,
      YF: x0 => x0.height,
      YG: () => 1000 * performance.now(),
      YH: (x0,x1) => x0.go(x1),
      YI: (x0,x1) => x0.vibrate(x1),
      YJ: x0 => x0.naturalHeight,
      YK: (x0,x1,x2,x3,x4) => globalThis.exportRecapVideo(x0,x1,x2,x3,x4),
      YL: (x0,x1) => { x0.scrollLeft = x1 },
      YM: x0 => x0.remove(),
      YN: x0 => x0.error,
      YO: (x0,x1) => { x0.pointerEvents = x1 },
      Z: (o0, o1, o2) => [o0, o1, o2],
      ZB: Function.prototype.call.bind(DataView.prototype.setFloat32),
      ZC: x0 => x0.userAgent,
      ZD: x0 => x0.body,
      ZE: x0 => x0.offsetTop,
      ZF: x0 => x0.width,
      ZG: x0 => x0.pop(),
      ZH: (x0,x1) => x0.querySelectorAll(x1),
      ZI: x0 => x0.content,
      ZJ: x0 => x0.naturalWidth,
      ZK: x0 => x0.arrayBuffer(),
      ZL: (x0,x1) => { x0.spellcheck = x1 },
      ZM: x0 => x0.click(),
      ZN: x0 => x0.credential,
      ZO: (x0,x1) => { x0.transformOrigin = x1 },
      a: (o0, o1, o2, o3) => [o0, o1, o2, o3],
      aB: Function.prototype.call.bind(DataView.prototype.getFloat32),
      aC: x0 => x0.navigator,
      aD: x0 => x0.visibilityState,
      aE: x0 => x0.scrollLeft,
      aF: x0 => x0.clientHeight,
      aG: x0 => new Uint8Array(x0),
      aH: x0 => x0.maxHeight,
      aI: x0 => x0.document,
      aJ: (x0,x1) => x0.createElement(x1),
      aK: x0 => x0.type,
      aL: (x0,x1) => { x0.disabled = x1 },
      aM: (x0,x1) => { x0.target = x1 },
      aN: (o, p) => p in o,
      aO: (x0,x1) => { x0.transform = x1 },
      b: (x0,x1,x2) => { x0[x1] = x2 },
      bB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Float32Array) return 1;
        return 2;
      },
      bC: Function.prototype.call.bind(String.prototype.toLowerCase),
      bD: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      bE: x0 => x0.offsetLeft,
      bF: x0 => x0.clientWidth,
      bG: (x0,x1,x2) => x0.slice(x1,x2),
      bH: x0 => x0.maxWidth,
      bI: () => new AbortController(),
      bJ: (x0,x1) => { x0.pointerEvents = x1 },
      bK: (x0,x1,x2) => globalThis.flipVideo(x0,x1,x2),
      bL: () => {
        // On browsers return `globalThis.location.href`
        if (globalThis.location != null) {
          return globalThis.location.href;
        }
        return null;
      },
      bM: (x0,x1) => { x0.href = x1 },
      bN: x0 => x0.groups,
      bO: x0 => new Event(x0),
      c: o => o,
      cB: Function.prototype.call.bind(DataView.prototype.getUint32),
      cC: Object.is,
      cD: x0 => x0.disconnect(),
      cE: x0 => x0.offsetParent,
      cF: x0 => x0.isConnected,
      cG: (x0,x1) => x0.decode(x1),
      cH: x0 => x0.minHeight,
      cI: (x0,x1,x2,x3,x4,x5) => ({method: x0,headers: x1,body: x2,credentials: x3,redirect: x4,signal: x5}),
      cJ: (x0,x1) => { x0.height = x1 },
      cK: (x0,x1,x2,x3) => x0.putImageData(x1,x2,x3),
      cL: x0 => x0.canvasKitMaximumSurfaces,
      cM: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      cN: () => globalThis.removeSplashFromWeb(),
      cO: x0 => x0.type,
      d: (o, p) => o[p],
      dB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Uint32Array) return 1;
        return 2;
      },
      dC: x0 => x0.vendor,
      dD: x0 => new Intl.Locale(x0),
      dE: x0 => x0.offsetY,
      dF: x0 => x0.head,
      dG: (x0,x1) => x0.adoptText(x1),
      dH: x0 => x0.minWidth,
      dI: (x0,x1) => globalThis.fetch(x0,x1),
      dJ: (x0,x1) => { x0.width = x1 },
      dK: x0 => x0.arrayBuffer(),
      dL: x0 => x0.nextSibling,
      dM: x0 => x0.body,
      dN: x0 => ({mimeType: x0}),
      dO: x0 => x0.orientation,
      e: () => globalThis,
      eB: Function.prototype.call.bind(DataView.prototype.getInt32),
      eC: (x0,x1) => x0.createTextNode(x1),
      eD: x0 => x0.region,
      eE: x0 => x0.offsetX,
      eF: (x0,x1) => { x0.content = x1 },
      eG: x0 => x0.first(),
      eH: (x0,x1) => x0.removeProperty(x1),
      eI: (x0,x1) => x0.get(x1),
      eJ: x0 => x0.style,
      eK: (x0,x1) => x0.transferFromImageBitmap(x1),
      eL: (x0,x1) => x0.debug(x1),
      eM: (x0,x1) => { x0.innerHTML = x1 },
      eN: (x0,x1) => new MediaRecorder(x0,x1),
      eO: x0 => x0.screen,
      f: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      fB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Int32Array) return 1;
        return 2;
      },
      fC: (x0,x1) => { x0.id = x1 },
      fD: x0 => x0.script,
      fE: (o, p, r) => o.replace(p, () => r),
      fF: (x0,x1) => { x0.name = x1 },
      fG: x0 => x0.next(),
      fH: (x0,x1) => x0.add(x1),
      fI: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1,x2) { return wasmFunction(f,arguments.length,x0,x1,x2) }),
      fJ: (x0,x1) => { x0.src = x1 },
      fK: x0 => x0.rasterEndMilliseconds,
      fL: x0 => x0.hostElement,
      fM: x0 => x0.document,
      fN: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      fO: x0 => x0.extraAssets,
      g: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      gB: o => o instanceof Uint16Array,
      gC: (x0,x1) => { x0.nonce = x1 },
      gD: x0 => x0.language,
      gE: (x0,x1) => { x0.lastIndex = x1 },
      gF: (x0,x1) => x0.removeChild(x1),
      gG: x0 => x0.current(),
      gH: x0 => x0.data,
      gI: (x0,x1) => x0.forEach(x1),
      gJ: () => globalThis.document,
      gK: x0 => x0.rasterStartMilliseconds,
      gL: x0 => x0.location,
      gM: x0 => x0.userAgent,
      gN: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      gO: x0 => x0.fontManifest,
      h: (x0,x1) => ({addView: x0,removeView: x1}),
      hB: Function.prototype.call.bind(DataView.prototype.getUint16),
      hC: x0 => x0.nonce,
      hD: x0 => x0.languages,
      hE: (s, m) => {
        try {
          return new RegExp(s, m);
        } catch (e) {
          return String(e);
        }
      },
      hF: x0 => x0.firstChild,
      hG: (x0,x1) => new Intl.v8BreakIterator(x0,x1),
      hH: (x0,x1) => x0.removeAttribute(x1),
      hI: x0 => x0.name,
      hJ: (x0,x1) => x0.renderButton(x1),
      hK: x0 => x0.imageBitmaps,
      hL: (x0,x1) => x0.getModifierState(x1),
      hM: x0 => x0.baseURI,
      hN: x0 => x0.start(),
      hO: x0 => x0.assetManifest,
      i: (l, r) => l === r,
      iB: o => o instanceof Int16Array,
      iC: () => globalThis.window.flutterConfiguration,
      iD: (x0,x1) => x0.observe(x1),
      iE: o => o instanceof RegExp,
      iF: x0 => x0.viewConstraints,
      iG: x0 => x0.v8BreakIterator,
      iH: (x0,x1) => { x0.value = x1 },
      iI: x0 => x0.statusText,
      iJ: (x0,x1,x2) => x0.renderButton(x1,x2),
      iK: (x0,x1) => { x0.height = x1 },
      iL: x0 => x0.metaKey,
      iM: (x0,x1) => x0.querySelector(x1),
      iN: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      iO: x0 => x0.buildConfig,
      j: x0 => x0.random(),
      jB: Function.prototype.call.bind(DataView.prototype.getInt16),
      jC: (x0,x1) => x0.attachShadow(x1),
      jD: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      jE: x0 => x0.dotAll,
      jF: x0 => x0.hostElement,
      jG: () => globalThis.Intl,
      jH: (x0,x1) => { x0.value = x1 },
      jI: x0 => x0.url,
      jJ: (x0,x1,x2,x3,x4,x5,x6,x7,x8) => ({type: x0,theme: x1,size: x2,text: x3,shape: x4,logo_alignment: x5,width: x6,locale: x7,click_listener: x8}),
      jK: (x0,x1) => { x0.width = x1 },
      jL: x0 => x0.altKey,
      jM: (x0,x1) => x0.getAttribute(x1),
      jN: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      jO: x0 => x0.length,
      k: o => o,
      kB: o => o instanceof Uint8ClampedArray,
      kC: (x0,x1) => x0.createElement(x1),
      kD: x0 => new ResizeObserver(x0),
      kE: x0 => x0.unicode,
      kF: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      kG: (x0,x1) => x0.segment(x1),
      kH: x0 => x0.value,
      kI: x0 => x0.status,
      kJ: () => globalThis.google.accounts.id,
      kK: x0 => x0.convertToBlob(),
      kL: x0 => x0.ctrlKey,
      kM: (x0,x1) => x0.debug(x1),
      kN: x0 => x0.data,
      kO: x0 => x0.getReader(),
      l: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'number') return 1;
        return 2;
      },
      lB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Uint8Array) return 1;
        return 2;
      },
      lC: x0 => x0.scale,
      lD: (x0,x1) => x0.getPropertyValue(x1),
      lE: x0 => x0.ignoreCase,
      lF: x0 => ({runApp: x0}),
      lG: x0 => x0.index,
      lH: x0 => x0.selectionDirection,
      lI: x0 => x0.getReader(),
      lJ: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      lK: (x0,x1,x2) => new ImageData(x0,x1,x2),
      lL: x0 => x0.isComposing,
      lM: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      lN: x0 => x0.srcObject,
      lO: x0 => x0.value,
      m: () => globalThis.Math,
      mB: Function.prototype.call.bind(DataView.prototype.setInt32),
      mC: x0 => x0.visualViewport,
      mD: x0 => globalThis.parseFloat(x0),
      mE: x0 => x0.multiline,
      mF: (x0,x1) => x0.requestAnimationFrame(x1),
      mG: x0 => x0.next(),
      mH: x0 => x0.selectionStart,
      mI: x0 => x0.read(),
      mJ: x0 => new MutationObserver(x0),
      mK: (x0,x1) => x0.getContext(x1),
      mL: x0 => x0.code,
      mM: x0 => ({createScriptURL: x0}),
      mN: (x0,x1) => { x0.videoBitsPerSecond = x1 },
      mO: x0 => x0.done,
      n: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      nB: Function.prototype.call.bind(DataView.prototype.setUint32),
      nC: x0 => x0.devicePixelRatio,
      nD: (x0,x1) => x0.getComputedStyle(x1),
      nE: (o, p, r) => o.replaceAll(p, () => r),
      nF: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      nG: x0 => x0.value,
      nH: x0 => x0.selectionEnd,
      nI: x0 => x0.value,
      nJ: x0 => ({childList: x0}),
      nK: (x0,x1) => new OffscreenCanvas(x0,x1),
      nL: x0 => x0.repeat,
      nM: (x0,x1,x2) => x0.createPolicy(x1,x2),
      nN: (x0,x1) => { x0.audioBitsPerSecond = x1 },
      nO: x0 => x0.read(),
      o: b => !!b,
      oB: Function.prototype.call.bind(DataView.prototype.setInt16),
      oC: x0 => x0.height,
      oD: x0 => x0.documentElement,
      oE: x0 => x0.deltaMode,
      oF: x0 => x0.now(),
      oG: x0 => x0.done,
      oH: x0 => x0.value,
      oI: x0 => x0.done,
      oJ: (x0,x1,x2) => x0.observe(x1,x2),
      oK: x0 => x0.allocationSize(),
      oL: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      oM: (x0,x1) => x0.createScriptURL(x1),
      oN: x0 => globalThis.MediaRecorder.isTypeSupported(x0),
      oO: x0 => x0.body,
      p: () => globalThis.document,
      pB: Function.prototype.call.bind(DataView.prototype.setUint16),
      pC: x0 => x0.width,
      pD: x0 => x0.computedStyleMap(),
      pE: x0 => x0.deltaY,
      pF: x0 => x0.performance,
      pG: (o, m, a) => o[m].apply(o, a),
      pH: x0 => x0.selectionDirection,
      pI: x0 => x0.cancel(),
      pJ: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      pK: (x0,x1) => x0.copyTo(x1),
      pL: (x0,x1) => { x0.loop = x1 },
      pM: (x0,x1) => x0.appendChild(x1),
      pN: x0 => x0.message,
      pO: x0 => x0.assetBase,
      q: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      qB: Function.prototype.call.bind(DataView.prototype.setUint8),
      qC: x0 => x0.screen,
      qD: (x0,x1) => x0.get(x1),
      qE: x0 => x0.deltaX,
      qF: x0 => new WeakRef(x0),
      qG: x0 => x0.iterator,
      qH: x0 => x0.selectionStart,
      qI: x0 => x0.body,
      qJ: x0 => new ResizeObserver(x0),
      qK: (x0,x1) => { x0.height = x1 },
      qL: (x0,x1) => { x0.volume = x1 },
      qM: x0 => x0.head,
      qN: (x0,x1,x2) => x0.translate(x1,x2),
      qO: x0 => x0.loader,
      r: (x0,x1) => x0.focus(x1),
      rB: Function.prototype.call.bind(DataView.prototype.setInt8),
      rC: (string, times) => string.repeat(times),
      rD: (o, p) => p in o,
      rE: x0 => x0.wheelDeltaY,
      rF: x0 => x0.deref(),
      rG: () => globalThis.Symbol,
      rH: x0 => x0.selectionEnd,
      rI: x0 => x0.headers,
      rJ: (x0,x1) => x0.observe(x1),
      rK: (x0,x1) => { x0.width = x1 },
      rL: (x0,x1) => { x0.muted = x1 },
      rM: (x0,x1) => { x0.nonce = x1 },
      rN: (x0,x1,x2) => x0.scale(x1,x2),
      rO: () => globalThis._flutter,
      s: () => ({}),
      sB: Function.prototype.call.bind(DataView.prototype.getInt8),
      sC: o => {
        if (o === null || o === undefined) return 0;
        if (typeof(o) === 'string') return 1;
        return 2;
      },
      sD: (x0,x1) => { x0.textContent = x1 },
      sE: x0 => x0.wheelDeltaX,
      sF: () => globalThis.WeakRef,
      sG: (x0,x1) => new Intl.Segmenter(x0,x1),
      sH: (x0,x1) => { x0.name = x1 },
      sI: x0 => x0.signal,
      sJ: x0 => x0.disconnect(),
      sK: (x0,x1) => x0.toDataURL(x1),
      sL: x0 => x0.load(),
      sM: (x0,x1) => x0.querySelectorAll(x1),
      sN: (x0,x1,x2,x3,x4,x5) => x0.drawImage(x1,x2,x3,x4,x5),
      t: (o, p, v) => o[p] = v,
      tB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Int8Array) return 1;
        return 2;
      },
      tC: x0 => x0.tabIndex,
      tD: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      tE: x0 => x0.bottom,
      tF: x0 => x0.search,
      tG: x0 => x0.Segmenter,
      tH: (x0,x1) => { x0.placeholder = x1 },
      tI: x0 => x0.close(),
      tJ: x0 => x0.height,
      tK: (x0,x1,x2,x3) => x0.drawImage(x1,x2,x3),
      tL: (x0,x1) => { x0.src = x1 },
      tM: x0 => x0.nonce,
      tN: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      u: () => [],
      uB: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
      uC: (x0,x1) => x0.contains(x1),
      uD: x0 => x0.matches,
      uE: x0 => x0.right,
      uF: x0 => x0.hostname,
      uG: x0 => x0.buffer,
      uH: (x0,x1) => { x0.autocomplete = x1 },
      uI: (o, p, v) => o[p] = v,
      uJ: x0 => x0.width,
      uK: (x0,x1,x2,x3,x4,x5,x6,x7,x8,x9) => x0.drawImage(x1,x2,x3,x4,x5,x6,x7,x8,x9),
      uL: x0 => x0.message,
      uM: (x0,x1) => { x0.src = x1 },
      uN: (x0,x1,x2) => x0.toBlob(x1,x2),
      v: (a, i) => a.push(i),
      vB: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
      vC: x0 => x0.activeElement,
      vD: (x0,x1) => x0.matchMedia(x1),
      vE: x0 => x0.clientY,
      vF: x0 => x0.location,
      vG: x0 => x0.wasmMemory,
      vH: (x0,x1) => { x0.type = x1 },
      vI: x0 => x0.height,
      vJ: x0 => x0.contentRect,
      vK: (x0,x1) => x0.getContext(x1),
      vL: x0 => x0.code,
      vM: (x0,x1) => { x0.src = x1 },
      vN: (x0,x1) => x0.getContext(x1),
      w: x0 => new Int8Array(x0),
      wB: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
      wC: x0 => x0.parentNode,
      wD: x0 => x0.matches,
      wE: x0 => x0.clientX,
      wF: () => globalThis.window,
      wG: () => globalThis.window._flutter_skwasmInstance,
      wH: (x0,x1) => { x0.name = x1 },
      wI: x0 => x0.width,
      wJ: (x0,x1) => x0.item(x1),
      wK: x0 => x0.format,
      wL: x0 => x0.error,
      wM: (x0,x1) => { x0.defer = x1 },
      wN: x0 => x0.getVideoTracks(),
      x: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI8ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      xB: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
      xC: x0 => x0.tagName,
      xD: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
      xE: x0 => x0.changedTouches,
      xF: () => globalThis.appFlavor,
      xG: () => new TextDecoder(),
      xH: (x0,x1) => { x0.placeholder = x1 },
      xI: (x0,x1,x2,x3,x4,x5) => x0.createImageBitmap(x1,x2,x3,x4,x5),
      xJ: x0 => x0.length,
      xK: (x0,x1,x2,x3,x4) => x0.getImageData(x1,x2,x3,x4),
      xL: (x0,x1) => x0.start(x1),
      xM: (x0,x1) => { x0.async = x1 },
      xN: x0 => x0.getSettings(),
      y: x0 => new Uint8Array(x0),
      yB: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
      yC: x0 => x0.target,
      yD: f => f.dartFunction,
      yE: x0 => x0.key,
      yF: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      yG: (a, i) => a.splice(i, 1),
      yH: (x0,x1) => { x0.scrollTop = x1 },
      yI: (x0,x1,x2) => x0.createImageBitmap(x1,x2),
      yJ: x0 => x0.addedNodes,
      yK: x0 => x0.data,
      yL: (x0,x1) => x0.end(x1),
      yM: x0 => x0.trustedTypes,
      yN: x0 => x0.facingMode,
      z: x0 => new Uint8ClampedArray(x0),
      zB: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
      zC: x0 => x0.clientY,
      zD: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      zE: x0 => x0.identifier,
      zF: (x0,x1,x2) => x0.addEventListener(x1,x2),
      zG: a => a.pop(),
      zH: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      zI: (x0,x1) => x0.createImageBitmap(x1),
      zJ: x0 => x0.firstElementChild,
      zK: () => new FileReader(),
      zL: x0 => x0.length,
      zM: () => globalThis.console,
      zN: (x0,x1) => { x0.height = x1 },

    };

    const baseImports = {
      _: dart2wasm,
      Math: Math,
      Date: Date,
      Object: Object,
      Array: Array,
      Reflect: Reflect,
      WebAssembly: {
        JSTag: WebAssembly.JSTag,
      },
      "": new Proxy({}, { get(_, prop) { return prop; } }),

    };

    

    dartInstance = await WebAssembly.instantiate(this.module, {
      ...baseImports,
      ...additionalImports,
      
    });

    return new InstantiatedApp(this, dartInstance);
  }
}

class InstantiatedApp {
  constructor(compiledApp, instantiatedModule) {
    this.compiledApp = compiledApp;
    this.instantiatedModule = instantiatedModule;
  }

  // Call the main function with the given arguments.
  invokeMain(...args) {
    this.instantiatedModule.exports.$invokeMain(args);
  }
}
