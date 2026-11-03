# XI: registros conectados mediante MPS sin truncamiento

`qmps INICIO ANCHURA` prepara **un componente cuántico único** en estado cero.
Admite 1.000 cúbits dentro del presupuesto habitual de 1.024 por componente.
No crea grupos independientes de cuatro ni cambia la anchura pedida.
`qmpsinfo INICIO` informa de la anchura, las dimensiones virtuales, la norma
y la pureza de todas las biparticiones consecutivas del componente.

La representación es un Matrix Product State abierto. Cada tensor corresponde
a un cúbit físico simulado; sus índices virtuales conectan el estado completo.
Una dimensión virtual de dos **no significa dos cúbits ni registros separados**.
La aplicación de un CNOT/CZ usa su descomposición exacta como suma de dos
productos y amplía el enlace correspondiente. Las rotaciones locales no
cambian los enlaces. No se aplica SVD, tolerancia de descarte ni truncamiento.
La aritmética sigue siendo binaria64, con sus errores de redondeo habituales.

Una capa de RY sobre cada entrada, 999 CNOT consecutivos y otra capa RY sobre
los 1.000 ángulos entrenables utiliza un registro conectado con enlaces
virtuales de dimensión dos. El estado ocupa 127.872 bytes de coeficientes;
esa cifra no es la RAM del proceso y excluye cachés, índices y memoria XI.
La prueba nativa comprueba 999 cortes entrelazados con entradas no degeneradas.
El diagnóstico cuenta un corte como no producto cuando su pureza es menor
que `1 - 1e-10`; ese umbral solo clasifica el diagnóstico y no modifica estados.

## Límites reales

El coste depende del entrelazamiento y de las capas que cruzan cada corte.
Sin compresión, cada CNOT/CZ que cruza un enlace puede duplicar su dimensión
almacenada, incluso si luego se cancelan compuertas. El presupuesto actual
es 64 por enlace y 64 MiB de carga del estado en InfiniteCore. Si se agota,
la operación falla con un error; nunca se divide el registro ni se descartan
amplitudes para continuar. No se afirma poder ejecutar cualquier circuito
arbitrario de 1.000 cúbits con memoria pequeña.

Se soportan rotaciones RX/RY/RZ de un sitio, H/S/T/Paulis y CNOT/CZ. Las puertas
entre sitios no vecinos se encaminan mediante SWAP exactos, sujetos al mismo
presupuesto. Las rotaciones de Pauli de varios sitios inducidas por un marco
Ether global no se convierten implícitamente: se rechazan. La preparación
requiere el marco Ether vacío y fondo cero, igual que `qprepare`.

La autoridad sigue siendo QuantumRuntime/InfiniteCore. El MPS es una nueva
alternativa de QuantumBlock, no un simulador externo ni un segundo estado
paralelo. Los snapshots `QBL1` incorporan la etiqueta 3 con carga `MPS1`;
las etiquetas históricas 0/1/2 conservan su lectura y escritura. Los runtimes
antiguos no interpretan esa etiqueta nueva, por lo que se guardan checkpoints
nuevos sin reemplazar los originales.

## Comprobación

```sh
bash scripts/build-xi-session.sh ../mundo-X build
g++ -std=c++17 -O2 -Wall -Wextra -Wpedantic -Isrc tests/mps_connected.cpp -o build/mps-connected
build/mps-connected
python tests/xi_continuous.py build/reverse_pc build/xi_session build/xi-validation
```

El oráculo nativo compara amplitudes, observables Pauli, purezas, mediciones,
guardado/restauración y rechazos por recursos con un cálculo denso separado
en registros pequeños. La prueba de anchura prepara y conecta 1.000 sitios.
Los agentes, sus pérdidas y los optimizadores permanecen implementados en XI
en BBY-Q. Su validación adicional comprueba derivadas del score completo,
influencia del primer sitio sobre el último y reanudación del entrenamiento.

Referencia matemática: [Schollwöck, 2011, MPS](https://arxiv.org/abs/1008.3477).
