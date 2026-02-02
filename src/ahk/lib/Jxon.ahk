; =============================================================================
; Jxon.ahk - Minimal JSON parser for AHK v2
; Only supports: string, number, boolean, null, object, array
; =============================================================================

class Jxon {

    static Load(src) {
        p := 1
        return Jxon._Value(&src, &p)
    }

    static _Value(&s, &p) {
        Jxon._White(&s, &p)
        c := SubStr(s, p, 1)
        if c = '"'
            return Jxon._Str(&s, &p)
        if c = "{"
            return Jxon._Obj(&s, &p)
        if c = "["
            return Jxon._Arr(&s, &p)
        if c = "t" {
            p += 4
            return true
        }
        if c = "f" {
            p += 5
            return false
        }
        if c = "n" {
            p += 4
            return ""
        }
        return Jxon._Num(&s, &p)
    }

    static _White(&s, &p) {
        while p <= StrLen(s) && InStr(" `t`n`r", SubStr(s, p, 1))
            p++
    }

    static _Str(&s, &p) {
        p++
        result := ""
        while p <= StrLen(s) {
            c := SubStr(s, p, 1)
            if c = '"' {
                p++
                return result
            }
            if c = "\" {
                p++
                c2 := SubStr(s, p, 1)
                switch c2 {
                    case '"':  result .= '"'
                    case "\": result .= "\"
                    case "/":  result .= "/"
                    case "n":  result .= "`n"
                    case "t":  result .= "`t"
                    case "r":  result .= "`r"
                    default:   result .= c2
                }
                p++
                continue
            }
            result .= c
            p++
        }
        return result
    }

    static _Num(&s, &p) {
        start := p
        if SubStr(s, p, 1) = "-"
            p++
        while p <= StrLen(s) && RegExMatch(SubStr(s, p, 1), "[0-9.eE+\-]")
            p++
        return Number(SubStr(s, start, p - start))
    }

    static _Obj(&s, &p) {
        p++
        result := Map()
        Jxon._White(&s, &p)
        if SubStr(s, p, 1) = "}" {
            p++
            return result
        }
        loop {
            Jxon._White(&s, &p)
            key := Jxon._Str(&s, &p)
            Jxon._White(&s, &p)
            p++
            val := Jxon._Value(&s, &p)
            result[key] := val
            Jxon._White(&s, &p)
            if SubStr(s, p, 1) = "}" {
                p++
                return result
            }
            p++
        }
    }

    static _Arr(&s, &p) {
        p++
        result := []
        Jxon._White(&s, &p)
        if SubStr(s, p, 1) = "]" {
            p++
            return result
        }
        loop {
            result.Push(Jxon._Value(&s, &p))
            Jxon._White(&s, &p)
            if SubStr(s, p, 1) = "]" {
                p++
                return result
            }
            p++
        }
    }
}
