-- [K] (c)2020
-- http://github.com/kongfl888

local sys = require "luci.sys"
local fs = require "nixio.fs"

local function isempty(s)
  return s == nil or s == ''
end

function string.trim(str)
    if isempty(str) then
        return ''
    end
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

local function read_file(f)
    if not fs.access(f) then
        return ''
    end
    return fs.readfile(f)
end

cpu_freqs = read_file("/sys/devices/system/cpu/cpufreq/policy0/scaling_available_frequencies")
cpu_freqs = string.trim(cpu_freqs)
if isempty(cpu_freqs) then
    cpu_freqs = read_file("/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies")
    cpu_freqs = string.trim(cpu_freqs)
    if isempty(cpu_freqs) then
        cpu_freqs = "1296000"
    end
end

cpu_governors = read_file("/sys/devices/system/cpu/cpufreq/policy0/scaling_available_governors")
cpu_governors = string.trim(cpu_governors)
if isempty(cpu_governors) then
    cpu_governors = read_file("/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors")
    cpu_governors = string.trim(cpu_governors)
    if isempty(cpu_governors) then
         cpu_governors = "conservative"
    end
end

freq_array = string.split(cpu_freqs, " ")
governor_array = string.split(cpu_governors, " ")

cur_gov = read_file("/sys/devices/system/cpu/cpufreq/policy0/scaling_governor")
cur_gov = string.trim(cur_gov)
if isempty(cur_gov) then
    cur_gov = read_file("/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor")
    if isempty(cur_gov) then
         cur_gov = "read failed"
    end
end

mp = Map("kcpufreq", translate("CPU Freq Settings"))
mp.description = translate("Set CPU Scaling Governor to Max Performance or Balance Mode <a href=\"https://github.com/kongfl888/luci-app-kcpufreq\">Github</a>")

s = mp:section(NamedSection, "kcpufreq", "settings")
s.anonymouse = true

enable=s:option(Flag,"enable",translate("Enable"))
enable.rmempty = false
enable.default=0

governor = s:option(ListValue, "governor", translate("Plan"))
for _, e in ipairs(governor_array) do
	if e ~= "" then governor:value(translate(e,string.upper(e))) end
end
governor.description = "<b>"..translate("Current governor:")..string.format(" [ %s ]", cur_gov).."</b>"..translate("<br/><br/>"
.."Performance: the cpu run at the maxfreq. the best performance.<br/>"
.."Ondemand: fast up,fast down. the traditional governor of linux. the better performance. default.<br/>"
.."Conservative: slow up,fast down.same as Ondemand,but energy conservation.Ordinary performance.<br/>"
.."UserSpace: all in user. Not recommended. <br/>"
.."Schedutil: the new governor of linux. Base on EAS. Recommended.<br/>"
.."Powersave: the cpu run at the minfreq, the best energy saving.<br/>"
.."Please wait for 10s after change!<br/><br/>"
)

advance=s:option(Flag,"advance",translate("Advance"))
advance.rmempty = false
advance.default=0
advance.description=translate("Apply the following settings.<br/>Uncheck it, unless you know what to do.The same below.")

minfreq = s:option(ListValue, "minifreq", translate("Min Idle CPU Freq"))
for _, e in ipairs(freq_array) do
	if e ~= "" then minfreq:value(e) end
end
minfreq.description=translate("Ignore it, unless ni know what is it.")

maxfreq = s:option(ListValue, "maxfreq", translate("Max Turbo Boost CPU Freq"))
for _, e in ipairs(freq_array) do
	if e ~= "" then maxfreq:value(e) end
end
maxfreq.description=translate("Ignore it, unless ni know what is it.")

local apply =luci.http.formvalue("cbi.apply")
if apply then
    if fs.access("/etc/init.d/kcpufreq") then
        sys.call("/bin/chmod +x /etc/init.d/kcpufreq")
        sys.exec("/etc/init.d/kcpufreq enable &")
        sys.exec("sleep 10 && /etc/init.d/kcpufreq restart &")
        sys.call("sleep 5")
    end
end

return mp
