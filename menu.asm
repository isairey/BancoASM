;=============================================================
; menu.asm
; Sistema Bancario ASM
; Módulo del Menú Principal
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

EXTERN ObtenerSaldo:PROC
EXTERN DepositarDinero:PROC
EXTERN RetirarDinero:PROC
EXTERN TransferirDinero:PROC
EXTERN MostrarHistorial:PROC
EXTERN GuardarBanco:PROC

;=============================================================
; Variables Inicializadas
;=============================================================

.data

TituloMenu db "Sistema Bancario",0

MsgCerrar db "¿Desea cerrar la sesión?",0

TituloCerrar db "Cerrar Sesión",0

TextoSaldo db "Saldo Actual: $",0

FormatoSaldo db "%u",0

CadenaVacia db 0

;=============================================================
; Variables No Inicializadas
;=============================================================

.data?

hMenu HWND ?

SaldoActual DWORD ?

BufferSaldo db 32 dup(?)

CuentaActual DWORD ?

.code


