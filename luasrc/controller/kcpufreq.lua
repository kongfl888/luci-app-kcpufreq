-- [K] (c)2020
-- http://github.com/kongfl888

module("luci.controller.kcpufreq", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/kcpufreq") then
		return
	end

	entry({"admin", "system", "kcpufreq"}, cbi("kcpufreq"), _("CPU Freq"), 80).dependent=false
end
