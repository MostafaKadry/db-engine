#!/bin/bash

# Create New DataBase == > Create new Dir
mostafa-db () {
    create=$1
    db=$2
    name=$3
    if [ "$create" == 'create' ] && [ "$db" == 'db' ] && [ "$name" ]; then
        mkdir -p "${name}"
        echo "Database '$name' created successfully!"
    else
        echo "#####################################"
        echo "Syntax Error: To create a new database, use:"
        echo "  mostafa-db create db your-db-name"
        echo ""
        echo "Optionally, specify the location to store the database."
        echo "To create a new database in a specific location, provide an absolute or relative path before the database name."
        echo "Ensure that no file or directory exists with the same name."
        echo ""
        echo "If no location is specified, the current directory is used to store your database."
        echo "######################################"
    fi
}

# Create New Table ==  > Create new CSV file

function table.create () {
    dbName=$1
    table_name=$3

    if [ -n "$dbName" ] && [ -n "$table_name" ]; then
        dbPath="${PWD}/${dbName}"

        # Check if the database directory exists
        if [ -d "$dbPath" ]; then
            tablePath="${dbPath}/${table_name}"

            # Check if the table file already exists
            if [ -f "$tablePath" ]; then
                echo "Error: The table '$table_name' already exists in database '$dbName'!"
            else
                touch "$tablePath".csv
                echo "Table '$table_name' created successfully in database '$dbName'."
            fi
        else
            echo "Error: No such database '$dbName' exists."
        fi
    else
        echo "#####################################"
        echo "Syntax Error: To create a new table, use:"
        echo "  table.create db-name new-table-name"
        echo "Example: table mydatabase create users_table"
        echo "######################################"
    fi
}

# Create Schema ==> new csv file with cols names and link with table
# schema.create new-schema-name db-name
function schema.create () {
    schemaName=$1
    dbName=$2

    if [ -n "$dbName" ] && [ -n "$schemaName" ]; then
        dbPath="${PWD}/${dbName}"

        # Check if the database directory exists
        if [ -d "$dbPath" ]; then
            if ! [ -d "${dbPath}/${dbName}-schema" ]; then
                mkdir -p "${dbPath}/${dbName}-schema"
            fi

            schemaPath="${dbPath}/${dbName}-schema/${schemaName}"

            # Check if the schema file already exists
            if [ -f "$schemaPath".csv ]; then
                echo "The schema '$schemaName' already exists in database '$dbName'"
                echo "What would you like to do?"
                select choice in "Keep the old schema" "Replace with the new schema" "Cancel"; do
                    case $choice in
                        "Keep the old schema")
                            echo "Keeping the old schema: $schemaName"
                            break
                            ;;
                        "Replace with the new schema")
                            echo "Replacing the old schema: $schemaName"
                            echo "colName,dataType,required,unique" > "$schemaPath.csv"
                            break
                            ;;
                        "Cancel")
                            echo "Operation canceled."
                            return 0
                            ;;
                        *)
                            echo "Invalid option. Please choose 1 (Keep), 2 (Replace), or 3 (Cancel)."
                            ;;
                    esac
                done

            else
                echo "colName,dataType,required,unique" > "$schemaPath.csv"
                echo "id,string,true,true" >> "$schemaPath.csv"
                echo "schema '$schemaName' created successfully in database '$dbName'."
            fi
        else
            echo "Error: No such database '$dbName' exists."
        fi
    else
        echo "#####################################"
        echo "Syntax Error: To create a new schema, use:"
        echo "  schema.create new-schema-name db-name"
        echo "######################################"
    fi
}

