;=============================================================
; login.asm
; Sistema Bancario ASM
; Módulo de Inicio de Sesión
; Autor: Isai Reyes Peña
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

EXTERN BuscarCuenta:PROC
EXTERN ValidarPIN:PROC
EXTERN MostrarMenu:PROC

;=============================================================
; IDs de controles
;=============================================================

IDC_USUARIO    EQU 1001
IDC_PIN        EQU 1002

IDC_LOGIN      EQU 1003
IDC_CREAR      EQU 1004
IDC_SALIR      EQU 1005

;=============================================================
; Variables
;=============================================================

.data

TituloLogin db "Sistema Bancario",0

MsgError db "Usuario o PIN incorrecto.",0

MsgVacio db "Debe completar todos los campos.",0

UsuarioIngresado db 32 dup(0)

PinIngresado db 16 dup(0)

CuentaActual dd 0

Resultado dd 0

;=============================================================
; Variables sin inicializar
;=============================================================

.data?

hLogin HWND ?

dwBytes DWORD ?

.code


;=============================================================
; Procedimiento del cuadro de diálogo de Login
;=============================================================

LoginProc PROC hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

    ;---------------------------------------------------------
    ; Guardar el manejador de la ventana
    ;---------------------------------------------------------

    mov eax, hWnd
    mov hLogin, eax

    ;---------------------------------------------------------
    ; Procesar mensaje recibido
    ;---------------------------------------------------------

    mov eax, uMsg

    .IF eax == WM_INITDIALOG

        ;---------------------------------------------
        ; Inicialización del formulario
        ;---------------------------------------------

        invoke SetWindowText, hWnd, ADDR TituloLogin

        invoke SetDlgItemText, hWnd, IDC_USUARIO, ADDR UsuarioIngresado
        invoke SetDlgItemText, hWnd, IDC_PIN, ADDR PinIngresado

        mov eax, TRUE
        ret

    .ELSEIF eax == WM_COMMAND

        ;---------------------------------------------
        ; Obtener el ID del control
        ;---------------------------------------------

        mov eax, wParam
        and eax, 0FFFFh

        .IF eax == IDC_LOGIN

                    .IF eax == IDC_LOGIN

            ;-------------------------------------------------
            ; Limpiar buffers
            ;-------------------------------------------------

            invoke RtlZeroMemory, ADDR UsuarioIngresado, SIZEOF UsuarioIngresado
            invoke RtlZeroMemory, ADDR PinIngresado, SIZEOF PinIngresado

            ;-------------------------------------------------
            ; Leer Usuario
            ;-------------------------------------------------

            invoke GetDlgItemText,\
                    hWnd,\
                    IDC_USUARIO,\
                    ADDR UsuarioIngresado,\
                    SIZEOF UsuarioIngresado

            ;-------------------------------------------------
            ; Leer PIN
            ;-------------------------------------------------

            invoke GetDlgItemText,\
                    hWnd,\
                    IDC_PIN,\
                    ADDR PinIngresado,\
                    SIZEOF PinIngresado

            ;-------------------------------------------------
            ; Validar Usuario vacío
            ;-------------------------------------------------

            mov al, UsuarioIngresado
            cmp al, 0
            je CamposVacios

            ;-------------------------------------------------
            ; Validar PIN vacío
            ;-------------------------------------------------

            mov al, PinIngresado
            cmp al, 0
            je CamposVacios

            ;-------------------------------------------------
            ; Continuará en la Parte 4
            ;-------------------------------------------------

            jmp ValidarLogin

CamposVacios:

            invoke MessageBox,\
                    hWnd,\
                    ADDR MsgVacio,\
                    ADDR TituloLogin,\
                    MB_OK or MB_ICONWARNING

            jmp FinLogin

ValidarLogin:

            ValidarLogin:

            ;-------------------------------------------------
            ; Buscar el usuario en banco.dat
            ;-------------------------------------------------

            invoke BuscarCuenta, ADDR UsuarioIngresado

            mov CuentaActual, eax

            ;-------------------------------------------------
            ; ¿Existe la cuenta?
            ;-------------------------------------------------

            cmp eax, 0
            je LoginIncorrecto

            ;-------------------------------------------------
            ; Validar el PIN
            ;-------------------------------------------------

            invoke ValidarPIN,\
                    CuentaActual,\
                    ADDR PinIngresado

            cmp eax, TRUE
            jne LoginIncorrecto

            ;-------------------------------------------------
            ; Login correcto
            ;-------------------------------------------------

            invoke MessageBox,\
                    hWnd,\
                    CSTR("Bienvenido al Sistema Bancario."),\
                    ADDR TituloLogin,\
                    MB_OK or MB_ICONINFORMATION

            ; Abrir menú principal
            invoke MostrarMenu

            ; Cerrar ventana de Login
            invoke EndDialog, hWnd, 1

            jmp FinLogin

