module.exports = {
  dependency: {
    platforms: {
      android: {
        sourceDir: './android',
        packageImportPath: 'import expo.modules.alarm.AlarmSchedulerPackage;',
        packageInstance: 'new AlarmSchedulerPackage()',
      },
      ios: {},
    },
  },
};
