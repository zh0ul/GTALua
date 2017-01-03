function  help()

  print('\
      List of functions: \
      \
      concat2files                   ( f1, f2, sep, justify, trimEdgeWhiteSpace, trimAllWhiteSpace ) \
      dumptable                      ( inp, inp_name, inp_depth ) \
      dumptable2file                 ( inp_table, inp_name, out_file, out_mode ) \
      dumptable_structure            ( t, curPath, disableDotNotation, ownCall ) \
      dumptable_structure_isIgnored  ( strQuery ) \
      dumpIgnore                     ( toIgnoreStr ) \
      echo                           (...) \
      file_create                    ( name ) \
      file_exists                    ( name ) \
      file2string                    ( source ) \
      file2table                     ( source, searchString, separators ) \
      forLineIn                      ( file, func ) \
      function2string                ( inp, inp_name ) \
      ls                             ( path ) \
      lua_do                         ( inp_string ) \
      lua_do_v2                      (...) \
      math.average                   (...) \
      pack                           (...) \
      shell                          (command) \
      string2file                    ( source, dest, mode, newline ) \
      string.split                   ( pat ) \
      string.split2                  ( separators ) \
      table.count                    ( t ) \
      table.has_key_value            ( t, k, v ) \
      table.match                    ( t1, t2, verbose ) \
      table.swap                     ( t, k1, k2 ) \
      testFunc                       ( count, func ) \
      timeMark.comment               ( comment ) \
      timeMark.mark                  ( comment ) \
      timeMark.print                 ( x, y) \
      timeMark.reset                 () \
      timeMark.start                 ( comment ) \
      toboolean                      (...) \
      unpackSerial                   ( t ) \
      varAsPrintable                 ( var, printFunctions )'
      )
end


--if    ( Debug ~= nil ) and ( Debug.Log ~= nil )
--then  Debug.Log(string.format("Hello from %s, using %s at %s\n","zhoUtils.lua",_VERSION,os.date()))
--else  print(string.format("Hello from %s, using %s at %s\n","zhoUtils.lua",_VERSION,os.date()))
--end

pi = math.pi

local dumptable_spaces = "                                                                      "

------------------------------------------------------------------------------------------------------------

function  shell(cmd)
    cmd = tostring(cmd) or ""
    if ( cmd == "" ) then return "",false ; end
    local handle = io.popen(cmd)
    if ( handle == nil ) then print("# shell() error while processing command: "..cmd) ; return "",false ; end
    local result = handle:read("*a")
    handle:close()
    if result then return result else return "" end
end

------------------------------------------------------------------------------------------------------------

ls_path = ""

function  ls(input,filter,justChangeDir) -- AKA  lua-ls

  --[[
        To list all keys in the root of lua (_G), try:

        ls("/")

        To drill down further, just keep adding keys.

        ls("/math")

  --]]

  input  = input   or  ""
  input  = tostring(input)
  filter = filter  or  ""

  input  = string.gsub(input,"[.][*]","*")
  input  = string.gsub(input,"[.]","/")
  input  = string.gsub(input,"[*]",".*")
  filter = string.gsub(filter,"[.][*]","*")
  filter = string.gsub(filter,"[*]",".*")

  if      filter == "" and string.find(input,"[/]")
  then    filter = string.gsub(input,".*/","") ; input = string.gsub(input,"/[^/]*$","")
  elseif  filter == ""
  then    filter = ".*"
  end

  filter = filter

  local path,pathTmp,pathAsStr = {},{},""

  local printProvider = echo or print

  if lua_fix_root_level_missing_type_functions then lua_fix_root_level_missing_type_functions() ; end

  input = string.gsub(input,"\\\\*","\\")
  input = string.gsub(input,"[/][/]*","/")
  input = string.gsub(input,"^/","")
  input = string.gsub(input,"^\\","")

