;=============================================================
; cuentas.asm
; Sistema Bancario ASM
; Módulo de Gestión de Cuentas
; MASM32 + Win32 API
; Parte 1 de 14
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
; Prototipos
;=============================================================

BuscarCuenta      PROTO :DWORD
ValidarPIN        PROTO :DWORD,:DWORD
ObtenerSaldo      PROTO :DWORD
DepositarDinero   PROTO :DWORD,:DWORD
RetirarDinero     PROTO :DWORD,:DWORD
TransferirDinero  PROTO :DWORD,:DWORD,:DWORD
CrearCuenta       PROTO :DWORD,:DWORD,:DWORD
GuardarBanco      PROTO
CargarBanco       PROTO

AbrirArchivo      PROTO
CerrarArchivo     PROTO

CopiarCadena      PROTO :DWORD,:DWORD
CompararCadena    PROTO :DWORD,:DWORD
LongitudCadena    PROTO :DWORD

NumeroACadena     PROTO :DWORD,:DWORD
CadenaANumero     PROTO :DWORD

;=============================================================
; Constantes
;=============================================================

MAX_USUARIO EQU 32
MAX_PIN     EQU 16
MAX_LINEA   EQU 128
MAX_BUFFER  EQU 8192

;=============================================================
; Estructura de Cuenta
;=============================================================

CUENTA STRUCT

    Usuario    db MAX_USUARIO dup(0)
    PIN        db MAX_PIN dup(0)
    Saldo      dd ?

CUENTA ENDS

;=============================================================
; Variables Inicializadas
;=============================================================

.data

ArchivoBanco db "banco.dat",0

Separador db "|",0

CRLF db 13,10,0

CadenaVacia db 0

;=============================================================
; Buffers
;=============================================================

BufferArchivo db MAX_BUFFER dup(0)

BufferLinea db MAX_LINEA dup(0)

BufferUsuario db MAX_USUARIO dup(0)

BufferPIN db MAX_PIN dup(0)

BufferNumero db 32 dup(0)

;=============================================================
; Variables Globales
;=============================================================

CuentaActual CUENTA <>

IndiceCuenta DWORD 0

SaldoTemporal DWORD 0

BytesLeidos DWORD 0

BytesEscritos DWORD 0

PosicionActual DWORD 0

TamArchivo DWORD 0

hArchivo HANDLE ?

;=============================================================
; Variables sin inicializar
;=============================================================

.data?

CuentaDestino CUENTA ?

CuentaOrigen CUENTA ?

;=============================================================
; Código
;=============================================================

.code

;=============================================================
; PARTE 2/14
; Apertura y cierre de banco.dat
;=============================================================

;-------------------------------------------------------------
; AbrirArchivo
;
; Abre banco.dat para lectura y escritura.
;
; Retorna:
;   EAX = TRUE  -> Archivo abierto
;   EAX = FALSE -> Error
;-------------------------------------------------------------

AbrirArchivo PROC

    invoke CreateFile,\
            ADDR ArchivoBanco,\
            GENERIC_READ or GENERIC_WRITE,\
            FILE_SHARE_READ,\
            NULL,\
            OPEN_ALWAYS,\
            FILE_ATTRIBUTE_NORMAL,\
            NULL

    mov hArchivo,eax

    cmp eax,INVALID_HANDLE_VALUE
    je ErrorAbrir

    mov eax,TRUE
    ret

ErrorAbrir:

    mov eax,FALSE
    ret

AbrirArchivo ENDP


;-------------------------------------------------------------
; CerrarArchivo
;
; Cierra el archivo si está abierto.
;
; Retorna:
;   TRUE
;-------------------------------------------------------------

CerrarArchivo PROC

    cmp hArchivo,INVALID_HANDLE_VALUE
    je FinCerrar

    invoke CloseHandle,hArchivo

    mov hArchivo,INVALID_HANDLE_VALUE

FinCerrar:

    mov eax,TRUE
    ret

CerrarArchivo ENDP


;-------------------------------------------------------------
; ReiniciarBuffers
;
; Limpia todos los buffers utilizados.
;-------------------------------------------------------------

