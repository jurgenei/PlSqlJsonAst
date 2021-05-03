import gulp from 'gulp';
import validate from 'gulp-jsvalidate';

export const jsvalidate = () => {
  console.log("Validate JavaScript");
  return gulp.src("build/**.js")
    .pipe(validate());
};

gulp.task('jsvalidate', jsvalidate);
