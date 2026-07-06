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

;-------------------------------
; Funciones principales
;-------------------------------

BuscarCuenta      PROTO :DWORD
ValidarPIN        PROTO :DWORD
ObtenerSaldo      PROTO

DepositarDinero   PROTO :DWORD
RetirarDinero     PROTO :DWORD
TransferirDinero  PROTO :DWORD,:DWORD

CrearCuenta       PROTO :DWORD,:DWORD,:DWORD

GuardarBanco      PROTO
CargarBanco       PROTO

;-------------------------------
; Manejo de archivos
;-------------------------------

AbrirArchivo      PROTO
CerrarArchivo     PROTO
ReiniciarBuffers  PROTO
ObtenerTamArchivo PROTO

LeerArchivo       PROTO
PosicionarInicio  PROTO
FinDeArchivo      PROTO
LeerLinea         PROTO
SepararCampos     PROTO

;-------------------------------
; Funciones auxiliares
;-------------------------------

CopiarCadena      PROTO :DWORD,:DWORD
CompararCadena    PROTO :DWORD,:DWORD
LongitudCadena    PROTO :DWORD

NumeroACadena     PROTO :DWORD,:DWORD
CadenaANumero     PROTO :DWORD

ObtenerUsuario    PROTO
ObtenerPIN        PROTO

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
;=============================================================

BuscarCuenta PROC lpUsuario:DWORD

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
    ; Posicionar al inicio
    ;---------------------------------------------------------

    invoke PosicionarInicio

BuscarSiguiente:

    ;---------------------------------------------------------
    ; ¿Fin del archivo?
    ;---------------------------------------------------------

    invoke FinDeArchivo

    cmp eax,TRUE
    je CuentaNoExiste

    ;---------------------------------------------------------
    ; Leer línea
    ;---------------------------------------------------------

    invoke LeerLinea

    cmp eax,TRUE
    jne CuentaNoExiste

    ;---------------------------------------------------------
    ; Separar usuario|pin|saldo
    ;---------------------------------------------------------

    invoke SepararCampos

    cmp eax,TRUE
    jne BuscarSiguiente

    ;---------------------------------------------------------
    ; Comparar usuario
    ;---------------------------------------------------------

    invoke lstrcmp,\
            ADDR CampoUsuario,\
            lpUsuario

    cmp eax,0
    jne BuscarSiguiente

;-------------------------------------------------------------
; Usuario encontrado
;-------------------------------------------------------------

CuentaEncontrada:

    invoke lstrcpy,\
            ADDR CuentaActual.Usuario,\
            ADDR CampoUsuario

    invoke lstrcpy,\
            ADDR CuentaActual.PIN,\
            ADDR CampoPIN

    invoke lstrcpy,\
            ADDR BufferNumero,\
            ADDR CampoSaldo

    invoke CadenaANumero,\
            ADDR BufferNumero

    mov CuentaActual.Saldo,eax

    invoke CerrarArchivo

    mov eax,TRUE
    ret

;-------------------------------------------------------------
; Usuario no encontrado
;-------------------------------------------------------------

CuentaNoExiste:

ErrorCerrar:

    invoke CerrarArchivo

ErrorBuscar:

    mov eax,FALSE
    ret

BuscarCuenta ENDP


;=============================================================
; PARTE 6/14
; ValidarPIN
; ObtenerSaldo
;=============================================================

;-------------------------------------------------------------
; ValidarPIN
;
; Parámetro:
;   lpPIN -> Dirección del PIN ingresado
;
; Devuelve:
;   EAX = TRUE
;   EAX = FALSE
;-------------------------------------------------------------

ValidarPIN PROC lpPIN:DWORD

    invoke lstrcmp,\
            lpPIN,\
            ADDR CuentaActual.PIN

    cmp eax,0
    jne PINIncorrecto

    mov eax,TRUE
    ret

PINIncorrecto:

    mov eax,FALSE
    ret

ValidarPIN ENDP


