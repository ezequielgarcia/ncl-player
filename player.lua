
require 'lxp'

local regions = {}
local medias = {}

local function callbacks()
	local state = {}
	state.nodes = {}
	state.level = 0 

	local function open(name)
		state.level = state.level + 1
		state.nodes[state.level] = name
	end

	local function close(name)
		if state.nodes[state.level] ~= name then
			error('Evil ncl: try to close not current node ' .. name)
		end
		state.level = state.level - 1
	end

	local startElem = function (parser, name, attr)
		open(name)

		if name == 'region' then
			table.insert(regions, attr)
		elseif name == 'media' then
			table.insert(medias, attr)
		end
	end

	local endElem = function(parser, name)
		close(name)
	end

	return {StartElement=startElem, EndElement=endElem}
end

p = lxp.new(callbacks())

-- Parses file from stdin
for l in io.lines() do
	p:parse(l)
	p:parse("\n")
end

print('Medias found:')
for k,v in pairs(medias) do
	print(v.id)
end
print('Regions found:')
for k,v in pairs(regions) do
	print(v.id)
end

p:parse()
p:close()
