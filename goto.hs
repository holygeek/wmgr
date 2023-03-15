#! /opt/local/bin/hs
-- vim:ft=lua
if #_cli.args <= 1 then
	print("usage: save.pos <appName>")
	do return end
end
local title = _cli.args[2]

local w = hs.window.find('^' .. title .. '$')
if not w then
	w = hs.window.find(title)
end
if w then
	w:focus()
end
