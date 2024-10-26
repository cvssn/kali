name = "360passivedns"
type = "api"

function start()
    set_rate_limit(1)
end

function check()
    local c
    local cfg = datasrc_config()

    if (cfg ~= nil) then
        c = cfg.credentials
    end

    if (c ~= nil and c.key ~= nil and c.key ~= "") then
        return true
    end

    return false
end

function vertical(ctx, domain)
    local c

    local cfg = datasrc_config()
    if (cfg ~= nil) then
        c = cfg.credentials
    end

    if (c == nil or c.key == nil or c.key == "") then
        return
    end

    scrape(ctx, {
        ['url']=build_url(domain),
        
        ['header']={
            ['Accept']="application/json",
            ['X-Authtoken']=c.key,
        },
    })
end

function build_url(domain)
    return "https://api.passivedns.cn/flint/rrset/*." .. domain .. "/?source=ALL&batch=5000"
end