;-------------------------------------------------------------
; ObtenerSaldo
;
; Devuelve:
;   EAX = saldo actual
;-------------------------------------------------------------

ObtenerSaldo PROC

    mov eax,CuentaActual.Saldo

    ret

ObtenerSaldo ENDP


;-------------------------------------------------------------
; ObtenerUsuario
;
; Devuelve:
;   EAX = Dirección del usuario
;-------------------------------------------------------------

ObtenerUsuario PROC

    mov eax,OFFSET CuentaActual.Usuario

    ret

ObtenerUsuario ENDP


;-------------------------------------------------------------
; ObtenerPIN
;
; Devuelve:
;   EAX = Dirección del PIN
;-------------------------------------------------------------

ObtenerPIN PROC

    mov eax,OFFSET CuentaActual.PIN

    ret

ObtenerPIN ENDP


;=============================================================
; PARTE 7/14
; DepositarDinero
;=============================================================

DepositarDinero PROC Monto:DWORD

    ;---------------------------------------------------------
    ; Verificar monto
    ;---------------------------------------------------------

    mov eax,Monto

    cmp eax,0
    jle DepositoError

    ;---------------------------------------------------------
    ; Obtener saldo actual
    ;---------------------------------------------------------

    invoke ObtenerSaldo

    mov SaldoTemporal,eax

    ;---------------------------------------------------------
    ; Sumar depósito
    ;---------------------------------------------------------

    mov eax,SaldoTemporal

    add eax,Monto

    mov CuentaActual.Saldo,eax

    ;---------------------------------------------------------
    ; Guardar cambios
    ;---------------------------------------------------------

    invoke GuardarBanco

    mov eax,TRUE
    ret

DepositoError:

    mov eax,FALSE
    ret

DepositarDinero ENDP


;=============================================================
; ConsultarSaldo
;=============================================================

ConsultarSaldo PROC

    invoke ObtenerSaldo

    ret

ConsultarSaldo ENDP


;=============================================================
; PARTE 8/14
; RetirarDinero
;=============================================================

RetirarDinero PROC Monto:DWORD

    ;---------------------------------------------------------
    ; Verificar monto
    ;---------------------------------------------------------

    mov eax,Monto

    cmp eax,0
    jle RetiroError

    ;---------------------------------------------------------
    ; Obtener saldo actual
    ;---------------------------------------------------------

    invoke ObtenerSaldo

    mov SaldoTemporal,eax

    ;---------------------------------------------------------
    ; ¿Hay saldo suficiente?
    ;---------------------------------------------------------

    cmp SaldoTemporal,eax
    jl FondosInsuficientes

    ;---------------------------------------------------------
    ; Restar saldo
    ;---------------------------------------------------------

    mov eax,SaldoTemporal

    sub eax,Monto

    mov CuentaActual.Saldo,eax

    ;---------------------------------------------------------
    ; Guardar cambios
    ;---------------------------------------------------------

    invoke GuardarBanco

    mov eax,TRUE
    ret

;-------------------------------------------------------------
; Fondos insuficientes
;-------------------------------------------------------------

FondosInsuficientes:

    mov eax,FALSE
    ret

;-------------------------------------------------------------
; Error en el monto
;-------------------------------------------------------------

RetiroError:

    mov eax,FALSE
    ret

RetirarDinero ENDP

;=============================================================
; PARTE 9/14
; TransferirDinero
;=============================================================

