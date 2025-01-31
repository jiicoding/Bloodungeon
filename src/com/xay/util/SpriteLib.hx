package com.xay.util;
import flash.display.Graphics;
import flash.display.Shape;
import flash.geom.Matrix;
import haxe.ds.StringMap;
#if openfl
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.Assets;
#elseif flash
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
#end
typedef Slice = {
	xOff:Int,
	yOff:Int,
	frameWid:Int,
	frameHei:Int,
	wid:Int,
	hei:Int,
	margin:Int,
	bdName:String
}
typedef AnimDef = {
	sliceName:String,
	frames:Array<Int>,
	fps:Float,
}
class SpriteLib {
	static var bds = new StringMap<BitmapData>();
	public static var slices = new StringMap<Slice>();
	static var animDefs = new StringMap<AnimDef>();
	#if openfl
	public static function addBD(bdName:String, bd:BitmapData) {
	// for openfl we want to register the bitmap data
		//if(bds.exists(bdName)) return;
		//bds.set(bdName, bd);
	}
	public static function sliceBD(path:String, sliceName:String, xOff:Int, yOff:Int, frameWid:Int, frameHei:Int, wid:Int=null, hei:Int=null, margin=0) {
		var name = sliceName;
		if(!bds.exists(path)) {
			var bd = Assets.getBitmapData("assets/"+path+".png");
			bds.set(name, bd);
		}
		var bd = bds.get(name);
		if(wid==null) wid = Std.int(bd.width/frameWid);
		if(hei==null) hei = Std.int(bd.height/frameHei);
		var slice : Slice = {xOff:xOff, yOff:yOff, frameWid:frameWid, frameHei:frameHei, wid:wid, hei:hei, margin:margin, bdName:name};
		slices.set(name, slice);
	}
	#elseif flash
	public static function addBD(bdName:String, bd:BitmapData) {
		if(bds.exists(bdName)) return;
		bds.set(bdName, bd);
	}
	public static function sliceBD(bdName:String, sliceName:String, xOff:Int, yOff:Int, frameWid:Int, frameHei:Int, wid:Int=null, hei:Int=null, margin=0) {
		var name = sliceName;
		var bd = getBD(bdName);
		if(bd == null) return;
		if(wid==null) wid = Std.int(bd.width / frameWid);
		if(hei==null) hei = Std.int(bd.height / frameHei);
		var slice : Slice = {xOff:xOff, yOff:yOff, frameWid:frameWid, frameHei:frameHei, wid:wid, hei:hei, margin:margin, bdName:bdName};
		slices.set(name, slice);
	}
	#end
	public static function getBD(name:String) {
		if(!bds.exists(name)) {
			trace("BD " + name + " not found");
			return null;
		}
		return bds.get(name);
	}
	public static function getSliceFrameRect(name:String, frame:Int) {
		if(!slices.exists(name)) {
			trace("Slice " + name + " not found");
			return null;
		}
		var slice = slices.get(name);
		if(frame<0 || frame>=slice.wid*slice.hei) {
			trace("Invalid frame id " + frame + " in slice " + name);
			return null;
		}
		return new Rectangle(slice.xOff + (frame%slice.wid)*(slice.frameWid+slice.margin), slice.yOff + Std.int(frame/slice.wid)*(slice.frameHei+slice.margin), slice.frameWid, slice.frameHei);
	}
	public static function getNewAnim(name:String) {
		if(!animDefs.exists(name)) {
			trace("AnimDef " + name + " not found");
			return null;
		}
		var animDef = animDefs.get(name);
		return new Anim(animDef.sliceName, animDef.frames, animDef.fps);
	}
	public static function copyFramePixelsFromSlice(destBD:BitmapData, sliceName:String, frame=0, destx=0, desty=0) {
		var frameRect = getSliceFrameRect(sliceName, frame);
		if(frameRect==null) return;
		var slice = slices.get(sliceName);
		destBD.copyPixels(bds.get(slice.bdName), frameRect, new Point(destx, desty));
	}
	public static function copyFramePixelsFromAnim(destBD:BitmapData, anim:Anim, destx=0, desty=0) {
		var frameRect = anim.getFrameRect();
		if(frameRect==null) return;
		destBD.copyPixels(bds.get(slices.get(anim.getSliceName()).bdName), frameRect, new Point(destx, desty));
	}
	public static function copyFramePixelsFromSliceToGraphics(g:Graphics, sliceName:String, frame=0, center=true, ?destx=0., ?desty=0.) {
		var frameRect = getSliceFrameRect(sliceName, frame);
		if(frameRect==null) return;
		var slice = slices.get(sliceName);
		var bd = bds.get(slice.bdName);
		if(center == true) {
			destx = -frameRect.width * .5;
			desty = -frameRect.height * .5;
		}
		var mat = new Matrix();
		mat.translate(-frameRect.left + destx, -frameRect.top + desty);
		g.beginBitmapFill(bd, mat);
		g.drawRect(destx, desty, frameRect.width, frameRect.height);
		g.endFill();
	}
	public static function addAnim(animName:String, sliceName:String, content:String, fps=60.) {
		content = StringTools.replace(content, " ", "");
		content = StringTools.replace(content, ")", "(");
		var frames = [];
		var parts = content.split(",");
		for(p in parts) {
			var nbFrames = 1;
			var from = 0;
			var to = 0;
			var backwards = false;
			if(p.indexOf("(") > 0) {
				var nbf = Std.parseInt(p.split("(")[1]);
				if(Math.isNaN(nbf)) {
					trace("Invalid nb of frames");
					return;
				}
				nbFrames = nbf;
				p = p.substr(0, parts.indexOf("("));
			}
			if(p.indexOf("-") > 0) {
				from = Std.parseInt(p.split("-")[0]);
				to = Std.parseInt(p.split("-")[1]);
				if(from > to) {
					backwards = true;
					from ^= to; to ^= from; from ^= to;
				}
			} else if(p.indexOf("-") < 0) {
				from = to = Std.parseInt(p);
			} else {
				trace("Invalid anim definition of " + animName + ": " + content);
				return;
			}
			for(i in from...to+1) {
				for(t in 0...nbFrames) {
					var f = backwards?to-i+from:i;
					frames.push(f);
				}
			}
		}
		animDefs.set(animName, {sliceName:sliceName, frames:frames, fps:fps});
	}
}