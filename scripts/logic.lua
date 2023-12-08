function isNotDoors()
	return (Tracker:ProviderCountForCode("doorsNo") + Tracker:ProviderCountForCode("doorsPanel") > 0) 
end

function isNotPanelsOnly()
	return (1 - Tracker:ProviderCountForCode("doorsPanel") > 0)
end

function isNotExpert(check)
	return (1 - Tracker:ProviderCountForCode("Expert") > 0)
end

function isNotLaserShuffle()
	return (1 - Tracker:ProviderCountForCode("shuffleLasers") > 0)
end

function isNotAutoElevators()
	return (1 - Tracker:ProviderCountForCode("autoElevators") > 0)
end

function unrandomizedDisabled()
	return (Tracker:ProviderCountForCode("Unrandomized") == 0)
end

function unrandomizedDisabledButSolvable()
	return (unrandomizedDisabled() and Tracker:ProviderCountForCode("disabledPanelsEnabled") > 0)
end

function longBoxWithoutMountainEntry()
	return (Tracker:ProviderCountForCode("boxLong") < 8)
end

function isDisabledByPostgame(id)
	return disabledDict[tonumber(id)]
end

function isNotDisabledByPostgame(id)
	return not disabledDict[tonumber(id)]
end

function extraChecksRequired()
	return (
		Tracker:ProviderCountForCode("Unrandomized") == 0 and
		Tracker:ProviderCountForCode("Expert") ~= 0 and
		Tracker:ProviderCountForCode("doorsPanel") ~= 0 and
		Tracker:ProviderCountForCode("Symbols") ~= 0 and
		Tracker:ProviderCountForCode("epsOff") ~= 0
	)
end

function laserCount(amount)
	if tonumber(amount) > 0 then
		return(Tracker:ProviderCountForCode("lasers") >= tonumber(amount))
	else
		return false
	end
end

function laserBox(box)
	if box == "short" then
		return Tracker:ProviderCountForCode("lasers")>=Tracker:ProviderCountForCode("boxShort") and Tracker:ProviderCountForCode("boxShort") > 0
	else
		return Tracker:ProviderCountForCode("lasers")>=Tracker:ProviderCountForCode("boxLong") and Tracker:ProviderCountForCode("boxLong") > 0
	end
end

function hasPanel(panel)
	if Tracker:ProviderCountForCode("doorsNo") + Tracker:ProviderCountForCode("doorsDoor") > 0 then return true
	else return Tracker:ProviderCountForCode(panel)
	end
end

function isNotPanelsOnlyOrHasPanel(panel)
	return isNotPanelsOnly() or hasPanel(panel)
end

function dots(level)
	return Tracker:FindObjectForCode("ProgressiveDots").CurrentStage >= tonumber(level)
end

function stars(level)
	return Tracker:FindObjectForCode("ProgressiveStars").CurrentStage >= tonumber(level)
end

function pp2()
	
	return (isNotExpert() or (isNotDoors() and canSolve("158198 158200 158202 158204")) or
	(
	Tracker:ProviderCountForCode("Keep Pressure Plates 1 Exit Door") == 1 and
	Tracker:ProviderCountForCode("Keep Pressure Plates 3 Exit Door") == 1 and
	(Tracker:ProviderCountForCode("Keep Shortcut to Shadows") == 1 or
	(Tracker:ProviderCountForCode("Keep Pressure Plates 4 Exit Door") == 1 and
	(Tracker:ProviderCountForCode("Keep Tower Shortcut") == 1 or
	(Tracker:ProviderCountForCode("Keep Hedge Maze 4 Exit Door") == 1 and
	(Tracker:ProviderCountForCode("Keep Hedge Maze 4 Shortcut") == 1 or
	(Tracker:ProviderCountForCode("Keep Hedge Maze 3 Exit Door") == 1 and
	(Tracker:ProviderCountForCode("Keep Hedge Maze 3 Shortcut") == 1 or
	(Tracker:ProviderCountForCode("Keep Hedge Maze 2 Exit Door") == 1 and
	(Tracker:ProviderCountForCode("Keep Hedge Maze 2 Shortcut") == 1 or
	(Tracker:ProviderCountForCode("Keep Hedge Maze 1 Exit Door") == 1))))))))))))

end

symbolCheck = {
	["Black/White Squares"] = "BWSquare",
	["Colored Squares"] = "ColoredSquares",
	["Symmetry"] = "Symmetry",
	["Colored Dots"] = "ColoredDots",
	["Sound Dots"] = "SoundDots",
	["Shapers"] = "Shapers",
	["Rotated Shapers"] = "RotatedShapers",
	["Negative Shapers"] = "NegativeShapers",
	["Eraser"] = "Eraser",
	["Triangles"] = "Triangles",
	["Arrows"] = "Arrows"
}

function hasSymbol(symbol)
	if symbol == "Dots" then
		return dots(1)
	elseif symbol == "Full Dots" then
		return dots(2)
	elseif symbol == "Stars" then
		return stars(1)
	elseif symbol == "Stars + Same Colored Symbol" then
		return stars(2)
	elseif symbolCheck[symbol] ~= nil then
		return Tracker:ProviderCountForCode(symbolCheck[symbol]) == 1
	else
		return true
	end
end

function getLogicFile()
	if Tracker:ProviderCountForCode("Expert") == 1 then
		return "WitnessLogicExpert"
	elseif Tracker:ProviderCountForCode("randomizationSigma") == 1 then
		return "WitnessLogic"
	else
		return "WitnessLogicVanilla"
	end
end

function parseIds(ids)
	dash = string.find(ids, "-")
	if not dash then
		return ids
	else
		output = ""
		for i = tonumber(string.sub(ids, 1, dash-1)), tonumber(string.sub(ids, dash+1, -1)), 1 do
			output = output .. i .. " "
		end
		return string.sub(output, 1, -2)
	end
end

require(getLogicFile())
function canSolve(ids)
	if Tracker:ProviderCountForCode("Symbols") == 0 or isClearing() then
		return true
	end
	ids = parseIds(ids)
	for id in ids:gmatch("%S+") do
		requiredSymbols = panel[tonumber(id)]
		for k, v in pairs(requiredSymbols) do
			if(not hasSymbol(v)) then
				return false
			end
		end
	end
	return true
end
