;=============================================================
; recursos.inc
; Sistema Bancario ASM
; Definición de IDs de recursos
; Autor: Isai Reyes Peña
;=============================================================

ifndef __RECURSOS_INC__
__RECURSOS_INC__ EQU 1

;=============================================================
; Diálogos
;=============================================================

IDD_LOGIN          EQU 100
IDD_MENU           EQU 101
IDD_CREARCUENTA    EQU 102

;=============================================================
; Login
;=============================================================

IDC_USUARIO        EQU 1001
IDC_PIN            EQU 1002

IDC_LOGIN          EQU 1003
IDC_CREAR          EQU 1004
IDC_SALIR          EQU 1005

;=============================================================
; Crear Cuenta
;=============================================================

IDC_NOMBRE         EQU 1101
IDC_NUMCUENTA      EQU 1102
IDC_PIN1           EQU 1103
IDC_PIN2           EQU 1104
IDC_SALDO          EQU 1105

IDC_GUARDAR        EQU 1106
IDC_CANCELAR       EQU 1107

;=============================================================
; Menú Principal
;=============================================================

IDC_SALDOACTUAL    EQU 1201

IDC_CONSULTAR      EQU 1202
IDC_DEPOSITAR      EQU 1203
IDC_RETIRAR        EQU 1204
IDC_TRANSFERIR     EQU 1205
IDC_HISTORIAL      EQU 1206
IDC_CERRARSESION   EQU 1207

;=============================================================
; Diálogo de Depósito
;=============================================================

IDC_MONTODEP       EQU 1301
IDC_ACEPTARDEP     EQU 1302
IDC_CANCELARDEP    EQU 1303

;=============================================================
; Diálogo de Retiro
;=============================================================

IDC_MONTORET       EQU 1401
IDC_ACEPTARRET     EQU 1402
IDC_CANCELARRET    EQU 1403

;=============================================================
; Transferencias
;=============================================================

IDC_CUENTADESTINO  EQU 1501
IDC_MONTOTRANS     EQU 1502
IDC_ACEPTARTRANS   EQU 1503
IDC_CANCELARTRANS  EQU 1504

;=============================================================
; Historial
;=============================================================

IDC_LISTAHISTORIAL EQU 1601

;=============================================================
; Iconos
;=============================================================

IDI_BANCO          EQU 200
IDI_LOGO           EQU 201

;=============================================================
; Menús
;=============================================================

IDM_ARCHIVO        EQU 300
IDM_SALIR          EQU 301

IDM_CUENTAS        EQU 310
IDM_CREARCUENTA    EQU 311

IDM_OPERACIONES    EQU 320
IDM_DEPOSITAR      EQU 321
IDM_RETIRAR        EQU 322
IDM_TRANSFERIR     EQU 323

IDM_AYUDA          EQU 330
IDM_ACERCADE       EQU 331

endif