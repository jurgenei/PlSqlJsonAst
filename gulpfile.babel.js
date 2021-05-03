
import gulp from 'gulp';
import { clean } from './gulp/clean.js';
import { build } from './gulp/build.js';
import { run }   from './gulp/run.js';
import { jsvalidate } from './gulp/jsvalidate.js'//;
import { demo }  from './gulp/demo.js';

gulp.task('default', gulp.series('clean', 'build'));