TransferirDinero PROC Monto:DWORD, lpDestino:DWORD

    LOCAL SaldoOrigen:DWORD

    ;---------------------------------------------------------
    ; Validar monto
    ;---------------------------------------------------------

    mov eax,Monto
    cmp eax,0
    jle TransferError

    ;---------------------------------------------------------
    ; Guardar saldo actual del origen
    ;---------------------------------------------------------

    invoke ObtenerSaldo
    mov SaldoOrigen,eax

    ;---------------------------------------------------------
    ; Verificar fondos suficientes
    ;---------------------------------------------------------

    mov eax,SaldoOrigen
    cmp eax,Monto
    jl FondosInsuficientes

    ;---------------------------------------------------------
    ; Restar del origen
    ;---------------------------------------------------------

    mov eax,SaldoOrigen
    sub eax,Monto
    mov CuentaActual.Saldo,eax

    ;---------------------------------------------------------
    ; Buscar cuenta destino
    ;---------------------------------------------------------

    invoke BuscarCuenta, lpDestino
    cmp eax,FALSE
    je CuentaDestinoNoExiste

    ;---------------------------------------------------------
    ; Sumar al destino
    ;---------------------------------------------------------

    mov eax,CuentaActual.Saldo
    add eax,Monto
    mov CuentaActual.Saldo,eax

    ;---------------------------------------------------------
    ; Guardar cambios
    ;---------------------------------------------------------

    invoke GuardarBanco

    mov eax,TRUE
    ret

;-------------------------------------------------------------
; Errores
;-------------------------------------------------------------

FondosInsuficientes:

    mov eax,FALSE
    ret

CuentaDestinoNoExiste:

    mov eax,FALSE
    ret

TransferError:

    mov eax,FALSE
    ret

TransferirDinero ENDP


;=============================================================
; PARTE 10/14
; CrearCuenta
;=============================================================

CrearCuenta PROC lpUsuario:DWORD, lpPIN:DWORD, SaldoInicial:DWORD

    ;---------------------------------------------------------
    ; Validar usuario
    ;---------------------------------------------------------

    cmp lpUsuario,0
    je CrearError

    cmp lpPIN,0
    je CrearError

    ;---------------------------------------------------------
    ; Abrir archivo
    ;---------------------------------------------------------

    invoke AbrirArchivo
    cmp eax,TRUE
    jne CrearError

    ;---------------------------------------------------------
    ; Posicionar al final del archivo
    ;---------------------------------------------------------

    invoke SetFilePointer,\
            hArchivo,\
            0,\
            NULL,\
            FILE_END

    ;---------------------------------------------------------
    ; Limpiar buffer de línea
    ;---------------------------------------------------------

    invoke RtlZeroMemory,\
            ADDR BufferLinea,\
            SIZEOF BufferLinea

    ;---------------------------------------------------------
    ; Construir línea:
    ; usuario|pin|saldo
    ;---------------------------------------------------------

    invoke lstrcpy,\
            ADDR BufferLinea,\
            lpUsuario

    invoke lstrcat,\
            ADDR BufferLinea,\
            ADDR Separador

    invoke lstrcat,\
            ADDR BufferLinea,\
            lpPIN

    invoke lstrcat,\
            ADDR BufferLinea,\
            ADDR Separador

    ; convertir saldo a string (debe existir CadenaANumero/NumeroACadena)
    invoke NumeroACadena,\
            SaldoInicial,\
            ADDR BufferNumero

    invoke lstrcat,\
            ADDR BufferLinea,\
            ADDR BufferNumero

    invoke lstrcat,\
            ADDR BufferLinea,\
            ADDR CRLF

    ;---------------------------------------------------------
    ; Escribir en archivo
    ;---------------------------------------------------------

    invoke lstrlen,ADDR BufferLinea

    invoke WriteFile,\
            hArchivo,\
            ADDR BufferLinea,\
            eax,\
            ADDR BytesEscritos,\
            NULL

    ;---------------------------------------------------------
    ; Cerrar archivo
    ;---------------------------------------------------------

    invoke CerrarArchivo

    mov eax,TRUE
    ret

;-------------------------------------------------------------
; Error
;-------------------------------------------------------------

CrearError:

    invoke CerrarArchivo

    mov eax,FALSE
    ret

CrearCuenta ENDP

;=============================================================
; PARTE 11/14
; GuardarBanco
; Reescribe completamente banco.dat con CuentaActual
;=============================================================

