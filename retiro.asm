;=============================================================
; retiro.asm
; Sistema Bancario ASM
; Módulo de Retiros
; MASM32 + Win32 API
;=============================================================


.386
.model flat, stdcall
option casemap:none


;=============================================================
; Librerías
;=============================================================

include windows.inc
include kernel32.inc
include user32.inc

includelib kernel32.lib
includelib user32.lib



;=============================================================
; Funciones externas
;=============================================================

EXTERN RetirarDinero:PROC
EXTERN GuardarMovimiento:PROC



;=============================================================
; IDs Dialogo
;=============================================================

IDC_MONTO_RETIRO     EQU 4001
IDC_RETIRAR          EQU 4002
IDC_CANCELAR_RETIRO  EQU 4003



;=============================================================
; Datos
;=============================================================

.data


TituloRetiro db "Retiro Bancario",0


MsgMontoError db "Monto invalido.",0

MsgSaldoError db "Saldo insuficiente.",0

MsgExito db "Retiro realizado correctamente.",0


MovimientoRetiro db "RETIRO",0


BufferMonto db 32 dup(0)


MontoRetiro DWORD 0



;=============================================================
; Variables sin inicializar
;=============================================================

.data?


hRetiro HWND ?



;=============================================================
; Código
;=============================================================

.code



;=============================================================
; RetiroProc
; Procedimiento del dialogo
;=============================================================


RetiroProc PROC hWnd:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM


    mov eax,uMsg



;-------------------------------------------------------------
; Inicializar
;-------------------------------------------------------------

    .IF eax == WM_INITDIALOG


        mov hRetiro,hWnd


        invoke SetWindowText,\
                hWnd,\
                ADDR TituloRetiro


        mov eax,TRUE
        ret



;-------------------------------------------------------------
; Botones
;-------------------------------------------------------------

    .ELSEIF eax == WM_COMMAND


        mov eax,wParam

        and eax,0FFFFh



;-------------------------------------------------------------
; Botón retirar
;-------------------------------------------------------------

        .IF eax == IDC_RETIRAR



            ;---------------------------------------------
            ; Obtener monto
            ;---------------------------------------------


            invoke GetDlgItemText,\
                    hWnd,\
                    IDC_MONTO_RETIRO,\
                    ADDR BufferMonto,\
                    SIZEOF BufferMonto



            ;---------------------------------------------
            ; Convertir texto a número
            ;---------------------------------------------


            invoke atodw,\
                    ADDR BufferMonto


            mov MontoRetiro,eax



            cmp eax,0

            je ErrorMonto



            ;---------------------------------------------
            ; Ejecutar retiro
            ;---------------------------------------------


            invoke RetirarDinero,\
                    MontoRetiro



            cmp eax,TRUE

            jne ErrorSaldo



            ;---------------------------------------------
            ; Guardar historial
            ;---------------------------------------------


            invoke GuardarMovimiento,\
                    ADDR MovimientoRetiro,\
                    MontoRetiro



            invoke MessageBox,\
                    hWnd,\
                    ADDR MsgExito,\
                    ADDR TituloRetiro,\
                    MB_OK or MB_ICONINFORMATION



            invoke EndDialog,\
                    hWnd,\
                    TRUE



            jmp FinRetiro




;-------------------------------------------------------------
; Error monto
;-------------------------------------------------------------

ErrorMonto:


            invoke MessageBox,\
                    hWnd,\
                    ADDR MsgMontoError,\
                    ADDR TituloRetiro,\
                    MB_OK or MB_ICONWARNING


            jmp FinRetiro



;-------------------------------------------------------------
; Saldo insuficiente
;-------------------------------------------------------------

ErrorSaldo:


            invoke MessageBox,\
                    hWnd,\
                    ADDR MsgSaldoError,\
                    ADDR TituloRetiro,\
                    MB_OK or MB_ICONERROR


            jmp FinRetiro



;-------------------------------------------------------------
; Cancelar
;-------------------------------------------------------------

        .ELSEIF eax == IDC_CANCELAR_RETIRO


            invoke EndDialog,\
                    hWnd,\
                    FALSE



        .ENDIF



FinRetiro:


        mov eax,TRUE
        ret




;-------------------------------------------------------------
; Cerrar ventana
;-------------------------------------------------------------

    .ELSEIF eax == WM_CLOSE


        invoke EndDialog,\
                hWnd,\
                FALSE


        mov eax,TRUE
        ret


    .ENDIF



    mov eax,FALSE

    ret


RetiroProc ENDP



END