--input = string.lower(input)

  if ( input == "" ) then input = "_G" ; end

  while ( #input > 0 ) do pathTmp[#pathTmp+1] = string.gsub(input,"[\\/].*","") ; if ( input == string.gsub(input,"^[^\\/][^\\/]*[\\/]","")  ) then input = "" ; else input = string.gsub(input,"^[^\\/][^\\/]*[\\/]","") ; end ; end

  local curPath = _G

  path[1] = "_G"

  if ls_debug then print("input:",input,"filter:",filter) ; end

  while ( pathTmp ~= nil ) do
        local pathFound = false
        for k,v in pairs(curPath) do
            if    not pathFound
            and   pathTmp  and  pathTmp[1]
            and   ( tostring(pathTmp[1]) == tostring(k) )
            then
                if      tonumber(pathTmp[1])  and  curPath[tonumber(pathTmp[1])]
                then    curPath = curPath[tonumber(pathTmp[1])]
                elseif  curPath[pathTmp[1]]
                then    curPath = curPath[pathTmp[1]]
                end
                table.insert(path,pathTmp[1])
                if      ( tostring(pathTmp[1]) == "_G" )
                then    pathAsStr = "/"
                else    pathAsStr = pathAsStr.."/"..tostring(pathTmp[1])
                end
                pathFound = true
            end
        end
        table.remove(pathTmp,1)
        if ( #pathTmp == 0 ) then pathTmp = nil ; end
  end

  if curPath[filter] then curPath = curPath[filter] ; pathAsStr = pathAsStr.."/"..filter ; table.insert(path,filter) ; filter = ".*" ; else filter = "^"..filter ; end

  pathAsStr = string.gsub(pathAsStr,"^[/][/]*","")
  pathAsStr = "/"..pathAsStr
  pathAsStr = string.gsub(pathAsStr,"[/][/]*$","")

  ls_path = pathAsStr

  if  justChangeDir then  printProvider(pathAsStr) ; return true ; end

  local pathKeysNum,pathKeysStr,pathKeysMaxLen = {},{},0
  local tabKeyTypes,tabKeyTypesCount        = {},0
  local varTypesMaxLen                      = 10

  for k,v in pairs(curPath) do
      if    ( type(k) == "number" )
      then  pathKeysNum[#pathKeysNum+1] = k
      else  pathKeysStr[#pathKeysStr+1] = tostring(k)
      end
      if ( string.len(pathAsStr..tostring(k)) > pathKeysMaxLen ) then pathKeysMaxLen = string.len(pathAsStr..tostring(k)) ; end
  end

  pathKeysMaxLen = tostring(pathKeysMaxLen+1)

  table.sort(pathKeysNum)
  table.sort(pathKeysStr)

  local ret = {}

  for k,v in pairs(pathKeysNum) do
      local curType = type(curPath[v])
      if ( curType == "nil" ) then curType = "Unknown" ; end
      local lineData = pathAsStr.."/"..tostring(v).." "..curType.." = "..tostring(curPath[v])
      if  filter == ".*"
      or  ( string.find(v,filter)  )
      or  ( string.find(curType,filter)  )
      then
          ret[#ret+1] = string.format( "%-"..pathKeysMaxLen.."s %-"..varTypesMaxLen.."s = %s", pathAsStr.."/"..tostring(v), curType,  tostring(curPath[v]) ) 
          printProvider( ret[#ret] )
      end
  end

  for k,v in pairs(pathKeysStr) do
      local curType = type(curPath[v])
      if ( curType == "nil" ) then curType = "Unknown" ; end
      local lineData = pathAsStr.."/"..tostring(v).." "..curType.." = "..tostring(curPath[v])
      if  filter == ".*"
      or  ( string.find(v,filter)  )
      or  ( string.find(curType,filter)  )
      then
          ret[#ret+1] = string.format( "%-"..pathKeysMaxLen.."s %-"..varTypesMaxLen.."s = %s", pathAsStr.."/"..tostring(v), curType,  tostring(curPath[v]) ) 
          printProvider( ret[#ret] )
      end
  end

  return ret

end

------------------------------------------------------------------------------------------------------------

function  cd(path)

    ls(path,nil,true)

end

------------------------------------------------------------------------------------------------------------

function  GetTestTable()
    local aTestTable = {}
    for i = 1,20 do local tabName = "aSubTable_"..tostring(i) ; aTestTable[tabName] = {}
    for j = 1,5  do local tabSubName = tabName.."_"..tostring(j) ; aTestTable[tabName][tabSubName] = {}
    for k = 1,5  do aTestTable[tabName][tabSubName][k] = math.random(10000000,99999999) ; aTestTable[tabName][tabSubName]["string_"..tostring(k)] = "string_"..tostring(k)
    end
    end
    end
    return aTestTable
end

------------------------------------------------------------------------------------------------------------

function  pack(...)
  -- unpack already exists as a command
  -- packing is simply putting multiple arguments into a table.
  -- So , heres pack()
  return {...}
end

------------------------------------------------------------------------------------------------------------

function  math.average(...)
    local args = ({...})
    if ( args[1] == nil ) then return 0 ; end
    local tot,cnt = 0,0
    if    ( #args == 1 ) and ( type(args[1]) == "table" )
    then
          if  ( #args[1] ~= 0 )
          then
              for k,v in ipairs(args[1]) do
                  cnt = cnt + 1
                  if    ( type(v) == "table" )
                  then  tot = tot + math.average(v)
                  else  tot = tot + tonumber(v or 1) or 1
                  end
              end
          else
              for k,v in pairs(args[1]) do
                  cnt = cnt + 1
                  if    ( type(v) == "table" )
                  then  tot = tot + math.average(v)
                  else  tot = tot + tonumber(v or 1) or 1
                  end
              end
          end
    else
          for k,v in pairs(args) do
              cnt = cnt + 1
              if    ( type(v) == "table" )
              then  tot = tot + math.average(v)
              else  tot = tot + tonumber(v or 1) or 1
              end
          end
    end
    if cnt == 0 then cnt = 1 ; end
    return tot / cnt, tot, cnt
end

------------------------------------------------------------------------------------------------------------

function  table.count(t)
    if     ( type(t) ~= "table" )  then print("ERROR : table.count : input is not a table") ; return 0    ;end
    local  tabCount = 0
    for    k,v in pairs(t)
    do     tabCount = tabCount + 1
    end
    return tabCount
end

------------------------------------------------------------------------------------------------------------

function table.value_size(v)
    local value_size_table = {
      -- lua base types: nil, boolean, number, string, function, userdata, thread, and table
      ["number"]    = function()  return 8                    ; end,
      ["string"]    = function(v) return math.floor( ( #v+3 ) / 4 ) * 4 ; end,
      ["boolean"]   = function(v) return 8                    ; end,
      ["function"]  = function(v) return #string.dump(v) or 0 ; end,
      ["Vector"]    = function(v) return 48                   ; end,
      ["nil"]       = function(v) return 8                    ; end,
    }
    local curType = type(v) or "userdata"

    if value_size_table[curType] then return value_size_table[curType](v) ; else return 0 ; end
end

------------------------------------------------------------------------------------------------------------

function table.size(t,sb,ec)

    sb,ec = sb or 0, ec or 0

    if type(t) ~= "table" then return table.value_size(t),1 ; end
    local element_count = 0
    local size_in_bytes = 0
    if    type(t) == "table"
    then
          for k,v in pairs(t) do
              element_count = element_count + 1
              if    type(k) == "number"
              then  size_in_bytes = size_in_bytes + 8
              else  size_in_bytes = size_in_bytes + #k + (#k%4)
              end
              if    type(v) == "table"
              then  size_in_bytes,element_count = table.size(v,size_in_bytes,element_count)
              else  size_in_bytes = size_in_bytes + table.value_size(v)
              end
          end
    else
          size_in_bytes = table.value_size(t)
          element_count = 1
    end
    return size_in_bytes+sb, element_count+ec

end

------------------------------------------------------------------------------------------------------------

function table.sort_insert(t,v)

    local ttype,vtype = type(t),type(v)

    if    ttype ~= "table"
    or    vtype == "nil"
    or    vtype == "boolean"
    then  return
    end

    local insertIndex = 1
    local vStr        = tostring(v)

    for k,ov in ipairs(t) do
        if      vtype == type(ov) and v > ov
        or      vStr > tostring(ov)
        then    insertIndex = k+1
        else    break
        end
    end

    table.insert(t,insertIndex,v)

end

------------------------------------------------------------------------------------------------------------

function table.sort_insert_verified(t,v)

    local insertIndex = 1

    for k,ov in ipairs(t) do
        if      v > ov
        then    insertIndex = k+1
        else    break
        end
    end

    table.insert(t,insertIndex,v)

end

------------------------------------------------------------------------------------------------------------

-- function  table.swap( t, k1, k2 )
--     if ( type(t) ~= "table" ) then print("table.swap : ERROR : type(t) ~= \"table\"") ; return false ; end
--     local k1s = tostring( k1 ) or ""
--     local k2s = tostring( k2 ) or ""
--     k1  = tonumber(k1)
--     k2  = tonumber(k2)
--     local k1r = ""
--     local k2r = ""
--     if ( k1 == nil ) then k1r = k1s ; else k1r = k1 ; end
--     if ( k2 == nil ) then k2r = k2s ; else k2r = k2 ; end
--     if ( t[k1r] == nil ) then print("table:swap : ERROR : t[k1r] == nil") ; return false ; end
--     if ( t[k2r] == nil ) then print("table:swap : ERROR : t[k2r] == nil") ; return false ; end
--     local tmpElement = t[k1r]
--     t[k1r] = t[k2r]
--     t[k2r] = tmpElement
--     return true
-- end


function  table.swap( t, k1, k2 )
    if ( type(t) ~= "table" ) then print("table.swap : ERROR : type(t) ~= \"table\"") ; return false ; end
    t[k1],t[k2] = t[k2],t[k1]
    return true
end

------------------------------------------------------------------------------------------------------------

function  table.match(t1,t2,verbose)

  --]] Returns false if one/both tables are not tables (nil, etc)
  --]] Returns false if count of elements between tables does not match
  --]] Returns false if value in table 1 , not found in table 2
  --]] Returns true  if the two tables match (even if both tables have 0 values)
  --]] If you call this function with a 3rd argument ( true ) , it will print the reason for its return.

  if ( type(t1) ~= "table" ) or ( type(t2) ~= "table" ) then if ( verbose ) then print( "table.match : false : Because t1 and/or t2 are not tables." ) ; end ; return false ; end

  if ( t1 == t2 ) then  if  verbose  then print( "table.match : true  : Because t1 and t2 point to the same memory address." ) ; end ; return true ; end

  local tKeys   = { [1] = {}, [2] = {}, }

  for k,v in pairs(t1) do
    if      not t2[k]              then  if verbose then print("table.match : false : Because t2["..tostring(k).."] does not exist")    ; end ; return false
    elseif  type(v) ~= type(t2[k]) then  if verbose then print("table.match : false : Because "..type(v).." ~= "..type(t2[k]) )         ; end ; return false
    elseif        v ~= t2[k]       then  if verbose then print("table.match : false : Because "..tostring(v).." ~= "..tostring(t2[k]) ) ; end ; return false
    end
  end

  if verbose then print("table.match : true  : Because all entries appear to match.") ; end

  return true

end

------------------------------------------------------------------------------------------------------------

function  table.has_key_value(t,k,v,ignoreCase,looseMatch,valueIfNo)

    local retKey,retVal,retBoth = false,false,false

    if   type(k) ~= "string" and type(k) ~= "number"    then k = nil ; else retKey = true ; end
    if   type(v) == "table"  or  type(v) == "userdata"  then v = nil ; else retVal = true ; end

    if retKey and retVal then retBoth = true ; end

    if   ( type(t) ~= "table" )    then print("ERROR : table.contains_key_value : input is not a table") ; return valueIfNo  ; end

    if     ignoreCase
    then
        for    k2,v2 in pairs(t)
        do
              if    (  ( k == nil ) or ( type(k2) == type(k) ) and (  k2 == k  or  tostring(k2):upper() == tostring(k):upper() ) )
              and   (  ( type(v2) == type(v) )                 and (  v2 == v  or  tostring(v2):upper() == tostring(v):upper() ) )
              then  if retBoth then return k2,v2 elseif retKey then return k2 elseif retVal then return v2 ; end
              end
        end

    else
        for    k2,v2 in pairs(t)
        do
              if    (  not k  or  ( ( type(k2) == type(k) ) and (  k2 == k  ) ) )
              and   (  ( type(v2) == type(v) ) and (  v2 == v  )  )
              then  if retBoth then return k2,v2 elseif retKey then return k2 elseif retVal then return v2 ; end
              end
        end
    end

    if    looseMatch and ignoreCase
    then
          local ktmp = string.gsub(tostring(k):lower(),"[^a-zA-Z0-9_.-]","")
          local vtmp = string.gsub(tostring(v):lower(),"[^a-zA-Z0-9_.-]","")

        for    k2,v2 in pairs(t)
        do
              local k2tmp = string.gsub(tostring(k2):lower(),"[^a-zA-Z0-9_.-]","")
              local v2tmp = string.gsub(tostring(v2):lower(),"[^a-zA-Z0-9_.-]","")
              if    ( k == nil ) or ( type(k2) == type(k)  and  string.find(k2tmp,ktmp) )
              and   ( v == nil ) or ( type(v2) == type(v)  and  string.find(v2tmp,vtmp) )
              then  if retBoth then return k2,v2 elseif retKey then return k2 elseif retVal then return v2 ; end
              end
        end

    elseif looseMatch
    then
          local ktmp = string.gsub(tostring(k),"[^a-zA-Z0-9_.-]","")
          local vtmp = string.gsub(tostring(v),"[^a-zA-Z0-9_.-]","")

        for    k2,v2 in pairs(t)
        do
              local k2tmp = string.gsub(tostring(k2),"[^a-zA-Z0-9_.-]","")
              local v2tmp = string.gsub(tostring(v2),"[^a-zA-Z0-9_.-]","")
              if    ( k == nil ) or ( type(k2) == type(k)  and  string.find(k2tmp,ktmp) )
              and   ( v == nil ) or ( type(v2) == type(v)  and  string.find(v2tmp,vtmp) )
              then  if retBoth then return k2,v2 elseif retKey then return k2 elseif retVal then return v2 ; end
              end
        end
    end

    return valueIfNo

end

------------------------------------------------------------------------------------------------------------

function table.maxWidth(inTab,selfCall)

   if type(inTab) ~= "table" then return ( #tostring(inTab) or 0 ) or 0 ; end

   local colMaxWidth = {}

   for k,v in pairs(inTab) do
       if    type(v) == "table"
       then  for k2,v2 in pairs(table.maxWidth(v,true)) do local k2Len,cLen = #tostring(k),v2 ; if k2Len > v2 then cLen = k2Len ; end ; if not colMaxWidth[k2] or colMaxWidth[k2] < cLen then colMaxWidth[k2] = cLen ; end ; end
       else  colMaxWidth[k] = math.max( (tonumber(colMaxWidth[k] or 0) or 0), #tostring(k), table.maxWidth(v,true) )
       end
   end

   if  not selfCall
   then
       local maxWidthAll,maxSpacesAll = 0,""
       for k,v in pairs(colMaxWidth) do if maxWidthAll < v then maxWidthAll = v ; end ; end
       for i = 1,maxWidthAll do  maxSpacesAll = maxSpacesAll.." " ; end
       return colMaxWidth, maxWidthAll, maxSpacesAll
   else
       return colMaxWidth
   end

end

------------------------------------------------------------------------------------------------------------

function echoTable(inTab,separator)

  local printProvider = echo or print

  separator = separator or "  "

  if type(inTab) ~= "table" then printProvider(tostring(inTab)) ; return ; end

  local colMaxWidth,allMaxWidth,allMaxSpaces = table.maxWidth(inTab)

  for kt,t in pairs(inTab) do
      local line = ""
      if  type(t) ~= "table"
      then
          printProvider(tostring(t))
      else
          for k,v in pairs(t) do
              if ( type(v) ~= "table" )
              then
                  local vStr,vSeparator = tostring(v),separator
                  if k == 1 then vSeparator = "" ; end
                  line = line..vSeparator..vStr..allMaxSpaces:sub(1,colMaxWidth[k]-#vStr)
              end
          end
          printProvider (line)
      end
  end

end

------------------------------------------------------------------------------------------------------------

function wc(t,key,includeNumeric,includeAll)

    local tType, str_bytes, str_words, str_lines, str_max_len  = type(t), 0, 0,0,0

    if      ( tType == "table" )
    then
            for k,v in pairs(t) do

                local cur_bytes,cur_words = 0,0

                if      not key
                or      (  type(key) == type(k)  and  key == k  )
                then
                        local   vType =  type(v)

                        if      vType == "string"
                        then
                                str_lines = str_lines + 1
                                _,cur_words = string.gsub(v,"[,. ][,. ]*")
                                cur_bytes = #v
                                if  #v > str_max_len  then  str_max_len = #v  end

                        elseif  (  ( includeAll and vType ~= "table" )  or  ( includeNumeric and vType == "number" )  )
                        then
                                str_lines = str_lines + 1
                                _,cur_words = string.gsub(tostring(v),"[,. ][,. ]*")
                                cur_bytes = #tostring(v)
                                if  #tostring(v) > str_max_len  then  str_max_len = #tostring(v)  end

                        elseif  vType == "table"
                        then    local ret_line_width = table.str_max_len(v,includeNumeric,includeAll) ; if ret_line_width > str_max_len then str_max_len = ret_line_width ; end
                        end
                        str_bytes = str_bytes + cur_bytes
                        str_words = str_words + cur_words
                end
            end

    elseif  includeAll or tType == "string" or ( includeNumeric and tType == "number" ) then return #tostring(t) or 0
    else    return 0
    end

    return str_bytes, str_words, str_lines, str_max_len

end

------------------------------------------------------------------------------------------------------------

function  randomChar(low,high)
  return string.char(math.random(tonumber(low or 0),tonumber(high or 255)))
end

------------------------------------------------------------------------------------------------------------

function concat2files(f1,f2,sep,justify,trimEdgeWhiteSpace,trimAllWhiteSpace)

  if type(f1) ~= "string" or type(f2) ~= "string" then return "" ; end

  local fd1 = io.open( f1, "r" ) ;  if ( fd1 == nil ) then print("File not found: "..f1); return ""; end
  local fd2 = io.open( f2, "r" ) ;  if ( fd2 == nil ) then print("File not found: "..f2); return ""; end

  if not sep then sep = " " ; else sep = tostring(sep) ; end

  local retValue    = ""
  local retTab      = {}
  local lcount      = 0
  local lremain     = true
  local line        = ""
  local lside,lmax  = "",0
  local rside,rmax  = "",0
  local lit,rit     = "",""

  if  justify
  then
      for lside in fd1:lines() do
          lside = string.gsub(lside,"[\r]","")
          if    trimEdgeWhiteSpace or trimAllWhiteSpace
          then  lside = string.gsub(lside,"^[\x09\x20][\x09\x20]*","") ; lside = string.gsub(lside,"[\x09\x20][\x09\x20]*$","")
          end
          if    trimAllWhiteSpace
          then  lside = string.gsub(lside,"[\x09\x20][\x09\x20]*"," ")
          end
          if lmax < #lside then lmax = #lside ; end
      end
      fd1:seek("set",0)
  end


  lit = fd1:lines()
  rit = fd2:lines()


  while lremain do

      lside = lit()
      rside = rit()

      if not lside and not rside then lremain = false ; else lcount = lcount + 1                  ; end
      if not lside               then lside = ""      ; else lside = string.gsub(lside,"[\r]","") ; end
      if not rside               then rside = ""      ; else rside = string.gsub(rside,"[\r]","") ; end

      if    trimEdgeWhiteSpace or trimAllWhiteSpace
      then
            lside = string.gsub(lside,"^[\x09\x20][\x09\x20]*","") ; lside = string.gsub(lside,"[\x09\x20][\x09\x20]*$","")
            rside = string.gsub(rside,"^[\x09\x20][\x09\x20]*","") ; rside = string.gsub(rside,"[\x09\x20][\x09\x20]*$","")
      end

      if    trimAllWhiteSpace
      then
            lside = string.gsub(lside,"[\x09\x20][\x09\x20]*"," ")
            rside = string.gsub(rside,"[\x09\x20][\x09\x20]*"," ")
      end

      if  justify then while #lside < lmax do lside = lside.." " ; end ; end

      if lremain  then  print( lside .. sep .. rside )  ; end

  end
  fd1:close() ; fd2:close()
  return retValue

end

------------------------------------------------------------------------------------------------------------

function  file_exists(name)
  if not name then return false ; end
  local f = io.open(name,"r")
  if    f ~= nil  then  io.close(f)  ;  return true  ;  else  return false  ;  end
end

------------------------------------------------------------------------------------------------------------

function  file_create(name)
  local f = io.open(name,"w")
  if    f ~= nil  then  io.close(f) ;  return true  ;  else  return false  ;  end
end

------------------------------------------------------------------------------------------------------------

function  forLineIn(file,func,suppressBlankLines,trimEdgeWhiteSpace,trimAllWhiteSpace)
  if type(file) ~= "string" or type(func) ~= "function" then return 0,0 ; end
  local fd = io.open( file, "r" )
  if ( fd == nil ) then return 0,0 ; end
  local lcount,lexec = 0,0
  for line in fd:lines() do
      lcount = lcount + 1
      if    trimEdgeWhiteSpace or trimAllWhiteSpace
      then  line = string.gsub(line,"^[\x09\x20][\x09\x20]*","") ; line = string.gsub(line,"[\x09\x20][\x09\x20]*$","")
      end
      if    trimAllWhiteSpace
      then  line = string.gsub(line,"[\x09\x20][\x09\x20]*"," ")
      end
      if    not suppressBlankLines or #line > 0
      then
            lexec = lexec + 1
            func(line)
      end
  end
  fd:close()
  return lcount,lexec
end

------------------------------------------------------------------------------------------------------------

-- file2string
function  file2string(source)
  local file2string_ret = ""
  source = tostring(source) or ""
  if ( source == "" ) then return "" ; end
  local infile = io.open( source , "r" )
  if ( infile == nil ) then return file2string_ret ; end
  file2string_ret = infile:read("*a")
  infile:close()
  return file2string_ret
end

------------------------------------------------------------------------------------------------------------

function file2table(source,delim,noWhiteSpaceHandling,noQuoteHandling)
    local aTab = {}
    local i = 0
    local fileAsStr = file2string(source)
    delim = delim or "[,=][,=]*"
    commentStr = "[-][-][^\n][^\n]*[\n]*"
    fileAsStr = string.gsub( fileAsStr, commentStr, "" )
    fileAsStr = string.gsub( fileAsStr, "[\n][\n]*", "\n" )
    for line in string.split(fileAsStr,"\n") do
        if #line > 0 then
            i = i + 1
            for word in string.split(line,delim) do
                if word ~= "" then
                    if  not aTab[i] then aTab[i] = {} ; end
                    if  not noWhiteSpaceHandling
                    then
                        word = string.gsub(word,"^[\n ][\n ]*","")
                        word = string.gsub(word,"[\n ][\n ]*$","")
                    end
                    if  not noQuoteHandling
                    then
                        if    ( word:sub(1,1) == "\"" and word:sub(-1) == "\"" )
                        or    ( word:sub(1,1) == "'"  and word:sub(-1) == "'"  )
                        then  word = word:sub(2,-2) ; end
                    end
                    if      tostring(tonumber(word)) == word
                    then    aTab[i][#aTab[i]+1] = tonumber(word)
                    else    aTab[i][#aTab[i]+1] = word
                    end
                end
            end
        end
    end
    return(aTab)
end

--if devingfile2table then  echo(file2table("settings.Automatic-Teleport-Coords.txt"))  ; end

------------------------------------------------------------------------------------------------------------

-- string2file
function  string2file(source,dest,mode,newline)
  if    ( type(source) ~= "string" ) then  source = tostring(source) or ""  ; end
  if    ( type(dest)   ~= "string" ) then  dest   = tostring(dest) or ""    ; end
  if    ( dest         == ""       ) then  dest   = "string2file-output.txt" ; end
  if    ( type(mode)   ~= "string" ) then  mode   = "a" ; end
  if    ( newline      ==  nil     ) then  newline = "\n"  else  newline = tostring(newline)  end
  local string2file_ret = "-1"
  local outfile = io.open( dest , mode )
  if    ( outfile == nil )           then return string2file_ret ; end
  if    ( newline ~= nil )           then source = tostring( source ) .. tostring(newline) ; end
  outfile:write(source)
  outfile:flush()
  outfile:close()
  string2file_ret = dest
  return string2file_ret
end

------------------------------------------------------------------------------------------------------------

-- function  file2table(source,searchString,separators)
--   --[[
    
--     Use like:
--       local tabFromFile = file2table("test.txt","ab",", ") ; print(dumptable(tabFromFile))

--     test.txt was:
--       123,456, 789,abc
--       123,456,789
--       abc,def,ghi

--     Output is:
--     {
--       [1]                             = {
--         [1]                         = '123' ,
--         [2]                         = '456' ,
--         [3]                         = '789' ,
--         [4]                         = 'abc' ,
--       } ,
--       [2]                             = {
--         [1]                         = '123' ,
--         [2]                         = '456' ,
--         [3]                         = '789' ,
--       } ,
--       [3]                             = {
--         [1]                         = 'abc' ,
--         [2]                         = 'def' ,
--         [3]                         = 'ghi' ,
--       } ,
--     }
--   --]]
--   local outTable = {}
--   source       = tostring( source ) or ""
--   searchString = tostring( searchString ) or ""
--   separators   = tostring( separators ) or ""
--   if ( source == "" ) then  return outTable ; end
--   local infile = io.open( source , "r" )
--   if ( infile == nil ) then print("line2table : ERROR : could not open source "..source) ; return outTable ; end
--   local k,kk = 0,0
--   local lines = string.split( infile:read("*a"), "\n" )
--   for line in lines do
--     if ( line:sub( -1,1) == "\n" ) then line=line:sub(1,#line - 1) ; end
--     if ( line:sub( -1,1) == "\r" ) then line=line:sub(1,#line - 1) ; end
--     if ( line ~= line:gsub(searchString,"X") )
--     then
--       k = #outTable+1
--       outTable[k] = {}
--       for v in string.split2(line,separators)
--       do  table.insert(outTable[k],v)
--       end
--     end
--   end
--   infile:close()
--   if    ( #outTable > 0 ) and ( #outTable[#outTable] == 1 ) and ( outTable[#outTable][1] == "" )
--   then  table.remove(outTable,#outTable)
--   end
--   return outTable
-- end

------------------------------------------------------------------------------------------------------------

function  function2string(inp,inp_name)

  --[[
      Turns a function into a saveable/loadable string.
      
      Example:

      If you wanted to turn this function into a loadable string:

      print(function2string(function2string,"function2string"))
  --]]

  --print(function2string(function2string,"function2string"))

  if      ( type(inp_name) ~= "string"  ) or ( #inp_name == 0 ) then    inp_name = "aFunction"  ; end
  if      ( type(inp) == "string"       ) then pcall(loadstring("function2string_ret = function2string("..inp..",'"..inp.."')")) ; return function2string_ret ; end
  if      ( type(inp) ~= "function"     ) then print("function2string : type(inp) ~= 'function' : "..tostring(inp) ) ; return( "-- function2string : type(inp) ~= 'function' : "..tostring(inp) ) ; end
--if      ( type(one_line) ~= "boolean" ) then one_line = false ; end

  local   inp_str  = string.dump(inp) or ""
  local   out_str  = inp_name.." = loadstring('"
  local   out_str_arr  = {}
  
  local i = 1 ; while i <= #inp_str do out_str_arr[#out_str_arr+1] = string.format( "\\x%02X", string.byte(inp_str,i) ) ; i=i+1 ; end

  out_str = out_str..table.concat(out_str_arr).."')"

  return(out_str)

end

------------------------------------------------------------------------------------------------------------

function  function2string_nohex(inp,inp_name)

  --[[
      Turns a function into a saveable/loadable string.
      
      Example:

      If you wanted to turn this function into a loadable string:

      print(function2string(function2string,"function2string"))
  --]]

  --print(function2string(function2string,"function2string"))

  if      ( type(inp_name) ~= "string"  ) or ( #inp_name == 0 ) then    inp_name = "aFunction"  ; end
  if      ( type(inp) == "string"       ) then pcall(loadstring("function2string_ret = function2string("..inp..",'"..inp.."')")) ; return function2string_ret ; end
  if      ( type(inp) ~= "function"     ) then print("function2string : type(inp) ~= 'function' : "..tostring(inp) ) ; return( "-- function2string : type(inp) ~= 'function' : "..tostring(inp) ) ; end
--if      ( type(one_line) ~= "boolean" ) then one_line = false ; end

  local   inp_str  = string.dump(inp) or ""
  --local   out_str  = inp_name.." = loadstring('"
  local out_str = "local str = ''; for k,v in pairs({"
  local   out_str_arr  = {}
  
  local i = 1 ; while i <= #inp_str do out_str_arr[#out_str_arr+1] = string.format( "0x%02X,", string.byte(inp_str,i) ) ; i=i+1 ; end

  out_str = out_str..table.concat(out_str_arr).."}) do str = str..string.char(v) ; end ; "..inp_name.." = loadstring(str)"

  return(out_str)

end

------------------------------------------------------------------------------------------------------------

function  dumptable( inp , inp_name , inp_depth )

    inp_depth = ( tonumber(inp_depth or 0) or 0 )

    inp_name = tostring(inp_name)

    if    ( inp_name == "nil" ) or ( inp_name == "" )
    then  inp_name = ""
    else  inp_name = inp_name .. " = "
    end

    if   ( type(inp) == "table" )
    then
            inp_depth = inp_depth + 4
            local s = inp_name .. '{\n'
            local tcountNum = #inp
            local tKeys     = {  ["number"] = {}, ["string"] = {}, }
            
            local tcountAll = 0 ; for k,v in pairs(inp)  do local kType = type(k) ; tcountAll = tcountAll + 1 ; if kType == "string" then tKeys["string"][#tKeys["string"]+1] = k ; elseif kType == "number" then tKeys["number"][#tKeys["number"]+1] = k ; end ; end
            table.sort(tKeys.number) ; table.sort(tKeys.string)
            if ( inp[1] ~= nil ) and ( inp[tcountNum] ~= nil ) and ( tcountNum == tcountAll )
            then
                for i = 1,#inp do
                    s = s .. string.format( "%"..tostring(inp_depth).."s%-"..tostring(35 - inp_depth).."s%s%s,\n" , "" , '['..tostring(i)..']' ,' = ' , dumptable(inp[i],nil,inp_depth) )
                end
            else
                for _,k in pairs(tKeys.number) do
                    local v = inp[k]
                    s = s .. string.format( "%"..tostring(inp_depth).."s%-"..tostring(35 - inp_depth).."s%s%s,\n" , "" , '['..tostring(k)..']' ,' = ' , dumptable(v,nil,inp_depth) )
                end

                for _,k in pairs(tKeys.string) do
                    local v = inp[k]
                    k = "'"..string.gsub( tostring( k ),"'","\\\'" ).."'"
                    s = s .. string.format( "%"..tostring(inp_depth).."s%-"..tostring(35 - inp_depth).."s%s%s,\n" , "" , '['..k..']' ,' = ' , dumptable(v,nil,inp_depth) )
                end
            end
            inp_depth = inp_depth - 4
            s = s .. string.sub(dumptable_spaces,0,inp_depth) .. '}'
            return s
    else
            if      ( type( inp ) == "function" ) or ( type(inp) == "Vector" )
            then    return varAsPrintable(inp)

            -- elseif  ( type( inp ) == "string" )
            -- then    return tostring(inp)

            elseif  ( type( inp ) ~= "number" ) and ( type ( inp ) ~= "boolean" )
            then    return "'" .. string.gsub(tostring(inp),"'","\\'" ) .. "'"

            else    return tostring(inp)
            end
    end

    return
end

------------------------------------------------------------------------------------------------------------

function  keyAsPrintable(key,outType)
  outType = tonumber(outType or 0) or 0 --   0 = ["string-keys-in-brackets-and-quotes"]    1 = .string_keys_in_dot_notation    2 = Same as 0, plus the type(key)   3 = Same as 1, plus the type(key)
  local keyType = type(key)
  local keyRet  = ""
  if      ( key == nil            ) then  keyRet = ""
  elseif  ( keyType == "number"   ) then  keyRet = "["..tostring(key).."]"
  elseif  ( keyType == "string"   ) then
      if ( outType == 0 )       then  keyRet = "[\"" .. string.gsub( key, "\"", "\\\"" ) .. "\"]", keyType
                    else  keyRet = "." .. key
      end
  end

  if ( outType >= 2 )
  then  return keyRet,keyType
  else  return keyRet
  end
end

------------------------------------------------------------------------------------------------------------

function  varAsPrintable(var,printFunctions)
    if       printFunctions then printFunctions = true ; else printFunctions = false ; end
    if      ( var == nil              ) then  return "nil", "nil"
    elseif  ( type(var) == "number"   ) then  return tostring(var) --if ( var % 1 == 0 )  then  return string.format("0x%08x",var), "number"  else  return tostring(var), "number"  end
    elseif  ( type(var) == "string"   ) then  return "\"" .. string.gsub( var, "\"", "\\\"" ) .. "\"", "string"
    elseif  ( type(var) == "function" ) then  if printFunctions then  return function2string(var,nil,true)  ;else  return "--[[ "..tostring(var).." --]]"  ;end
    elseif  ( type(var) == "boolean"  ) then  return tostring(var), "boolean"
    elseif  ( type(var) == "Vector"   ) then  return "Vector("..tostring(var.x)..","..tostring(var.y)..","..tostring(var.z)..")", "Vector"
    elseif  ( type(var) == "Vector2"  ) then  return "Vector2("..tostring(var.x)..","..tostring(var.y)..")", "Vector2"
    elseif  ( type(var) == "Vector3"  ) then  return "Vector3("..tostring(var.x)..","..tostring(var.y)..")", "Vector3"
    elseif  ( type(var) == "nil"      ) then  return "nil", "nil"
                                        else  return "\""..tostring(var).."\"", "string/unknown"
    end
end

------------------------------------------------------------------------------------------------------------

function  dumptable_structure(t,curPath,disableDotNotation,ownCall)

  local printProvoder = echo or original_print or print

  if    ( ownCall == nil ) and ( type(t) == "string" ) and ( _G[t] ~= nil )
  then  curPath = t ; t = _G[t]
  end

  if    ( type(curPath) ~= "string" )              then  curPath = tostring(curPath) or ""    end

  if    disableDotNotation then disableDotNotation = true ; else disableDotNotation = false ; end

  if    ( ownCall == nil ) then addressListSeen = {} ; end

  local subTables, subVars = {}, {}

  if    ( curPath ~= "" ) then printProvoder( curPath.." = {}" ) ; end

  if    ( type(t) == "nil" )
  then  printProvoder( curPath .. " = nil" ) ; return
  end

  local prevPath = tostring(curPath)

  local vCount = 0

  if ( type(t) ~= "table" ) then t = {t} ; end

  for   k,v in pairs(t) do

      if      ( type(k) == "number" )
      then    curPath = prevPath.."["..tostring(k).."]"
      elseif  ( type(k) == "string" )
      then
          if    ( disableDotNotation == false )
          then  curPath = prevPath.."."..k
          else  curPath = prevPath.."["..varAsPrintable(k).."]"
          end
      end

      if      ( dumptable_structure_isIgnored(curPath) == false ) and ( dumptable_structure_isIgnored(k) == false ) and ( v ~= nil )
      then
          vCount = vCount + 1

          if    ( type(v) == "table" )
          then
            local   tAddress = tonumber( "0x"..string.gsub( tostring(t), ".*[x ]", "" ) ) or 1

            if      ( addressListSeen[tAddress] == nil )
            then
                if    ( curPath ~= "_G.package" )
                and   ( ( curPath == "_G" ) or ( curPath:sub(1,2)..curPath:sub(#curPath-1) ~= "_G_G" )  )
                then  addressListSeen[tAddress] = prevPath  ;  dumptable_structure(v,curPath,disableDotNotation,true)  -- subTables[#subTables+1] = {k,v}
                end

            elseif  ( addressListSeen[tAddress] == prevPath )
            and     ( string.find(curPath,"_G[^a-zA-Z]") )
            then    printProvoder("-- Skipping "..curPath.." because we've already seen it.")
            else    dumptable_structure(v,curPath,disableDotNotation,true) -- subTables[#subTables+1] = {k,v}
            end
          else
            printProvoder( curPath.." = "..varAsPrintable(v) )
          end
      else
        printProvoder(curPath.." = {} -- Ignoring rest-of-contents due to dumptable filter.")
      end
  end

  for   k,v in pairs(subTables) do
      dumptable_structure(v[2], curPath, disableDotNotation, true)
  end

end ; dump = dumptable_structure

--[[
  human={

    [1]={body={arms={
      l={upper={fore={wrist={fingers={pinky={ attached = true,  jointForce = 1.0000, model = "white_male_42_fingers_pinky_l_attached", },},},},},},
      r={upper={fore={wrist={fingers={pinky={ attached = false, jointForce = 0.0000, model = "white_male_42_fingers_pinky_r_deattached", },},},},},},
      },    },    },

    [2]={body={arms={
      l={upper={fore={wrist={fingers={pinky={ attached = false, jointForce = 0.0000, model = "black_female_69_fingers_pinky_l_deattached", },},},},},},
      r={upper={fore={wrist={fingers={pinky={ attached = true,  jointForce = 1.0000, model = "black_female_69_fingers_pinky_r_attached",   },},},},},},
      },    },    },
  }

  dump("human")
--]]

------------------------------------------------------------------------------------------------------------

dumptable_structure_ignore = {}

function  dumpIgnore(toIgnoreStr,verbose)
  if    verbose    then  verbose = true    else  verbose = false    end
  if ( type(toIgnoreStr) ~= "string" ) then print(unpack(dumptable_structure_ignore)) ; return ; end
  local intFound,i = -1,1
  while ( i <= #dumptable_structure_ignore ) do
      if    ( dumptable_structure_ignore[i] == toIgnoreStr )
      then  strFound = true ; intFound = i
      end
      i = i + 1
  end

  if ( intFound == -1 )
  then
    if verbose  then  print("dumptable_structure : Add Ignore String : "..toIgnoreStr)  ; end
    dumptable_structure_ignore[#dumptable_structure_ignore+1] = toIgnoreStr
  else
    if verbose  then  print("dumptable_structure : Remove Ignore String : "..dumptable_structure_ignore[intFound])  ; end
    table.remove(dumptable_structure_ignore,intFound)
  end
end

------------------------------------------------------------------------------------------------------------

function  dumptable_structure_isIgnored(strQuery)
  strQuery = tostring(strQuery)
  for   k,v in pairs(dumptable_structure_ignore or {}) do
      if    ( string.upper(strQuery) ~= string.gsub( string.upper(strQuery), string.upper(v), "" ) )
      then  return true
      end
  end
  return false
end

------------------------------------------------------------------------------------------------------------
echo_outputFile      = "echo-output.txt"
echo_outputFile_once = nil

function  echo(...) -- Requires   string2file  ,  dumptable

    local ret,retStr,cur_echo_outputFile = {}, "", echo_outputFile

    if    echo_outputFile_once
    then  cur_echo_outputFile = echo_outputFile_once
    end

    local inp = ({...})
    for k,v in pairs(inp)
    do
        local typev = type(v) or ""
        local retCur = ""
        if      ( typev == "table"  )  then  if #ret > 0 then retCur = "\n"..dumptable(v) ;  else  retCur = dumptable(v)  ; end
        elseif  ( typev == "string" )  then  retCur = v
        elseif  ( typev == "number" )  then  retCur = tostring(v) --if string.find(v,"[.]") then retCur = tostring(v) ; else retCur = string.format("0x%08x",v) ; end
        elseif  ( typev == "Vector" )  then  retCur = string.format( "Vector( x = %6.f, y = %6.f, z = %6.f )", v.x, v.y, v.z )
      --else    ret[#ret+1] = dumptable(v) ; print(ret[#ret])
      --else    retCur = varAsPrintable(v)
        else    retCur = tostring(v)
        end
        print(retCur) ; ret[#ret+1] = retCur
    end

    if ( #ret > 0 ) and string2file  then
        retStr = table.concat(ret,"  ")
        string2file(retStr,cur_echo_outputFile,"a")
    end

    if echo_outputFile_once then echo_outputFile_once = nil ; end

    return retStr

end

------------------------------------------------------------------------------------------------------------

function  string.contains( ... )
    local s   = ""
    for k,v in pairs({...}) do
        if  k == 1 then s = v  ; else  if  string.find(s,v)  then  return true,k ; end ; end
    end
    return false,0
end

------------------------------------------------------------------------------------------------------------

function  string.lowercontains( ... )
    local s   = ""
    for k,v in pairs({...}) do
        if  k == 1 then s = string.lower(v)  ; else  if  string.find(s,string.lower(v))  then  return true,k ; end ; end
    end
    return false,0
end

------------------------------------------------------------------------------------------------------------

function  string.split( s, pat )
  --[[
    Use like:
      for k in string.split("asdf,,fdsa,,,dsaf") do print(k) ; end

    Output is:
      asdf

      fdsa


      dsaf
  --]]
  s = tostring(s) or ""
  pat = tostring( pat ) or '%s+'
  local st, g = 1, s:gmatch("()("..pat..")")
  local function getter(segs, seps, sep, cap1, ...)
  st = sep and seps + #sep
  return s:sub(segs, (seps or 0) - 1), cap1 or sep, ...
  end
  return function() if st then return getter(st, g()) end end

end

------------------------------------------------------------------------------------------------------------

function string.totable( s, separators )

    local newTab = {}
    separators = separators or "[\t ,:|]"
    for v in string.split(s,separators) do newTab[#newTab+1] = v ; end
    return newTab

end

------------------------------------------------------------------------------------------------------------

function string.alike(s1,s2)
    s1 = tostring(s1 or ""):upper()
    s1 = string.gsub(s1,"[^\x20-\x6C]","")
    s2 = tostring(s2 or ""):upper()
    s2 = string.gsub(s2,"[^\x20-\x6C]","")
    local aNum,bNum,rNum = 0,0,0
    for i = 1,#s1 do bNum = bNum + 1 ; if string.find(s2,"["..s1:sub(i,i).."]") then aNum = aNum + 1 ; end ; end
    for i = 1,#s2 do bNum = bNum + 1 ; if string.find(s1,"["..s2:sub(i,i).."]") then aNum = aNum + 1 ; end ; end
    if ( bNum > 0 )
    then rNum = aNum / bNum
    end
    return rNum, aNum, bNum
end

------------------------------------------------------------------------------------------------------------

function string.totablekeyvalue( s, separators )

    local newTab  = {}
    local lineNum = 0
    local gsub    = string.gsub
    separators = separators or "[\t ,:|]"
    local separatorsNot = ""
    if    separators:sub(1,1) == "["
    then  separatorsNot = "[^"..separators:sub(2,#separators-1).."]"
    else  separatorsNot = "[^"..separators.."]"
    end
    s = s or ""
    for line in string.split2(s,"\n") do
        local   curKey   = gsub(line,separators..".*","")
        local   curValue = gsub(line,"^"..separatorsNot..separatorsNot.."*"..separators,"")
                curKey   = gsub(curKey,"^['\"\t ]['\"\t ]*","")
                curKey   = gsub(curKey,"['\"\t ]['\"\t ]*$","")
                curValue = gsub(curValue,"^['\"\t ]['\"\t ]*","")
                curValue = gsub(curValue,"['\"\t ]['\"\t ]*$","")

        if      curKey  ~= "" and  not newTab[curKey] then    newTab[curKey] = curValue
        elseif  newTab[curKey]                        then    newTab[curKey] = newTab[curKey]..", "..curValue
        end
    end

    return newTab

end

------------------------------------------------------------------------------------------------------------

function  string.split2( s, separators )
  --[[
    Use like:
      for k in string.split2("asdf  ,  , fdsa , , , dsaf") do print(k) ; end

    Output is:
      asdf
      fdsa
      dsaf
  --]]
  if      ( type(s) ~= "string" ) then  s = tostring(s) or ""   ; end
  if      not separators  then  separators = "[\", ][\", ]*" ; end
  local   st, g = 1, s:gmatch("()("..separators..")")
  local   function getter(segs, seps, sep, cap1, ...) st = sep and seps + #sep ; return s:sub(segs, (seps or 0) - 1), cap1 or sep, ... ; end
  return  function() if st then return getter(st, g()) end end

end
--for k in string.split2("asdf,fdsa") do print(k) ; end
------------------------------------------------------------------------------------------------------------

function  toboolean(...)

  local inpTable = ({...})

  for k,inp in pairs(inpTable)
  do
    if      ( type(inp) == "table" )
    then    for k,v in pairs(inp) do return tobool(v) ; end

    elseif  ( type(inp) == "nil" )
    then    return false

    elseif  ( type(inp) == "boolean" )
    then    return inp

    elseif  ( type(inp) == "string" )
    then    if ( inp == "" ) or ( inp == "nil" ) or ( inp == "f" ) or ( inp == "0" ) then return false ; else return true ; end

    elseif  ( type(inp) == "number" )
    then    if ( inp <= 0  ) then return false ; else return true ; end

    end
   end
   return false
end ; tobool = toboolean

------------------------------------------------------------------------------------------------------------

function  lua_do(...)

  ----------------------------------------------------------------------------
  -- This is the lua equiv of 'eval', in shell.
  -- It can take input text and compile/run the code.
  ----------------------------------------------------------------------------
  ----------------------------------------------------------------------------
  -- Example:
  ----------------------------------------------------------------------------
  --
  --   lua_do("for i = 1,10 do  print(i) ; end")
  --
  ----------------------------------------------------------------------------
  -- In Console Example:
  ----------------------------------------------------------------------------
  --
  --   lua for i = 1,10 do  print(i) ; end
  --
  local args = {...}
  local inp_string = ""
  for k,v in pairs(args) do
      if    (type(v) == "table")
      then  for k2,v2 in pairs(v) do inp_string = inp_string..tostring(v2).."\n" ; end
      else  inp_string = inp_string..tostring(v).."\n"
      end
  end
  local f = loadstring(inp_string)
  if ( f == nil )
  then
      print("-- lua_do [ERROR] - loadstring failed to load below input:")
      print(inp_string)
      return false
  end
  local success, err = 0 , ""
  success, err = pcall(f) --catch errors
  if ( not success ) then  print( "[Failure] - " , tostring(err) )  ; end
  return true
end

------------------------------------------------------------------------------------------------------------

function  lua_do_v2(...)

  --[[
    Note - This version is not 'better'.  It simply uses dofile to execute given string, rather than loadstring.

    - This is the lua equiv of 'eval', in shell.
    - It can take input text and compile/run the code.
    - Example:   do_lua("for i = 1,10 do  print(i) ; end")
  --]]

  --'arg' is only supported in lua 5.3
  --So we use args instead (which works in all versions.)
  --local inp_string = table.concat(arg," ")

  local args = {...}
  local inp_string = ""
  for k,v in pairs(args) do
    if    (type(v) == "table")
    then  for k2,v2 in pairs(v) do inp_string = inp_string..tostring(v2).."\n" ; end
    else  inp_string = inp_string..tostring(v).."\n"
    end
  end
  string2file(inp_string,"lua_do-latest.txt","w","\r\n")
  local result = dofile("lua_do-latest.txt")
  return true

end

------------------------------------------------------------------------------------------------------------

function  lua_do_request(strLuaCode)
    if    ( lua_do_request_table == nil )
    then  lua_do_request_table = {}
    end
    if    ( type(strLuaCode) ~= "string" )
    then  print("lua_do_request : ERROR : arg 1 does not appear to be a string.") ; return false
    end
    table.insert(lua_do_request_table,strLuaCode)
    return true
end

------------------------------------------------------------------------------------------------------------

function unpack2(t,mode)

  local   modeNumber,modeString = false,false

  if      not mode
  then    modeNumber,modeString = true,true
  elseif  mode:sub(1,2) == "nu"  then    modeNumber,modeString = true,  false
  elseif  mode:sub(1,1) == "s"   then    modeNumber,modeString = false, true
  elseif  mode:sub(1,2) == "na"  then    modeNumber,modeString = false, true
  elseif  mode:sub(1,1) == "b"   then    modeNumber,modeString = true,  true
  end

  if ( type(t) ~= "table" ) then return t ; end

  local retVals,retKeysNumeric,retKeysString = {},{},{}

  for k,v in pairs(t) do
      local ktype,vtype = type(k),type(v)
      if       modeNumber and ktype == "number" and vtype ~= "table"
      then     retKeysNumeric[#retKeysNumeric+1] = k
      elseif   modeString and ktype == "string" and vtype ~= "table"
      then     retKeysString[#retKeysString+1]   = k
      end
  end

  table.sort(retKeysNumeric)
  table.sort(retKeysString)

  for _,k in pairs(retKeysNumeric) do retVals[#retVals+1] = t[k] ; end
  for _,k in pairs(retKeysString)  do retVals[#retVals+1] = t[k] ; end

  return unpack(retVals)

end

------------------------------------------------------------------------------------------------------------

function unpackSerial2(t)

    if type(t) ~= "table" then return(t) ;end
    local tKeysAlpha,tKeysNumeric = {},{}
    for k,v in pairs(t) do if type(k) == "string" then tKeysAlpha[#tKeysAlpha+1] = k ; else tKeysNumeric[#tKeysNumeric+1] = k ; end ; end
    table.sort(tKeysAlpha)
    table.sort(tKeysNumeric)

end

------------------------------------------------------------------------------------------------------------

function  unpackSerial(t)

  if    ( type(t) ~= "table" )
  then  return(t)
  end

  local tCount,tCountActual = #t,0
  for k,v in pairs(t) do tCountActual = tCountActual + 1 ; end

  local tNewElements,tNewKeys = {},{}

  if    ( tCount == tCountActual )
  then
    for i = 1,tCountActual do
      if      ( type( t[i] ) == "table" )
      then    for k,v in pairs( {unpackSerial(t[i])} ) do  tNewKeys[#tNewKeys+1] = k ; tNewElements[#tNewElements+1] = v ; end
      else    tNewKeys[#tNewKeys+1] = i ; tNewElements[#tNewElements+1] = t[i]
      end
    end

  elseif ( tCount > 0 ) and ( tCount < tCountActual )
  then
    for i = 1,tCountActual do
      if      ( type( t[i] ) == "table" )
      then    for k2,v2 in pairs( {unpackSerial(t[i])} ) do  tNewKeys[#tNewKeys+1] = k2 ; tNewElements[#tNewElements+1] = v2 ; end
      else    tNewKeys[#tNewKeys+1] = i ; tNewElements[#tNewElements+1] = t[i]
      end
    end
    for k,v in pairs(t) do
      if      ( type(k) ~= "number" ) or ( k < 1 ) or ( k > tCount )
      then
        if      ( type( v ) == "table" )
        then    for k2,v2 in pairs( {unpackSerial(v)} ) do  tNewKeys[#tNewKeys+1] = k2 ; tNewElements[#tNewElements+1] = v2 ; end
        else    tNewKeys[#tNewKeys+1] = k ; tNewElements[#tNewElements+1] = v
        end
      end
    end

  elseif ( tCount == 0 ) and ( tCountActual > 0 )
  then
    for k,v in pairs(t) do
      if      ( type(v) == "table" )
      then    for k2,v2 in pairs( {unpackSerial(v)} ) do  tNewKeys[#tNewKeys+1] = k2 ; tNewElements[#tNewElements+1] = v2 ; end
      else    tNewKeys[#tNewKeys+1] = k ; tNewElements[#tNewElements+1] = v
      end
    end
  end

  return unpack(tNewElements)

end


function findAllFunctions(key,value,path,noDotNotation,doNotPrint)

  local printProvider = echo or print
  local overrideG     = false
  local pathCur       = ""

  if    not key or not value
  then
        key = "_G" ; value = _G ; path = "_G"
        local ret = ""
        for k,v in pairs(value) do if type(v) == "table" or type(v) == "function" then  if not noDotNotation and type(k) == "string" then pathCur = path.."."..k ; elseif type(k) == "string" then pathCur = path .. "['"..k.."']" ; else pathCur = path .. "["..tostring(k).."]" ; end ; ret = ret .. "\n" .. tostring(findAllFunctions(k,v,pathCur,noDotNotation,doNotPrint) or "") ; end ; end ;
        return ret
  end

  if path and ( path == "_G['package']" or path == "_G.package" ) then local ret = "" ; return ret ; end

  local pathCur = path

  if      type(value) == "table"  and  key ~= "_G"  then  local ret = "" ; for k,v in pairs(value) do if type(v) == "table" or type(v) == "function" then  if not noDotNotation and type(k) == "string" then pathCur = path.."."..k ; elseif type(k) == "string" then pathCur = path .. "['"..k.."']" ; else pathCur = path .. "["..tostring(k).."]" ; end ; ret = ret .. "\n" .. tostring(findAllFunctions(k,v,pathCur,noDotNotation,doNotPrint) or "") ; end ; end ; return ret
  elseif  type(value) == "function"                 then  local ret = varAsPrintable(value).." "..path ; if  not doNotPrint  then  printProvider( ret )  ; end ; return ret
  end

end


function findAllTables(key,value,path,noDotNotation,doNotPrint)

  local printProvider = echo or print
  local overrideG     = false
  local pathCur       = ""

  if    not key or not value
  then
        key = "_G" ; value = _G ; path = "_G"
        local ret = ""
        for k,v in pairs(value) do if type(v) == "table"  then  if not noDotNotation and type(k) == "string" then pathCur = path.."."..k ; elseif type(k) == "string" then pathCur = path .. "['"..k.."']" ; else pathCur = path .. "["..tostring(k).."]" ; end ; ret = ret .. "\n" .. tostring(findAllTables(k,v,pathCur,noDotNotation,doNotPrint) or "") ; end ; end ;
        return ret
  end

  if path and ( path == "_G['package']" or path == "_G.package" ) then local ret = "" ; return ret ; end

  local pathCur = path

  if    type(value) == "table"  and  key ~= "_G"
  then
        local ret = varAsPrintable(value).." "..path
        if  not doNotPrint  then  printProvider( ret )  ; end
        for k,v in pairs(value) do
            if type(v) == "table"  then
                if      not noDotNotation  and  type(k) == "string"
                then
                        pathCur = path.."."..k

                elseif  type(k) == "string"
                then
                        pathCur = path .. "['"..k.."']"
                else
                        pathCur = path .. "["..tostring(k).."]"
                end
                ret = ret .. "\n" .. tostring(findAllTables(k,v,pathCur,noDotNotation,doNotPrint) or "")
            end
        end

        return ret
  end

end


function  testFunc(count,func)
  --[[ Examples
    testFunc(1000000,function() local x,y   = 1.2, -10.3          ; local z = x ; end)
    testFunc(1000000,function() local w,x,y = 1.2, -10.3, 100.234 ; local z = math.max(w,x,y) ; end)
    testFunc(1000000,function() local model = "BIG_ASS_BUS" ; if ( string.find(model,"BUS") ) then ; end ; end)
  --]]

    count = tonumber(count or 1) or 1

    if    ( type(func) ~= "function" ) then print("# usage: testFunc( testCount, testFunc )") ; return ; end

    local start_clock,ret = os.clock(), {}

    for i = 1,count do        ret = func()    end

    local end_clock   = os.clock()
    local timeElapsed = end_clock - start_clock + 0.00000000001
    local timePerExec = count/timeElapsed
    local printProvider = echo or print

    printProvider( tostring(math.floor((end_clock-start_clock)*1000)*0.001).." "..tostring(math.floor(1/timeElapsed*count)).."/sec" )
end


gc = {}
function gc.help()          --[[ Prints available commands --]] for k,v in pairs(gc) do local arg = "" ; if k:sub(1,1) == "s" and k ~= "stop" then arg = "arg" ; end ; print(string.format("  %-15s = %s","gc."..k.."("..arg..")",v)) ; end ; end
function gc.collect()       --[[ Performs a full garbage-collection cycle. This is the default option. --]] return collectgarbage("collect") ; end
function gc.stop()          --[[ Stops the garbage collector. --]] return collectgarbage("stop") ; end
function gc.restart()       --[[ Restarts the garbage collector. --]] return collectgarbage("restart") ; end
function gc.count()         --[[ Returns the total memory in use by Lua (in Kbytes). --]] return collectgarbage("count") ; end
function gc.step(size)      --[[ size:int  Performs a garbage-collection step. The step "size" is controlled by arg (larger values mean more steps) in a non-specified way. If you want to control the step size you must experimentally tune the value of arg. Returns true if the step finished a collection cycle. --]] return collectgarbage("step",size) ; end
function gc.setpause(arg)   --[[  arg:bool Sets arg as the new value for the pause of the collector. Returns the previous value for pause. --]] return collectgarbage("setpause",arg) ; end
function gc.setstepmul(arg) --[[  arg:int  Sets arg as the new value for the step multiplier of the collector. Returns the previous value for step. --]] return collectgarbage("setstepmul",arg) ; end


--[[--------------------------------------------------------------------------------------------------------
 ----                         timeMark: An arbitrary time tracking system                              ----
------------------------------------------------------------------------------------------------------------

    - For use in console.
    - Records/Prints the times between TM.start() and TM.mark()

    Usage:
          TM.start()  aka  TM.s()
          TM.mark()   aka  TM.m()
          TM.reset()  aka  TM.r()
          TM.print()  aka  TM.p()

    Example:
          > TM.m()
          Timer Started.
          > TM.m()
           #  =     time.y - time.x     = time.delta comment.x > comment.y
          --- =     ------ - ------     = ---------- ---------------------
          [1] =   5854.046 - 5853.265   = 0.078      05/03/16 02:08:44 > 05/03/16 02:08:45

          > TM.m()
           #  =     time.y - time.x     = time.delta comment.x > comment.y
          --- =     ------ - ------     = ---------- ---------------------
          [1] =   5854.046 - 5853.265   = 0.078      05/03/16 02:08:44 > 05/03/16 02:08:45
          [2] =   5854.546 - 5854.046   = 0.05       05/03/16 02:08:45 > 05/03/16 02:08:45

          > TM.m()
           #  =     time.y - time.x     = time.delta comment.x > comment.y
          --- =     ------ - ------     = ---------- ---------------------
          [1] =   5854.046 - 5853.265   = 0.078      05/03/16 02:08:44 > 05/03/16 02:08:45
          [2] =   5854.546 - 5854.046   = 0.05       05/03/16 02:08:45 > 05/03/16 02:08:45
          [3] =   5854.812 - 5854.546   = 0.0265     05/03/16 02:08:45 > 05/03/16 02:08:46

--------------------------------------------------------------------------------------------------------]]--

timeMark         = {}
function  timeMark.reset()           print("Timer Data Reset.") ; timeMark.List,timeMark.Comments,timeMark.defaultComment = {},{},"" ; end
function  timeMark.comment(comment)  if ( type(comment) == "string" ) and ( comment ~= "" ) then timeMark.defaultComment = comment ; else timeMark.defaultComment = os.date() ; end  timeMark.Comments[#timeMark.Comments+1] = timeMark.defaultComment ; end
function  timeMark.start(comment)    timeMark.reset() ; timeMark.comment(comment) ; timeMark.List = { os.clock(), } ; timeMark.print() ; end
function  timeMark.mark(comment)     timeMark.comment(comment) ; timeMark.List[#timeMark.List+1] = os.clock() ; timeMark.print(#TM.List-1,#TM.List) ; end
function  timeMark.print(x,y)
  if    ( #TM.List == 0 ) then return 0  end;

  local curListNumLen = #tostring( #TM.List )

  x = tonumber(x or -1);
  y = tonumber(y or -1);

  if    ( x == -1  and  y == -1 )
  then
    if    ( #TM.List == 1 )
    then  print( "Timer Started." );
    else
      print( "# "..tostring(timeMark.Comments[1]))
      print( string.format( "%"..tostring(curListNumLen+2).."s = %10s - %-10s = %-10s   %s", " # ", "time.y", "time.x","time.delta", "comment"  ) );
      print( string.format( "%"..tostring(curListNumLen+2).."s = %10s - %-10s = %-10s   %s", "---", "------", "------","----------", "------------------------------------------"  ) );
      local i,j = 1,2; while ( j <= #TM.List ) do print( string.format( "%"..tostring(curListNumLen+2).."s = %10s - %-10s = %-10s   %s","["..tostring(i).."]",TM.List[j],TM.List[i],math.floor((TM.List[j]-TM.List[i])*10000)*0.0001, tostring(TM.Comments[j]) ) ) ;  i = i+1 ; j = j+1;  end;
    end;
    return true;
  end;

  if ( x < 1 ) then x = #TM.List + x ; end
  if ( y < 1 ) then x = #TM.List + y ; end

  if ( #TM.List == 1 ) then  print( "Timer Started." );  return true;  end;

  if x < 0 then x = #TM.List + x; end;
  if y < 0 then y = #TM.List + y; end;

  if      (   ( TM.List[x] ~= nil ) and ( TM.List[y] == nil )   )
  or      ( #TM.List == 1 )
  then    x = #TM.List;  print( "Timer Started." );
  elseif  ( TM.List[x] ~= nil ) and ( TM.List[y] ~= nil )
  and     ( x >= 1 ) and ( x <= #TM.List ) and ( y >= 1 and y <= #TM.List )
  then
      print( string.format( "%"..tostring(curListNumLen+2).."s = %10s - %-10s = %-10s   %s", " # ",     "time.y",     "time.x","time.delta", "comment"  ) );
      print( string.format( "%"..tostring(curListNumLen+2).."s = %10s - %-10s = %-10s   %s", "---", "----------", "----------","----------", "---------------------"  ) );
      if     ( x < y )
      then   print( string.format( "%"..tostring(curListNumLen+2).."s = %10s - %-10s = %-10s   %s","["..tostring(x).."]",TM.List[y],TM.List[x],math.floor((TM.List[y]-TM.List[x])*10000)*0.0001, tostring(TM.Comments[y]) ) );
      elseif ( x > y )
      then   print( string.format( "%"..tostring(curListNumLen+2).."s = %10s - %-10s = %-10s   %s","["..tostring(y).."]",TM.List[x],TM.List[y],math.floor((TM.List[x]-TM.List[y])*10000)*0.0001, tostring(TM.Comments[x]) ) );
      end;
  end;
end;
timeMark.List     = {}
timeMark.Comments = {}
timeMark.r  = timeMark.reset;  timeMark.R = timeMark.reset;
timeMark.s  = timeMark.start;  timeMark.S = timeMark.start;
timeMark.m  = timeMark.mark;   timeMark.M = timeMark.mark;
timeMark.p  = timeMark.print;  timeMark.P = timeMark.print;
TM          = timeMark;



------------------------------------------------------------------------------------------------------------

MILLION_MONKEYS = {
       keys      = {  "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", ",", ".", " "," "," "," "," " },
       searchStr = "TEST",
       characterCount = 0,
}

function MILLION_MONKEYS:search(searchStr)  searchStr = searchStr or self.searchStr;  searchStr = string.upper(tostring(searchStr)); self.searchStr = searchStr; self.characterCount = 0; local foundStr = ""; print("Searching for: "..searchStr); while foundStr ~= searchStr  do  self.characterCount = self.characterCount + 1; local monkeyStr = foundStr..self.keys[math.random(1,#self.keys)]; if monkeyStr == searchStr:sub(1,#monkeyStr) then foundStr = monkeyStr ; if #monkeyStr > 1 then print(foundStr) ; end ; elseif #foundStr ~= 0 then foundStr = "" ; end; if self.characterCount % 1000000 == 0 then print( "\x1b\x5d\x32\x3b"..string.format("%.0f",self.characterCount).." Monkey Keys Pressed".."\x07"..string.format("%.0f",self.characterCount).." Monkey Keys Pressed" ) ; end; end; print("Found "..foundStr.." in just "..tostring(self.characterCount).." Monkey Keys!"); end

------------------------------------------------------------------------------------------------------------

function lua_fix_root_level_missing_type_functions()
    -- Auto-fix root-level(_G) missing __type functions.
    for k,v in pairs(_G) do
        local success,err = pcall(loadstring("local curType = type("..tostring(k)..")"))
        if (err ~= nil) then print("Adding __type to "..tostring(k)) ; pcall(loadstring("function "..tostring(k)..":__type()  return \""..tostring(k).."\" ; end")) ; end
    end
end

lua_fix_root_level_missing_type_functions()


-- CHR and HEX
CHR,HEX = {},{}
for i = 0,255 do CHR[i] = string.char(i) ; HEX[i] = string.format("%02X",i) ; HEX[string.format("%02x",i)] = HEX[i] ; HEX[string.format("%02X",i)] = HEX[i] ; HEX[tostring(i)] = HEX[i] ; end


USERAGENTS = {
  "Mozilla/5.0 (Windows NT 5.1; rv:18.0) Gecko/20100101 Firefox/18.0",
  "Mozilla/5.0 (Windows NT 5.1; rv:31.0) Gecko/20100101 Firefox/31.0",
  "Mozilla/5.0 (Windows NT 5.1; rv:41.0) Gecko/20100101 Firefox/41.0",
  "Mozilla/5.0 (Windows NT 6.1; rv:38.0) Gecko/20100101 Firefox/38.0",
  "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0)",
}

-- Tell untiy application to not pause when application loses focus (aka run-in-background)
  if    UnityEngine  and  UnityEngine.Application  and  UnityEngine.Application.runInBackground
  then  UnityEngine.Application.runInBackground = true
  end


-- local newMath = {}
-- for k,v in pairs(math) do newMath[k] = v ; end
-- math = newMath

-- local newTable = {}
-- for k,v in pairs(table) do newTable[k] = v ; end
-- table = newTable

-- local newString = {}
-- for k,v in pairs(string) do newString[k] = v ; end
-- string = newString



-- Tell dump function which tables to ignore.
  -- for k,v in pairs({
  --   "UnityEngine.Vector",                             "UnityEngine.Quaternion",
  --   "UnityEngine.ParticleSystem",                     "UnityEngine.EventSystems.EventTrigger",
  --   "UnityEngine.EventSystems.StandaloneInputModule",
  --   "UnityEngine.StandaloneInputModule",              "UnityEngine.EventSystems.PointerEventData",
  --   "UnityEngine.EventSystems.PointerInputModule",    "UnityEngine.RectTransform",
  --   "UnityEngine.GUILayout",                          "UnityEngine.GUI",
  --   "UnityEngine.Color",                              "UnityEngine.Toggle",
  --   "UnityEngine.Scrollbar",                          "UnityEngine.Image",
  --   "UnityEngine.ContentSizeFitter",                  "UnityEngine.Navigation",
  --   "UnityEngine.UI",
  --   "_G.Vector",                                      "_G.Quaternion",
  --   "_G.ParticleSystem",                              "_G.EventSystems.EventTrigger",
  --   "_G.StandaloneInputModule",                       "_G.EventSystems.PointerEventData",
  --   "_G.EventSystems.PointerInputModule",             "_G.RectTransform",
  --   "_G.GUILayout",                                   "_G.GUI",
  --   "_G.Color",                                       "_G.Toggle",
  --   "_G.Scrollbar",                                   "_G.Image",
  --   "_G.ContentSizeFitter",                           "_G.Navigation",
  --   "_G.UI",
  --   })
  -- do
  --   dumpIgnore(v)
  -- end

  if    ( file_exists("RuntimeEditor_Data/StreamingAssets/key.lua") == true )
  then  KEY = dofile("RuntimeEditor_Data/StreamingAssets/key.lua")
  end

  echo_outputFile_once    = "###################################################"
  echo_outputFile_once    = ""

  -- zhoutils = {}
  -- zhoutils.help                           =  help;
  -- zhoutils.shell                          =  shell;
  -- zhoutils.ls                             =  ls;
  -- zhoutils.pack                           =  pack;
  -- zhoutils.unpack                         =  unpack;
  -- zhoutils.math                           =  math;
  -- zhoutils.table                          =  table;
  -- zhoutils.wc                             =  wc;
  -- zhoutils.randomChar                     =  randomChar;
  -- zhoutils.file_exists                    =  file_exists;
  -- zhoutils.file_create                    =  file_create;
  -- zhoutils.file2string                    =  file2string;
  -- zhoutils.string2file                    =  string2file;
  -- zhoutils.file2table                     =  file2table;
  -- zhoutils.function2string                =  function2string;
  -- zhoutils.function2string_nohex          =  function2string_nohex;
  -- zhoutils.dumptable                      =  dumptable;
  -- zhoutils.keyAsPrintable                 =  keyAsPrintable;
  -- zhoutils.varAsPrintable                 =  varAsPrintable;
  -- zhoutils.dumptable_structure            =  dumptable_structure;
  -- zhoutils.dumpIgnore                     =  dumpIgnore;
  -- zhoutils.dumptable_structure_isIgnored  =  dumptable_structure_isIgnored;
  -- zhoutils.echo                           =  echo;
  -- zhoutils.string                         =  string;
  -- zhoutils.toboolean                      =  toboolean;
  -- zhoutils.lua_do                         =  lua_do;
  -- zhoutils.lua_do_v2                      =  lua_do_v2;
  -- zhoutils.lua_do_request                 =  lua_do_request;
  -- zhoutils.unpackSerial                   =  unpackSerial;
  -- zhoutils.findAllFunctions               =  findAllFunctions;
  -- zhoutils.findAllTables                  =  findAllTables;
  -- zhoutils.testFunc                       =  testFunc;
  -- zhoutils.timeMark =                     =  timeMark;

-- math table string

--[[

searchTab = {
"aBLCAgj054oPWdeoQGktZaBFGCcLJ7aeVSq9",
"aBLCAgj0c5ebroDvbs5Zx54s9njdUIeUJrCE",
"aBLCAgj0Vo35M6oNfqlNNSMCK7S38Cot5mrL",
"aBLCAgj1RfQpLAo9Kl8lrgG4omzV5kpQ4VcN",
"aBLCAgj2lhSPQBj90CPJARLJh9ieRBQdA3fF",
"aBLCAgj2RQxrB7Ft38sPwGI4A5pbp8aJbkCu",
"aBLCAgj3iqPnNKAcbKLQPdGdkyAHOy1WK8xt",
"aBLCAgj3OFmEwtoeNHq2R1J2XUdCO8csRfQX",
"aBLCAgj5hIvlz8CEzlTNR8b8SfrMQQRoMNTK",
"aBLCAgj6MxLobo4X533X4flRWn93xfN8VfUs",
"aBLCAgj6uv1MrCVOb5Q5RkbpRdkCG5cOi1da",
"aBLCAgj72lk8ldPbXcMEVpT7Lto6QZ1Z4QiA",
"aBLCAgj7caflJFqWptl4OGm58lxCIhu65sbI",
"aBLCAgj7V4fquS9e4eqTN63uLpNrAsCmlqMM",
"aBLCAgj8aqwMbndHQTpa9UrsKryepX5FozXk",
"aBLCAgj8CpqO1S8n97yuMoj5xBVNDMROlURc",
"aBLCAgj8PKMtsnvEgSoGsMJrrcdTe9foNhwm",
"aBLCAgj8XM7cs6ZVpAEO2yC1VbZyoaZVw9Ek",
"aBLCAgj9PcjoE9514gmIBIVJIE8xUBd8Fv6b",
"aBLCAgj9Z9Cqf9dMYdWH9zcoWeWQGyUGOuSG",
"aBLCAgjaJbO8Wrtlzibwt2uIKoBDt70LihNi",
"aBLCAgjakqKOrhJkbke8QaWyCu565ZDTqnpQ",
"aBLCAgjb92ABHuW3b4O9pXJDHiEFETj9Lxj1",
"aBLCAgjbJvL646Yc71oIH1JoxBIRAvv8YBwf",
"aBLCAgjblV8Z3xaimuDn1XjyvPBPbSupymUT",
"aBLCAgjbPJkgqYoMrb86Sx91mzzQb9UAYypT",
"aBLCAgjdF9IWX47AyOwzrKE8pBrYqYmPskhw",
"aBLCAgjdOmKF1KTPtRYatD374GQFSGGHiKTQ",
"aBLCAgjdUja1m5fiNxMVwBOEMrjzC6OB1YAW",
"aBLCAgje49M7hT8y8uouyC8qG1hV30kKOGcj",
"aBLCAgjeOLp6p9LLEQhSYcCAYWQv6muaCI3P",
"aBLCAgjfdEvjll40Mvh4zTF9UR35OI9sQ3C6",
"aBLCAgjg9JMaw8TC7afN8fHaprqSRRZK8g6J",
"aBLCAgjhpHH0nOsSpL0UGSaUqOsGXNlONhsJ",
"aBLCAgjhY2ThT8ukpY7rS8gyz0J3ZBtGeCxY",
"aBLCAgjiABVTZcE7SqLdzkNxWws0iLa3VD6K",
"aBLCAgjipi2qslMfg100nBRVTbKawsI8uwv3",
"aBLCAgjj4wr02MgcJFRTYDgDeIRTJgBufbi3",
"aBLCAgjk0aslAG38rE4C9YKepRv1Hrqhqq5k",
"aBLCAgjkbF4gqhUO5INpUytqk33PRf9erAHc",
"aBLCAgjkS4swRHQsrD9rfFULL6x61nEZAq4S",
"aBLCAgjl4Nyq7vjHFRIrIDScpH3IE5Udy9KG",
"aBLCAgjlvxqMqUDbuJPNg0kBUOZbHoOlQgBo",
"aBLCAgjmvJBEYzZz84GZQDiiTqlKm4W1JojD",
"aBLCAgjmXuqaiBUMWViY5zUw7GtMNwjhMvbt",
"aBLCAgjnje3WUQ1UX8YPLu4ml7MZbtvM9Y7q",
"aBLCAgjno4Gus22uDTG7iCsk6zlRPk45hu2b",
"aBLCAgjob9qiGSLjF81TGUjvesbL8RM0eSE8",
"aBLCAgjok4UiaYWKgFdVu77529kxeLG5Tq9b",
"aBLCAgjotk8q248rkhBYd6y5PxirLKbABdoo",
"aBLCAgjp2rdISN2Nnl7T4M9ZrdIsoLJrn3qQ",
"aBLCAgjPR3phn009GhGxeSCY6JYwB0pI33TJ",
"aBLCAgjQ8KgQGK0q89u38eo1XsNQ69WPxVlS",
"aBLCAgjqACFG4KWCB0FEhTh22cXqRzBmv998",
"aBLCAgjQrS7nTISj9Tvo7pFIGuU9vwHec4RB",
"aBLCAgjqX5uxGTvCR9I7b9LF9WuN5GxbyjYm",
"aBLCAgjSFKkD0dEc2uhwDKXxInGSNmzLctXG",
"aBLCAgjSjge2CeMFt2HJIxai5IY8LMkXndTW",
"aBLCAgjskAaKGW8HP8wpQAkwNtdkpwBGP6eK",
"aBLCAgjSL3aYDPXjTuwimWcgfYBN4bOLb9qC",
"aBLCAgjSXMUILr7MJdS9ai3FQw9NrRMfX8nB",
"aBLCAgjTcxY3nnQcT9mUitymC6Mro2tZkAqn",
"aBLCAgjtQIfg39w5WLpc8PjPXJRhf4xoglZ8",
"aBLCAgjtXeuE9cHgfzfXeUVGq7KVS6SvA8N4",
"aBLCAgju3yu39IovVFmUy80x4cw8pBGVw2d8",
"aBLCAgjU8DI9YqzqAZky91CM6kX9G1rzPKXJ",
"aBLCAgjuTTeEev8Ynh58fS0QXALH4n9ZzZQZ",
"aBLCAgjVbLUOHWwL8qM5fUoyzGJWCkLoI7Ze",
"aBLCAgjvcxZ8iRkDvfFbZ1UX8M44OrDFE6Nj",
"aBLCAgjVFxvuIsL9U9SK83rRrdoZ895DiOWf",
"aBLCAgjvGwyOuvSnKKeO9AB1AsPepLk9NpuL",
"aBLCAgjVLhCM2SvmJaETUmok3hVPvLQgsoNc",
"aBLCAgjVo0G9XY0fLM2ezI0G53oYCR9W9fGO",
"aBLCAgjvPn89lo8YZxQpQLs7cpEppGchnVNG",
"aBLCAgjVSTHB4CFqn8h9D4r9HciR1ZdaAQnc",
"aBLCAgjvWGt98uc4JNYzWvXZ1lh5004z8t8Y",
"aBLCAgjw494YsFZXz2IeoI8pkx8a49qUNzyg",
"aBLCAgjWC69Cxa4f660YFBHkCI5m2LhZzZSX",
"aBLCAgjwJOX1hBI9d3mtporaQYq6fjywiAys",
"aBLCAgjWQI3IiZTcxD5iRDqkzCVKW5Z2YzFx",
"aBLCAgjwUkOyIs9gqDWQVbXaoSxEigM58ry5",
"aBLCAgjX95mRdjYlJGUSt3cA66vatbwesvPR",
"aBLCAgjxL9aSveEANRkX9lfy78ihTmMWZzOY",
"aBLCAgjxR6uxbbAijXW6hq5q49jhYHELyYVW",
"aBLCAgjybdAoWDVlzTl0ZUizHZ9ichZULI0h",
"aBLCAgjYv2sob4MZ5Q6DMGXT1cFQ9wXqd189",
"aBLCAgjZ1N58tqo4IYXeSw8o90JPwUAdsap3",
"aBLCAgjzFmWRg58uWZSx2SZ8m3Mw0Ko12asL",
"aBLCAgjZjRnsJpldayMvW4NH410Uz8SgudOv",
"aBLCAgkA8QEfnktZ38OjTJjfEnz4X2B8W7AG",
"aBLCAgkaIMj8SAswsisBlrQfYA0k5vtvfZFg",
"aBLCAgkaUlQzIVXC1t4ZjQd8I4yO9ap8k3xi",
"aBLCAgkAXuypWRx9On2i96sZkq9viWP0tPLv",
"aBLCAgkbF6fAtN08E45nzQa1ym4Dy4tdu2kU",
"aBLCAgkbrzKIjT3TzNAjBd4pmo0T3yOWMmXU",
"aBLCAgkbTpEFp8tCK2Bc8FidR3MU3DvLIwrM",
"aBLCAgkCkBeChSTmUrU4TWpuqb8UlLa0VXf6",
"aBLCAgkcQfpwiacbLN2htsMCwTS4Q8rmI9er",
"aBLCAgkcqsEGRdxAtPX3hCJgLeLT3ZN3XueT",
"aBLCAgkcVafPnHBoxbEj8f8A0DtAzJs0oVi2",
"aBLCAgkD4xOrjr13J26x3WErdAy80qL70gCR",
"aBLCAgkDBk8IcRGVPRFKgZAzyo9QLtP287Kq",
"aBLCAgkddT1oW8lOMqzJ8OIGNel8eEkDkxr8",
"aBLCAgkDxM9gi6D6zEtWdgDUCVuhaR7wolUp",
"aBLCAgke2XaucGs3rA2wSAyNixuL9BEg5r2Q",
"aBLCAgkE98Rs0b4PtMGEECpyl9s2bfjxpRVu",
"aBLCAgkeoor08dV44zoGxBwOj8sYp28KTggk",
"aBLCAgket9lIAzieSWvRXkw7rWnZYPcoKOyB",
"aBLCAgkEw5RjSeAI4wgJCiVBrGSzMKiNX0v9",
"aBLCAgkf9Z76xhyGNycnPlH8b22gcB8IK40W",
"aBLCAgkfLypxE18Tj0psGUHbiuGi8ZdMIDav",
"aBLCAgkg8009gxc7JNsTZ98WZGtk6gJT93pz",
"aBLCAgkgDzFEmpw2ZIHhfU1ochpaNvHuh578",
"aBLCAgkGN7maBPixsWJQ2GTTlYQ6k3Ta0tSX",
"aBLCAgkGU4h3Qt236NGnqr8g3iwLCCMzLeI2",
"aBLCAgkGuMM8lP5wf949JXK9jVNM7RzqwXKO",
"aBLCAgkGzsYKm2j9YE5A5lU4Qim155iAQbp3",
"aBLCAgkhOpMsromJpGInJkRE7LVdg98eDlPO",
"aBLCAgkIl5U9n4En49XJCBUAm4aQRSRVClm9",
"aBLCAgkjCRREQxKfPsnF78tOFautha0QTeiL",
"aBLCAgkjJ8ZhSFTbbqjNuMd92fQsPy8hGboY",
"aBLCAgkjkgcJ0ej7sbfpPF88vyRIacBUaKSW",
"aBLCAgkJWLkogNfVfSPQNavQXppPvvxNpU6e",
"aBLCAgkkm3GQ80cNErYyNLNXORqAr7zUtl2R",
"aBLCAgkkNsx7TimGrZ2EuF8VK2lbvQJjSbEv",
"aBLCAgkL7ez5NlmhuvJ19DnqhK8zDTujNmPf",
"aBLCAgklLFBeD8HU4c8dwi6t8wYMyBA316FL",
"aBLCAgkLPE9w8u7fjoKQ8xUlQT3v4qyqwAJb",
"aBLCAgkLyzBZwHTE1vsLnMcIydOkb2PYWR5s",
"aBLCAgkMaL5X8xZWTZk8H1BGU7lnOf8W2tZd",
"aBLCAgkMBob47yBoDEWR9W9G8F3PNIP8xeao",
"aBLCAgkMKpL8Jb7tc2h8Yroqe9EIQ8WCnqxn",
"aBLCAgkMS5IbhDszmTuPrKE6UbxTvUBfTL7c",
"aBLCAgkmxHIZWs4AkrYFD49SknBkTcE19LLo",
"aBLCAgkNC8bBa9xKMdg1s6dEWH2yh5j3808r",
"aBLCAgkndyelGjQggFj89XaaZMzf2aHEIjhd",
"aBLCAgknkGZhEWic6DQ005P4QAZEtkTF986h",
"aBLCAgkNlbNHcgE89lqwUGH65I8uPg9C0H9a",
"aBLCAgknLHRxNlmZSTv9u8QNHZXCGtFU2FIu",
"aBLCAgkNrkTZ93sB0274fLHoQDQMLBySBvnE",
"aBLCAgkom8EfWS3SC0vXSMu4JcVgBfSUk8n6",
"aBLCAgkOmDoE9DAsgIfp79m7aOBTTfTEpQHu",
"aBLCAgkoQuh9MyO9KE8rOnPM9dWzYpeiJbdw",
"aBLCAgkP2aqAn79jC5fNR8iUsWa590tD54Fr",
"aBLCAgkpKGLWfUhxbRvDt6a8nkJkkU9KszFF",
"aBLCAgkPoej8KkrFihHb0w0WanycxmMOCVxq",
"aBLCAgkPPWo9vzXX0Wb303ShPvq7jwhTkQtH",
"aBLCAgkpY2BfQRTAw3IR9QXPKABEjBjbPdgG",
"aBLCAgkpyUX8ElTkFtYHuYofSpOCMPIiTzcB",
"aBLCAgkQxaZB0TUTAq2LhcKrzU9bUxz9hti2",
"aBLCAgkRbG7sIKifS8jZtkBnKWgoibmU7gWz",
"aBLCAgkrdtO6t0z16u6c8M8J4SnfsEJk2Lrt",
"aBLCAgksHYCp92Lj3t4utPNSPtSWKN58i8J7",
"aBLCAgkskMW7sWuEO2V032Gb3ePT3V4C2nop",
"aBLCAgkSN5e8tnQzeseOXGenSLaeWHupYvgj",
"aBLCAgkSTH0E2I9k2zZuk6yiVuJehnw47nT7",
"aBLCAgksUSUVw8vo2GCz4oIkZrOqEddV5aDz",
"aBLCAgktlCxYQnF0sEv68lO4WUiCx784N7uU",
"aBLCAgktrFIze0cwLzs2P3YccZyY5Yde2OHw",
"aBLCAgkTuEziHd9F9wvZ9Ua7IQPcNFHHOZMG",
"aBLCAgku2YcEIEfLuBEx0UPuepqvhCE7hgIM",
"aBLCAgkuGPRnFK6Cz5PV6I2L1YrcIhCHHFvF",
"aBLCAgkUJ7mVHlDd0FccF8Fwn4PriZsGagLu",
"aBLCAgkuNECQJ9bqklHzl8inPCd8Y1X8MSgx",
"aBLCAgkuSpZ8QtrsbUjjCR4FBX7r48iq6ds3",
"aBLCAgkUZZJBmi4199iY9qo8rR3jnsfrsrfr",
"aBLCAgkv3Mfvm0ZEIuDlbtoNwftwtHvCEH89",
"aBLCAgkVc9uVnA4DC6YSfDzF6uTuqo2bpRhK",
"aBLCAgkvdicCL2oYjELksLAQWW6gv6iy2FRc",
"aBLCAgkVmC8fPu10UWCf1x0uhdDpZqr3MT5E",
"aBLCAgkvnbbxIXXJXVJjjWa92Bbf3TQoe6Oq",
"aBLCAgkVPjOiP9pmxI5brV8U0tsFOnTfsD3u",
"aBLCAgkvwWMsL4pmTwwKPW16L8hb8OlbAJOI",
"aBLCAgkWcjceaDIV8ewmaBln9nps9snxXeXQ",
"aBLCAgkWnFZYDJXdZi8ivu18pLkWA7Y88y1S",
"aBLCAgkWsdQHAFKKqlwUk6tU7ua4GCo18tCF",
"aBLCAgkWU3jRVgpD8y4JwFWFR2SNjNeXgmRo",
"aBLCAgkx189LuUzpTRABuc8zOXG9bA8Xwg0q",
"aBLCAgkxLlygnZXwt8Jz9PwKvuJdd20xcdY8",
"aBLCAgkxTRR5DLrbuBzJvphychKaVLExPhOW",
"aBLCAgkxwRfcYzlLqQ31jFUtvGjOmLHPlvFM",
"aBLCAgkyGJxsOufwYoyZi82TFuTRm64wyOXn",
"aBLCAgkyMoqILZy9VvC9k8cfIoQs8K5u5u84",
"aBLCAgkYoJCa9wGJCGpuGa85WrTxWg16G0kJ",
"aBLCAgkYXOy2SSmlkjxiyOYRP8GxKFqdhjSD",
"aBLCAgkzp8JCB7xAWHGAgIGJ1EgquQv4M1MF",
"aBLCAgkzQCuyI6pIZ69PwAcIPG8byjy0Og98",
"Ag0hEVU4nTCE9qb7D8czumjJTK7R9P9C1NmJ",
"Ag0hEVU8COP9fa9m8Zt3CUrBYp8aw7V8sV7E",
"Ag0hEVUbqvI9YtxZYn52f8DHOYIvPAjL5i2g",
"Ag0hEVUbUV6628SFTRDPciFCChVRfqe0MeDv",
"Ag0hEVUcUeaier86XaA5M0PHCplmgvcL8cVg",
"Ag0hEVUjLEr8MrViyyD7cDSD8F1qyNqNvTLV",
"Ag0hEVUlCo2qVF85buoo8VDPRnWSyoQRU6Eq",
"Ag0hEVUnyLoEjlKxnJtk6IRJkvyUeaOASuLN",
"Ag0hEVUop8LBtGQJvv5LHqolNVRanZzcyAD8",
"Ag0hEVUp9PXcarW2iW8YFg9n8cVZ25bUEUF8",
"Ag0hEVUPGeHQFC5TPGJIwfxKzvpF4RpTIcmk",
"Ag0hEVUPyd0bUKWqrwTYe4fDXQQO2D92Wv0w",
"Ag0hEVUqiIyZ9KhJYJRlihx6vEVbhpEbxpTg",
}


TM.s() ;
tl,tb = 0,0
for line in io.lines("all-data.txt") do
    for   k,searchStr in pairs(searchTab) do
          tl = tl + 1 ;
          tb = tb + #line ;
          if  string.find(line,searchStr) then local lineAsHexTab = {} ;
              for i = 1,#line  do lineAsHexTab[i] = string.format("%02X",string.byte(line,i)) ; end ;
              local lineAsHex = table.concat(lineAsHexTab,"") ;
              print(lineAsHex) ;
          end ;
    end
end
print(tl,tb)
TM.m()


searchInputFile = "ATTMO-15164-input.txt"
searchTab = {}
searchCount = 0
for line in io.lines(searchInputFile) do
    searchCount = searchCount + 1
    searchTab[#searchTab+1] = line:sub(1,#line-1)
    if searchCount >= 200 then
    end

end


for line in io.lines(searchInputFile) do
    for   k,searchStr in pairs(searchTab) do
          tl = tl + 1 ;
          tb = tb + #line ;
          if  string.find(line,searchStr) then local lineAsHexTab = {} ;
              for i = 1,#line  do lineAsHexTab[i] = string.format("%02X",string.byte(line,i)) ; end ;
              local lineAsHex = table.concat(lineAsHexTab,"") ;
              print(lineAsHex) ;
          end ;
    end
end


--]]


zhoutilsLoaded = true


-- Extensions to the math,string,table
module ("table",  package.seeall)

function  str_max_len(t,key,includeNumeric,includeAll)

    local tType, str_max_len = type(t), 0

    if      ( tType == "table" )
    then
            for k,v in pairs(t) do
                if      not key
                or      (  type(key) == type(k)  and  key == k  )
                then
                        local    vType =  type(v)

                        if       vType == "string"  and  #v > str_max_len
                        then     str_max_len = #v

                        elseif   (   ( includeNumeric  and  vType == "number" ) or ( includeAll      and  vType ~= "table" )   )
                        and      #tostring(v) > str_max_len
                        then     str_max_len = #tostring(v)

                        elseif   vType == "table"
                        then     local ret_line_width = table.str_max_len(v,includeNumeric,includeAll) ; if ret_line_width > str_max_len then str_max_len = ret_line_width ; end
                        end
                end
            end

    elseif  includeAll or tType == "string" or ( includeNumeric and tType == "number" ) then return #tostring(t) or 0
    else    return 0
    end

    return str_max_len

end

--[[
    aTab = {} ; for i = 1,1000 do for s = 1,math.random(1,256) do aTab[i] = (tostring(aTab[i] or "") or "")..string.char(math.random(65,92)) ; end ; end
    print( table.str_max_len(aTab) )
    testFunc( 1000, function() table.str_max_len(aTab)  ; end )
    aTab = {} ; for j = 1,10 do local group = string.char(math.random(65,92))..string.char(math.random(65,92))..string.char(math.random(65,92)) ; aTab[group] = {} ; for i = 1,1000 do for s = 1,math.random(1,256) do aTab[group][i] = (tostring(aTab[group][i] or "") or "")..string.char(math.random(65,92)) ; end ; end ; end
--]]

------------------------------------------------------------------------------------------------------------

module ("math",   package.seeall)
module ("string", package.seeall)
-- if timer then module("timer", package.seeall) ; end
-- module ("table",  package.seeall)

--[[
    For updating all my locations of this script:
    XCOPY  /Y  "\\192.168.2.77\c\Program Files (x86)\Steam\steamapps\common\Grand Theft Auto V\GTALua\internal\modules\zhoUtils.lua"  "c:\web_home\"
    XCOPY  /Y  "\\192.168.2.77\c\Program Files (x86)\Steam\steamapps\common\Grand Theft Auto V\GTALua\internal\modules\zhoUtils.lua"  "C:\Program Files\lua\5.2\lua\"
    TYPE    "\\192.168.2.77\c\Program Files (x86)\Steam\steamapps\common\Grand Theft Auto V\GTALua\internal\modules\zhoUtils.lua" | ssh owner@jake tee ./svn/repo_zhoul/zhoUtils.lua

--]]