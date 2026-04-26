local T={
Req={
"cloneref","gethui",
"readfile","writefile","appendfile",
"delfile","makefolder","isfile",
"isfolder","listfiles","dofile",
"rconsoleprint","rconsolesettitle",
"rconsoleinput","rconsoleclear",
"setclipboard","setfpscap",
"lz4compress","lz4decompress"
},
Safe={
cloneref=function(v)return v end,
gethui=function()return game.CoreGui end,
dofile=function(p)
    if readfile then
        return loadstring(readfile(p))()
    end
end,
setfpscap=function()end,
setclipboard=function()end,
rconsoleprint=function()end,
rconsolesettitle=function()end,
rconsoleinput=function()return "" end,
rconsoleclear=function()end
},
Missing={},
Replaced={}
}

local env=getgenv()

for _,f in ipairs(T.Req) do
    if not env[f] then
        if T.Safe[f] then
            env[f]=T.Safe[f]
            table.insert(T.Replaced,f)
        else
            table.insert(T.Missing,f)
        end
    end
end

local msg=""

if #T.Missing>0 then
    msg=msg.."Missing: "..table.concat(T.Missing,", ")
end

if #T.Replaced>0 then
    if msg~="" then msg=msg.."\n" end
    msg=msg.."Replaced: "..table.concat(T.Replaced,", ")
end

if msg~="" then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title="Env Check",
            Text=msg,
            Duration=8
        })
    end)
end

return {
Missing=T.Missing,
Replaced=T.Replaced
}
