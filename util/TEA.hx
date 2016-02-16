package util;
//import haxe.Int;

//import Int;

class TEA
{
    static public var base = haxe.io.Bytes.ofString("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ=.");
    static public var key = [1, 2, 3, 4];

    static private function encrypt (v:Array<Int>, k:Array<Int>):Array<Int>
    {
        var v0 = v[0];
        var v1 = v[1];
        var sum:Int = 0;
        var delta:Int = 0x9e37 << 16 + 0x79b9;
        var k0 = k[0], k1 = k[1], k2 = k[2], k3 = k[3];
        for (i in 0...32)
        {
            sum += delta;

            v0 = v0.add(((v1.shl(4) + k0)).xor(v1.add(sum)).xor((v1.shr(5) + k1)));
            v1 = v1.add(((v0.shl(4) + k2)).xor(v0.add(sum)).xor((v0.shr(5) + k3)));
        }
        v[0] = v0;
        v[1] = v1;

        return v;
    }

    static private function decrypt (v:Array<Int>, k:Array<Int>):Array<Int>
    {
        var v0 = v[0];
        var v1 = v[1];

        var sum:Int = 0xC6EF << 16 + 0x3720;
        var delta:Int = 0x9e37 << 16 + 0x79b9;
        var k0 = k[0], k1 = k[1], k2 = k[2], k3 = k[3];

        for (i in 0...32)
        {
            v1 = v1.sub(((v0.shl(4) + k2)).xor(v0.add(sum)).xor((v0.shr(5) + k3)));
            v0 = v0.sub(((v1.shl(4) + k0)).xor(v1.add(sum)).xor((v1.shr(5) + k1)));
            sum = sum.sub(delta);
        }

        v[0]=v0;
        v[1]=v1;

        return v;
    }

    static public function crypt(str:String):String
    {
        var out:Array<Int> = [];

        var index = 0;

        for (i in 0...Math.ceil(str.length / 4))
        {
            var c0 = getCharCode(str, index++);
            var c1 = getCharCode(str, index++);
            var c2 = getCharCode(str, index++);
            var c3 = getCharCode(str, index++);
            var c4 = getCharCode(str, index++);
            var c5 = getCharCode(str, index++);
            var c6 = getCharCode(str, index++);
            var c7 = getCharCode(str, index++);

            var b0 = c0 + c1 << 8  + c2 << 16 + c3 << 24;
            var b1 = c4.add(c5) << 8  + c6 << 16 + c7 << 24;

            var o = encrypt([b0, b1], key);
            out.push(o[0]);
            out.push(o[1]);
        }

        var b = new haxe.io.BytesOutput();
        for (i in 0...out.length)
        {
            b.writeInt(out[i]);
        }

        var baseCode = new haxe.BaseCode(base);

        return baseCode.encodeBytes(b.getBytes()).toString();
    }

    static public function getCharCode(str:String, index:Int)
    {
        if (str.length > index)
            return str.charCodeAt(index);

        return 0;
    }

    static public function uncrypt(str:String):String
    {
        var arr:Array<Int> = [];

        var baseCode = new haxe.BaseCode(base);

        var bytes = baseCode.decodeBytes(haxe.io.Bytes.ofString(str));
        var b = new haxe.io.BytesInput(bytes);

        for (i in 0...Std.int(bytes.length / 4))
        {
            arr.push(b.readInt());
        }

        var out = "";

        var mask = 0xFF;

        for (i in 0...Std.int(arr.length / 2))
        {
            var decrypted = decrypt([arr[i * 2], arr[i * 2 + 1]], key);
            out += String.fromCharCode(decrypted[0].and(mask).toInt());
            out += String.fromCharCode(decrypted[0].shr(8).and(mask).toInt());
            out += String.fromCharCode(decrypted[0].shr(16).and(mask).toInt());
            out += String.fromCharCode(decrypted[0].shr(24).and(mask).toInt());
            out += String.fromCharCode(decrypted[1].and(mask).toInt());
            out += String.fromCharCode(decrypted[1].shr(8).and(mask).toInt());
            out += String.fromCharCode(decrypted[1].shr(16).and(mask).toInt());
            out += String.fromCharCode(decrypted[1].shr(24).and(mask).toInt());
        }

        //Filter out trailing \0s
        var final = "";
        for (i in 0...out.length)
        {
            if (out.charCodeAt(i) == 0)
                return final;

            final += out.charAt(i);
        }

        return final;
    }

    //Usage exemple :
    static public function main()
    {
        //Change key to something you want to
        TEA.key = [1, 2, 3, 4];

        var toCrypt = "1234567890";

        //Crypt values
        var r = TEA.crypt(toCrypt);

        var base = TEA.uncrypt(r);

        if (base != toCrypt)
            throw "Not working !";

        trace("Crypted and decrypted "+toCrypt+" successfully.");
    }
}
