;=============================================================
; deposito.asm
; Sistema Bancario ASM
; Módulo de Depósitos
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
; Prototipos externos
;=============================================================

EXTERN DepositarDinero:PROC
EXTERN ObtenerSaldo:PROC


;=============================================================
; IDs del diálogo
;=============================================================

IDC_MONTO       EQU 2001
IDC_DEPOSITAR   EQU 2002
IDC_CANCELAR    EQU 2003


;=============================================================
; Datos
;=============================================================

.data

TituloDeposito db "Deposito Bancario",0

MsgMontoError db "Ingrese un monto valido.",0

MsgExito db "Deposito realizado correctamente.",0

MsgSaldo db "Saldo actualizado.",0


BufferMonto db 32 dup(0)

Monto DWORD 0


;=============================================================
; Variables sin inicializar
;=============================================================

.data?

hDeposito HWND ?


;=============================================================
; Código
;=============================================================

.code


;=============================================================
; Dialogo Deposito
;=============================================================

DepositoProc PROC hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM


    mov eax,uMsg


;-------------------------------------------------------------
; Inicializar ventana
;-------------------------------------------------------------

    .IF eax == WM_INITDIALOG


        mov hDeposito,hWnd


        invoke SetWindowText,\
                hWnd,\
                ADDR TituloDeposito


        mov eax,TRUE
        ret



;-------------------------------------------------------------
; Botones
;-------------------------------------------------------------

    .ELSEIF eax == WM_COMMAND


        mov eax,wParam

        and eax,0FFFFh



;-------------------------------------------------------------
; Botón Depositar
;-------------------------------------------------------------

        .IF eax == IDC_DEPOSITAR



            ;---------------------------------------------
            ; Obtener monto escrito
            ;---------------------------------------------


            invoke GetDlgItemText,\
                    hWnd,\
                    IDC_MONTO,\
                    ADDR BufferMonto,\
                    SIZEOF BufferMonto



            ;---------------------------------------------
            ; Convertir texto a número
            ;---------------------------------------------


            invoke atodw,\
                    ADDR BufferMonto


            mov Monto,eax



            ;---------------------------------------------
            ; Validar monto
            ;---------------------------------------------


            cmp eax,0

            je ErrorMonto



            ;---------------------------------------------
            ; Ejecutar depósito
            ;---------------------------------------------


            invoke DepositarDinero,\
                    Monto



            cmp eax,TRUE

            jne ErrorMonto



            invoke MessageBox,\
                    hWnd,\
                    ADDR MsgExito,\
                    ADDR TituloDeposito,\
                    MB_OK or MB_ICONINFORMATION



            invoke EndDialog,\
                    hWnd,\
                    TRUE


            jmp FinDeposito



;-------------------------------------------------------------
; Error
;-------------------------------------------------------------

ErrorMonto:


            invoke MessageBox,\
                    hWnd,\
                    ADDR MsgMontoError,\
                    ADDR TituloDeposito,\
                    MB_OK or MB_ICONERROR



            jmp FinDeposito




;-------------------------------------------------------------
; Cancelar
;-------------------------------------------------------------

        .ELSEIF eax == IDC_CANCELAR


            invoke EndDialog,\
                    hWnd,\
                    FALSE


        .ENDIF



FinDeposito:


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


DepositoProc ENDP



END