;---------------------------------------------------------
; Usuario o PIN incorrectos
;---------------------------------------------------------

LoginIncorrecto:

            invoke MessageBox,\
                    hWnd,\
                    ADDR MsgError,\
                    ADDR TituloLogin,\
                    MB_OK or MB_ICONERROR

            ; Limpiar el PIN
            invoke SetDlgItemText,\
                    hWnd,\
                    IDC_PIN,\
                    CSTR("")

            ; Colocar el cursor nuevamente en el PIN
            invoke GetDlgItem,\
                    hWnd,\
                    IDC_PIN

            invoke SetFocus,eax

            jmp FinLogin
            ; del usuario y PIN (Parte 4)

FinLogin:
            ; (Se implementará en la Parte 5)

        .ELSEIF eax == IDC_CREAR

            ; Botón Crear Cuenta
            ; (Se implementará en la Parte 6)

        .ELSEIF eax == IDC_SALIR

            ; Botón Salir
            invoke EndDialog, hWnd, 0

        .ENDIF

        mov eax, TRUE
        ret

    .ELSEIF eax == WM_CLOSE

        ;---------------------------------------------
        ; Cerrar ventana
        ;---------------------------------------------

        invoke EndDialog, hWnd, 0

        mov eax, TRUE
        ret

    .ENDIF

    ;---------------------------------------------------------
    ; Mensaje no procesado
    ;---------------------------------------------------------

    mov eax, FALSE
    ret

LoginProc ENDP

;=============================================================
; ProcesarInicioSesion
; Lee Usuario y PIN y valida el acceso
;=============================================================

ProcesarInicioSesion PROC USES ebx

    ;-----------------------------------------
    ; Limpiar buffers
    ;-----------------------------------------

    invoke RtlZeroMemory,\
            ADDR UsuarioIngresado,\
            SIZEOF UsuarioIngresado

    invoke RtlZeroMemory,\
            ADDR PinIngresado,\
            SIZEOF PinIngresado

    ;-----------------------------------------
    ; Leer Usuario
    ;-----------------------------------------

    invoke GetDlgItemText,\
            hLogin,\
            IDC_USUARIO,\
            ADDR UsuarioIngresado,\
            SIZEOF UsuarioIngresado

    ;-----------------------------------------
    ; Leer PIN
    ;-----------------------------------------

    invoke GetDlgItemText,\
            hLogin,\
            IDC_PIN,\
            ADDR PinIngresado,\
            SIZEOF PinIngresado

    ;-----------------------------------------
    ; ¿Usuario vacío?
    ;-----------------------------------------

    cmp BYTE PTR UsuarioIngresado,0
    je DatosInvalidos

    ;-----------------------------------------
    ; ¿PIN vacío?
    ;-----------------------------------------

    cmp BYTE PTR PinIngresado,0
    je DatosInvalidos

    ;-----------------------------------------
    ; Buscar cuenta
    ;-----------------------------------------

    invoke BuscarCuenta,\
            ADDR UsuarioIngresado

    mov CuentaActual,eax

    cmp eax,0
    je LoginIncorrecto

    ;-----------------------------------------
    ; Validar PIN
    ;-----------------------------------------

    invoke ValidarPIN,\
            CuentaActual,\
            ADDR PinIngresado

    cmp eax,TRUE
    jne LoginIncorrecto

    ;-----------------------------------------
    ; Login correcto
    ;-----------------------------------------

    invoke MessageBox,\
            hLogin,\
            ADDR MsgBienvenido,\
            ADDR TituloLogin,\
            MB_OK or MB_ICONINFORMATION

    invoke MostrarMenu

    invoke EndDialog,\
            hLogin,\
            IDOK

    mov eax,TRUE
    ret

;-----------------------------------------
; Campos vacíos
;-----------------------------------------

DatosInvalidos:

    invoke MessageBox,\
            hLogin,\
            ADDR MsgVacio,\
            ADDR TituloLogin,\
            MB_OK or MB_ICONWARNING

    mov eax,FALSE
    ret

;-----------------------------------------
; Login incorrecto
;-----------------------------------------

LoginIncorrecto:

    invoke MessageBox,\
            hLogin,\
            ADDR MsgError,\
            ADDR TituloLogin,\
            MB_OK or MB_ICONERROR

    invoke SetDlgItemText,\
            hLogin,\
            IDC_PIN,\
            ADDR CadenaVacia

    invoke GetDlgItem,\
            hLogin,\
            IDC_PIN

    invoke SetFocus,eax

    mov eax,FALSE
    ret

ProcesarInicioSesion ENDP