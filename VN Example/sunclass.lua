
--------------------------------------------------------------------------------
-- The MIT License (MIT)

-- Copyright (c) 2014 Henry Quoc Tran

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

--------------------------------------------------------------------------------

_R = _R or {}

local function class(name, ...)

    -- if this class already exists, just load it up.
    if _R[name] then
        return _R[name]
    end

    local class = {}

    -- class index access
    class.__index = function(s, k)
        -- create a fake object for accessing superclass methods
        if (k) == "super" then
            return setmetatable({},
            {
            __index =
                function(fake, k)
                    local sp_array = class.__super
                    for _, _sp in pairs(sp_array) do
                        local sp = _sp
                        while (sp[k] == nil and sp.__super) do
                            sp = sp.__super
                        end
                        if type(sp[k]) == "function" then
                            return function(fake, ...)
                                local olindex = class.__index
                                class.__index = sp.__index
                                local ret = {sp[k](s, ...)}
                                class.__index = olindex
                                return unpack(ret)
                            end
                        end
                    end
                end;
            __tostring =
                function()
                    return "class Super of " .. class.__classname
                end
            })
        end

        -- loop through super classes / mixins to find what we're looking for
        if class[k] == nil then
            local sp_array = class.__super
            for _, sp in pairs(sp_array) do
                local ret = sp.__index(s, k)
                if ret ~= nil then
                    return ret
                end
            end
        end

        -- return normally
        return class[k]
    end
    -- end class index access

    class.new = function(s, ...) local n = {} local o = setmetatable(n, s) if o.initialize then o:initialize(...) end return o end
    class.__tostring = function() return "class " .. class.__classname end
    class.__classname = name
    class.__super = {...}

    class.instanceOf = function( self, c )
        local mt = getmetatable(self)
        if mt == c then return true else
            -- using a queue, go through each of the supers
            -- try to match up a super with the given class c
            local supers = {}
            for k, v in pairs(mt.__super) do
                table.insert(supers, v)
            end
            while (#supers > 0) do
                for i = 1, #supers do
                    local mt = supers[1]
                    if c == mt then return true end
                    for k, v in pairs(mt.__super) do
                        table.insert(supers, v)
                    end
                    table.remove(supers, 1)
                end
            end
        end

        return false 
    end

    _R[name] = class

    return class

end

return class