ReiniciarBuffers PROC

    invoke RtlZeroMemory,\
            ADDR BufferArchivo,\
            SIZEOF BufferArchivo

    invoke RtlZeroMemory,\
            ADDR BufferLinea,\
            SIZEOF BufferLinea

    invoke RtlZeroMemory,\
            ADDR BufferUsuario,\
            SIZEOF BufferUsuario

    invoke RtlZeroMemory,\
            ADDR BufferPIN,\
            SIZEOF BufferPIN

    invoke RtlZeroMemory,\
            ADDR BufferNumero,\
            SIZEOF BufferNumero

    mov BytesLeidos,0
    mov BytesEscritos,0
    mov PosicionActual,0
    mov TamArchivo,0

    mov eax,TRUE
    ret

ReiniciarBuffers ENDP


;-------------------------------------------------------------
; ObtenerTamArchivo
;
; Obtiene el tamaño del archivo banco.dat.
;
; Retorna:
;   EAX = tamaño del archivo
;-------------------------------------------------------------

ObtenerTamArchivo PROC

    invoke GetFileSize,\
            hArchivo,\
            NULL

    mov TamArchivo,eax

    mov eax,TamArchivo
    ret

ObtenerTamArchivo ENDP

;=============================================================
; PARTE 3/14
; Lectura del archivo banco.dat
;=============================================================

;-------------------------------------------------------------
; LeerArchivo
;
; Lee completamente banco.dat dentro de BufferArchivo.
;
; Retorna:
;   TRUE  -> Lectura correcta
;   FALSE -> Error
;-------------------------------------------------------------

LeerArchivo PROC

    invoke ReiniciarBuffers

    invoke SetFilePointer,\
            hArchivo,\
            0,\
            NULL,\
            FILE_BEGIN

    invoke ReadFile,\
            hArchivo,\
            ADDR BufferArchivo,\
            SIZEOF BufferArchivo-1,\
            ADDR BytesLeidos,\
            NULL

    cmp eax,FALSE
    je ErrorLectura

    mov esi,OFFSET BufferArchivo
    add esi,BytesLeidos

    mov BYTE PTR [esi],0

    mov eax,TRUE
    ret

ErrorLectura:

    mov eax,FALSE
    ret

LeerArchivo ENDP


;-------------------------------------------------------------
; MoverInicioArchivo
;
; Coloca el puntero al inicio del archivo.
;-------------------------------------------------------------

MoverInicioArchivo PROC

    invoke SetFilePointer,\
            hArchivo,\
            0,\
            NULL,\
            FILE_BEGIN

    mov eax,TRUE
    ret

MoverInicioArchivo ENDP


;-------------------------------------------------------------
; FinDeArchivo
;
; Devuelve TRUE cuando ya no quedan datos.
;-------------------------------------------------------------

FinDeArchivo PROC

    mov eax,PosicionActual

    cmp eax,BytesLeidos
    jb HayDatos

    mov eax,TRUE
    ret

HayDatos:

    mov eax,FALSE
    ret

FinDeArchivo ENDP


;-------------------------------------------------------------
; LeerLinea
;
; Lee una línea desde BufferArchivo hacia BufferLinea.
;
; Formato esperado:
;
; usuario|pin|saldo
;
;-------------------------------------------------------------

LeerLinea PROC

    LOCAL indice:DWORD

    invoke RtlZeroMemory,\
            ADDR BufferLinea,\
            SIZEOF BufferLinea

    mov indice,0

SiguienteCaracter:

    mov eax,PosicionActual

    cmp eax,BytesLeidos
    jae FinLinea

    mov esi,OFFSET BufferArchivo
    add esi,eax

    mov bl,[esi]

    inc PosicionActual

    cmp bl,13
    je SaltarCR

    cmp bl,10
    je FinLinea

    mov ecx,indice

    mov edi,OFFSET BufferLinea
    add edi,ecx

    mov [edi],bl

    inc indice

    jmp SiguienteCaracter

SaltarCR:

    jmp SiguienteCaracter

FinLinea:

    mov ecx,indice

    mov edi,OFFSET BufferLinea
    add edi,ecx

    mov BYTE PTR [edi],0

    mov eax,TRUE
    ret

LeerLinea ENDP


;=============================================================
; PARTE 4/14
; SepararCampos
; Convierte:
;
; usuario|pin|saldo
;
; en:
;
; CampoUsuario
; CampoPIN
; CampoSaldo
;=============================================================

.data

CampoUsuario db MAX_USUARIO dup(0)
CampoPIN     db MAX_PIN dup(0)
CampoSaldo   db 16 dup(0)

.code