# Linking Schema to its Table => add meta data in schema file for table name and its path.
# schema.link schema-name table-name db-name
function schema.link () {
    schemaName=$1
    tableName=$2
    dbName=$3
    if [ "$schemaName" ] && [ "$tableName" ] && [ "$dbName" ]; then
        dbPath="${PWD}/${dbName}"
        schemaPath="${PWD}/${dbName}/${dbName}-schema/${schemaName}.csv"
        tablePath="${PWD}/${dbName}/${tableName}.csv"

        if [ -d "$dbPath" ]; then
            if [ -f "$tablePath" ]; then
                if [ -f "$schemaPath" ]; then
                    existingSchema=$(grep "^schema_name," "$tablePath" | cut -d ',' -f2)
                    schemaCols=$(awk -F ',' 'NR>1 {print $1}' "$schemaPath" | paste -sd ',')
                    if [ -n "$existingSchema" ]; then
                        echo "Error: A Table is already linked to schema '$existingSchema' in database '$dbName'!"
                        echo ""
                        echo "PLZ, Note: If you need to link table to another schema delete it and create it again."
                    else
                           # check if File is NOT empty, then use sed to insert at the top
                        if [ -s "$tablePath" ]; then
                            # sed -i "1s|^|schema_name,$schemaName,schema_path,$schemaPath\n|" "$tablePath"
                            # sed -i "2s|^|$schemaCols,\n|" "$tablePath"
                            echo "Erorr: Table is not empty, you can't link schema to it."
                            echo " "
                            echo "PLZ, Note: If you need to link table to another schema delete it and create it again."
                        else
                            # if File is empty, then directly write schema to it

                            if ! [ -z "$schemaCols" ];then 
                                newschemaCols="${schemaCols%,}"
                                echo "schema_name,$schemaName,schema_path,$schemaPath" > "$tablePath"
                                echo "$newschemaCols" >> "$tablePath"
                                echo "Table '$tableName' successfully linked to schema '$schemaName'."
                            
                            else
                                echo "Error: The schema '$schemaName' is empty!"
                                echo "Before linking the schema to the table, add constrains to the schema."
                            fi


                        fi
                    fi
                else
                    echo "Error: The schema '$schemaName' does not exist in database '$dbName'!"
                fi
            else
                echo "Error: Table '$tableName' does not exist in database '$dbName'!"
            fi
        else
            echo "Error: Database '$dbName' does not exist!"
        fi
    else
        echo "#####################################"
        echo "Syntax Error: To link a schema to a certain table, use:"
        echo "  schema.link schema-name table-name db-name"
        echo "######################################"
    fi
}

