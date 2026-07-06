;=============================================================
; transferencia.asm
; Sistema Bancario ASM
; Módulo de Transferencias
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

EXTERN TransferirDinero:PROC
EXTERN GuardarMovimiento:PROC



;=============================================================
; IDs Dialogo
;=============================================================

IDC_CUENTA_DESTINO       EQU 5001
IDC_MONTO_TRANSFERENCIA  EQU 5002

IDC_TRANSFERIR           EQU 5003
IDC_CANCELAR_TRANSFER    EQU 5004



;=============================================================
; Datos
;=============================================================

.data


TituloTransferencia db "Transferencia Bancaria",0


MsgErrorMonto db "Monto invalido.",0

MsgErrorCuenta db "La cuenta destino no existe.",0

MsgErrorSaldo db "Saldo insuficiente.",0

MsgExito db "Transferencia realizada correctamente.",0



MovimientoTransferencia db "TRANSFERENCIA",0



BufferDestino db 32 dup(0)

BufferMonto db 32 dup(0)



MontoTransferencia DWORD 0



;=============================================================
; Variables sin inicializar
;=============================================================

.data?


hTransferencia HWND ?



;=============================================================
; Código
;=============================================================

.code



;=============================================================
; TransferenciaProc
;=============================================================


TransferenciaProc PROC hWnd:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM


    mov eax,uMsg



;-------------------------------------------------------------
; Inicialización
;-------------------------------------------------------------

    .IF eax == WM_INITDIALOG


        mov hTransferencia,hWnd


        invoke SetWindowText,\
                hWnd,\
                ADDR TituloTransferencia


        mov eax,TRUE
        ret



;-------------------------------------------------------------
; Eventos
;-------------------------------------------------------------

    .ELSEIF eax == WM_COMMAND


        mov eax,wParam

        and eax,0FFFFh



;-------------------------------------------------------------
; Botón transferir
;-------------------------------------------------------------

        .IF eax == IDC_TRANSFERIR



            ;---------------------------------------------
            ; Leer cuenta destino
            ;---------------------------------------------


            invoke GetDlgItemText,\
                    hWnd,\
                    IDC_CUENTA_DESTINO,\
                    ADDR BufferDestino,\
                    SIZEOF BufferDestino



            ;---------------------------------------------
            ; Leer monto
            ;---------------------------------------------


            invoke GetDlgItemText,\
                    hWnd,\
                    IDC_MONTO_TRANSFERENCIA,\
                    ADDR BufferMonto,\
                    SIZEOF BufferMonto



            ;---------------------------------------------
            ; Convertir monto
            ;---------------------------------------------


            invoke atodw,\
                    ADDR BufferMonto


            mov MontoTransferencia,eax



            cmp eax,0

            je ErrorMonto



            ;---------------------------------------------
            ; Ejecutar transferencia
            ;
            ; cuenta destino
            ; monto
            ;---------------------------------------------


            invoke TransferirDinero,\
                    MontoTransferencia,\
                    ADDR BufferDestino



            cmp eax,TRUE

            je TransferOk



            ; Si falla puede ser saldo o cuenta


            invoke MessageBox,\
                    hWnd,\
                    ADDR MsgErrorSaldo,\
                    ADDR TituloTransferencia,\
                    MB_OK or MB_ICONERROR


            jmp FinTransferencia




;-------------------------------------------------------------
; Transferencia correcta
;-------------------------------------------------------------

TransferOk:



            invoke GuardarMovimiento,\
                    ADDR MovimientoTransferencia,\
                    MontoTransferencia



            invoke MessageBox,\
                    hWnd,\
                    ADDR MsgExito,\
                    ADDR TituloTransferencia,\
                    MB_OK or MB_ICONINFORMATION



            invoke EndDialog,\
                    hWnd,\
                    TRUE



            jmp FinTransferencia



;-------------------------------------------------------------
; Error monto
;-------------------------------------------------------------

ErrorMonto:


            invoke MessageBox,\
                    hWnd,\
                    ADDR MsgErrorMonto,\
                    ADDR TituloTransferencia,\
                    MB_OK or MB_ICONWARNING


            jmp FinTransferencia



;-------------------------------------------------------------
; Cancelar
;-------------------------------------------------------------

        .ELSEIF eax == IDC_CANCELAR_TRANSFER


            invoke EndDialog,\
                    hWnd,\
                    FALSE



        .ENDIF



FinTransferencia:


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


TransferenciaProc ENDP



END