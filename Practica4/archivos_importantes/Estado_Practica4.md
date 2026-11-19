# Práctica 4 (conversor binario a BCD): estado y tareas pendientes

Pega este archivo al empezar una sesión nueva junto con lo que se indica en "Qué adjuntar". Resume lo hecho hasta el 16/11/2026 y lo que queda.

## Contexto

- Asignatura: Métodos de Diseño Electrónico (Tecnun, curso 2026-2027), VHDL. Pareja: Diego Orellana e Iñigo Zubieta.
- Herramientas: Questa (simulación, en el portátil de Diego, Windows), Design Compiler con `class.db` y Vivado con la Basys 3 (solo en el laboratorio, Rocky Linux).
- **Fecha límite: jueves 26 de noviembre de 2026.** Laboratorio para sintetizar e implementar: jueves 19 de noviembre de 2026.
- Repo: https://github.com/diegorellana/ParteDigitalMDE.git. La práctica va en `Practica4/practica_binary_bcd/`. En la máquina de Diego está en `C:/Users/diego/Desktop/UNAV/4to/MDE/ParteDigitalMDE/Practica4/practica_binary_bcd`.

## Entregables del enunciado (sección 7)

1. Todos los VHDL del conversor (6 puntos).
2. Todos los reports de síntesis de Design Compiler, incluido `log_sintesis.txt`. Sin latches (1 punto).
3. Reports de Vivado «Utilization - Place Design» y «Timing Summary - Route Design», más el `.bit` y el `.bin` (3 puntos).

Parámetros de síntesis: periodo 10 ns, input delay 2 ns, output delay 2 ns, genéricos = `C_BINARY_BW` (14), `C_BCD_BW` (16), `C_MAX_BINARY_VALUE` (9999) y `C_PIPELINE` (14 bits a '1'), de `ctes_pkg.vhd`.

El enunciado **no tiene preguntas**. Aun así, los alumnos quieren un documento de respuestas con el formato de la práctica 2, con el diagrama RTL dentro del Word (sin archivo aparte).

## Lo que ya está hecho

| Archivo | Estado |
|---|---|
| `rtl/binary_to_bcd.vhd` | Escrito. Arquitectura de la sección 5: `p_input_reg` (con saturación a 9999), `for generate` de 14 etapas (normalizar con `f_double_dabble_normalize_nibble_array`, desplazar, `if generate` con `p_pipeline_reg` si `gen_pipeline(I)='1'`), `p_valid_delay_reg` (registro de desplazamiento de `c_pipeline_delay` bits) y `p_output_reg`. Los genéricos tienen valor por defecto = constantes de `ctes_pkg`, para que DC elabore sin `-parameters`. |
| `rtl/binary_to_bcd_lib/functions_pkg.vhd` | Implementada `f_count_ones_in_vector` (bucle sobre `input'range`). |
| `impl_fpga/rtl_fpga/top_fpga_binary_bcd.vhd` | Sustituida la palabra fija «TODO» por `p_display_chars_reg`: con `valid_out='1'` guarda los 4 nibbles de `bcd_out` como caracteres (`f_basys3_nibble_to_char`). Índice 0 = dígito derecho = unidades. Reset: 0000. |
| `testbench/tb_binary_to_bcd.vhd` | Escrito. Tres fases: cronograma del enunciado (7, 42, hueco, 999), los 16384 valores de 14 bits y 3000 valores con huecos en `valid_in`. Genérico `g_pipeline`. Termina con `std.env.stop`. |
| `sim/bin/fuentes.tcl`, `simular.do`, `ondas.do` | Rellenados. `simular.do`: top `tb_binary_to_bcd`, librerías `work` y `binary_to_bcd_lib`, carga `ondas.do` y hace `run -all`. |
| `syn/bin/fuentes.tcl`, `sintesis.tcl` | Rellenados: `C_TOP binary_to_bcd`, `C_ARQUITECTURA rtl`, `work`, `binary_to_bcd_lib`. Sin `-parameters`. |
| `proyecto_binary_bcd.yaml` | Proyecto de TerosHDL con 3 librerías: `binary_to_bcd_lib` (3 paquetes), `basys3_lib` (6 archivos), `work` (`binary_to_bcd`, `tb_binary_to_bcd`, `top_fpga_binary_bcd`). Top: `tb_binary_to_bcd`. |
| `respuestas/Respuestas_Practica4.docx` y `.pdf` | 10 páginas con el formato de la práctica 2. Secciones 1 (diseño, 7 pasos, diagrama RTL apaisado en la pág. 6) y 2 (simulación) completas. Secciones 3 y 4 con **marcas PENDIENTE en rojo**. |

Simulación en Questa (16/11/2026, transcript de Diego): **19387 conversiones sin errores, latencia medida 16 ciclos** (14 + 2), y las entradas 7, 42 y 999 dan 0007, 0042 y 0999. Hay 56 avisos `NUMERIC_STD ">=" metavalue` en 0 ns, iteración 0, antes del reset (4 dígitos × 14 etapas). No son errores. También se comprobó con GHDL con `gen_pipeline` = 11111111111111, 10101010101010, 10000000000000, 00000000000001, 11001100110011 y 01000000000000: todas correctas.

