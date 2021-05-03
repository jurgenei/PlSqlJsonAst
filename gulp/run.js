
import gulp from 'gulp';
const { src, dest } = gulp;
import antlr4 from 'gulp-antlr4';

const grammarGlob = [
  'src/static/antlr4/grammars/**/*.g4'
];
const parserDir = 'build/src/parsers';
const dataGlob = [
  'src/static/data/**/*.sql'
];
const grammar = 'PlSql';
const rule = 'sql_script';
const listener = 'PlSqlListener';
const listenerDir = 'build/src/parser';

const astDir = 'build/ast';

export const run = () => {
  return gulp.src(dataGlob) 
	 .pipe(dest(astDir))
}

gulp.task('run',run);
