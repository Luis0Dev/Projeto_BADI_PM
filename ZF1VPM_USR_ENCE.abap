METHOD if_ex_workorder_update~before_update.

  DATA: lv_exists TYPE abap_bool,
        ls_header TYPE caufvd.

  " 1. Filtra para garantir que a lógica rode apenas na alteração da ordem
  CHECK sy-tcode = 'IW32'.

  LOOP AT it_header INTO ls_header.

    " 2. Verifica se o status I0046 (ENCE) está INATIVO agora.
    " A função STATUS_CHECK verifica se o status está ativo no buffer/banco.
    CALL FUNCTION 'STATUS_CHECK'
      EXPORTING
        objnr             = ls_header-objnr
        status            = 'I0046'
      EXCEPTIONS
        status_not_active = 1
        OTHERS            = 2.

    " Se sy-subrc = 1, o status ENCE não está ativo (foi anulado pelo usuário na tela)
    IF sy-subrc = 1.

      " 3. Valida se o usuário está na tabela de permissões
      SELECT SINGLE 'X'
        FROM zf1vpm_usr_ence
        INTO @lv_exists
        WHERE bname = @sy-uname.

      IF sy-subrc <> 0.
        " 4. Bloqueia a gravação. O erro no BEFORE_UPDATE interrompe o processo.
        MESSAGE 'Usuário não autorizado para anular ENCE. Verifique a transação ZF1GPM019.' TYPE 'E'.
      ENDIF.

    ENDIF.
  ENDLOOP.

ENDMETHOD.