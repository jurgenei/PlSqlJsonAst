import gulp from 'gulp';

import { plsqlparser } from '../src/plsqlparser.js';

export const demo = (cb) => {
  console.log("start demo");
  plsqlparser();
  console.log("end demo");
  cb();
};

gulp.task('demo', demo);