SepararCampos PROC

    LOCAL Estado:DWORD
    LOCAL Indice:DWORD

    ;-----------------------------------------
    ; Limpiar buffers
    ;-----------------------------------------

    invoke RtlZeroMemory,\
            ADDR CampoUsuario,\
            SIZEOF CampoUsuario

    invoke RtlZeroMemory,\
            ADDR CampoPIN,\
            SIZEOF CampoPIN

    invoke RtlZeroMemory,\
            ADDR CampoSaldo,\
            SIZEOF CampoSaldo

    mov Estado,0
    mov Indice,0

    mov esi,OFFSET BufferLinea

LeerSiguiente:

    mov al,[esi]

    cmp al,0
    je FinSeparacion

    cmp al,'|'
    je CambiarCampo

    ;-----------------------------------------
    ; Usuario
    ;-----------------------------------------

    cmp Estado,0
    jne RevisarPIN

    mov edi,OFFSET CampoUsuario
    add edi,Indice
    mov [edi],al

    inc Indice
    inc esi

    jmp LeerSiguiente

RevisarPIN:

    ;-----------------------------------------
    ; PIN
    ;-----------------------------------------

    cmp Estado,1
    jne GuardarSaldo

    mov edi,OFFSET CampoPIN
    add edi,Indice
    mov [edi],al

    inc Indice
    inc esi

    jmp LeerSiguiente

GuardarSaldo:

    ;-----------------------------------------
    ; Saldo
    ;-----------------------------------------

    mov edi,OFFSET CampoSaldo
    add edi,Indice
    mov [edi],al

    inc Indice
    inc esi

    jmp LeerSiguiente

CambiarCampo:

    inc Estado
    mov Indice,0

    inc esi

    jmp LeerSiguiente

FinSeparacion:

    mov eax,TRUE
    ret

SepararCampos ENDP

;=============================================================
; PARTE 5/14
; BuscarCuenta
; Busca un usuario dentro de banco.dat
;=============================================================

BuscarCuenta PROC lpUsuario:DWORD

BuscarInicio:

    ;---------------------------------------------------------
    ; Abrir archivo
    ;---------------------------------------------------------

    invoke AbrirArchivo

    cmp eax,TRUE
    jne ErrorBuscar

    ;---------------------------------------------------------
    ; Leer archivo completo
    ;---------------------------------------------------------

    invoke LeerArchivo

    cmp eax,TRUE
    jne ErrorCerrar

    ;---------------------------------------------------------
    ; Iniciar lectura desde el principio
    ;---------------------------------------------------------

    invoke PosicionarInicio

SiguienteRegistro:

    ;---------------------------------------------------------
    ; ¿Llegó al final?
    ;---------------------------------------------------------

    invoke FinDeArchivo

    cmp eax,TRUE
    je NoEncontrada

    ;---------------------------------------------------------
    ; Leer una línea
    ;---------------------------------------------------------

    invoke LeerLinea

    ;---------------------------------------------------------
    ; Separar:
    ; usuario|pin|saldo
    ;---------------------------------------------------------

    invoke SepararCampos

    ;---------------------------------------------------------
    ; Comparar usuario
    ;---------------------------------------------------------

    invoke lstrcmp,\
            ADDR CampoUsuario,\
            lpUsuario

    cmp eax,0
    je Encontrada

    ;---------------------------------------------------------
    ; Continuar con la siguiente línea
    ;---------------------------------------------------------

    jmp SiguienteRegistro

;-------------------------------------------------------------
; Cuenta encontrada
;-------------------------------------------------------------

Encontrada:

    ; Copiar datos encontrados

    invoke lstrcpy,\
            ADDR CuentaActual.Usuario,\
            ADDR CampoUsuario

    invoke lstrcpy,\
            ADDR CuentaActual.PIN,\
            ADDR CampoPIN

    invoke lstrcpy,\
            ADDR BufferNumero,\
            ADDR CampoSaldo

    ; Convertir saldo ASCII -> DWORD

    invoke CadenaANumero,\
            ADDR BufferNumero

    mov CuentaActual.Saldo,eax

    invoke CerrarArchivo

    mov eax,TRUE
    ret

;-------------------------------------------------------------
; Cuenta no encontrada
;-------------------------------------------------------------

NoEncontrada:

ErrorCerrar:

    invoke CerrarArchivo

ErrorBuscar:

    mov eax,FALSE
    ret

BuscarCuenta ENDP

