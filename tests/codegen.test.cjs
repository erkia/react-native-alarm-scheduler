const assert = require('node:assert/strict');
const { test } = require('node:test');
const { mkdtempSync, readFileSync, rmSync } = require('node:fs');
const { tmpdir } = require('node:os');
const path = require('node:path');
const { createRequire } = require('node:module');

const rnRequire = createRequire(require.resolve('react-native/package.json'));
const { TypeScriptParser } = rnRequire('@react-native/codegen/lib/parsers/typescript/parser');
const { generateSpecFromInMemorySchema } = require('react-native/scripts/codegen/generate-specs-cli-executor.js');

test('Codegen generates Android and iOS bindings for all public methods and events', () => {
  const directory = mkdtempSync(path.join(tmpdir(), 'alarm-codegen-test-'));
  try {
    const schema = new TypeScriptParser().parseFile(path.resolve('src/specs/NativeAlarmScheduler.ts'));
    for (const platform of ['android', 'ios']) {
      generateSpecFromInMemorySchema(platform, schema, path.join(directory, platform), 'AlarmSchedulerSpec', 'expo.modules.alarm', 'modules', false);
    }
    const android = readFileSync(path.join(directory, 'android/java/expo/modules/alarm/NativeAlarmSchedulerSpec.java'), 'utf8');
    const ios = readFileSync(path.join(directory, 'ios/AlarmSchedulerSpec/AlarmSchedulerSpec.h'), 'utf8');
    const source = readFileSync('src/AlarmSchedulerModule.ts', 'utf8');
    const methods = [...source.matchAll(/^  (\w+Async)\(/gm)].map((m) => m[1]);
    assert.equal(methods.length, 23);
    for (const method of methods) {
      assert.ok(android.includes(`void ${method}(`), method);
      assert.ok(ios.includes(`(void)${method}:`), method);
    }
    assert.match(android, /emitOnAlarmEvent/);
    assert.match(ios, /emitOnAlarmEvent/);
  } finally {
    rmSync(directory, { recursive: true, force: true });
  }
});
