const assert = require('node:assert/strict');
const { test } = require('node:test');
const { readFileSync } = require('node:fs');
const path = require('node:path');
const ts = require('typescript');

function loadModule({ web = false, native = {} } = {}) {
  const cache = new Map();
  function load(filename) {
    if (cache.has(filename)) return cache.get(filename).exports;
    const module = { exports: {} };
    cache.set(filename, module);
    const source = ts.transpileModule(readFileSync(filename, 'utf8'), {
      compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2020 },
    }).outputText;
    const localRequire = (id) => {
      if (id === 'react-native') return { TurboModuleRegistry: { getEnforcing(name) {
        assert.equal(name, 'AlarmScheduler');
        return native;
      } } };
      assert.ok(id.startsWith('.'), `Unexpected runtime dependency: ${id}`);
      return load(path.resolve(path.dirname(filename), `${id}.ts`));
    };
    new Function('require', 'module', 'exports', source)(localRequire, module, module.exports);
    return module.exports;
  }
  return load(path.resolve('src', web ? 'AlarmSchedulerModule.web.ts' : 'AlarmSchedulerModule.ts')).default;
}

test('public methods forward inputs/results without Expo; omitted arguments become native null', async () => {
  const calls = [];
  const result = { metadata: { text: 'wake up', count: 3, enabled: false } };
  const native = new Proxy({}, { get: (_, name) => (...args) => {
    calls.push([name, ...args]);
    return Promise.resolve(result);
  } });
  const api = loadModule({ native });
  const alarm = { hour: 7, minute: 30, ios: { silent: false, metadata: result.metadata }, android: { volume: 0 }, soundUri: 'file:///song.wav' };
  assert.equal(await api.scheduleAlarmAsync(alarm), result);
  assert.deepEqual(calls.pop(), ['scheduleAlarmAsync', alarm]);
  for (const name of ['clearPendingAlarmActionsAsync', 'getAlarmOccurrencesAsync']) {
    await api[name]();
    assert.deepEqual(calls.pop(), [name, null]);
  }
  await api.scheduleNativeAlarmBackupAsync('alarm');
  assert.deepEqual(calls.pop(), ['scheduleNativeAlarmBackupAsync', 'alarm', null]);
  await api.scheduleNativeAlarmBackupAsync('alarm', 0);
  assert.deepEqual(calls.pop(), ['scheduleNativeAlarmBackupAsync', 'alarm', 0]);
  for (const name of ['getPermissionsAsync', 'requestPermissionsAsync', 'openAlarmSettingsAsync', 'openFullScreenIntentSettingsAsync', 'getScheduledAlarmsAsync', 'getCurrentAlarmContextAsync', 'getPendingAlarmActionsAsync', 'getPendingNativeAlarmHandoffAsync', 'clearPendingNativeAlarmHandoffAsync', 'openSystemAlarmAppAsync']) {
    await api[name]();
    assert.deepEqual(calls.pop(), [name]);
  }
  for (const name of ['cancelAlarmAsync', 'completeNativeAlarmAsync', 'cancelAlarmOccurrenceAsync', 'cancelNativeAlarmBackupAsync', 'clearBypassAsync', 'resetNativeAlarmCompletionAsync', 'getNativeAlarmDebugStateAsync']) {
    await api[name]('id');
    assert.deepEqual(calls.pop(), [name, 'id']);
  }
  const resolution = { outcome: 'deferred', next: { delaySeconds: 10, relationship: 'deferred' }, idempotencyKey: 'retry' };
  await api.resolveAlarmOccurrenceAsync('occurrence', resolution);
  assert.deepEqual(calls.pop(), ['resolveAlarmOccurrenceAsync', 'occurrence', resolution]);
  await api.setSystemAlarmAsync(alarm);
  assert.deepEqual(calls.pop(), ['setSystemAlarmAsync', alarm]);
  await api.clearPendingAlarmActionsAsync([]);
  assert.deepEqual(calls.pop(), ['clearPendingAlarmActionsAsync', []]);
});

test('null results and native rejections retain their meaning', async () => {
  const error = Object.assign(new Error('Unreadable audio'), { code: 'ERR_INVALID_ALARM' });
  const api = loadModule({ native: {
    getCurrentAlarmContextAsync: async () => null,
    scheduleAlarmAsync: async () => { throw error; },
  } });
  assert.equal(await api.getCurrentAlarmContextAsync(), null);
  await assert.rejects(api.scheduleAlarmAsync({ hour: 1, minute: 2 }), (e) => e === error);
});

test('events keep independent subscriptions, first/last observer lifecycle, and idempotent removal', () => {
  let dispatch;
  let subscribed = 0;
  let removed = 0;
  const observations = [];
  const api = loadModule({ native: {
    onAlarmEvent(callback) { subscribed++; dispatch = callback; return { remove() { removed++; } }; },
    setObserving(...args) { observations.push(args); },
  } });
  const received = [];
  const callback = (payload) => received.push(payload);
  const first = api.addListener('onAlarmAction', callback);
  const second = api.addListener('onAlarmAction', callback);
  const state = api.addListener('onAlarmStateChange', callback);
  assert.equal(subscribed, 1);
  assert.deepEqual(observations, [['onAlarmAction', true], ['onAlarmStateChange', true]]);
  dispatch({ name: 'onAlarmAction', payload: { id: 'action' } });
  assert.equal(received.length, 2);
  first.remove(); first.remove();
  assert.equal(api.listenerCount('onAlarmAction'), 1);
  assert.equal(observations.length, 2);
  api.removeAllListeners('onAlarmAction');
  assert.deepEqual(observations.at(-1), ['onAlarmAction', false]);
  assert.equal(removed, 0);
  const next = api.addListener('onAlarmAction', callback);
  second.remove(); // A stale subscription must not remove a newly added listener.
  assert.equal(api.listenerCount('onAlarmAction'), 1);
  next.remove(); state.remove();
  assert.equal(removed, 1);
  assert.equal(api.listenerCount('onAlarmAction'), 0);
});

test('web needs neither React Native nor Expo and keeps explicit unsupported/no-op behavior', async () => {
  const api = loadModule({ web: true });
  assert.equal((await api.getPermissionsAsync()).status, 'unavailable');
  assert.equal(await api.openFullScreenIntentSettingsAsync(), false);
  assert.equal(await api.getCurrentAlarmContextAsync(), null);
  assert.deepEqual(await api.getScheduledAlarmsAsync(), []);
  assert.equal(await api.cancelAlarmAsync('id'), false);
  assert.equal((await api.scheduleNativeAlarmBackupAsync('id')).scheduled, false);
  await assert.rejects(api.scheduleAlarmAsync({ hour: 1, minute: 2 }), /only available/);
  await assert.rejects(api.setSystemAlarmAsync({ hour: 1, minute: 2 }), /only available/);
  const subscription = api.addListener('onAlarmAction', () => {});
  subscription.remove(); subscription.remove();
});
