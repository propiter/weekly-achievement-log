# Tropiezos concretos

Todos estos se pagaron una vez. Ninguno es teorico.

## husky: el shim sale antes de llegar a tu codigo

`core.hooksPath=.husky/_` significa que git corre `.husky/_/post-commit`, que es un
shim:

```sh
#!/usr/bin/env sh
. "$(dirname "$0")/h"
```

Y `h` hace, entre otras cosas:

```sh
n=$(basename "$0")
s=$(dirname "$(dirname "$0")")/$n      # -> <repo>/.husky/post-commit
[ ! -f "$s" ] && exit 0                # <- aca se termina todo
```

Si agregas tu codigo AL FINAL del shim, nunca corre: el `exit 0` de `h` (que se
sourcea) mata el script antes. Y si el archivo de usuario no existe, `h` sale con 0
como si todo estuviera bien.

**Correcto:** escribir `<repo>/.husky/post-commit` (el hook de USUARIO). El shim lo
llama via `sh -e "$s"`. husky no lo pisa, porque solo administra `_/`.

## husky regenera `.husky/_/` en cada `npm install`

`.husky/_/.gitignore` contiene `*`. Esa carpeta es descartable y se reconstruye. Lo
que pongas ahi dura hasta el proximo `npm install`.

## `sh -e` en el shim: un fallo bloquea el commit

El shim corre el hook de usuario con `sh -e`. Si tu script devuelve distinto de 0,
husky imprime "script failed" y propaga el codigo: **el commit se aborta**. Tu hook
tiene que empezar con `set +e` y terminar con `exit 0`, sin excepcion.

## `core.hooksPath` hace que git ignore `.git/hooks`

En repos con husky, escribir `.git/hooks/post-commit` no hace nada. Resolucion:

```sh
hp=$(git -C "$repo" config core.hooksPath)
if [ -n "$hp" ]; then
  case "$hp" in /*) dir="$hp";; *) dir="$repo/$hp";; esac   # relativo = al worktree
else
  dir="$repo/.git/hooks"
fi
```

Ojo: `git rev-parse --git-path hooks` NO resuelve el `hooksPath` relativo (devuelve
la cadena tal cual). Hay que resolverlo a mano.

## El hook no debe entrar al repo de trabajo

Si el hook cae en `.husky/` (versionado), `git status` lo muestra como archivo nuevo
y un `git add -A` lo sube al repo compartido. Solucion: `git check-ignore` debe
encontrarlo, agregandolo a `.git/info/exclude` (local, no versionado):

```sh
printf '/%s\n' ".husky/post-commit" >> "$repo/.git/info/exclude"
```

Verificar con `git -C "$repo" check-ignore -v .husky/post-commit`.

## `git log --pretty` con formato de fecha que contiene el separador

Esto parece inofensivo y rompe el parseo:

```sh
git log --pretty="%ad|%ad|%H|%D|%s" --date=format:'%Y-%m-%d|%H:%M'   # MAL
```

`%ad` con ese `--date` ya trae un `|` adentro, asi que el separador se mezcla con el
dato y se pierden commits en silencio (172 esperados, 9 capturados).

**Correcto:** un solo placeholder ISO y cortar en el script:

```sh
git log --pretty="%aI|%H|%D|%an|%s"
# iso="${iso:0:10}"  fecha   |  "${iso:11:5}"  hora
```

## El inbox se duplica

El mismo commit puede entrar dos veces (el hook corre por mas de un camino, rebase,
cherry-pick, o un backfill que no detecto el sha). Deduplicar por sha al compilar, no
confiar en el orden de escritura.

## "Huecos" por sha da falsos positivos

Un logro cita 3-6 commits de 170. Si mides cobertura por sha citado, vas a ver 146
"huecos" que no lo son. Mide por **repo con commits y sin ningun logro**, y conta
tambien los PRs citados (`Merge pull request #NN` en el subject del inbox) como
cobertura.

## Un chip con `white-space: nowrap` desborda el celular

Un chip monoespaciado con un texto largo (una ruta, una nota) empuja la pagina a
527 px en una pantalla de 390. `overflow-wrap: anywhere` y `max-width: 100%`. Se
detecta midiendo `scrollWidth > innerWidth` y listando los elementos cuyo
`getBoundingClientRect().right` pasa el viewport.

## La atribucion no se supone: se verifica

Construir los logros desde `git log` sin mirar el autor hace que el trabajo de otros
se cuele como propio. No es un detalle de estilo: en un weekly es quedarse con el
merito de un companiero. Guarda `autor` en la captura y compara contra las
identidades del duenio del registro.

## Limpiar archivos de verificacion: mirar antes de borrar

Los screenshots y snapshots que dejan las herramientas de navegacion caen en
carpetas compartidas y efimeras. Antes de `rm -rf` una de esas carpetas, listarla:
puede tener archivos de otra sesion que no son tuyos. Borrar por nombre, no por
directorio.
