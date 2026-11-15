-- Lava Leap: tiny shared formatting helpers (server + client).

local Format = {}

-- 90 -> "01:30", 7 -> "00:07". Never errors on nil or negative input.
function Format.clock(seconds)
	if type(seconds) ~= "number" or seconds ~= seconds then
		return "00:00"
	end
	if seconds < 0 then
		seconds = 0
	end
	local total = math.floor(seconds + 0.5)
	local minutes = math.floor(total / 60)
	local secs = total - minutes * 60
	return string.format("%02d:%02d", minutes, secs)
end

-- 1234 -> "1,234" for the stats line.
function Format.withCommas(n)
	local s = tostring(math.floor(n or 0))
	local out = ""
	while #s > 3 do
		out = "," .. string.sub(s, -3) .. out
		s = string.sub(s, 1, -4)
	end
	return s .. out
end

-- Best time: nil (never finished) -> "--:--".
function Format.bestTime(seconds)
	if type(seconds) ~= "number" or seconds <= 0 then
		return "--:--"
	end
	return Format.clock(seconds)
end

return Format
