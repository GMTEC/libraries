/*
 * Copyright (C)2005-2012 Haxe Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */
package pdf;

class Int32 {

	public static inline function make( a : Int, b : Int ) : Int32 {
		return cast ((a << 16) | b);
	}

	public static inline function ofInt( x : Int ) : Int32 {
		return clamp(cast x);
	}

	static inline function clamp( x : Int32 ) : Int32 {
		#if (js || flash8 || php)
		return cast ((cast x) | 0); // force to-int convertion
		#else
		return x;
		#end
	}

	public static inline function toInt( x : Int32 ) : Int {
		if( (((cast x) >> 30) & 1) != ((cast x) >>> 31) ) throw "Overflow " + x;
		#if php
		return (cast x) & 0xFFFFFFFF;
		#else
		return cast x;
		#end
	}

	public static inline function toNativeInt( x : Int32 ) : Int {
		return cast x;
	}

	public static inline function add( a : Int32, b : Int32 ) : Int32 {
		return clamp(cast ((cast a) + (cast b)));
	}

	public static inline function sub( a : Int32, b : Int32 ) : Int32 {
		return clamp(cast ((cast a) - (cast b)));
	}

	public static inline function mul( a : Int32, b : Int32 ) : Int32 {
		#if (flash8 || php || js)
		return add(cast ((cast a) * ((cast b) & 0xFFFF)),clamp(cast ((cast a) * ((cast b) >>> 16) << 16)));
		#else
		return clamp(cast ((cast a) * (cast b)));
		#end
	}

	public static inline function div( a : Int32, b : Int32 ) : Int32 {
		return cast Std.int(cast(a) / cast(b));
	}

	public static inline function mod( a : Int32, b : Int32 ) : Int32 {
		return cast (cast(a) % cast(b));
	}

	public static inline function shl( a : Int32, b : Int ) : Int32 {
		return cast ((cast a) << b);
	}

	public static inline function shr( a : Int32, b : Int ) : Int32 {
		return cast ((cast a) >> b);
	}

	public static inline function ushr( a : Int32, b : Int ) : Int32 {
		return cast ((cast a) >>> b);
	}

	public static inline function and( a : Int32, b : Int32 ) : Int32 {
		return cast ((cast a) & (cast b));
	}

	public static inline function or( a : Int32, b : Int32 ) : Int32 {
		return cast ((cast a) | (cast b));
	}

	public static inline function xor( a : Int32, b : Int32 ) : Int32 {
		return cast ((cast a) ^ (cast b));
	}

	public static inline function neg( a : Int32 ) : Int32 {
		return cast -(cast a);
	}

	public static inline function isNeg( a : Int32 ) : Bool {
		return (cast a) < 0;
	}

	public static inline function isZero( a : Int32 ) : Bool {
		return (cast a) == 0;
	}

	public static inline function complement( a : Int32 ) : Int32 {
		return cast ~(cast a);
	}

	public static inline function compare( a : Int32, b : Int32 ) : Int {
		#if neko
		return untyped __i32__compare(a,b);
		#else
		return untyped a - b;
		#end
	}

	/**
		Compare two Int32 in unsigned mode.
	**/
	public static function ucompare( a : Int32, b : Int32 ) : Int {
		if( isNeg(a) )
			return isNeg(b) ? compare(complement(b),complement(a)) : 1;
		return isNeg(b) ? -1 : compare(a,b);
	}

}