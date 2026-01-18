#Requires AutoHotkey v1.1.17+
;==============================================================
; normalizeSendKeys — Normalizes Send-style modifier syntax into explicit key down/up sequences
;
; GitHub: https://github.com/SevenKeyboard/normalize-send-keys
; Author: SevenKeyboard Ltd. (2026)
; License: The Unlicense
;==============================================================

/*
Example Usage:
    msgbox % normalizeSendKeys("<^a") ;  "{LCtrl down}a{LCtrl up}"
*/

class VersionManager_normalizeSendKeys
{
    static _ := VersionManager_normalizeSendKeys._init()
    _init()    {
        global
        NORMALIZESENDKEYS_VERSION := "1.0.0"
    }
}
normalizeSendKeys(keys, allowDuplicateModifiers:=false)    {
    static translMap:={"^":"Ctrl","+":"Shift","!":"Alt","#":"LWin"
                    ,"<^":"LCtrl","<+":"LShift","<!":"LAlt","<#":"LWin"
                    ,">^":"RCtrl",">+":"RShift",">!":"RAlt",">#":"RWin"}
    regExMatch(keys,"isD`aO)^(.*?)(\{Text}|\{Raw})(.*)$",m)
        ?(usualKeys:=m[1]   ,rawKeys:=m[2] . m[3])
        :(usualKeys:=keys   ,rawKeys:="")
    ;---------------------------------
    spo:=1, out:=""
    while (fpo:=regExMatch(usualKeys
    , "s`aO)(?<!\{)(?P<affix>(?:[<>]?[\Q^+!#\E])+)"
    . "(?P<main>\{.+?}|[^\Q^+!#{}\E])",m,spo))    {
        out.=subStr(usualKeys,spo,fpo-spo), spo:=m.pos(0)+m.len(0)
        ,vMain:=m.main
        ,vAffix:=m.affix
        ,(vMain~="D`a)^([A-Z]|\{[A-Z]})$"?(vMain:=format("{:L}",vMain), vAffix.="+"):"")
        ;---------------------------------
        ,affixList:=[]
        ,prevField:= currField:= ""
        loop Parse, % vAffix
        {
            prevField:=currField, currField:=A_LoopField
            (prevField~="<|>")
                ?affixList[affixList.length()].=currField
                :affixList.push(currField)
        }
        ;---------------------------------
        prefix:= suffix:= ""
        ,modifierKeyCount:={Ctrl:0,LCtrl:0,RCtrl:0
                            ,Alt:0,LAlt:0,RAlt:0
                            ,Shift:0,LShift:0,RShift:0
                            ,Win:0,LWin:0,RWin:0}
        for _,v in affixList    {
            modifierKeyCount[modifierKey:=translMap[v]]++
            switch (!!allowDuplicateModifiers)
            {
                case false:
                    if (2<=modifierKeyCount[modifierKey])
                        continue
            }
            prefix.="{" modifierKey " down}"
            ,suffix:="{" modifierKey " up}" . suffix
        }
        out.=prefix . vMain . suffix
    }
    out.=subStr(usualKeys,spo)
    return out . rawKeys
}