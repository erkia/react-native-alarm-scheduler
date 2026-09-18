const assert = require('node:assert/strict');
const { test } = require('node:test');
const { mkdtempSync, mkdirSync, writeFileSync, rmSync } = require('node:fs');
const { tmpdir } = require('node:os');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

// Check header lookup independently of the Apple SDK. Stub dependency contents;
// the actual adapter header and the compiler's include resolution remain in use.
test('iOS adapter resolves CocoaPods public headers and direct Codegen headers', (t) => {
  const compiler = process.env.CXX || 'c++';
  const available = spawnSync(compiler, ['--version']);
  if (available.error?.code === 'ENOENT') {
    t.skip('C++ preprocessor is not installed');
    return;
  }
  const directory = mkdtempSync(path.join(tmpdir(), 'alarm-ios-header-'));
  try {
    for (const layout of ['ReactCodegen/AlarmSchedulerSpec', 'AlarmSchedulerSpec']) {
      const includeDir = path.join(directory, layout.startsWith('ReactCodegen') ? 'pods' : 'direct');
      for (const name of ['Foundation/Foundation.h', 'React/RCTInvalidating.h', `${layout}/AlarmSchedulerSpec.h`]) {
        const filename = path.join(includeDir, name);
        mkdirSync(path.dirname(filename), { recursive: true });
        writeFileSync(filename, name.endsWith('AlarmSchedulerSpec.h') ? '#define ALARM_SPEC_RESOLVED 1\n' : '');
      }
      const result = spawnSync(compiler, ['-E', '-x', 'c++', '-I', includeDir, '-'], {
        encoding: 'utf8',
        input: `#include "${path.resolve('ios/AlarmScheduler/RCTAlarmScheduler.h')}"\n#ifndef ALARM_SPEC_RESOLVED\n#error Codegen header was not imported\n#endif\n`,
      });
      assert.equal(result.status, 0, `${layout}: ${result.stderr || result.error}`);
    }
  } finally {
    rmSync(directory, { recursive: true, force: true });
  }
});
