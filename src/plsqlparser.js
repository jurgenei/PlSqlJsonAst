
import antlr4        from 'antlr4';
import PlSqlLexer    from '../build/parser/PlSqlLexer.js';
import PlSqlParser   from '../build/parser/PlSqlParser.js';
import PlSqlParserListener from '../build/parser/PlSqlParserListener.js';

class Listener extends PlSqlParserListener 
{
  enterEveryRule(ctx) {
  }
  exitEveryRule(ctx) {
  }
  visitTerminal(node) {
    console.log("node: ", node);
  }
}

export const plsqlparser = () => {
  console.log("start  plsqlparser");

  const input = 'select bar from foo;';
  const chars = new antlr4.InputStream(input);
  const lexer = new PlSqlLexer(chars);
  lexer.strictMode = false; // do not use js strictMode
  const tokens = new antlr4.CommonTokenStream(lexer);
  const parser = new PlSqlParser(tokens);

  const tree = parser.sql_script();
  const listener = new Listener();

  antlr4.tree.ParseTreeWalker.DEFAULT.walk(listener, tree);

  console.log("end  plsqlparser");
}
