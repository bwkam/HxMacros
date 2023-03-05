/**
	A very simple and short utility macro inspired by HaxeFlixel's AssetsPath 
**/

import sys.FileSystem;
import haxe.macro.Expr;
import haxe.macro.Context;

using haxe.macro.Tools;
using Lambda;
using StringTools;

// Lessons learned: macro converts basic types to `TPath`, so macro reification!!!
class AssetsPath {
	private static var files:Array<String> = [];

	public static function build() {
		var fields = Context.getBuildFields();
		recursiveLoop(FileSystem.absolutePath("assets"));
		for (file in files) {
			fields.push({
				name: file.split(".")[0].replace("-", "_"),
				access: [Access.APublic, Access.AStatic],
				kind: FieldType.FVar(macro :String, macro $v{file}),
				pos: Context.currentPos()
			});
		}

		return fields;
	}

	/**
		A function that recursively returns the contents of `directory`
	**/
	private static function recursiveLoop(directory):Void {
		for (file in sys.FileSystem.readDirectory(directory)) {
			var path = haxe.io.Path.join([directory, file]);
			if (!sys.FileSystem.isDirectory(path)) {
				files.push(file);
			} else {
				var directory = haxe.io.Path.addTrailingSlash(path);
				recursiveLoop(directory);
			}
		}
	}
}
