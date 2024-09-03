### Copy file names from ls -lh
ls -lh <dir> | cut -d ' ' -f 11 | cut -d '_' -f 1 | awk NF

### Rsync
rsync -r -h  <source> <destination>

### Delete line using vim example deleting 95N 
g/[0-9]N/d

### Remove empty lines vim
g/^$/d


### Activate conda dir
export PATH=$HOME/miniconda3/bin:$PATH

### Adding default channels for conda
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --set channel_priority strict

### Get depend... packages
conda info --all artic


### Mysql windows fixes
https://stackoverflow.com/questions/51448958/mysql-server-8-0-keyring-migration-error-at-login

### Running java with sdk
java --module-path ~/Downloads/javafx-sdk-21.0.1/lib --add-modules javafx.controls,javafx.fxml -jar ~/IdeaProjects/Glue_02052024/out/artifacts/Glue_jar/Glue.jar

### List process running in screen mode
login to GPU 
ps -x
