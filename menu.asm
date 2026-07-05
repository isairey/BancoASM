;=============================================================
; menu.asm
; Sistema Bancario ASM
; Módulo del Menú Principal
; PARTE 1/10
;=============================================================

.386
.model flat, stdcall
option casemap:none

;=============================================================
; Librerías
;=============================================================

include windows.inc
include user32.inc
include kernel32.inc
include gdi32.inc

includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib

include recursos.inc

;=============================================================
; Funciones externas
;=============================================================

EXTERN ObtenerSaldo:PROC
EXTERN DepositarDinero:PROC
EXTERN RetirarDinero:PROC
EXTERN TransferirDinero:PROC
EXTERN MostrarHistorial:PROC
EXTERN GuardarBanco:PROC

;=============================================================
; Variables de datos
;=============================================================

.data

TituloMenu db "Sistema Bancario",0

MsgCerrar db "¿Desea cerrar la sesión?",0
TituloCerrar db "Cerrar Sesión",0

TextoSaldo db "Saldo Actual: ",0

FormatoNumero db "%u",0

CadenaVacia db 0

;=============================================================
; Variables sin inicializar
;=============================================================

.data?

hMenu HWND ?

SaldoActual DWORD ?

CuentaActual DWORD ?

BufferNumero db 32 dup(?)
BufferSaldoFinal db 64 dup(?)

.code


;=============================================================
; PARTE 2/10 - Procedimiento principal del menú
;=============================================================

MenuProc PROC hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

    ;---------------------------------------------------------
    ; Guardar handle de la ventana
    ;---------------------------------------------------------

    mov eax, hWnd
    mov hMenu, eax

    ;---------------------------------------------------------
    ; Evaluar mensaje
    ;---------------------------------------------------------

    mov eax, uMsg

    .IF eax == WM_INITDIALOG

        ;---------------------------------------------
        ; Inicialización del menú
        ;---------------------------------------------

        invoke SetWindowText, hWnd, ADDR TituloMenu
        invoke ShowInitialBalance
        mov eax, TRUE
        ret

    .ELSEIF eax == WM_COMMAND

        ;---------------------------------------------
        ; Obtener ID del botón presionado
        ;---------------------------------------------

        mov eax, wParam
        and eax, 0FFFFh

        ;=================================================
        ; BOTÓN CONSULTAR SALDO
        ;=================================================

        .IF eax == IDC_CONSULTAR

           ;=============================================================
; PARTE 4/10 - Consultar saldo (actualización manual)
;=============================================================

;-------------------------------------------------------------
; BOTÓN: CONSULTAR SALDO
;-------------------------------------------------------------


    ;---------------------------------------------------------
    ; Refrescar saldo desde el sistema de cuentas
    ;---------------------------------------------------------

    invoke ObtenerSaldo, CuentaActual
    mov SaldoActual, eax

    ;---------------------------------------------------------
    ; Convertir a texto
    ;---------------------------------------------------------

    invoke wsprintf, ADDR BufferNumero, ADDR FormatoNumero, SaldoActual

    ;---------------------------------------------------------
    ; Construir mensaje final
    ;---------------------------------------------------------

    invoke lstrcpy, ADDR BufferSaldoFinal, ADDR TextoSaldo
    invoke lstrcat, ADDR BufferSaldoFinal, ADDR BufferNumero

    ;---------------------------------------------------------
    ; Mostrar en pantalla
    ;---------------------------------------------------------

    invoke SetDlgItemText, hMenu, IDC_SALDOACTUAL, ADDR BufferSaldoFinal

        ;=================================================
        ; BOTÓN DEPOSITAR
        ;=================================================

        .ELSEIF eax == IDC_DEPOSITAR

           ;=============================================================
; PARTE 5/10 - DEPÓSITO
;=============================================================

;-------------------------------------------------------------
; BOTÓN: DEPOSITAR
;-------------------------------------------------------------


    ;---------------------------------------------------------
    ; Llamar al sistema de depósito
    ;---------------------------------------------------------

    invoke DepositarDinero, CuentaActual

    ;---------------------------------------------------------
    ; Actualizar saldo después del depósito
    ;---------------------------------------------------------

    invoke ObtenerSaldo, CuentaActual
    mov SaldoActual, eax

    ;---------------------------------------------------------
    ; Convertir a texto
    ;---------------------------------------------------------

    invoke wsprintf, ADDR BufferNumero, ADDR FormatoNumero, SaldoActual

    ;---------------------------------------------------------
    ; Construir texto final
    ;---------------------------------------------------------

    invoke lstrcpy, ADDR BufferSaldoFinal, ADDR TextoSaldo
    invoke lstrcat, ADDR BufferSaldoFinal, ADDR BufferNumero

    ;---------------------------------------------------------
    ; Mostrar en pantalla
    ;---------------------------------------------------------

    invoke SetDlgItemText, hMenu, IDC_SALDOACTUAL, ADDR BufferSaldoFinal

    ;---------------------------------------------------------
    ; Mensaje de confirmación
    ;---------------------------------------------------------

    invoke MessageBox, hMenu, CSTR("Depósito realizado correctamente."), ADDR TituloMenu, MB_OK or MB_ICONINFORMATION


        ;=================================================
        ; BOTÓN RETIRAR
        ;=================================================

        .ELSEIF eax == IDC_RETIRAR

            ;=============================================================
