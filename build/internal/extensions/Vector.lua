-- Vector

--[[

    function X:__add(other)  return  self + other    end
    function X:__mul(other)  return  self * other    end
    function X:__sub(other)  return  self - other    end
    function X:__div(other)  return  self / other    end
    function X:__unm(other)  return  self - other    end
    function X:__pow(other)  return  self ^ other    end
    function X:__concat()    return  tostring(self)  end

--]]

-- Localize most used math functions
local min,max,random,ceil,floor,abs,cos,sin,sqrt = math.min, math.max, math.random, math.ceil, math.floor, math.abs, math.cos, math.sin, math.sqrt

--[[
local useMetatable = false

if    not Vector
then
    Vector = {}
    useMetatable = true
    function Vector:new(...) arg = {...} ; return setmetatable({x=arg[1] or 0,y=arg[2] or 0,z=arg[3] or 0},getmetatable(Vector)); end; -- create a new table and give it the metatable of Vector3
    function Vector:__type() return "Vector"; end;
    if    not otype and type(Vector:new()) ~= "Vector"
    then  otype = type ;  function type(inp) if self then inp = self ; end ; local inpType = otype(inp) ; if inpType == "table" and inp.x and inp.y then return "Vector" ; else return inpType ; end ; end
    end
end
--]]

function Vector:__type() return "Vector"; end;

function Vector:__add(other)
	if      type(other) == "Vector"
  then    return Vector( self.x + other.x, self.y + other.y, self.z + other.z )
  elseif  type(other) == "number"
  then    return Vector( self.x + other,   self.y + other,   self.z + other   )
  end
  return  self
end

function Vector:__sub(other)
  if      type(other) == "Vector"
  then    return Vector( self.x - other.x, self.y - other.y, self.z - other.z )
  elseif  type(other) == "number"
  then    return Vector( self.x - other,   self.y - other,   self.z - other   )
  end
end


function Vector:__eq(other)
	return self.x == other.x and self.y == other.y and self.z == other.z
end


function Vector:__mul(other)
  if      type(other) == "Vector"
  then    return Vector( self.x * other.x, self.y * other.y, self.z * other.z )
  elseif  type(other) == "number"
  then    return Vector( self.x * other,   self.y * other,   self.z * other   )
  end
end

function Vector:__div(other)
  if      type(other) == "Vector"
  then
          if other.x == 0 then other = Vector( 0.000001,  other.y, other.z  ) end
          if other.y == 0 then other = Vector(  other.x, 0.000001, other.z  ) end
          if other.z == 0 then other = Vector(  other.x,  other.y, 0.000001 ) end
          return Vector( self.x / other.x, self.y / other.y, self.z / other.z )
  elseif  type(other) == "number"
  then
          if other == 0 then other = 0.000001 ; end
          return Vector( self.x / other,   self.y / other,   self.z / other   )
  end
end

function Vector:__tostring(v)
  if self and not v then v = self ; end
  if v then return string.format("Vector(%.6f,%.6f,%.6f)",v.x,v.y,v.z) ; end
end

function Vector:Unpack()
  mx = mx or 1.0
  my = my or 1.0
  mz = mz or 1.0
  return self.x*mx, self.y*my, self.z*mz
end

function Vector:unpack(multx,multy,multz)
  mx = mx or 1.0
  my = my or 1.0
  mz = mz or 1.0
  return self.x*mx, self.y*my, self.z*mz
end

function Vector:distance(other)
  if not other then return 0 ; end
  local subvec = (self - other)
  return math.sqrt(subvec.x * subvec.x + subvec.y * subvec.y + subvec.z * subvec.z)
end

function Vector:direction(other)
    if not other then return self else return Vector(math.sqrt(self.x*other.x),math.sqrt(self.y*other.y),math.sqrt(self.z*other.z)) end
end

function Vector:distance2d(other)
  if not other then return 0 ; end
  local subvec = (self - other)
  return math.sqrt(subvec.x * subvec.x + subvec.y * subvec.y )
end

function Vector:toint(x,y,z,m,sx,sy,sz)
  if      x and y and z     then  if not m then m = 32768 ; end
  elseif  self and self.x   then  if x then m = x ; end ; x,y,z = self.x,self.y,self.z
  elseif  self and x and y  then  if z then m = z ; end ; x,y,z = self,x,y
  else    return 0
  end
  sx,sy,sz = sx or 1, sy or 1, sz or 1
  if not m then m = 32768 ; end
  return ( (x*sx)-((x*sx)%1)+(m*0.5) ) + ( (y*sy)-((y*sy)%1)+(m*0.5) )*m + ( (z*sz)-((z*sz)%1)+(m*0.5) )*m*m
