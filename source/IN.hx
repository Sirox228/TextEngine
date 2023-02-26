package;

import byte.ByteData;
import hxparse.Lexer;
import hxparse.LexerTokenSource;
import hxparse.Parser;
import hxparse.RuleBuilder;

using StringTools;

// import hxparse.Parser.parse as parse;

private enum Token
{
	TDblDot;
	TNumber(v:String);
	TString(v:String);
	TEof;
	TLabel(v:String);
	TEndLabel;
	TCallLabel(n:String);
}

enum Expr
{
	EString(s:String);
	ELabel(m:String, l:Array<Expr>);
	ECallLabel(n:String);
}

class INLexer extends Lexer implements RuleBuilder
{
	static var buf:StringBuf;

	public static var tok = @:rule [
		// ":" => TDblDot,
		"-?(([1-9][0-9]*)|0)(.[0-9]+)?([eE][\\+\\-]?[0-9]+)?" => TNumber(lexer.current),
		'"' => {
			buf = new StringBuf();
			lexer.token(string);
			TString(buf.toString());
		},
		"[\r\n\t ]" => lexer.token(tok),
		"" => TEof,
		"end" => TEndLabel,
		"goto[ ]*[A-Za-z0-9]+;" => {
			var regex = ~/[A-Za-z0-9]+/gm;
			regex.match(lexer.current);
			var text = regex.matchedRight();
			TCallLabel(text.substr(0, text.length - 1).trim());
		},
		"[A-Za-z0-9]+:" => TLabel(lexer.current.substr(0, lexer.current.length - 1)) // "[A-Za-z]+" => TLabelString(lexer.current)
	];

	static var string = @:rule [
		"\\\\t" => {
			buf.addChar("\t".code);
			lexer.token(string);
		},
		"\\\\n" => {
			buf.addChar("\n".code);
			lexer.token(string);
		},
		"\\\\r" => {
			buf.addChar("\r".code);
			lexer.token(string);
		},
		'\\\\"' => {
			buf.addChar('"'.code);
			lexer.token(string);
		},
		"\\\\u[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]" => {
			buf.add(String.fromCharCode(Std.parseInt("0x" + lexer.current.substr(2))));
			lexer.token(string);
		},
		'"' => {
			lexer.curPos().pmax;
		},
		'[^"]' => {
			buf.add(lexer.current);
			lexer.token(string);
		},
	];
}

class INParser extends Parser<LexerTokenSource<Token>, Token>
{
	public function new(input:ByteData, sourceName:String)
	{
		var lexer = new INLexer(input, sourceName);
		var ts = new LexerTokenSource(lexer, INLexer.tok);
		super(ts);
	}

	public function parse():Array<Expr>
	{
		// return Parser.parse(switch stream
		// {
		// 	case [TLabel(s)]: s;
		// 	case [TString(s)]: s;
		// 	case [TDblDot]: '(TDblDot)';
		// 	case [TNumber(s)]: s;
		// });
		var exprs = [];
		var parsing = true;
		while (parsing)
		{
			var expr = parseToken();
			switch (expr)
			{
				case null:
					parsing = false;
				case _:
					exprs.push(expr);
			}
		}
		return exprs;
	}

	function parseToken():Dynamic
	{
		return Parser.parse(switch stream
		{
			case [TLabel(v)]: parseLabel([], v);
			case [TString(s)]: EString(s);
			case [TCallLabel(n)]: ECallLabel(n);
			case [TEof]: null;
				// case [TString(v)]: parseNext(stream);
		});
	}

	function parseLabel(dialogs:Array<Expr>, name:String):Dynamic
	{
		return Parser.parse(switch stream
		{
			case [TEndLabel]: ELabel(name, dialogs);
			case [elt = parseToken()]:
				switch (peek(0))
				{
					case TString(s):
						dialogs.push(EString(s));
					case TCallLabel(n):
						dialogs.push(ECallLabel(n));
					case _:
				}
				dialogs.push(elt);
				switch stream
				{
					case [TEndLabel]: ELabel(name, dialogs);
					case [TString(_)]: parseLabel(dialogs, name);
					case [TCallLabel(_)]: parseLabel(dialogs, name);
				}
		});
	}
}