; PARTE 6/10 - RETIRO
;=============================================================

;-------------------------------------------------------------
; BOTÓN: RETIRAR
;-------------------------------------------------------------



    ;---------------------------------------------------------
    ; Llamar al sistema de retiro
    ;---------------------------------------------------------

    invoke RetirarDinero, CuentaActual

    ;---------------------------------------------------------
    ; Obtener saldo actualizado
    ;---------------------------------------------------------

    invoke ObtenerSaldo, CuentaActual
    mov SaldoActual, eax

    ;---------------------------------------------------------
    ; Convertir a texto
    ;---------------------------------------------------------

    invoke wsprintf, ADDR BufferNumero, ADDR FormatoNumero, SaldoActual

    ;---------------------------------------------------------
    ; Construir texto final
    ;---------------------------------------------------------

    invoke lstrcpy, ADDR BufferSaldoFinal, ADDR TextoSaldo
    invoke lstrcat, ADDR BufferSaldoFinal, ADDR BufferNumero

    ;---------------------------------------------------------
    ; Actualizar interfaz
    ;---------------------------------------------------------

    invoke SetDlgItemText, hMenu, IDC_SALDOACTUAL, ADDR BufferSaldoFinal

    ;---------------------------------------------------------
    ; Mensaje de confirmación
    ;---------------------------------------------------------

    invoke MessageBox, hMenu, CSTR("Retiro realizado correctamente."), ADDR TituloMenu, MB_OK or MB_ICONINFORMATION

;-------------------------------------------------------------
; Validación básica (saldo insuficiente)
;-------------------------------------------------------------

    cmp SaldoActual, 0
    jge FinRetiro

    invoke MessageBox, hMenu, CSTR("Saldo insuficiente."), ADDR TituloMenu, MB_OK or MB_ICONERROR

FinRetiro:

        ;=================================================
        ; BOTÓN TRANSFERIR
        ;=================================================

        .ELSEIF eax == IDC_TRANSFERIR

            ; Parte 7

        ;=================================================
        ; BOTÓN HISTORIAL
        ;=================================================

        .ELSEIF eax == IDC_HISTORIAL

            ; Parte 8

        ;=================================================
        ; BOTÓN CERRAR SESIÓN
        ;=================================================

        .ELSEIF eax == IDC_CERRARSESION

            invoke MessageBox, hWnd, ADDR MsgCerrar, ADDR TituloCerrar, MB_YESNO or MB_ICONQUESTION

            cmp eax, IDYES
            jne FinMenu

            invoke EndDialog, hWnd, 0

        .ENDIF

        mov eax, TRUE
        ret

    .ELSEIF eax == WM_CLOSE

        ;---------------------------------------------
        ; Cierre con X
        ;---------------------------------------------

        invoke MessageBox, hWnd, ADDR MsgCerrar, ADDR TituloCerrar, MB_YESNO or MB_ICONQUESTION

        cmp eax, IDYES
        jne CancelarCierre

        invoke EndDialog, hWnd, 0
        jmp FinMenu

CancelarCierre:

        mov eax, TRUE
        ret

    .ENDIF

    ;---------------------------------------------------------
    ; Mensaje no procesado
    ;---------------------------------------------------------

    mov eax, FALSE
    ret

FinMenu:

    mov eax, TRUE
    ret

MenuProc ENDP


;=============================================================
; PARTE 3/10 - Mostrar saldo al abrir el menú
;=============================================================

ShowInitialBalance PROC

    ;---------------------------------------------------------
    ; Obtener saldo desde el sistema de cuentas
    ;---------------------------------------------------------

    invoke ObtenerSaldo, CuentaActual
    mov SaldoActual, eax

    ;---------------------------------------------------------
    ; Convertir número a texto
    ;---------------------------------------------------------

    invoke wsprintf, ADDR BufferNumero, ADDR FormatoNumero, SaldoActual

    ;---------------------------------------------------------
    ; Construir texto final: "Saldo Actual: XXXXX"
    ;---------------------------------------------------------

    invoke lstrcpy, ADDR BufferSaldoFinal, ADDR TextoSaldo
    invoke lstrcat, ADDR BufferSaldoFinal, ADDR BufferNumero

    ;---------------------------------------------------------
    ; Mostrar en la interfaz (Label del menú)
    ;---------------------------------------------------------

    invoke SetDlgItemText, hMenu, IDC_SALDOACTUAL, ADDR BufferSaldoFinal

    ret

ShowInitialBalance ENDP