# insert constraints to this schema
# schema.constrains schema-name db-name "[col-name, data-type, required|optional, unique]..."
function schema.constrains () {
    pattern='^\[[a-zA-Z0-9_]+, [a-zA-Z0-9_]+, (required|optional)(, unique)?\]$'

    # Function to validate schema arguments
    validate_constrains() {
        for arg in "$@"; do
            if [[ "$arg" =~ $pattern ]]; then
                echo "Valid constrain: $arg"
            else
                echo "################################"
                echo "Error: Invalid constrain format -> $arg"
                return 987
            fi
        done
        return 0
    }

    schemaName=$1
    dbName=$2
    shift 2
    constrains=("$@")

    if [ -z "$schemaName" ] || [ -z "$dbName" ] || [ ${#constrains[@]} -eq 0 ]; then
        echo " "
        echo "#####################################"
        echo "Syntax Error: To add constrains to schema, use:"
        echo "  schema.constrains schema-name db-name \"[col-name, data-type, required|optional, unique]...\""
        echo "  you can insert more than one constrain but ensure every one is between []"
        echo "  by default it is optional and not unique"
        echo " "
        echo "Mostafa k. DB :)"
        echo "######################################"
        return 101
    fi

    dbPath="${PWD}/${dbName}"
    schemaPath="${PWD}/${dbName}/${dbName}-schema/${schemaName}.csv"

    if ! [ -d ${dbPath} ]; then
        echo "Error: no such Database '${dbName}'"
        return 102
    fi

    if ! [ -f ${schemaPath} ];then
        echo "Error: no such Schema '${schemaName}'"
        return 103
    fi

    validate_constrains "${constrains[@]}"

    if [ $? -eq 0 ]; then
        for const in "${constrains[@]}"; do
            # Remove the square brackets and split the constraint into parts
            const=$(echo "$const" | sed 's/^\[//; s/\]$//')

            IFS=', ' read -r colName dataType requirement unique <<< "$const"

            # Set the required column value
            if [[ "$requirement" == "required" ]]; then
                required="true"
            elif [[ "$requirement" == "optional" ]]; then
                required="false"
            else
                required="false"  # Default to false if not specified
            fi

            # Set the unique column value
            if [[ "$unique" == "unique" ]]; then
                unique="true"
            else
                unique="false"  # Default to false if not specified
            fi

            # Check if the column already exists in the schema
            if grep -q "^$colName," "$schemaPath"; then
                echo "A column with the name '$colName' already exists in the schema."
                echo "What would you like to do?"
                select choice in "Keep the old column" "Replace with the new column" "Cancel"; do
                    case $choice in
                        "Keep the old column")
                            echo "Keeping the old column: $colName"
                            break
                            ;;
                        "Replace with the new column")
                            echo "Replacing the old column: $colName"
                            # Remove the old column from the schema file
                            sed -i "/^$colName,/d" "$schemaPath"
                            # Add the new column
                            echo "$colName,$dataType,$required,$unique" >> "$schemaPath"
                            break
                            ;;
                        "Cancel")
                            echo "Operation canceled."
                            return 0
                            ;;
                        *)
                            echo "Invalid option. Please choose 1 (Keep), 2 (Replace), or 3 (Cancel)."
                            ;;
                    esac
                done
            else
                # Add the new column to the schema file
                echo "$colName,$dataType,$required,$unique" >> "$schemaPath"
                echo "Added constraint: $colName, $dataType, Required: $required, Unique: $unique"
            fi
        done

        if [ ${#constrains[@]} -gt 1 ]; then
            echo "All Constraints successfully added!"
        fi
    else
        echo "The valid format is \"[col-name, data-type, required|optional, unique]...\""
        echo "Note: 'unique' is optional by default it's not unique"
        echo "################################"
        return 987
    fi
}

# Create new row => check data, insert it in table file 
# table.insert table-name db-name {col_name: col_data, ...}


function table.insert() {
    
    function generate_random_id() {
        openssl rand -base64 6 | tr -dc 'A-Za-z0-9' | head -c 8
    }

    tableName=$1
    dbName=$2
    shift 2
    rawData="$*"  # Preserve original input

    if [ -z "$tableName" ] || [ -z "$dbName" ] || [ -z "$rawData" ]; then
        echo "#####################################"
        echo "Syntax Error: To insert a new row in Table, use:"
        echo "  table.insert table-name db-name {col_name: col_data, ...} "
        echo "######################################"
        return 106
    fi

    dbPath="${PWD}/${dbName}"
    tablePath="${PWD}/${dbName}/${tableName}.csv"

    if ! [ -d "${dbPath}" ]; then
        echo "Error: No such Database '${dbName}'"
        return 102
    fi

    if ! [ -f "${tablePath}" ]; then
        echo "Error: No such Table '${tableName}'"
        return 103
    fi

    schemaPath=$(awk -F, 'NR==1 {print $4}' "$tablePath")

    if [ -z "$schemaPath" ] || ! [ -f "$schemaPath" ]; then
        echo "Error: No Schema is linked to your table '${tableName}'"
        return 107
    fi

    # Load schema columns
    schemaCols=($(awk -F ',' 'NR>1 {print $1}' "$schemaPath"))
    requiredCols=($(awk -F ',' '$3=="true" {print $1}' "$schemaPath"))
    uniqueCols=($(awk -F ',' '$4=="true" {print $1}' "$schemaPath"))

    declare -A userData
    # Remove '{' and '}'
    data="${rawData//\{ /}"
    data="${data// \}/}"

    # Parse user input into key-value pairs
    while [[ $data =~ ([a-zA-Z0-9_]+)[[:space:]]*:[[:space:]]*\"?([^,}]+)\"?[[:space:]]*,?[[:space:]]* ]]; do
        key="${BASH_REMATCH[1]}"
        value="${BASH_REMATCH[2]}"

        if [[ "$key" = "id" ]]; then
            echo "Error: You can't insert the 'id' column. It's auto-generated."
            return 108
        fi

        value=$(echo "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/^"\(.*\)"$/\1/')
        userData["$key"]="$value"
        data="${data#*"${BASH_REMATCH[0]}"}"
    done

    # Generate a unique random ID
    while true; do
        autoID=$(generate_random_id)     
        # Check if ID already exists in the table
        if awk -F ',' -v val="$autoID" -v idx=1 'NR>1 && $idx==val {exit 1}' "$tablePath"; then
            break
        fi
    done

    userData["id"]="$autoID" 
    if [[ "${#userData[@]}" -lt 2 ]]; then
        echo "#####################################"
        echo "Error: No data provided to insert into table '$tableName'."
        echo "Please provide data in the format: {col_name: col_data, ...}"
        echo "Ensure that the column names and data are enclosed in curly braces."
        echo "Example: table.insert users_db users_table {name: 'John Doe', age: 30, email: '}"
        echo "Note: The 'id' column is auto-generated and should not be provided."
        echo "Mostafa k. DB :)"
        echo "#####################################"
        return 109
    fi
    # Validate user columns against schema
    for col in "${!userData[@]}"; do
        exists=false
        for schema_col in "${schemaCols[@]}"; do
            if [[ "$schema_col" == "$col" ]]; then
                exists=true
                break
            fi
        done

        if ! $exists; then
            echo "Error: Column '$col' does not exist in the schema of table '$tableName'."
            return 104
        fi
    done

    # Check required columns
    for col in "${requiredCols[@]}"; do
        if [[ -z "${userData[$col]}" ]]; then
            echo "Error: Column '$col' is required but not provided in the data."
            return 105
        fi
    done

    # Check unique constraints
    for col in "${uniqueCols[@]}"; do
        colIndex=$(awk -F ',' -v col="$col" 'NR==1 {for (i=1; i<=NF; i++) if ($i==col) print i}' "$tablePath")
        colValue="${userData[$col]}"

        if [[ -n "$colValue" ]] && grep -q "^.*,\?$colValue,\?.*$" "$tablePath"; then
            echo "Error: Column '$col' must be unique but the value '$colValue' already exists in the table."
            return 106
        fi
    done

    # Construct new row
    newRow=""
    for col in "${schemaCols[@]}"; do
        newRow+="${userData[$col]:-NULL},"
    done
    newRow="${newRow%,}"

    # Insert data
    echo "$newRow" >> "$tablePath"
    echo inserted row data = $newRow
    echo "Row inserted successfully into table '$tableName'."
}

# Retrieve row/s => search in given file
# table.select table-name db-name {col_name: col_data}
function table.select() {
    tableName=$1
    dbName=$2
    shift 2
    dataToSearch="$*" 

    if [ -z "$tableName" ] || [ -z "$dbName" ] || [ -z "$dataToSearch" ]; then
        echo "#####################################"
        echo "Syntax Error: To select a row from Table, use:"
        echo "  table.select table-name db-name {col_name: col_data, ...} "
        echo "######################################"
        return 106
    fi

    dbPath="${PWD}/${dbName}"
    tablePath="${PWD}/${dbName}/${tableName}.csv"

    if ! [ -d "${dbPath}" ]; then
        echo "Error: No such Database '${dbName}'"
        return 102
    fi

    if ! [ -f "${tablePath}" ]; then
        echo "Error: No such Table '${tableName}'"
        return 103
    fi

    schemaPath=$(awk -F ',' 'NR==1 {print $4}' "$tablePath")

    if [ -z "$schemaPath" ] || ! [ -f "$schemaPath" ]; then
        echo "Error: No Schema is linked to your table '${tableName}'"
        return 107
    fi

declare -A userData
    # Remove '{' and '}'
    data="${dataToSearch//\{ /}"
    data="${data// \}/}"

    # Parse user input into key-value pairs
    while [[ $data =~ ([a-zA-Z0-9_]+)[[:space:]]*:[[:space:]]*\"?([^,}]+)\"?[[:space:]]*,?[[:space:]]* ]]; do
        key="${BASH_REMATCH[1]}"
        value="${BASH_REMATCH[2]}"
        value=$(echo "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/^"\(.*\)"$/\1/')
        userData["$key"]="$value"
        data="${data#*"${BASH_REMATCH[0]}"}"
    done
    
    echo "userData = ${userData[@]}"

    tableCols=($(awk -F ',' 'NR==2 {print $0}' "$tablePath"))
    echo tableCols = ${tableCols[@]}
}

# Delete row/s => search and delete
# Update row/s => modify data in file