#!/bin/bash

# Define the array of values
ids=("HO" "CO" "ES" "PE" "MX")

# Function to display the list of IDs and let the user choose
choose_ids() {
    echo ""
    echo "Geografías disponibles: ${ids[*]}"
    echo ""
    read -p 'Elige las geografías separadas por un espacio (e.g., HO CO), o pulsa Intro para buscar en todas: ' -a chosen_ids
    echo ""
    if [ ${#chosen_ids[@]} -eq 0 ]; then
        chosen_ids=("${ids[@]}")
        echo "No se han seleccionado geografías, se van a usar todas: ${chosen_ids[*]}"
    else
        echo "Has elegido las siguientes geografias: ${chosen_ids[*]}"
    fi
    echo ""
}

# Prompt the user to choose the IDs
choose_ids

# Define the table-ID associations
declare -A table_ids
table_ids=(
    ["t_xmce_eod_prices_fi"]="HO"
    ["t_xgug_collateral_balances"]="HO"
    ["t_xgug_collateral_characteristic"]="HO"
    ["t_krdc_issuances_equity_derv"]="HO"
    ["t_xmce_equity_prices"]="HO"
    ["t_nztg_trade_core_inf_fo_eod_agg"]="HO"
    ["t_nztg_trade_prod_inf_fo_eod_agg"]="HO"
    ["t_xgug_trade_collateral_vm"]="HO"
    ["t_nztg_trade_core_inf_bo_eom"]="CO ES PE MX"
    ["t_nztg_trade_prod_inf_bo_eom"]="CO ES PE MX"
    ["t_nztg_secur_accounting_position"]="CO ES PE MX"
    ["t_xctk_wrong_way_risk"]="HO CO"
    ["t_xdkq_clearing_house"]="HO CO"
    ["t_xpdm_trade_netting_indicator"]="HO CO"
    ["t_xgug_guarantee_fund"]="HO CO MX"
    ["t_xmce_fx_price"]="HO CO PE"
    ["t_xctk_xva_risk"]="HO CO"
    ["t_xrei_trade_sa_ccr_attributes"]="HO CO ES PE MX"
    ["t_krdc_issuances_fixed_income"]=""
    ["t_xdkq_issuers"]=""
    ["t_xdkq_matrix_house"]=""
    ["t_xdkq_counterparty_dictionary"]=""
)

# Check if "criticas.txt" file exists
if [ ! -e "criticas.txt" ]; then
    echo "El fichero criticas.txt no existe."
    exit 1
fi

echo ""
read -p 'Escriba la cutoff_date en formato YYYY-MM-DD: ' cutoff_date
echo ""
read -p 'Escriba el odate en formato YYYYMMDD: ' odate
echo ""
echo "(Puede consultar el resultado de esta búsqueda en resultado_criticas.txt)"
echo ""
echo ""

# Check if "criticas.txt" file exists
if [ -e "criticas.txt" ]; then

    # Abrir resultado_criticas.txt para escritura
    exec 3>&1
    exec 1> >(tee resultado_criticas.txt)

    # Print the table headers
    printf "+----------------------------------+------------+-------+-----------+\n"
    printf "| %-32s | %-10s | %-5s | %-9s |\n" "TABLA" "FECHA" "HORA" "GEOGRAFIA"
    printf "+----------------------------------+------------+-------+-----------+\n"

    # Lee cada linea y busca el fichero para hoy
    while IFS= read -r line; do
    
        path=$(echo "$line" | awk '{print $1}')
        table=$(echo "$line" | awk '{print $2}')
        path_search="$path""$table"
        
        # Get the IDs to check for the current table
        table_ids_to_check="${table_ids[$table]}"

        # Check if the table is t_xdkq_counterparty_dictionary or t_xdkq_matrix_house
        if [ "$table" = "t_xdkq_counterparty_dictionary" ] || [ "$table" = "t_xdkq_matrix_house" ]; then
            output=$(hdfs dfs -ls -R "$path_search" | grep -m 1 '\.parquet$' | awk '{print $6, $7}')        
            printf "| %-32s | %-10s | %-5s | %-9s |\n" "$table" "$(echo "$output" | cut -d ' ' -f1)" "$(echo "$output" | cut -d ' ' -f2)" ""
            printf "+----------------------------------+------------+-------+-----------+\n"
        
        # Check if the table is t_krdc_issuances_fixed_income or t_xdkq_issuers  
        elif [ "$table" = "t_krdc_issuances_fixed_income" ] || [ "$table" = "t_xdkq_issuers" ]; then
            output=$(hdfs dfs -ls -R "$path_search" | grep "gf_odate_date_id=$odate" | grep -m 1 '\.parquet$' | awk '{print $6, $7}')
            printf "| %-32s | %-10s | %-5s | %-9s |\n" "$table" "$(echo "$output" | cut -d ' ' -f1)" "$(echo "$output" | cut -d ' ' -f2)" ""
            printf "+----------------------------------+------------+-------+-----------+\n"

        else
            # If not, proceed with checking IDs
            if [ -n "$table_ids_to_check" ]; then
                for id in $table_ids_to_check; do
                    # Check if the ID is in the chosen IDs
                    if [[ " ${chosen_ids[*]} " == *" $id "* ]]; then
                        g_entific_id="$id"

                        output=$(hdfs dfs -ls -R "$path_search" | grep "g_entific_id=$g_entific_id" | grep "gf_cutoff_date=$cutoff_date" | grep -m 1 '\.parquet$' | awk '{print $6, $7}')

                        # Check if the table is t_xctk_wrong_way_risk and g_entific_id is CO
                        if [ "$table" = "t_xctk_wrong_way_risk" ] && [ "$g_entific_id" = "CO" ]; then
                            # Calculate the last day of the previous month
                            cutoff_date_past=$(date -d "$cutoff_date -$(date +%d -d $cutoff_date) days" +%Y-%m-%d)

                            output=$(hdfs dfs -ls -R "$path_search" | grep "g_entific_id=$g_entific_id" | grep "gf_cutoff_date=$cutoff_date_past" | grep -m 1 '\.parquet$' | awk '{print $6, $7}')
                        fi              

                        # Print the formatted output                  
                        if [ -n "$output" ]; then
                            printf "| %-32s | %-10s | %-5s | %-9s |\n" "$table" "$(echo "$output" | cut -d ' ' -f1)" "$(echo "$output" | cut -d ' ' -f2)" "$id"
                            printf "+----------------------------------+------------+-------+-----------+\n"
                        else
                            printf "| %-32s | %-10s | %-5s | %-9s |\n" "$table" "" "" "$id"
                            printf "+----------------------------------+------------+-------+-----------+\n"
                        fi
                    fi
                done
            else
                # If no IDs specified for this table, print it without checking IDs      
                printf "| %-32s | %-10s | %-5s | %-9s |\n" "$table" "" "" ""
                printf "+----------------------------------+------------+-------+-----------+\n"
            fi
        fi
        
    done < "criticas.txt"

    # Cerrar el descriptor de archivo
    exec 1>&3
    exec 3>&-
    
else
    echo "El fichero criticas.txt no existe."
fi
