import gulp from 'gulp';
import antlr4 from 'gulp-antlr4';

const grammarGlob = [
  'src/static/antlr4/grammars/**/*.g4'
];
const parserDir = 'build/parser';
const dataGlob = [
  'src/static/data/**/*.sql'
];
const grammar = 'PlSql';
const rule = 'sql_script';

export const build = () => {
  return gulp.src(grammarGlob) // If the glob contains .g4 files,
  // they will be processed first and the data files buffered, then the new
  // generated translator will process them
    .pipe(antlr4({
      grammar: grammar, // Stem for all the generated Parser file names
      parserDir: parserDir, // Where to find/put the generated Parser files
      rule: rule, // Starting rule for parsing data files
    })); // Streams down the translated data files
}

gulp.task('build',build);
