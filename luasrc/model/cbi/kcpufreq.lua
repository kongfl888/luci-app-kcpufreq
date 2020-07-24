-- [K] (c)2020
-- http://github.com/kongfl888

local sys = require "luci.sys"
local fs = require "nixio.fs"

function string.trim(str)
    return (string.gsub(str, "^[%s\n\r\t]*(.-)[%s\n\r\t]*$", "%1"))
end

function string.split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

cpu_freqs = fs.readfile("/sys/devices/system/cpu/cpufreq/policy0/scaling_available_frequencies") or "1296000"
cpu_freqs = string.trim(cpu_freqs)

cpu_governors = fs.readfile("/sys/devices/system/cpu/cpufreq/policy0/scaling_available_governors") or "conservative"
cpu_governors = string.trim(cpu_governors)

freq_array = string.split(cpu_freqs, " ")
governor_array = string.split(cpu_governors, " ")

cur_gov = fs.readfile("/sys/devices/system/cpu/cpufreq/policy0/scaling_governor")

mp = Map("kcpufreq", translate("CPU Freq Settings"))
mp.description = translate("Set CPU Scaling Governor to Max Performance or Balance Mode <a href=\"https://github.com/kongfl888/luci-app-autorewan\">Github</a>")

s = mp:section(NamedSection, "kcpufreq", "settings")
s.anonymouse = true

enable=s:option(Flag,"enable",translate("Enable"))
enable.rmempty = false
enable.default=0

governor = s:option(ListValue, "governor", translate("Plan"))
for _, e in ipairs(governor_array) do
	if e ~= "" then governor:value(translate(e,string.upper(e))) end
end
governor.description = "<b>"..translate("Current governor: ")..string.format(" [ %s ]", cur_gov).."</b>"..translate("<br/><br/>"
.."Performance: the cpu run at the maxfreq. the best performance.<br/>"
.."Ondemand: fast up,fast down. the traditional governor of linux. the better performance. default.<br/>"
.."Conservative: slow up,fast down.same as Ondemand,but energy conservation.Ordinary performance.<br/>"
.."UserSpace: all in user. Not recommended. <br/>"
.."Schedutil: the new governor of linux. Base on EAS. Recommended.<br/>"
.."Powersave: the cpu run at the minfreq, the best energy saving.<br/><br/>"
)

advance=s:option(Flag,"advance",translate("Advance"))
advance.rmempty = false
advance.default=0
advance.description="Apply the following settings.<br/>Uncheck it, unless you know what to do.The same below."

minfreq = s:option(ListValue, "minifreq", translate("Min Idle CPU Freq"))
for _, e in ipairs(freq_array) do
	if e ~= "" then minfreq:value(e) end
end
minfreq.description="Ignore it, unless ni know what is it."

maxfreq = s:option(ListValue, "maxfreq", translate("Max Turbo Boost CPU Freq"))
for _, e in ipairs(freq_array) do
	if e ~= "" then maxfreq:value(e) end
end
maxfreq.description="Ignore it, unless ni know what is it."

local apply =luci.http.formvalue("cbi.apply")
if apply then
    sys.call("/etc/init.d/kcpufreq enable &")
    sys.call("sleep 10 && /etc/init.d/kcpufreq restart &")
end

return mp
