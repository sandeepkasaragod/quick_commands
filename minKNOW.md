sudo su -

apt-key adv --fetch-keys https://cdn.oxfordnanoportal.com/apt/ont-repo.pub

echo "deb http://cdn.oxfordnanoportal.com/apt focal-stable non-free" | sudo tee /etc/apt/sources.list.d/nanoporetech.sources.list

apt update

apt install ont-standalone-minknow-release


apt update && apt list --upgradable
