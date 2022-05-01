local stringmatch = string.match
local stringgmatch = string.gmatch
local stringsub = string.sub
local stringgsub = string.gsub
local stringfind = string.find
local stringlen = string.len
local ioread = io.read
local next = next
local print = print

local function Minify(Source)
    Source = stringgsub(Source, "\n", " ")
    Source = stringgsub(Source, "\t", " ")
    Source = stringgsub(Source, "[%s]*([%s]+)[%s]*", " ")
    Source = stringgsub(Source, "[%s]*,[%s]*", ",")
    Source = stringgsub(Source, "[%s]*=[%s]*", "=")
    Source = stringgsub(Source, "[%s]*%+[%s]*", "+")
    Source = stringgsub(Source, "[%s]*%-[%s]*", "-")
    Source = stringgsub(Source, "[%s]*%/[%s]*", "/")
    Source = stringgsub(Source, "[%s]*%*[%s]*", "*")
    Source = stringgsub(Source, "[%s]*%^[%s]*", "^")
    Source = stringgsub(Source, "[%s]*%%[%s]*", "%%")
    Source = stringgsub(Source, "[%s]*%.%.[%s]*", "..")
    Source = stringgsub(Source, "[%s]*<[%s]*", "<")
    Source = stringgsub(Source, "[%s]*>[%s]*", ">")
    Source = stringgsub(Source, "[%s]*==[%s]*", "==")
    Source = stringgsub(Source, "[%s]*~=[%s]*", "~=")
    Source = stringgsub(Source, "[%s]*<=[%s]*", "<=")
    Source = stringgsub(Source, "[%s]*>=[%s]*", ">=")
    Source = stringgsub(Source, "{[%s]*", "{")
    Source = stringgsub(Source, "[%s]*}", "}")
    Source = stringgsub(Source, "%[[%s]*", "[")
    Source = stringgsub(Source, "[%s]*%]", "]")
    Source = stringgsub(Source, "not[%s]*%(", "not(")
    Source = stringgsub(Source, "not[%s]+", "not ")
    Source = stringgsub(Source, "[%s]*%([%s]*", "(")
    Source = stringgsub(Source, "[%s]*%)[%s]*", ")")

    return Source
end

