
require 'lxp'

-- _t defines the nodes we want to record fully
local _t = {region={}, descriptor={}, media={}, port={}}

-- doc defines the known structure of
-- a ncl document
local _doc = {
	ncl = { 
		head = { 
			regionBase = { 
				region = {} 
			},
			descriptorBase = { 
				descriptor = {} 
			}
		},
		body = {
			port = {},
			media = {
				area = {},
				property = {}
			}
		}
	}
}

local function callbacks()
	local current = _doc
	local stack = {}

	local function open(name)
		if not current[name] then
			print('[W] unknown tag',name)
			current[name] = {}
		end
		current = current[name]
		table.insert(stack, name)
	end

	local function close(name)

		if stack[#stack] == name then
			table.remove(stack, #stack)
			if #stack > 0 then
				-- Redo current, TODO: Is there a better way?
				current = _doc
				for i=1,#stack do
					current = current[stack[i]]
				end
			end
		else
			error('[E] Evil ncl: trying to close not opened tag', name)
		end
	end

	local startElem = function (parser, name, attr)
		open(name)
		if _t[name] then _t[name][attr.id] = attr end
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
p:parse()
p:close()

print('--- regions:')
for k,v in pairs(_t.region) do
	print(k)
end

print('--- medias:')
for k,v in pairs(_t.media) do
	print(k)
end
