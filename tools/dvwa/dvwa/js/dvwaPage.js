/* popup de ajuda */

function popUp(URL) {
    day = new Date();

    id = day.getTime();

    window.open(URL, '" + id + "', 'toolbar=0,scrollbars=1,location=0,statusbar=0,menubar=0,resizable=1,width=800,height=300,left=540,top=250');

    // eval("page" + id + " = window.open(URL, '" + id + "', 'toolbar=0,scrollbars=1,location=0,statusbar=0,menubar=0,resizable=1,width=800,height=300,left=540,top=250');");
}

/* validação de forma */

function validate_required(field, alerttxt) {
    with (field) {
        if (value == null || value == "") {
            alert(alerttxt);

            return false;
        } else {
            return true;
        }
    }
}

function validateGuestbookForm(thisform) {
    with (thisform) {
        // form de guestbook
        if (validate_required(txtName, "o nome não pode ser vazio.") == false) {
            txtName.focus();

            return false;
        }

        if (validate_required(mtxMessage, "a mensagem não pode ser vazia.") == false) {
            mtxMessage.focus();

            return false;
        }
    }
}

function confirmClearGuestbook() {
    return confirm("você tem certeza que deseja limpar o guestbook?");
}