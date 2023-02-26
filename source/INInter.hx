package;

import IN.Expr;
import flixel.util.FlxStringUtil.LabelValuePair;
import haxe.ds.List;
import openfl.Vector;

class INInter
{
	var ast:Array<Expr>;

	var labels:Map<String, Vector<Expr>>;

	public function new(ast:Array<Expr>)
	{
		this.ast = ast;
		labels = new Map();
		prepare();
	}

	public var labelPos:String = 'start';
	public var pos:Int = 0;

	public function eval()
	{
		var start = labels.get(labelPos);

		if (pos > start.length - 1)
			return trace('(The End)');

		switch (start[pos])
		{
			case EString(s):
				trace(s);
			case ECallLabel(n):
				labelPos = n;
				pos = -1;
				trace('(switching to "' + n + '" label)');
			case _:
		}
		pos++;
	}

	function prepare()
	{
		labels.set('start', new Vector());
		for (expr in ast)
		{
			switch (expr)
			{
				case EString(s):
					labels.get('start').push(EString(s));
				case ELabel(m, l):
					labels.set(m, arrToList(l));
				case ECallLabel(n):
					labels.get('start').push(ECallLabel(n));
			}
		}

		function eval() {}
	}

	function arrToList(arr:Array<Expr>)
	{
		var list = new Vector();
		for (el in arr)
			list.push(el);
		return list;
	}
}
