;=============================================================
; main.asm
; Sistema Bancario ASM
; Punto de entrada de la aplicación
; Autor: Isai Reyes Peña
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

include recursos.inc

;=============================================================
; Prototipos
;=============================================================

LoginProc PROTO :HWND,:UINT,:WPARAM,:LPARAM

;=============================================================
; Variables
;=============================================================

.data?

hInstance HINSTANCE ?

.code

;=============================================================
; Punto de entrada
;=============================================================

start:

    ;-----------------------------------------
    ; Obtener el Handle de la aplicación
    ;-----------------------------------------

    invoke GetModuleHandle, NULL
    mov hInstance, eax

    ;-----------------------------------------
    ; Mostrar el Login
    ;-----------------------------------------

    invoke DialogBoxParam,\
            hInstance,\
            IDD_LOGIN,\
            NULL,\
            ADDR LoginProc,\
            NULL

    ;-----------------------------------------
    ; Finalizar aplicación
    ;-----------------------------------------

    invoke ExitProcess,0

END start