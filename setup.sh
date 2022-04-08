#!/usr/bin/env bash

# Determine location of the script file with respect to the local folder structure
script_dir="$(dirname "${BASH_SOURCE[0]}")"
script_dir="$(realpath "${script_dir}")"

# Get the location where the new project should be located
output_dir=$(pwd)

# Get the name of the new project
[[ -z "$1" ]] && { echo "Error: no project name given. Please read the README.md file for usage."; exit 1; }
project_name=$1

# Get some basic info of the developer to deploy the project
echo "Deploying a new plutus development project '"$project_name"' in the directory: " $output_dir
echo "Developers name: "
read name
[[ -z "$name" ]] && { name="John Doe"; }
echo "Contact email: "
read email
[[ -z "$email" ]] && { email="JohnDoe@mail.com"; }

#Creating the directory for the new project
new_dir=$output_dir/$project_name
[ -d "$new_dir" ] && { echo "Error: Directory already exists. Please read the README.md file for usage."; exit 1; }

# Copying all files of the project and removing unwanted artifacts of this script
mkdir $project_name
cp -r $script_dir/* $new_dir
rm $new_dir/setup.sh

# Renaming all important variables in the cabal structure to the new one
sed -i 's/cleanPlutusProject.cabal/'$project_name'.cabal/g' $new_dir/cabal.project
sed -i 's/cleanPlutusProject/'$project_name'/g' $new_dir/cleanPlutusProject.cabal
sed -i 's/DevName/'$name'/g' $new_dir/cleanPlutusProject.cabal
sed -i 's/DevEmail/'$email'/g' $new_dir/cleanPlutusProject.cabal

# Renaming the .cabal file
mv $new_dir/cleanPlutusProject.cabal $new_dir/$project_name.cabal

# Giving the correct tag to use in the plutus-app directory for a nix-shell for this repo.
plutus_app_line=$(awk '/plutus-app/{ print NR; exit }' $new_dir/cabal.project)
plutus_app_line=$(($plutus_app_line + 1))
echo "Use this git tag for you plutus-app git repository to build te dependacies for your "$project_name" project."
sed "${plutus_app_line}q;d" $new_dir/cabal.project | awk '{print $1}'
