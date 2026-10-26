#!/usr/bin/env bash
#
# configurar_entorno.sh - Configura el entorno de una herramienta EDA en las
# maquinas del laboratorio de Miramon (Rocky Linux).
#
#     source configurar_entorno.sh

# Comprueba que se ha cargado con source y no ejecutado como proceso hijo
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    echo "ERROR: este script tiene que lanzarse con source"
    echo
    echo "    source ${0}"
    echo
    exit 1
fi

# Aborta si la ruta no existe, para no dar por configurado lo que no lo esta
_comprobar() {
    if [ ! -e "${1}" ]; then
        echo "ERROR: no existe ${1}"
        echo "La herramienta no está instalada en esta máquina o ha cambiado de sitio."
        return 1
    fi
}

_limpiar() {
    unset opcion regla ruta_questa ruta_synopsys ruta_vivado
    unset -f _comprobar _limpiar
}

regla="*********************"

# Menú
echo
echo "*** Elige qué herramienta quieres configurar ***"
echo
echo "  1 - Visual Studio Code"
echo "  2 - Questa"
echo "  3 - Design Compiler"
echo "  4 - Vivado"
echo

# Lectura de la opción y filtrado: cualquier valor fuera de 1-4 aborta
read -r -p "Opción: " opcion
echo

case "${opcion}" in

    1)
        echo "${regla}"
        echo "comandos ejecutados:"
        echo "    (Visual Studio Code ya está correctamente configurado en el host)"
        echo "cómo lanzar la herramienta Visual Studio Code:"
        echo "    navega a la ubicación deseada"
        echo "    code &"
        echo "${regla}"
        ;;

    2)
        ruta_questa=/apps/siemens/QUESTAONESIM_2025.3/questasim/bin
        _comprobar "${ruta_questa}" || { _limpiar; return 1; }

        export PATH=${ruta_questa}/:$PATH
        export SALT_LICENSE_SERVER=/apps/siemens/licencias/LicenciaSiemens2026.lic

        echo "${regla}"
        echo "comandos ejecutados:"
        echo "    export PATH=${ruta_questa}/:\$PATH"
        echo "    export SALT_LICENSE_SERVER=${SALT_LICENSE_SERVER}"
        echo "cómo lanzar la herramienta Questa:"
        echo "    navega a la ubicación deseada"
        echo "    vsim &"
        echo "${regla}"
        ;;

    3)
        ruta_synopsys=/apps/synopsys/SYN_2024.09-SP2/bin
        _comprobar "${ruta_synopsys}" || { _limpiar; return 1; }

        export PATH=${ruta_synopsys}/:$PATH
        export SNPSLMD_LICENSE_FILE=/apps/synopsys/licencias/LicenciaSynopsys2026.lic

        echo "${regla}"
        echo "comandos ejecutados:"
        echo "    export PATH=${ruta_synopsys}/:\$PATH"
        echo "    export SNPSLMD_LICENSE_FILE=${SNPSLMD_LICENSE_FILE}"
        echo "cómo lanzar la herramienta Design Compiler:"
        echo "    navega a la ubicación deseada"
        echo "    dc_shell"
        echo "${regla}"
        ;;

    4)
        ruta_vivado=/apps/Xilinx/2025.2.1/Vivado/settings64.sh
        _comprobar "${ruta_vivado}" || { _limpiar; return 1; }

        source "${ruta_vivado}"

        echo "${regla}"
        echo "comandos ejecutados:"
        echo "    source ${ruta_vivado}"
        echo "cómo lanzar la herramienta Vivado:"
        echo "    navega a la ubicación deseada"
        echo "    vivado &"
        echo "${regla}"
        ;;

    *)
        echo "Opción no válida. No se ha configurado nada."
        _limpiar
        return 1
        ;;
esac

echo
_limpiar
