--[[
    Supported Obfuscators:
        IronBrew V2
        AztupBrew -- NOT TESTED A LOT DUE TO THE PROJECT NOW BEING DISCONTINUED, OUTPUT COULD BE INACCURATE
        PSU -- NOT TESTED A LOT DUE TO THE PROJECT NOW BEING DISCONTINUED, OUTPUT COULD BE INACCURATE OR PROCESS COULD EASILY BREAK
]]

local ioopen = io.open
local ioread = io.read
local ioclose = io.close
local osremove = os.remove
local osexecute = os.execute
local osexit = os.exit
local loadstring = loadstring
local require = require
local assert = assert
local print = print

_G.Cache = false -- Caches the hooked, obfuscated code

if ioopen(".\\Output.lua") then
    osremove(".\\Output.lua")
end

osexecute("color 03"); osexecute("cls")
print("\n   [*] Exunys - Constant Dumper: Starting process...\n")

local Input = assert(ioopen(".\\Input.txt", "r"))
Source = Input:read("*a")
local Hook = require(".\\Resources\\Hook")
ioclose(Input)
local Hooked = Hook(Source)

if Hooked ~= "N/A" then
    loadstring(Hooked)()
else
    osexit()
end

osexecute("cls"); print("\n   [*] Exunys - Constant Dumper: Process has finished! Check Output.lua for results.\n"); _ = ioread()