#include <nbase.h>

#include "nse_lua.h"
#include "MACLookup.h"
#include "services.h"
#include "protocols.h"

static inline u8 nibble(char hex) {
    return (hex & 0xf) + ((hex & 0x40) ? 9 : 0);
}

static int l_mac2corp (lua_State *L)
{
    size_t len = 0;

    u8 prefix[6] = {0};

    size_t i = 0;
    size_t j = 0;

    const char *buf = luaL_checklstring(L, 1, &len);

    if (len == 6) {
        // opção 1: mac cru de 6 bytes
        lua_pushstring(L, MACPrefix2Corp((u8 *)buf));

        return 1;
    }

    // tentar a string hex
    for (i = 0; i + 1 < len && j < 6; i += 2) {
        if (buf[i] == ':' && i + 2 < len) {
            i++;
        }

        if (isxdigit(buf[i]) && isxdigit(buf[i+1])) {
            prefix[j++] = (nibble(buf[i]) << 4) + nibble(buf[i + 1]);
        }

        else {
            break;
        }
    }

    // exigir exatamente 6 bytes de resultado e usar toda a entrada
    if (j == 6 && i >= len) {
        lua_pushstring(L, MACPrefix2Corp(prefix));

        return 1;
    }

    return luaL_error(L, "era esperado um endereço mac de 6 bytes");
}

static int l_getservbyport (lua_State *L)
{
    const struct nservent *serv = NULL;

    static const u16 proto[] = {IPPROTO_TCP, IPPROTO_UDP, IPPROTO_SCTP};
    static const char * op[] = {"tcp", "udp", "sctp"};

    lua_Integer port = luaL_checkinteger(L, 1);

    int i = luaL_checkoption(L, 2, NULL, op);

    if (port < 0 || port > 0xffff) {
        return luaL_error(L, "número de porto fora de alcance");
    }

    serv = nmap_getservbyport((u16) port, proto[i]);

    if (serv == NULL) {
        lua_pushnil(L);
    }

    else {
        lua_pushstring(L, serv->s_name);
    }

    return 1;
}

static int l_getprotbynum (lua_State *L)
{
    const struct nprotoent *proto = NULL;

    lua_Integer num = luaL_checkinteger(L, 1);

    if (num < 0 || num > 0xff) {
        return luaL_error(L, "número de protocolo fora de alcance");
    }

    proto = nmap_getprotbynum(num);

    if (proto == NULL) {
        lua_pushnil(L);
    }

    else {
        lua_pushstring(L, proto->p_name);
    }

    return 1;
}

static int l_getprotbyname (lua_State *L)
{
    const struct nprotoent *proto = NULL;
    const char *name = luaL_checkstring(L, 1);

    proto = nmap_getprotbyname(name);

    if (proto == NULL) {
        lua_pushnil(L);
    }

    else {
        lua_pushinteger(L, proto->p_proto);
    }

    return 1;
}

LUALIB_API int luaopen_db (lua_State *L)
{
    static const luaL_Reg dblib [] = {
        {"mac2corp", l_mac2corp},
        {"getservbyport", l_getservbyport},
        {"getprotbynum", l_getprotbynum},
        {"getprotbyname", l_getprotbyname},
        
        {NULL, NULL}
    };

    luaL_newlib(L, dblib);

    return 1;
}