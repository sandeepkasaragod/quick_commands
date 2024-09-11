#!/bin/bash

# Get the system architecture and OS type
architecture=$(uname -m)
os_type=$(uname)

# Check if conda is installed
if command -v conda &> /dev/null
then
    conda_installed=true
    echo "Conda is already installed."
else
    conda_installed=false
    echo "Conda is not installed."
fi

# Function to download and install Miniforge
conda_install() {
    local download_url=$1
    local install_dir=$2
    local conda_source=$3
    local installer_name="conda_installer.sh"

    # Download the installer
    echo "Downloading Miniforge from $download_url"
    curl -L -o $installer_name $download_url

    # Make the installer executable
    chmod +x $installer_name

    # Run the installer
    bash $installer_name -b -p $install_dir

    # Initialize conda
    source $conda_source
    conda init

    if command -v conda &> /dev/null
    then
        echo "Conda initialized successfully."
    else
        echo "Failed to initialize Conda."
    fi
}

setup_conda_env() {
    # Add bioconda and conda-forge channels
    echo "Adding conda channels: conda-forge, bioconda"
    conda config --add channels conda-forge
    conda config --add channels bioconda
    conda config --add channels defaults

    if [[ -f "gluetools.yml" ]]; then
        echo "Creating conda environment from gluetools.yml"
        conda env create -f gluetools.yml
    else
        echo "Error: gluetools.yml file not found."
    fi

    if [[ -f "environment.yml" ]]; then
        echo "Creating conda environment from environment.yml"
        conda env create -f environment.yml
    else
        echo "Error: environment.yml file not found."
    fi
}

activate_gluetools_and_get_paths() {
    # Check if the gluetools environment exists
    if conda env list | grep -q 'gluetools'; then
        echo "Activating the gluetools environment."
        source "$(conda info --base)/etc/profile.d/conda.sh"
        conda activate gluetools

        # List the tools to check
        local tools=("blastn" "tblastn" "makeblastdb" "mafft" "raxmlHPC" "table2asn")

        for tool in "${tools[@]}"; do
            tool_path=$(command -v $tool)
            if [[ -n "$tool_path" ]]; then
                echo "$tool is installed at: $tool_path"
                # Add the paths to gluetools-config.xml
                update_gluetools_config "$tool" "$tool_path"
            else
                echo "$tool is not installed in the gluetools environment."
            fi
        done

        # Deactivate the environment after use
        conda deactivate
    else
        echo "The gluetools environment is not found."
    fi
}

update_gluetools_config() {
    local tool_name=$1
    local tool_path=$2
    local current_working_dir=$(pwd)/tmp

    # Update gluetools-config.xml with the correct path for the tool and its temporary directory
    config_file="gluetools-config.xml"
    if [[ -f "$config_file" ]]; then
        echo "Updating $config_file for $tool_name"
				echo "Updating samtools temp directory in $config_file"
    		sed -i.bak "s|<value>.*samfiles</value>|<value>$current_working_dir/samfiles</value>|g" $config_file
        
        case "$tool_name" in
            "blastn")
                sed -i.bak "s|<value>.blastn</value>|<value>$tool_path</value>|g" $config_file
                sed -i.bak "s|<value>.*/blastfiles</value>|<value>$current_working_dir/blastfiles</value>|g" $config_file
                sed -i.bak "s|<value>.*/blastdbs</value>|<value>$current_working_dir/blastdbs</value>|g" $config_file
                ;;
            "tblastn")
                sed -i.bak "s|<value>.*tblastn</value>|<value>$tool_path</value>|g" $config_file
                ;;
            "makeblastdb")
                sed -i.bak "s|<value>.*makeblastdb</value>|<value>$tool_path</value>|g" $config_file
                ;;
            "mafft")
                sed -i.bak "s|<value>.*mafft</value>|<value>$tool_path</value>|g" $config_file
                sed -i.bak "s|<value>.*/mafftfiles</value>|<value>$current_working_dir/mafftfiles</value>|g" $config_file
                ;;
            "raxmlHPC")
                sed -i.bak "s|<value>.*raxmlHPC</value>|<value>$tool_path</value>|g" $config_file
                sed -i.bak "s|<value>.*/raxmlfiles</value>|<value>$current_working_dir/raxmlfiles</value>|g" $config_file
                ;;
            "table2asn")
                sed -i.bak "s|<value>.*table2asn</value>|<value>$tool_path</value>|g" $config_file
                sed -i.bak "s|<value>.*/tbl2asn</value>|<value>$current_working_dir/tbl2asnfiles</value>|g" $config_file
                ;;
            *)
                echo "Unknown tool: $tool_name"
                ;;
        esac
    else
        echo "$config_file not found, creating a new one."
        create_gluetools_config
    fi
}

