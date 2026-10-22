#!/bin/bash
i=3
# Iterate over all subdirectories in the current directory.
for dir in */; do
    dir=${dir%/}  # Remove the trailing slash.

    # Enter the selected replica directory.
    zero_dir="${dir}/${i}"
    if [ -d "$zero_dir" ]; then
        cd "$zero_dir"
        echo " cd "$zero_dir""
        # Enter the output subdirectory.
        output_dir="output"
        if [ -d "$output_dir" ]; then
            cd "$output_dir"

            # Check for a PDB file.
            pdb_file=$(ls *50000*.pdb 2>/dev/null | head -n 1)
            if [ -n "$pdb_file" ]; then
                # Return to the selected replica directory.
                cd ..

                # Create the chain_index.ndx file.
                gmx make_ndx -f output/"$pdb_file" -o chain_index.ndx << EOF
chain A|chain B
name 10 HLA
chain C
name 11 pep
chain D|chain E
name 12 TCR
chain A|chain B|chain C
name 13 pHLA
q
EOF

                echo "Created index file for $dir"

                # Calculate hydrogen bonds between the peptide and HLA.
                echo "10 11" | gmx hbond -s md.tpr -f ${dir}_${i}.xtc -n chain_index.ndx -num ${dir}_${i}_hbond_p_HLA.xvg -tu ns -hbn hbond_p_HLA.ndx

                # Calculate hydrogen bonds between TCR and pHLA.
                echo "12 13" | gmx hbond -s md.tpr -f ${dir}_${i}.xtc -n chain_index.ndx -num ${dir}_${i}_hbond_TCR_pHLA.xvg -tu ns -hbn hbond_TCR_pHLA.ndx

            else
                echo "No PDB file found in $output_dir. Skipping..."
            fi
        else
            echo "No output directory found in $zero_dir. Skipping..."
        fi
    else
        echo "No ${i} directory found in $dir. Skipping..."
    fi

    # Return to the parent directory.
    cd ..
done
