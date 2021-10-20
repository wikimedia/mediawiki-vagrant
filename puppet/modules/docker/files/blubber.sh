#####################################
# THIS FILE IS MAINTAINED BY PUPPET #
#####################################

if [ $# -lt 2 ]; then
	echo 'Usage: blubber config.yaml variant'
	exit 1
fi
curl -s -H 'content-type: application/yaml' --data-binary @"$1" https://blubberoid.wikimedia.org/v1/"$2"
