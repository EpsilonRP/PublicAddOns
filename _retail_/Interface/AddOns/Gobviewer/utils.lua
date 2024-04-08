--Thanks to Prosper for this simple code, i added a few basic functions

local _, utils = ...


utils.deepcopy = function (orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[utils.deepcopy(orig_key)] = utils.deepcopy(orig_value)
        end
        setmetatable(copy, utils.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

--from https://github.com/Mount-West-Music/MWM-ReaScripts_for_free/blob/main/MWM-Table_serializer.lua
local function exportstring( s )
    s = string.format( "%q",s )
    s = string.gsub( s,"\\\n","\\n" )
    s = string.gsub( s,"\r","\\r" )
    s = string.gsub( s,string.char(26),"\"..string.char(26)..\"" )
    return s
end

--// Serialize
utils.serialize = function (tbl) 
    local charS, charE = "   ","\n"
    local file, err
    -- create a pseudo file that writes to a string and return the string
    file =  { write = function( self, newstr ) self.str = self.str..newstr end, str = "" }
    charS,charE = "",""
    -- initiate variables for save procedure
    local tables, lookup = { tbl },{ [tbl] = 1 }
    file:write( "{"..charE )
    for idx, t in ipairs( tables ) do
        file:write( "{"..charE )
        local thandled = {}
        for i, v in ipairs( t ) do
            thandled[i] = true
            -- escape functions and userdata
            if type( v ) ~= "userdata" then
                -- only handle value
                if type( v ) == "table" then
                if not lookup[v] then
                    table.insert( tables, v )
                    lookup[v] = #tables
                end
                    file:write( charS.."{"..lookup[v].."},"..charE )
                elseif type( v ) == "function" then
                    file:write( charS.."load("..exportstring(string.dump( v )).."),"..charE )
                else
                    local value =  ( type( v ) == "string" and exportstring( v ) ) or tostring( v )
                    file:write(  charS..value..","..charE )
                end
            end
        end
        for i, v in pairs( t ) do
            -- escape functions and userdata
            if (not thandled[i]) and type( v ) ~= "userdata" then
                -- handle index
                if type( i ) == "table" then
                    if not lookup[i] then
                        table.insert( tables,i )
                        lookup[i] = #tables
                    end
                    file:write( charS.."[{"..lookup[i].."}]=" )
                elseif type( i ) == "function" then
                    file:write( "load("..exportstring(string.dump( i )).."),"..charE )
                else
                    local index = ( type( i ) == "string" and "["..exportstring( i ).."]" ) or string.format( "[%d]", i )
                    file:write( charS..index.."=" )
                end
                -- handle value
                if type( v ) == "table" then
                    if not lookup[v] then
                        table.insert( tables,v )
                        lookup[v] = #tables
                    end
                    file:write( "{"..lookup[v].."},"..charE )
                elseif type( v ) == "function" then
                    file:write( "load("..exportstring(string.dump( v )).."),"..charE )
                else
                    local value =  ( type( v ) == "string" and exportstring( v ) ) or tostring( v )
                    file:write( value..","..charE )
                end
            end
        end
        file:write( "},"..charE )
    end
    file:write( "}" )
    return file.str
end

--// Deserialize
utils.deserialize = function ( sTable )
    local tables, err
    tables, err = assert(loadstring("return " .. sTable)) --had to modify this because WoW using older version of Lua
    if err then return err end
    tables = tables()
    for idx = 1,#tables do
        local tolinkv,tolinki = {},{}
        for i,v in pairs( tables[idx] ) do
            if type( v ) == "table" and tables[v[1]] then
                table.insert( tolinkv,{ i,tables[v[1]] } )
            end
            if type( i ) == "table" and tables[i[1]] then
                table.insert( tolinki,{ i,tables[i[1]] } )
            end
        end
        -- link values, first due to possible changes of indices
        for _,v in ipairs( tolinkv ) do
            tables[idx][v[1]] = v[2]
        end
        -- link indices
        for _,v in ipairs( tolinki ) do
            tables[idx][v[2]],tables[idx][v[1]] =  tables[idx][v[1]],nil
        end
    end
    return tables[1]
end

-- MWM