create_gluetools_config() {
    # Create gluetools-config.xml with default tool paths (update dynamically as needed)
    local current_working_dir=$(pwd)/tmp

    cat <<EOL > gluetools-config.xml
<gluetools>
	<database>
		<username>gluetools</username>
		<password>Password123#@!</password>
		<vendor>MySQL</vendor>
		<jdbcUrl>jdbc:mysql://localhost:3306/GLUE_TOOLS?characterEncoding=UTF-8</jdbcUrl>	
	</database>
	<properties>
		<!-- BLAST specific config -->
		<property>
			<name>gluetools.core.programs.blast.blastn.executable</name>
			<value>/path/to/blastn</value>
		</property>
		<property>
			<name>gluetools.core.programs.blast.tblastn.executable</name>
			<value>/path/to/tblastn</value>
		</property>
		<property>
			<name>gluetools.core.programs.blast.makeblastdb.executable</name>
			<value>/path/to/makeblastdb</value>
		</property>
		<property>
			<name>gluetools.core.programs.blast.temp.dir</name>
			<value>$current_working_dir/tmp/blastfiles</value>
		</property>
		<property>
			<name>gluetools.core.programs.blast.db.dir</name>
			<value>$current_working_dir/tmp/blastdbs</value>
		</property>
		<!-- MAFFT specific config -->
		<property>
			<name>gluetools.core.programs.mafft.executable</name>
			<value>/path/to/mafft</value>
		</property>
		<property>
			<name>gluetools.core.programs.mafft.temp.dir</name>
			<value>$current_working_dir/tmp/mafftfiles</value>
		</property>
		<!-- RAxML-specific config -->
		<property>
			<name>gluetools.core.programs.raxml.raxmlhpc.executable</name>
			<value>/path/to/raxmlHPC</value>
		</property>
		<property>
			<name>gluetools.core.programs.raxml.temp.dir</name>
			<value>$current_working_dir/tmp/raxmlfiles</value>
		</property>
		<!-- tbl2asn-specific config -->
		<property>
			<name>gluetools.core.programs.tbl2asn.executable</name>
			<value>/path/to/table2asn</value>
		</property>
		<property>
			<name>gluetools.core.programs.tbl2asn.temp.dir</name>
			<value>$current_working_dir/tmp/tbl2asnfiles</value>
		</property>
	</properties>
</gluetools>
EOL
}

if [[ "$conda_installed" == "false" ]]; then
    if [[ "$os_type" == "Darwin" && "$architecture" == "arm64" ]]; then
        echo "macOS on ARM architecture detected. Downloading Miniforge for ARM64..."
        conda_install "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-arm64.sh" "$HOME/miniforge3" "$HOME/miniforge3/etc/profile.d/conda.sh"

    elif [[ "$os_type" == "Darwin" && "$architecture" == "x86_64" ]]; then
        echo "macOS on x86_64 architecture detected. Downloading Miniforge for x86_64..."
        conda_install "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-x86_64.sh" "$HOME/miniforge3" "$HOME/miniforge3/etc/profile.d/conda.sh"

    elif [[ "$os_type" == "Linux" && "$architecture" == "x86_64" ]]; then
        echo "Linux on x86_64 architecture detected. Downloading Miniforge for x86_64..."
        conda_install "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh" "$HOME/miniconda3" "$HOME/miniconda3/etc/profile.d/conda.sh"

    elif [[ "$os_type" == "Linux" && "$architecture" == "aarch64" ]]; then
        echo "Linux on aarch64 architecture detected. Downloading Miniconda for aarch64..."
        conda_install "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-aarch64.sh" "$HOME/miniforge3" "$HOME/miniforge3/etc/profile.d/conda.sh"

    else
        echo "Unsupported OS type or architecture for this script."
    fi
    setup_conda_env
else
    echo "Skipping installation as Conda is already installed."
		setup_conda_env
    activate_gluetools_and_get_paths
fi

#activate_gluetools_and_get_paths
