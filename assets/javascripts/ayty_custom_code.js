/* ##### AYTYCRM - Silvio Fernandes ##### */

// Funcao para ajustar um string
function lpad(originalstr, length, strToPad) {
    while (originalstr.length < length)
        originalstr = strToPad + originalstr;
    return originalstr;
}

// Funcao para ajustar a prioridade dos tickes para salvar depois
function adjustAytyIssuePriorityInList() {
    var arr_label = jQuery('.ayty_issue_priorities_handle')
    var arr_hidden = jQuery('.ayty_issue_priority_id');

    if (arr_label != null) {
        for (var index = 0; index < arr_label.length; ++index) {
            var label = arr_label[index];
            var hidden = arr_hidden[index];
            var newindex = index + 1;
            label.innerHTML = '[ ' + lpad(String(newindex), 2, '0') + ' ]';
            hidden.name = 'issues[priority][' + newindex + ']';
        }
    }
}

/*
 # Funcao para fazer um Toggle em uma DIV que o nome é passado por parametro
 */
function toggleDiv(object) {
    $(object).toggle();
}

/*
 # Funcao para ocultar e mostrar divs sem comentarios
 */
function toggleAytyJournal(nameObject) {
    objects = $(nameObject);
    for (var index = 0; index < objects.length; ++index) {
        toggleDiv(objects[index]);
    }
}
/*
 # Funcao de controle para ocultar e mostrar divs sem comentarios
 */
function controlAytyToggleJournal() {
    toggleAytyJournal('div.ayty-journal-blank');
}

/*
 # Funcao alterar o background e color de um select box
 */
function toggleStyleOfSelect(object) {
    object.style.backgroundColor = object.options[object.selectedIndex].style.backgroundColor;
    object.style.color = object.options[object.selectedIndex].style.color;
}

/*
 # Funcao para bloquear a alteracao de objetos pelo teclado
 */
//if(window.Event) window.captureEvents(Event.KEYDOWN);
function blockKeyboardkeyDown(e) {
    var n = (window.Event) ? e.which : e.keyCode;
    if (n != 9) {
        return false;
    }
}