Bits de registro en el VHDL (tabla 3 del documento): 14 + 1 + 14×30 + 14 + 16 + 1 = **466**. DC no implementa los biestables constantes, así que `registros.rpt` dará menos. Ese número **no se ha estimado**: hay que leerlo del report.

## Lo que falta (en orden)

1. **Commit y push** de `Practica4/practica_binary_bcd/` al repo, sin las carpetas internas de las herramientas.
2. **Laboratorio del jueves 19, Design Compiler:** `source configurar_entorno.sh` (opción 3); desde `syn/run` ejecutar `dc_shell -f ../bin/sintesis.tcl -output_log_file ../reports/log_sintesis.txt`. Comprobar `registros.rpt` (0 latches), `area.rpt`, `timing.rpt` (slack con T = 10 ns), `check_design.rpt` y los avisos de `log_sintesis.txt`. Si DC protesta por los genéricos (record, `std_logic_vector` sin rango o la función en la constante), revisarlo antes de seguir.
3. **Laboratorio, Vivado:** `source configurar_entorno.sh` (opción 4); desde `impl_fpga/vivado_prj` ejecutar `vivado &`. Proyecto RTL, FPGA `xc7a35tcpg236-1`, sin copiar fuentes al proyecto. Librerías: `binary_to_bcd_lib` (3 paquetes), `basys3_lib` (6 archivos) y `xil_defaultlib` (`binary_to_bcd.vhd`, `top_fpga_binary_bcd.vhd`). Restricciones: `impl_fpga/constraints/constraints.xdc`. El testbench no se añade. Run Synthesis, Run Implementation y Generate Bitstream (activar la generación del `.bin`: Settings → Bitstream → `-bin_file`). Exportar «Utilization - Place Design» y «Timing Summary - Route Design».
4. **Probar en la placa:** con 1234 en los interruptores y `btnU`, el display debe mostrar 1234. Con todos los interruptores a 1 (16383 en los 14 bits bajos), 9999. `btnC` es el reset.
5. **Completar el documento:** sustituir cada «PENDIENTE» en rojo con datos de los reports, citando el report del que sale cada número:
   - Tabla 1 (datos de partida): biestables, latches, área, slack, LUT y registros de Vivado, WNS.
   - Final del paso 7 de la sección 1: número de biestables de `registros.rpt` y 0 latches.
   - Sección 2, PENDIENTE opcional: simular otras configuraciones en Questa con `vsim -voptargs=+acc -gg_pipeline=10101010101010 work.tb_binary_to_bcd` (y otras) y añadir una tabla con la latencia de cada una. Si no se hace, borrar ese párrafo.
   - Sección 3, paso 2: resultados de DC (camino crítico de `timing.rpt` y avisos del log).
   - Sección 4, pasos 3 y 4: datos de Vivado y pruebas en la placa.
   - Después regenerar el índice (las páginas pueden cambiar), volver a generar el PDF y revisarlo página a página.
6. **Carpeta final de entrega:** `rtl`, `testbench`, `sim`, `syn`, `impl_fpga`, `respuestas`. Debe incluir todos los VHDL, todos los reports de DC con `log_sintesis.txt`, los dos reports de Vivado, `.bit` y `.bin`, y el PDF de respuestas. Sin `sim/run/work`, `syn/run/WORK`, `syn/run/binary_to_bcd_lib`, el proyecto interno de Vivado ni duplicados.

## Cómo regenerar el documento

En `herramientas_doc_p4.zip` está el generador que se usó: `gen.js` (contenido, con docx-js), `build.py` (inserta campos SEQ en los títulos, convierte a PDF con LibreOffice y calcula las páginas del índice en dos pasadas), `diag.py` (dibuja el diagrama RTL en SVG), `logo.png` y `diagrama.png`. Para actualizar: editar los textos en `gen.js` (los PENDIENTE son `{{...}}`) y ejecutar `python3 build.py`. Se puede editar también el `.docx` a mano en Word; en ese caso hay que actualizar el índice y los campos con F9.

Formato que hay que mantener: el de la práctica 2. Portada con logo de Tecnun, índice con páginas, recuadro gris con barra roja para el enunciado, "Paso N.", Times New Roman 12 para el texto y Courier New para código y rutas, tablas numeradas con una frase antes que las presenta y título debajo en azul y cursiva (estilo Caption con campo SEQ), y la figura en página apaisada.

## Reglas de los alumnos (resumen)

- Explicar de forma sencilla, sin teoría que no salga en las diapositivas de la asignatura.
- Todo número sale de un report adjunto y se cita. No inventar ni estimar; si falta un dato, decirlo.
- Si el enunciado y los archivos no cuadran, avisar antes de seguir.
- Generar siempre Word y PDF, y revisar el PDF página a página.
- Estilo de escritura: el de las instrucciones del proyecto (sin vocabulario de relleno, prosa, títulos en minúscula).

## Qué adjuntar en la sesión nueva

- Este archivo.
- `practica_binary_bcd.zip` actualizado, con los reports de `syn/reports/` y los de Vivado.
- `herramientas_doc_p4.zip`, si se quiere regenerar el documento con el script.
- El HTML del enunciado de la práctica 4, si hace falta revisar algo del texto.