local function ConvertOperators(Code)
    local CachedLOP = {}
	local Operators = {"([%w_]+[%s]*%+=[%s]*[%w_]+)", "([%w_]+[%s]*%-=[%s]*[%w_]+)", "([%w_]+[%s]*%*=[%s]*[%w_]+)", "([%w_]+[%s]*/=[%s]*[%w_]+)", "([%w_]+[%s]*%^=[%s]*[%w_]+)", "([%w_]+[%s]*%%=[%s]*[%w_]+)", "([%w_]+[%s]*%.%.=[%s]*[%w_]+)"}
	local Patterns = {"+=", "-=", "*=", "/=", "^=", "%=", "..="}

	for Index, Value in next, Operators do
		for v in stringgmatch(Code, Value) do
			CachedLOP[#CachedLOP + 1] = {v, Patterns[Index]}
		end
	end

	for _, Value in next, CachedLOP do
		local FirstVariable = stringmatch(Value[1], "([%w_]+)[%s]*"..Value[2])
		local SecondVariable = stringmatch(Value[1], Value[2].."[%s]*([%w_]+)")
		local Start, End = stringfind(Code, Value[1], 1, true)
        local Operator = stringsub(Value[2], 1, stringlen(Value[2]) - 1)

		Code = stringsub(Code, 1, Start - 1)..FirstVariable.." = "..FirstVariable.." "..Operator.." "..SecondVariable..stringsub(Code, End + 1, stringlen(Code))
	end

	return Code
end

return function(Code)

    --// Remove Comments & Clean Up

    Code = stringgsub(Code, "(%-%-%[(=*)%[.-%]%2%])", "")
    Code = stringgsub(Code, "(%-%-[^\r\n]*)", "")

    --// Minify

    Code = Minify(Code)

    local function Error()
        print("\n   [!] (Hook.lua): Unmatched or unsupported obfuscator!"); local _ = ioread(); return "N/A"
    end

    if stringmatch(Code, "local function [%w_]+%([%w_]+,[%w_]+,[%w_]+%)local [%w_]+=[%w_]+%[1%];local [%w_]+=[%w_]+%[2%];local [%w_]+=[%w_]+%[3%];local [%w_]+=[%w_]+%[4%];return function%(%.%.%.%)") then -- IronBrew V2

        --// Inject Hook

        local Hook = [[local function SetType(Value) if getfenv()[tostring(Value)] then return Value elseif type(Value) == "string" then return "\""..Value.."\"" else return Value end end local File = assert(io.open(".\\Output.lua", "w+")) local Output = "--[=[\n\n\t• Exunys - Constant Dumper [IronBrew V2] (Dumped @"..os.date()..")\n\n]=]\n\nlocal Dumped_"..os.time().." = {" table.foreach(CONSTANTTABLE, function(Index, Value) Output = Output.."\n\t["..tostring(Index).."] = "..tostring(SetType(Value)).."," end) File:write(string.sub(Output, 1, string.len(Output) - 1).."\n}") File:close()]]
        local _, End, Constants = stringfind(Code, "local function [%w_]+%([%w_]+,[%w_]+,[%w_]+%)local [%w_]+=[%w_]+%[[%d]+%];local ([%w_]+)=[%w_]+%[[%d]+%];")

        if not End then return Error() end

        local Part1 = stringsub(Code, 1, End)
        local Part2 = stringsub(Code, End, stringlen(Code))
        Code = Part1..stringgsub(Hook, "CONSTANTTABLE", Constants)..Part2
    elseif stringmatch(Code, "[%w_]+=%([%w_]+==true and [%w_]+%(%)%)or [%w_]+") then -- AztupBrew

        --// Inject Hook

        local Hook = [[local function SetType(Value) if getfenv()[tostring(Value)] then return Value elseif type(Value) == "string" then return "\""..Value.."\"" else return Value end end local File = assert(io.open(".\\Output.lua", "w+")) local Output = "--[=[\n\n\t• Exunys - Constant Dumper [AztupBrew] (Dumped @"..os.date()..")\n\n]=]\n\nlocal Dumped_"..os.time().." = {" for Index = 1, #CONSTANTTABLE[1] do Output = Output.."\n\t["..tostring(Index).."] = "..tostring(SetType(CONSTANTTABLE[1][Index][3])).."," end File:write(string.sub(Output, 1, string.len(Output) - 1).."\n}") File:close()]]
        local _, End, Constants = stringfind(Code, "[%w_]+=%([%w_]+==true and [%w_]+%(%)%)or ([%w_]+)")

        if not End then return Error() end

        local Part1 = stringsub(Code, 1, End + 1)
        local Part2 = stringsub(Code, End + 1, stringlen(Code))
        Code = Part1..stringgsub(Hook, "CONSTANTTABLE", Constants)..Part2
    elseif stringmatch(Code, "[PSU]*[KFC]* Obfuscator [%d]+%.[%d]+%.[%u]+") then -- PSU
        Code = ConvertOperators(Code)

        local Hook = [[local function Hook(ConstantTable) local function SetType(Value) if getfenv()[tostring(Value)] then return Value elseif type(Value) == "string" then return "\""..Value.."\"" else return Value end end local File = assert(io.open(".\\Output.lua", "w+")) local Output = "--[=[\n\n\t• Exunys - Constant Dumper [AztupBrew] (Dumped @"..os.date()..")\n\n]=]\n\nlocal Dumped_"..os.time().." = {" for Index, Value in ConstantTable do Output = Output.."\n\t["..tostring(Index).."] = "..tostring(SetType(Value)).."," end File:write(string.sub(Output, 1, string.len(Output) - 1).."\n}") File:close() end]]
        local Start, End, Constants = stringfind(Code, "%(([%w_]+)%(%.%.%.%)%)")
        local Hooked = Hook..";Hook("..Constants.."(...))"

        if not Start then return Error() end

        local Part1 = stringsub(Code, 1, End)
        local Part2 = Hooked
        local Part3 = stringsub(Code, End, stringlen(Code))
        Code = Part1..Part2..Part3
    else
        return Error()
    end

    if _G.Cache then
        io.open("Cache.lua", "w+"):write(Code)
    end

    return Code
end