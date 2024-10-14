// ipassword.h

#ifndef ZIP7_INC_IPASSWORD_H
#define ZIP7_INC_IPASSWORD_H

#include "../Common/MyTypes.h"

#include "IDecl.h"

Z7_PURE_INTERFACES_BEGIN

#define Z7_IFACE_CONSTR_PASSWORD(i, n) \
    Z7_DECL_IFACE_7ZIP(i, 5, n) \
    { Z7_IFACE_COM7_PURE(i) };

/*
como usar o parâmetro de saída (bstr *password):

in:  o chamador deve definir o valor bstr como null (sem string).
     o receptor (no código 7-zip) ignora o valor de entrada armazenado na variável bstr;

out: o receptor reescreve a variável bstr (*password) com novo ponteiro de string alocado.
     o chamador deve liberar a string bstr com a função sysfreestring().
*/

#define Z7_IFACEM_ICryptoGetTextPassword(x) \
    x(CryptoGetTextPassword(BSTR *password))
Z7_IFACE_CONSTR_PASSWORD(ICryptoGetTextPassword, 0x10)


/*
cryptogettextpassword2()

in:
    o chamador deve definir o valor bstr como null (sem string).
    o chamador não é obrigado a definir o valor (*passwordisdefined).

out:
    código de retorno: != s_ok : código de erro
    código de retorno:    s_ok : sucesso

    caso (*passwordisdefined == 1), a variável (*password) contém a string password

    caso (*passwordisdefined == 0), a senha não está definida,
        mas o receptor ainda pode definir (*senha) para alguma string alocada, por exemplo, como uma string vazia.

    o chamador deve liberar a string bstr com a função sysfreestring()
*/

#define Z7_IFACEM_ICryptoGetTextPassword2(x) \
    x(CryptoGetTextPassword2(Int32 *passwordIsDefined, BSTR *password))
Z7_IFACE_CONSTR_PASSWORD(ICryptoGetTextPassword2, 0x11)

Z7_PURE_INTERFACES_END
#endif