GuardarBanco PROC

    ;---------------------------------------------------------
    ; Abrir archivo en modo escritura (sobrescribir)
    ;---------------------------------------------------------

    invoke CreateFile,\
            ADDR ArchivoBanco,\
            GENERIC_WRITE,\
            0,\
            NULL,\
            CREATE_ALWAYS,\
            FILE_ATTRIBUTE_NORMAL,\
            NULL

    mov hArchivo,eax

    cmp eax,INVALID_HANDLE_VALUE
    je GuardarError

    ;---------------------------------------------------------
    ; Construir línea de cuenta actual
    ; usuario|pin|saldo
    ;---------------------------------------------------------

    invoke RtlZeroMemory,\
            ADDR BufferLinea,\
            SIZEOF BufferLinea

    invoke lstrcpy,\
            ADDR BufferLinea,\
            ADDR CuentaActual.Usuario

    invoke lstrcat,\
            ADDR BufferLinea,\
            ADDR Separador

    invoke lstrcat,\
            ADDR BufferLinea,\
            ADDR CuentaActual.PIN

    invoke lstrcat,\
            ADDR BufferLinea,\
            ADDR Separador

    invoke NumeroACadena,\
            CuentaActual.Saldo,\
            ADDR BufferNumero

    invoke lstrcat,\
            ADDR BufferLinea,\
            ADDR BufferNumero

    invoke lstrcat,\
            ADDR BufferLinea,\
            ADDR CRLF

    ;---------------------------------------------------------
    ; Escribir en archivo
    ;---------------------------------------------------------

    invoke lstrlen,ADDR BufferLinea

    invoke WriteFile,\
            hArchivo,\
            ADDR BufferLinea,\
            eax,\
            ADDR BytesEscritos,\
            NULL

    ;---------------------------------------------------------
    ; Cerrar archivo
    ;---------------------------------------------------------

    invoke CloseHandle,hArchivo

    mov eax,TRUE
    ret

;-------------------------------------------------------------
; Error
;-------------------------------------------------------------

GuardarError:

    mov eax,FALSE
    ret

GuardarBanco ENDP


;=============================================================
; PARTE 12/14
; Conversiones de cadena y número
; CadenaANumero / NumeroACadena
;=============================================================

;-------------------------------------------------------------
; CadenaANumero
;
; Convierte string ASCII a DWORD
; Ej: "1500" -> 1500
;-------------------------------------------------------------

CadenaANumero PROC lpCadena:DWORD

    mov esi,lpCadena
    xor eax,eax
    xor ecx,ecx

ConvertLoop:

    mov bl,[esi]
    cmp bl,0
    je FinConversion

    cmp bl,'0'
    jl FinConversion

    cmp bl,'9'
    jg FinConversion

    sub bl,'0'

    mov edx,eax
    imul eax,10
    add eax,edx
    add eax,ebx

    inc esi
    jmp ConvertLoop

FinConversion:

    ret

CadenaANumero ENDP


;-------------------------------------------------------------
; NumeroACadena
;
; Convierte DWORD a ASCII
; Ej: 1500 -> "1500"
;-------------------------------------------------------------

NumeroACadena PROC Valor:DWORD, lpBuffer:DWORD

    LOCAL temp[16]:BYTE

    mov eax,Valor
    mov edi,OFFSET temp
    add edi,15
    mov BYTE PTR [edi],0

    dec edi

    cmp eax,0
    jne Convertir

    mov BYTE PTR [edi],'0'
    jmp Copiar

Convertir:

ConvertLoop:

    xor edx,edx
    mov ecx,10
    div ecx

    add dl,'0'
    mov [edi],dl

    dec edi

    cmp eax,0
    jne ConvertLoop

    inc edi

Copiar:

    mov esi,edi
    mov edi,lpBuffer

CopiarLoop:

    mov al,[esi]
    mov [edi],al

    cmp al,0
    je FinNumero

    inc esi
    inc edi
    jmp CopiarLoop

FinNumero:

    ret

NumeroACadena ENDP


