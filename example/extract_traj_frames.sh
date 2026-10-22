#!/bin/bash
# Set the replica ID to 0, 1, or 2.
i=2


# Store the absolute path of the current working directory.
current_dir=$(pwd)

# Adjust the glob below to match the desired directory name prefix.
for dir in *; do
     dir=${dir%/}  # Remove the trailing slash.
    dir_name=$(basename "$dir")
    echo "Processing folder: $dir_name"
    
    # Enter the selected replica directory.
    if cd "$dir/${i}"; then
        # Check whether md.gro exists.
        if [ -f "md.gro" ]; then
            echo "Found md.gro in $dir_name/0"
            

                    # Use the directory name as job1.
                    job1=$(basename "$dir")
                    
                    # 1. Convert the trajectory with the peptide at the center.
                    echo "1 0" | gmx trjconv -s md.tpr -f md.xtc -o "${job1}_${i}_md_nopbc.xtc" -n index.ndx -ur compact -center -pbc mol
                    echo "Completed step 1: peptide-centered trajectory conversion."
                    
                    # 2. Convert the trajectory to remove jumps across periodic boundaries.
                    #echo "0" | gmx trjconv -s md.tpr -f "${job1}_${i}_md_nopbc.xtc" -o "${job1}_${i}_md_nojump.xtc" -n index.ndx -pbc nojump
                    #echo "Completed step 2: trajectory conversion without boundary jumps."
                    
                    # 3. Generate a TCR-pHLA-only trajectory without jumps across periodic boundaries.
                    echo "1" | gmx trjconv -s md.tpr -f "${job1}_${i}_md_nopbc.xtc" -o "${job1}_${i}.xtc" -n index.ndx -pbc nojump
                    echo "Completed step 3: TCR-pHLA trajectory generation."
                    
                    # 4. Calculate RMSD.
                   
		    echo -e "1\n1\n" | gmx rms -s md.tpr -f "${job1}_${i}.xtc"  -o "${job1}_${i}_rmsd.xvg"
                    echo "Completed step 4: RMSD calculation."
                    
                    # 5. Export a protein PDB file every 50 ps.
                    start_time=0
                    end_time=50000  # Assume a total duration of 50 ns (50000 ps).
                    step=50
                    count=0
                    
                    # Create the output directory.
                    output_dir="output"
                    mkdir -p "$output_dir"
                    
                    for ((t=start_time; t<=end_time; t+=step)); do
                        output_pdb="${job1}_${i}_${t}ps.pdb"
                        echo "1" | gmx trjconv -f "${job1}_${i}.xtc" -s md.tpr -pbc mol -ur compact -o "$output_pdb" -b $t -e $t
                        echo "Generated PDB file: $output_pdb"
                        
                        # Move the PDB file to the output directory.
                        mv "$output_pdb" "$output_dir"
                        ((count++))
                    done
                    
                    echo "Generated $count PDB files."
                else
                    echo "md.gro file not found in subdirectory: 0. Skipping analysis."
                fi
                
                # Return to the parent directory.
                cd ..
            fi
            
            # Return to the parent directory.
            cd ..
    done

# Return to the original working directory.
cd "$current_dir"