end

function Vector.fromint(int,intMax,sx,sy,sz)
    int     =  int     or 0
    intMax  =  intMax  or  32768
    sx,sy,sz = sx or 1, sy or 1, sz or 1
    return Vector( (math.floor(int%intMax)-(intMax*0.5))*sx, (math.floor(int/intMax%intMax)-(intMax*0.5))*sy, (math.floor(int/intMax/intMax%intMax)-(intMax*0.5))*sz )
end

function  Vector:isnear(other_vec,max_dist)
          if type(other_vec) ~= "Vector" then return false ; end
          max_dist = max_dist or 10
          if ( self:distance(other_vec) <= max_dist )
          then return true
          else return false
          end
end

function Vector:len()
  return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z )
end

function Vector:scale(scale)
  if not scale then scale = 1 ; end
  local len = self:len()
  if len == 0 then return Vector(0,0,0) ; end
  return Vector( scale/len*self.x,scale/len*self.y,scale/len*self.z )
end

function Vector:normalize()
  local len = self:len()
  if len == 0 then return Vector(0,0,0) else return Vector(self.x/len,self.y/len,self.z/len) ; end
end


--[[

if  useMetatable
then
    setmetatable(Vector,{

        __index    = Vector;
        __call     = function( _, ... )    return Vector:new(...); end;
        __add      = function(self,other)  return Vector:new(self.x+other.x, self.y+other.y, self.z+other.z); end;
        __sub      = function(self,other)  if type(other) == "Vector"  then  return Vector( self.x - other.x, self.y - other.y, self.z - other.z );  elseif  type(other) == "number"  then  return Vector( self.x - other,   self.y - other,   self.z - other   ); end; end;
        __eq       = function(self,other)  return self.x == other.x and self.y == other.y and self.z == other.z ; end;
        __mul      = function(self,other)  if type(other) == "Vector"  then  return Vector( self.x * other.x, self.y * other.y, self.z * other.z )  elseif  type(other) == "number"  then  return Vector( self.x * other,   self.y * other,   self.z * other   ); end; end;
        __div      = function(self,other)  if type(other) == "Vector"  then  if other.x == 0  then  other = Vector( 0.000001,  other.y, other.z  ) end; if other.y == 0 then other = Vector(  other.x, 0.000001, other.z  ) end; if other.z == 0 then other = Vector(  other.x,  other.y, 0.000001 ) end; return Vector( self.x / other.x, self.y / other.y, self.z / other.z ); elseif  type(other) == "number"  then  if other == 0 then return Vector( 0, 0, 0 ); else return Vector( self.x/other, self.y/other, self.z/other ); end; end; end;
        __tostring = function(self)        return "Vector("..self.x..','..self.y..','..self.z..")"; end;
        __type     = function(self)        return "Vector"; end;
        });
end

--]]


--[[

function Vector.__eq(a, b)
  return a.x == b.x and a.y == b.y
end

function Vector.__lt(a, b)
  return a.x < b.x or (a.x == b.x and a.y < b.y)
end

function Vector.__le(a, b)
  return a.x <= b.x and a.y <= b.y
end

function Vector.__tostring(a)
  return "(" .. a.x .. ", " .. a.y .. ")"
end

function Vector.new(x, y)
  return setmetatable({ x = x or 0, y = y or 0 }, Vector)
end

function Vector.distance(a, b)
  return (b - a):len()
end

function Vector:clone()
  return Vector.new(self.x, self.y)
end

function Vector:unpack()
  return self.x, self.y
end

function Vector:len()
  return math.sqrt(self.x * self.x + self.y * self.y)
end

function Vector:lenSq()
  return self.x * self.x + self.y * self.y
end

function Vector:normalize()
  local len = self:len()
  self.x = self.x / len
  self.y = self.y / len
  return self
end

function Vector:normalized()
  return self / self:len()
end

function Vector:rotate(phi)
  local c = math.cos(phi)
  local s = math.sin(phi)
  self.x = c * self.x - s * self.y
  self.y = s * self.x + c * self.y
  return self
end

function Vector:rotated(phi)
  return self:clone():rotate(phi)
end

function Vector:perpendicular()
  return Vector.new(-self.y, self.x)
end

function Vector:projectOn(other)
  return (self * other) * other / other:lenSq()
end

function Vector:cross(other)
  return self.x * other.y - self.y * other.x
end
--]]

