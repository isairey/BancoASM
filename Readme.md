# 🏦 BancoASM
### Sistema Bancario con Interfaz Gráfica desarrollado en Ensamblador x86 (MASM32) y Win32 API

<div align="center">

![Assembly](https://img.shields.io/badge/Assembly-MASM32-blue?style=for-the-badge)
![Windows](https://img.shields.io/badge/Windows-Win32_API-success?style=for-the-badge)
![Language](https://img.shields.io/badge/Language-x86_Assembly-orange?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-En_Desarrollo-yellow?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-red?style=for-the-badge)

<img src="https://raw.githubusercontent.com/github/explore/main/topics/assembly/assembly.png" width="180"/>

### Un sistema bancario completo desarrollado completamente en lenguaje ensamblador utilizando MASM32 y la API de Windows.

</div>

---

# 📖 Descripción

**BancoASM** es un proyecto educativo que demuestra cómo desarrollar una aplicación de escritorio utilizando **Lenguaje Ensamblador (Assembly x86)** junto con **MASM32** y la **Win32 API**.

El objetivo del proyecto es construir un sistema bancario funcional que permita administrar cuentas de usuarios mediante una interfaz gráfica de Windows, almacenando la información en archivos locales.

Todo el sistema está implementado utilizando instrucciones de ensamblador, llamadas a la API de Windows y archivos de datos, sin utilizar lenguajes de alto nivel como C, C++ o C#.

---

# ✨ Características

- 🔐 Inicio de sesión mediante usuario y PIN.
- 👤 Creación de nuevas cuentas.
- 💰 Consulta de saldo.
- 📥 Depósitos.
- 📤 Retiros.
- 🔄 Transferencias entre cuentas.
- 📜 Historial de movimientos.
- 💾 Persistencia mediante archivos `.dat`.
- 🖥️ Interfaz gráfica desarrollada con Win32 API.
- ⚡ Código escrito completamente en Assembly x86.
- 📂 Arquitectura modular.

---

# 📁 Estructura del Proyecto

```text
BancoASM
│
├── banco.dat
├── historial.dat
│
├── main.asm
├── login.asm
├── menu.asm
├── cuentas.asm
├── deposito.asm
├── retiro.asm
├── transferencia.asm
├── historial.asm
│
├── recursos.rc
├── recursos.inc
│
├── README.md
│
└── assets/
```

---

# 🛠 Tecnologías Utilizadas

| Tecnología | Descripción |
|------------|-------------|
| Assembly x86 | Lenguaje principal |
| MASM32 | Ensamblador Microsoft |
| Win32 API | Interfaz gráfica |
| Windows | Sistema operativo |
| Resource Script | Recursos gráficos |
| Archivos DAT | Base de datos local |

---

# 🖥 Funcionalidades

## 🔐 Inicio de Sesión

Permite acceder al sistema mediante:

- Usuario
- PIN

Los datos son validados contra el archivo:

```text
banco.dat
```

---

## 👤 Gestión de Cuentas

Permite:

- Crear cuentas.
- Buscar usuarios.
- Validar credenciales.
- Consultar información.

---

## 💰 Depósitos

Los depósitos:

- Validan el monto.
- Actualizan el saldo.
- Guardan la información.
- Registran el movimiento en el historial.

---

## 📤 Retiros

Los retiros:

- Verifican saldo suficiente.
- Actualizan la cuenta.
- Guardan cambios.
- Registran el movimiento.

---

## 🔄 Transferencias

Las transferencias permiten:

- Seleccionar cuenta destino.
- Validar existencia.
- Validar saldo.
- Actualizar ambas cuentas.
- Registrar historial.

---

## 📜 Historial

Cada operación queda registrada.

Ejemplo:

```text
isai|DEPOSITO|5000
isai|RETIRO|1000
juan|TRANSFERENCIA|2500
```

---

# 💾 Formato de la Base de Datos

## banco.dat

```text
usuario|pin|saldo
```

Ejemplo:

```text
isai|1234|15000
juan|1111|8000
admin|0000|50000
```

---

## historial.dat

```text
usuario|movimiento|monto
```

Ejemplo:

```text
isai|DEPOSITO|5000
isai|RETIRO|1000
juan|TRANSFERENCIA|3000
```

---

# 🧩 Arquitectura

```text
                +----------------+
                |   main.asm     |
                +--------+-------+
                         |
                         v
                +----------------+
                |   login.asm    |
                +--------+-------+
                         |
                         v
                +----------------+
                |    menu.asm    |
                +--------+-------+
                         |
     +----------+--------+--------+----------+
     |          |                 |          |
     v          v                 v          v
deposito   retiro.asm   transferencia   historial
     |          |                 |          |
     +----------+--------+--------+----------+
                         |
                         v
                  cuentas.asm
                         |
                         v
                banco.dat / historial.dat
```

---

# ⚙ Requisitos

- Windows 10 / 11
- MASM32 SDK
- Resource Compiler
- Link.exe
- Microsoft Macro Assembler

---

# 🚀 Compilación

Compilar los archivos:

```bat
ml /c /coff main.asm
ml /c /coff login.asm
ml /c /coff menu.asm
ml /c /coff cuentas.asm
ml /c /coff deposito.asm
ml /c /coff retiro.asm
ml /c /coff transferencia.asm
ml /c /coff historial.asm
rc recursos.rc

link /SUBSYSTEM:WINDOWS ^
main.obj ^
login.obj ^
menu.obj ^
cuentas.obj ^
deposito.obj ^
retiro.obj ^
transferencia.obj ^
historial.obj ^
recursos.res
```

---



# 📚 Objetivos del Proyecto

- Aprender programación en Assembly.
- Comprender la Win32 API.
- Manejo de archivos binarios y de texto.
- Arquitectura modular en ensamblador.
- Desarrollo de interfaces gráficas.
- Administración de memoria.
- Uso de recursos de Windows.

---

# 📈 Estado del Proyecto

| Módulo | Estado |
|---------|:------:|
| Login | ✅ |
| Menú Principal | ✅ |
| Gestión de Cuentas | ✅ |
| Depósitos | ✅ |
| Retiros | ✅ |
| Transferencias | ✅ |
| Historial | ✅ |
| Base de Datos | ✅ |
| Recursos | ✅ |

---

# 👨‍💻 Autor

**Isai Reyes Peña**

GitHub:

https://github.com/isairey

---

# 📄 Licencia

Este proyecto se distribuye bajo la licencia **MIT**.

---

<div align="center">

### ⭐ Si este proyecto te resulta útil, no olvides dejar una estrella en GitHub.

**Desarrollado con Assembly x86, MASM32 y Win32 API.**

</div>