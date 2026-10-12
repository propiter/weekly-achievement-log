# weekly-achievement-log

**Tu weekly no debería depender de que te acuerdes el viernes.**

Una skill para agentes (Hermes, Claude Code, Codex, OpenCode, Cursor) que convierte
la actividad real de tus repos en un resumen semanal **con evidencia**, y que sabe de
quién es cada logro.

```bash
curl -fsSL https://raw.githubusercontent.com/propiter/weekly-achievement-log/main/install.sh | bash
```

Una línea. Queda instalada en todos los agentes que tengas en la máquina, y tu agente
la carga solo cuando el tema aparece — no hay que invocarla.

---

## El problema que resuelve

Todos los registros de logros mueren igual, y casi siempre en la semana 2. No es falta
de disciplina: es que están mal construidos.

| Cómo se hace normalmente | Por qué muere |
|---|---|
| Un `.md` que alguien escribe a mano | Nadie lo abre, y depende de que te acuerdes |
| Un cron que lo arma cada viernes | Gasta corridas cuando nada cambió, y captura tarde |
| Sacar los logros de `git log` y listo | El trabajo de tus compañeros se cuela como tuyo |
| "Aproximadamente aguanta 15 clientes" | Un número sin medición, que no podés defender |

Esta skill ataca las cuatro.

## Las tres capas

```
commit  ──hook──▶  inbox crudo  ──juicio──▶  logros con evidencia  ──▶  artefacto con URL
   ▲                                                                        ▲
   el evento escribe, no el reloj                              el entregable es una URL, no un archivo
```

| Capa | Qué hace | Qué NUNCA hace |
|---|---|---|
| **Captura** | El commit escribe una línea cruda en un inbox | Juzgar, resumir, tocar el repo de trabajo |
| **Juicio** | Convertir el crudo en logros: qué, por qué, evidencia | Inventar un dato |
| **Entrega** | Compilar la semana y publicar el artefacto | Terminar sin URL |

## Las reglas que la hacen funcionar

**1. El evento escribe, el reloj no.** Un hook `post-commit`, nunca un cron. Un cron
gasta corridas cuando nada cambió.

**2. El hook jamás bloquea un commit.** `set +e` y `exit 0` al final, sin excepción.
Con husky el hook corre bajo `sh -e`: un error tumba el commit.

**3. El autor manda.** La captura guarda el autor de cada commit y el compilador lo
compara contra las identidades del dueño del registro. Un logro propio que cita a otra
persona **es un error, no un detalle**: el trabajo del equipo va en su propia sección,
atribuido, sin contarlo como propio. En un weekly, quedarse con el mérito de un
compañero no es un bug de formato.

**4. Medido o declarado, nunca inventado.** Y si no está medido, no lleva una nota de
advertencia: lleva un bloque `verificar` con **el comando exacto** para medirlo, y **no
lleva guion** hasta que esté medido.

> Una advertencia se ignora; un comando se corre.

**5. Ventanas, no recuerdos.** Un trabajo que cruza el fin de semana se declara con
`fecha` y `fin`. Nunca se cuenta dos veces ni se corre de semana.

## El esquema de un logro

```json
{
  "id": "2026-10-06/acme/automatizaciones",
  "fecha": "2026-10-06",
  "fin": "2026-10-12",
  "proyecto": "Acme",
  "tipo": "feature",
  "atribucion": "propia",
  "destacado": true,
  "titulo": "Automatizaciones por etapa",
  "que": "qué se hizo, en una o dos frases",
  "por_que": "por qué importa, en términos de negocio",
  "impacto": {"alcance": "...", "riesgo": "...", "ingreso": "...", "desbloquea": "..."},
  "evidencia": [{"tipo": "pr", "ref": "#37"}, {"tipo": "commit", "ref": "d9a555175"}],
  "confianza": "medido",
  "guion": "la frase que se dice en el weekly, en primera persona"
}
```

## Qué te deja

- Un hook instalado y **verificado** en tus repos (no solo escrito).
- Un inbox crudo que se puede reconstruir desde `git log` si arrancás de cero.
- Un compilador que reporta **huecos** (repos con commits y sin ningún logro) y
  **atribución** (commits ajenos citados como propios).
- Un artefacto publicado con URL, verificado a 390/768/1366 px.

## Estructura

```
skill/
├── SKILL.md                  # el procedimiento (esto es lo que lee el agente)
└── references/pitfalls.md    # los tropiezos concretos, ya pagados
install.sh                    # instalador de una línea
```

## Lo que ya está pagado

`skill/references/pitfalls.md` tiene los errores que cuestan una tarde cada uno:

- En repos con husky, escribir en `.husky/_/` **no funciona**: husky regenera esa
  carpeta en cada `npm install`, y su shim hace `exit 0` antes de llegar a tu código.
- `core.hooksPath` hace que git ignore `.git/hooks` por completo.
- `git log --pretty` con un `--date=format` que contiene el separador **pierde commits
  en silencio**.
- Medir cobertura por SHA citado da falsos positivos.
- Un chip con `white-space: nowrap` desborda el celular.

## Licencia

MIT.
