---
name: weekly-achievement-log
description: "Use when setting up or running a weekly achievements log fed by repo activity — captures work with a commit hook, attributes each achievement to its real author, and compiles a publishable weekly recap. Trigger: logros semanales, achievements log, weekly report from commits, registrar avances, weekly wins."
version: 1.0.0
author: Piter + Hermes Agent
license: MIT
platforms: [linux, macos]
metadata:
  hermes:
    tags: [weekly, logros, achievements, git-hooks, reporting, attribution, hub]
    related_skills: [artifact-craft, weekly-review-planning, obsidian]
---

# Registro de logros semanales

Convertir la actividad real de los repos en un resumen semanal con evidencia, para
que el weekly no dependa de que alguien se acuerde el viernes.

## Contrato de activacion

Usala cuando alguien pida: montar un registro de logros/avances semanales, generar
el resumen del weekly desde los repos, o capturar automaticamente lo que se hizo.
No la uses para planificar la semana (eso es `weekly-review-planning`) ni para
entregar el artefacto (eso es `artifact-craft`).

## Tres capas, y la separacion importa

| Capa | Que hace | Nunca hace |
|---|---|---|
| **Captura** | El commit escribe una linea cruda en un inbox | Juzgar, resumir, commitear en el repo de trabajo |
| **Juicio** | Convertir el crudo en logros: que, por que, evidencia | Inventar un dato |
| **Entrega** | Compilar la semana y publicar el artefacto | Salir sin URL |

## Reglas duras

1. **El evento escribe, el reloj no.** Hook `post-commit`, nunca un cron. Un cron
   gasta corridas cuando nada cambio.
2. **El hook jamas bloquea un commit.** `set +e`, `exit 0` al final, y nada que
   pueda fallar hacia afuera. Con husky (`sh -e`) un error tumba el commit.
   **Y el hook instalado es un STUB que lee el cuerpo canonico**, nunca una copia:
   N copias del cuerpo significa que editar una no alcanza a las otras, y los repos
   siguen capturando con la logica vieja sin que nada lo avise.
3. **En repos con husky, escribir `.husky/post-commit`, NUNCA `.husky/_/`.**
   Dos razones: husky regenera `_` en cada `npm install` y pisa lo que pusiste
   ahi; y su shim `_/post-commit` hace `exit 0` cuando no hay hook de usuario,
   asi que codigo agregado despues del shim NUNCA corre. Ademas, `core.hooksPath`
   hace que git ignore `.git/hooks` por completo: resolvelo siempre.
4. **El hook no se commitea.** Si cae en un directorio versionado (`.husky/`),
   agregalo a `.git/info/exclude`. Nunca lo metas al repo de trabajo.
5. **El autor manda.** Guarda `autor` en la captura y compara cada commit citado
   contra las identidades del duenio del registro. Un logro propio que cita a otra
   persona es un error, no un detalle: el trabajo del equipo va en su propia
   seccion, atribuido, sin contarlo como propio.
6. **Medido o declarado, nunca inventado.** Y si no esta medido, no lleva una nota
   de advertencia: lleva un bloque `verificar` con **el comando exacto** para
   medirlo, y **no lleva guion** hasta que este medido. Una advertencia se ignora;
   un comando se corre.
7. **El repo del registro es aparte.** El hook debe saltarlo, o se auto-alimenta.
8. **Ventanas, no recuerdos.** Un trabajo que cruza el fin de semana se declara con
   `fecha` y `fin`; nunca se cuenta dos veces ni se corre de semana.

## Puertas de decision

| Situacion | Accion |
|---|---|
| El repo usa husky | Escribir el hook en `.husky/post-commit`; excluirlo de git |
| El repo no usa husky | `.git/hooks/post-commit` |
| Se suman repos despues | Re-correr el instalador: es idempotente |
| Se perdio el inbox o es maquina nueva | Backfill desde `git log` del rango |
| Un logro no tiene evidencia | Bloque `verificar` con el comando; sin guion |
| El commit citado es de otra persona | `atribucion: "equipo"` + `autor`; seccion aparte |
| El commit capturado es de un proyecto excluido | Excluirlo en el instalador y el backfill |

## Pasos de ejecucion

1. Crear el repo del registro (privado si es trabajo de cliente) con: `capture.sh`
   (cuerpo del hook), `install-hooks.sh`, `backfill.sh`, `compilar.py`,
   `logros.jsonl`, `artefacto/generar.py`.
2. `capture.sh` escribe `{fecha,hora,repo,sha,rama,autor,subject}` en
   `inbox/commits.jsonl`. Siempre `exit 0`.
3. `install-hooks.sh` resuelve el directorio de hooks efectivo por repo, escribe
   el hook de usuario, lo excluye de git y limpia shims tocados por versiones
   anteriores.
4. `backfill.sh` rellena el inbox desde `git log` para no empezar de cero.
5. Curado semanal en `logros.jsonl`: un logro por linea, con `que`, `por_que`,
   `impacto`, `evidencia`, `confianza`, `atribucion`, y `guion` solo si esta medido.
6. `compilar.py` cruza logros y git, y reporta **huecos** (repos con commits y sin
   logro) y **atribucion** (commits ajenos citados como propios).
7. `artefacto/generar.py` arma el HTML; se publica en el hub y se comparte la URL.
   Verificar a 390/768/1366 px antes de publicar.

## Contrato de salida

- El repo del registro, con el hook instalado y verificado en los repos reales.
- `logros.jsonl` de la ventana, con evidencia por logro.
- La salida de `compilar.py`: logros, atribucion, huecos, pendientes de verificar.
- El artefacto **publicado**, con URL.

## Referencias

- `references/pitfalls.md` — los tropiezos concretos (husky, hooksPath, formato de
  fecha en `git log`, dedupe por sha, chips que desbordan en celular).
