#!/bin/bash

# Expected command-line parameters order:
# Same as order below. Specify all or nothing.

# Expected env variables:
# RANCHER_URL="http://rancher/"
#
# RANCHER_BACKEND_ENV_ID="1asdfasdf234"
# RANCHER_BACKEND_ACCESS_KEY="abunchofhex"
# RANCHER_BACKEND_SECRET_KEY="sosecretmorehex"
#
# RANCHER_FRONTEND_ENV_ID="1asdfa13135"
# RANCHER_FRONTEND_ACCESS_KEY="abunchmorehex"
# RANCHER_FRONTEND_SECRET_KEY="sosecretevenmorehex"
#
# ENVKEY_MASTER_KEY="someguid"

set -e

if [ $# -gt 0 ]
then
	echo "Found $# parameters on the command line. Loading them."
	export RANCHER_URL="$1"
	export RANCHER_BACKEND_ENV_ID="$2"
	export RANCHER_BACKEND_ACCESS_KEY="$3"
	export RANCHER_BACKEND_SECRET_KEY="$4"
	export RANCHER_FRONTEND_ENV_ID="$5"
	export RANCHER_FRONTEND_ACCESS_KEY="$6"
	export RANCHER_FRONTEND_SECRET_KEY="$7"
	export ENVKEY_MASTER_KEY="$8"
	export RANCHER2_DEPLOY_VARS_ENVKEY="$9"
fi

function validate_variables() {
    echo '##octopus[stderr-default]'

    if [ -z "$DEFAULT_SERVICE_SCALE" ]
    then
        export DEFAULT_SERVICE_SCALE="`get_octopusvariable 'DEFAULT_SERVICE_SCALE'`"  || :
        if [ -z "$DEFAULT_SERVICE_SCALE" ]
        then
            echo "[deploy_snapshot.sh] ERROR: No DEFAULT_SERVICE_SCALE specified. Cannot continue." 1>&2
            exit 1
        fi
    fi
    if [ -z "$RANCHER2_DEPLOY_VARS_ENVKEY" ]
    then
        export RANCHER2_DEPLOY_VARS_ENVKEY="`get_octopusvariable 'RANCHER2_DEPLOY_VARS_ENVKEY'`" || :
        if [ -z "$RANCHER2_DEPLOY_VARS_ENVKEY" ]
        then
            echo "[deploy_snapshot.sh] ERROR: No RANCHER2_DEPLOY_VARS_ENVKEY specified. Cannot continue." 1>&2
            exit 1
        fi
    fi
    if [ -z "$ENVKEY_MASTER_KEY" ]
    then
        export ENVKEY_MASTER_KEY="`get_octopusvariable 'ENVKEY_MASTER_KEY'`" || :
        if [ -z "$ENVKEY_MASTER_KEY" ]
        then
            echo "[deploy_snapshot.sh] ERROR: No ENVKEY_MASTER_KEY specified. Cannot continue." 1>&2
            exit 1
        fi
    fi
    if [ -z "$RANCHER_BACKEND_ACCESS_KEY" ]
    then
        export RANCHER_BACKEND_ACCESS_KEY="`get_octopusvariable 'RANCHER_BACKEND_ACCESS_KEY'`" || :
        if [ -z "$RANCHER_BACKEND_ACCESS_KEY" ]
        then
            echo "[deploy_snapshot.sh] ERROR: No RANCHER_BACKEND_ACCESS_KEY specified. Cannot continue." 1>&2
            exit 1
        fi
    fi
    if [ -z "$RANCHER_BACKEND_ENV_ID" ]
    then
        export RANCHER_BACKEND_ENV_ID="`get_octopusvariable 'RANCHER_BACKEND_ENV_ID'`" || :
        if [ -z "$RANCHER_BACKEND_ENV_ID" ]
        then
            echo "[deploy_snapshot.sh] ERROR: No RANCHER_BACKEND_ENV_ID specified. Cannot continue." 1>&2
            exit 1
        fi
    fi
    if [ -z "$RANCHER_BACKEND_SECRET_KEY" ]
    then
        export RANCHER_BACKEND_SECRET_KEY="`get_octopusvariable 'RANCHER_BACKEND_SECRET_KEY'`" || :
        if [ -z "$RANCHER_BACKEND_SECRET_KEY" ]
        then
            echo "[deploy_snapshot.sh] ERROR: No RANCHER_BACKEND_SECRET_KEY specified. Cannot continue." 1>&2
            exit 1
        fi
    fi
    if [ -z "$RANCHER_FRONTEND_ACCESS_KEY" ]
    then
        export RANCHER_FRONTEND_ACCESS_KEY="`get_octopusvariable 'RANCHER_FRONTEND_ACCESS_KEY'`" || :
        if [ -z "$RANCHER_FRONTEND_ACCESS_KEY" ]
        then
            echo "[deploy_snapshot.sh] ERROR: No RANCHER_FRONTEND_ACCESS_KEY specified. Cannot continue." 1>&2
            exit 1
        fi
    fi
    if [ -z "$RANCHER_FRONTEND_ENV_ID" ]
    then
        export RANCHER_FRONTEND_ENV_ID="`get_octopusvariable 'RANCHER_FRONTEND_ENV_ID'`" || :
        if [ -z "$RANCHER_FRONTEND_ENV_ID" ]
        then
            echo "[deploy_snapshot.sh] ERROR: No RANCHER_FRONTEND_ENV_ID specified. Cannot continue." 1>&2
            exit 1
        fi
    fi
    if [ -z "$RANCHER_FRONTEND_SECRET_KEY" ]
    then
        export RANCHER_FRONTEND_SECRET_KEY="`get_octopusvariable 'RANCHER_FRONTEND_SECRET_KEY'`" || :
        if [ -z "$RANCHER_FRONTEND_SECRET_KEY" ]
        then
            echo "[deploy_snapshot.sh] ERROR: No RANCHER_FRONTEND_SECRET_KEY specified. Cannot continue." 1>&2
            exit 1
        fi
    fi
    if [ -z "$RANCHER_URL" ]
    then
        export RANCHER_URL="`get_octopusvariable 'RANCHER_URL'`" || :
        if [ -z "$RANCHER_URL" ]
        then
            echo "[deploy_snapshot.sh] ERROR: No RANCHER_URL specified. Cannot continue." 1>&2
            exit 1
        fi
    fi

    echo '##octopus[stderr-progress]'
}

function run_docker() {
    echo '##octopus[stderr-progress]'
    docker container prune -f
    docker login cardano.azurecr.io -u "${DOCKER_REGISTRY_USERNAME}" -p "${DOCKER_REGISTRY_PASSWORD}"
    docker pull cardano.azurecr.io/devops/deploy-image:latest
    
    set +e
    docker run -v `pwd`:/home/jenkins/scripts -w="/home/jenkins/scripts" \
        -e RANCHER_URL="$RANCHER_URL" \
        -e ENVKEY_MASTER_KEY="$ENVKEY_MASTER_KEY" \
        -e RANCHER2_DEPLOY_VARS_ENVKEY="$RANCHER2_DEPLOY_VARS_ENVKEY" \
        -e DEFAULT_SERVICE_SCALE="$DEFAULT_SERVICE_SCALE" \
        -e RANCHER_BACKEND_ACCESS_KEY="$RANCHER_BACKEND_ACCESS_KEY" \
        -e RANCHER_BACKEND_ENV_ID="$RANCHER_BACKEND_ENV_ID" \
        -e RANCHER_BACKEND_SECRET_KEY="$RANCHER_BACKEND_SECRET_KEY" \
        -e RANCHER_FRONTEND_ACCESS_KEY="$RANCHER_FRONTEND_ACCESS_KEY" \
        -e RANCHER_FRONTEND_ENV_ID="$RANCHER_FRONTEND_ENV_ID" \
        -e RANCHER_FRONTEND_SECRET_KEY="$RANCHER_FRONTEND_SECRET_KEY" \
		-e OCTOPUS_PROJECT_NAME="`get_octopusvariable 'Octopus.Project.Name'`" \
        -e RUNNING_IN_DOCKER="true" \
        cardano.azurecr.io/devops/deploy-image:latest /bin/bash /home/jenkins/scripts/deploy_rancher_snapshot.sh
    SUCCESS=$?
    set -e

    echo '##octopus[stderr-default]'

    if [ $SUCCESS -gt 0 ]
    then
        echo "[deploy_snapshot.sh] Deploy of AppFamily failed." 1>&2
        exit 1
    fi
}

function push_templates () {
	end=$1
	stackName=$2
	
	cd ${WORKSPACE}/rancher-environment-export/$end/$stackName
	
	echo "===================================================="
	echo "Current env: $end"
	echo "Current stack: $stackName"
	echo "Current directory is: `pwd`"
	echo "Listing files:"
	echo "----------------------------------------------------"
	ls -l
	echo "===================================================="
	
	# Check for and remove any pre-existing stack with this name:
	existing_stack_id="`${WORKSPACE}/rancher-${RANCHER_CLI_VERSION}/rancher stacks ls | grep -e \"\\s${stackName}\\s\" | awk '{print $1}'`"
	if [[ $existing_stack_id ]]
	then 
		echo "Found an existing stack with this name of id: $existing_stack_id. Deleting it first."
		${WORKSPACE}/rancher-${RANCHER_CLI_VERSION}/rancher rm $existing_stack_id	
	fi
	
	# If a template file exists, deploy it:
	if [[ -f ./docker-compose.yml ]]
	then
		# Merge-in the ENVKEY(s)
		# Fetch Envkeys for this stack, if any:
		echo "Found a docker-compose.yml for $end stack: $stackName"
		echo "DEBUG: Path to apps.json is: ${WORKSPACE}/apps.json"
		
		set +e
		jq -r '.customEnvkeyMappings' ${WORKSPACE}/apps.json | grep -e "^null" >/dev/null
		export NO_CUSTOM_MAPPINGS=$?
		set -e

		CUSTOM_ENVMAP_STACK_SETTINGS="`jq -r \".customEnvkeyMappings.${end}[\\\"${stackName}\\\"]\" ${WORKSPACE}/apps.json || :`"

		if [ $NO_CUSTOM_MAPPINGS -eq 0 ] || [ "$CUSTOM_ENVMAP_STACK_SETTINGS" == "null" ]
		then
			echo "Didn't detect any custom envkey mappings in the apps.json which apply to this stack."
			
			serviceEnvkeys=( `envkey-source $ENVKEY_MASTER_KEY | tr " " "\n" | sed '/export/d' | sed -e 's|["'\'']||g' | grep --ignore-case ^$stackName=` ) || (echo "No entry found in rancher-apps-master-keystore for this stack name. You should probably add it. Failing the deploy." && exit 1)
			if [ ${serviceEnvkeys[1]} ] 
			then
				# More than one envkey for this stack,
				# should be of the format 'stack-name:service-name=value'
				# So map them to their respective services:
				echo "Detected multiple service-linked Envkeys for this stack. Iterating through each." 
				for i in "${serviceEnvkeys[@]}"
				do
					yq r ./docker-compose.yml 'services' | sed '/^[[:space:]]/d' | sed 's/.$//' | while read j; do
						set +e
						pattern=":${j}="
						match=`printf '%s\n' "${i}" | grep --ignore-case "$pattern"`
						set -e

						if [ $match ] 
						then
							# Found a service with an envkey defined. Merge its ENVKEY into the file in its environment section:
							echo "Found a service match: '$j'. Applying the Envkey to its environment in the docker-compose.yml."
							service_key="`echo $match | cut -d'=' -f 2`"
							yq w -i ./docker-compose.yml "services.${j}.environment[ENVKEY]" "[[a]]$service_key[[a]]" # add funky [[a]] to force yq to single-quote the line in the yml 
						fi
					done
				done
			else
				# There is only one Envkey defined for this stack. So:
				#   1) If it's mapped to a single service, honour that. 
				#   2) If it's not mapped to any particular service, apply it to all services
				echo "Only detected one Envkey for this stack."

				set +e
				echo "${serviceEnvkeys[0]}" | grep ':' > /dev/null 2>&1
				colon=$?
				set -e

				if [ $colon -eq 0 ]
				then
					# 1) A service name is explicitly defined
					echo "The Envkey '${serviceEnvkeys[0]}' is linked to a specific service."
					yq r ./docker-compose.yml 'services' | sed '/^[[:space:]]/d' | sed 's/.$//' | while read j; do
						match="`printf '%s\n' "${serviceEnvkeys[0]}" | grep --ignore-case :${j}=`"
						if [ $match ] 
						then
							# Found a service with an envkey defined. Merge its ENVKEY into the file in its environment section:
							echo "Found a service match: '$j'. Applying the Envkey to its environment in the docker-compose.yml."
							service_key="`echo $match | cut -d'=' -f 2`"
							yq w -i ./docker-compose.yml "services.${j}.environment[ENVKEY]" "[[a]]$service_key[[a]]" # add funky [[a]] to force yq to single-quote the line in the yml 
						else 
							echo "No service name match found in the docker-compose.yml! Likely a misconfiguration. Aborting deploy."
							exit 1
						fi
					done
				else
					# 2) No service name is defined. Apply it to all services
					echo "This Envkey is not service-specific. Applying it to all services in the stack."
					yq r ./docker-compose.yml "services" | sed '/^[[:space:]]/d' | sed 's/.$//' | while read j; do
						service_key="`echo ${serviceEnvkeys[0]} | cut -d'=' -f 2`"
						yq w -i ./docker-compose.yml "services.${j}.environment[ENVKEY]" "[[a]]$service_key[[a]]" # add funky [[a]] to force yq to single-quote the line in the yml 
					done
				fi
			fi
		else
			echo "Detected custom envkey mappings in the apps.json which apply to this stack."

			MAPPINGS=`echo "$CUSTOM_ENVMAP_STACK_SETTINGS" | jq -r 'keys[] as $k | "\($k)\t\(.[$k])"' --`
			echo "$MAPPINGS" | while IFS=$'\t' read -r -a tuple; do
				echo "Variable name is: ${tuple[0]} and stack name is: ${tuple[1]}" 
				serviceEnvkeys=( `envkey-source $ENVKEY_MASTER_KEY | tr " " "\n" | sed '/export/d' | sed -e 's|["'\'']||g' | grep --ignore-case ^${tuple[1]}=` ) || (echo "No entry found in rancher-apps-master-keystore for stack name ${tuple[1]}. You should probably add it, or reference a stack that exists. Failing the deploy." && exit 1)

				echo "Found an ENVKEY stack match for stack ${tuple[1]}. Inserting it into the environment with variable name: ${tuple[0]}"
				yq r ./docker-compose.yml "services" | sed '/^[[:space:]]/d' | sed 's/.$//' | while read j; do
					service_key="`echo ${serviceEnvkeys[0]} | cut -d'=' -f 2`"
					yq w -i ./docker-compose.yml "services.${j}.environment[${tuple[0]}]" "[[a]]$service_key[[a]]" # add funky [[a]] to force yq to single-quote the line in the yml 
				done
			done
		fi
		
		sed -i 's/\[\[a\]\]//g' ./docker-compose.yml # strip fudged chars out
		
		# Set default scale based on env, and add missing Scheduler tab stuff if it's not defined 
		# (the latter is critical for apps to survive the Reaper):
		sed -i "s/scale:\ [0-9]*/scale:\ $DEFAULT_SERVICE_SCALE/g" ./rancher-compose.yml 
		yq r ./docker-compose.yml "services" | sed '/^[[:space:]]/d' | sed 's/.$//' | while read j; do
			HOST_AFFINITY="`yq r ./docker-compose.yml \"services.${j}.labels[io.rancher.scheduler.affinity:host_label]\"`"
			if [ "$HOST_AFFINITY" == "null" ]
			then
				# there is no host affinity defined, assume container_host affinity
				yq w -i ./docker-compose.yml "services.${j}.labels[io.rancher.scheduler.affinity:host_label]" "container_host=true"
			fi
			
			CONTAINER_AFFINITY="`yq r ./docker-compose.yml \"services.${j}.labels[io.rancher.scheduler.affinity:container_label_ne]\"`"
			if [ "$CONTAINER_AFFINITY" == "null" ]
			then
				# there is no container label affinity defined. Insert it, so 2 containers won't run on same host
				yq w -i ./docker-compose.yml "services.${j}.labels[io.rancher.scheduler.affinity:container_label_ne]" 'io.rancher.stack_service.name=$${stack_name}/$${service_name}'
			fi
		done
		
		# Check for and remove any pre-existing stack with this name:
		existing_stack_id="`${WORKSPACE}/rancher-${RANCHER_CLI_VERSION}/rancher stacks ls | grep -e \"\\s${stackName}\\s\" | awk '{print $1}'`"
		if [[ $existing_stack_id ]]
		then 
			echo "Found an existing stack with this name of id: $existing_stack_id. Deleting it first."
			${WORKSPACE}/rancher-${RANCHER_CLI_VERSION}/rancher rm $existing_stack_id	
		fi
		
		# Now deploy the new one:
		${WORKSPACE}/rancher-${RANCHER_CLI_VERSION}/rancher up --pull -d
		newStackId="`${WORKSPACE}/rancher-${RANCHER_CLI_VERSION}/rancher stacks ls | grep -e \"\\s${stackName}\\s\" | awk '{print $1}'`"
		${WORKSPACE}/rancher-${RANCHER_CLI_VERSION}/rancher --wait-state healthy --wait-timeout 600 wait $newStackId
	else
		echo "There is no docker-compose.yml for $end stack: '$stackName'. Not deploying anything."
	fi
}

function update_rancher2_app_manifest() {
	# Rancher 2:
	echo "Rancher 2: Applying changes to ${MANIFEST_ENV}'s Rancher 2 manifest for this appfamily snapshot."
	
	# Get our Git repository name (appfamily name) and the appfamily version we're deploying:
	cd ${WORKSPACE}
	repoName="$OCTOPUS_PROJECT_NAME"
    tag=`cat ${WORKSPACE}/version`
	
	rm -rf /tmp/app-manifest
	if [ "${MANIFEST_ENV,,}" == "prod-north" ] || [ "${MANIFEST_ENV,,}" == "prod-west" ] || [ "${MANIFEST_ENV,,}" == "prod" ]
	then
		git clone https://github.com/cardano/devops-rancher2-prod-app-manifest.git /tmp/app-manifest
		cd /tmp/app-manifest
		git checkout -f master
	else
		git clone https://github.com/cardano/devops-rancher2-nonprod-app-manifest.git /tmp/app-manifest
		cd /tmp/app-manifest
		git checkout -f ${MANIFEST_ENV,,}
	fi
	
	# Grab the stacks/versions from our snapshot's app-manifest and merge them into the real app-manifest:
	cat $WORKSPACE/app-manifest.json | jq -r 'keys[] as $k | "\($k)\t\(.[$k])"' -- > /tmp/app-mappings
	rm -f /tmp/.app-manifest-deploy-successful

	until [ -f /tmp/.app-manifest-deploy-successful ]; do
		cd /tmp/app-manifest
		git pull

		echo "Applying appfamily snapshot to ${MANIFEST_ENV} app-manifest.json..."
		cat /tmp/app-mappings | while IFS=$'\t' read -r -a tuple; do
			APP_NAME="${tuple[0]}"
			APP_VERSION="${tuple[1]}"
			
			echo "Setting ${APP_NAME} to ${APP_VERSION} in canonical app-manifest.json"
			cd /tmp/app-manifest
			cat ./app-manifest.json | jq ".\"${APP_NAME}\" = \"${APP_VERSION}\"" > ./app-manifest2.json
			mv ./app-manifest2.json ./app-manifest.json
		done
		
		echo "Done applying appfamily snapshot changes."

		cd /tmp/app-manifest
		git add ./app-manifest.json
		(git commit --allow-empty -m "${repoName}: ${tag}" && git push && touch /tmp/.app-manifest-deploy-successful) || (git reset --hard HEAD~1)
		
		if [ -f /tmp/.app-manifest-deploy-successful ]
		then
			echo "Appfamily manifest update successful."
		else
			echo "There was a problem updating the Appfamily Manifest for ${MANIFEST_ENV}. Retrying."
			sleep 10
		fi
	done
}

if [ "$RUNNING_IN_DOCKER" == "true" ]
then
	# Run from the temp folder to avoid filesystem access errors;
	TEMP_WORKSPACE="/tmp/deploy_rancher_workspace"
	rm -rf $TEMP_WORKSPACE
	mkdir $TEMP_WORKSPACE
	cp -R ./* $TEMP_WORKSPACE
	cd $TEMP_WORKSPACE
	
	export RANCHER_CLI_VERSION="v0.6.10"
	export WORKSPACE="`pwd`"

	wget -q https://releases.rancher.com/cli/${RANCHER_CLI_VERSION}/rancher-linux-amd64-${RANCHER_CLI_VERSION}.tar.gz
	tar -xvzf ./rancher-linux-amd64-${RANCHER_CLI_VERSION}.tar.gz
	chmod +x ./rancher-${RANCHER_CLI_VERSION}/rancher

	curl -s https://raw.githubusercontent.com/envkey/envkey-source/master/install.sh | bash

	if [ -d "${WORKSPACE}/rancher-environment-export/backend" ]
	then
		cd ${WORKSPACE}/rancher-environment-export/backend
		export RANCHER_ACCESS_KEY="${RANCHER_BACKEND_ACCESS_KEY}"
		export RANCHER_SECRET_KEY="${RANCHER_BACKEND_SECRET_KEY}"
		export RANCHER_ENVIRONMENT="${RANCHER_BACKEND_ENV_ID}"

		jq -cr '.backend[]' ${WORKSPACE}/apps.json | while read i; do
			push_templates backend $i
		done
	fi

	if [ -d "${WORKSPACE}/rancher-environment-export/frontend" ]
	then
		cd ${WORKSPACE}/rancher-environment-export/frontend
		export RANCHER_ACCESS_KEY="${RANCHER_FRONTEND_ACCESS_KEY}"
		export RANCHER_SECRET_KEY="${RANCHER_FRONTEND_SECRET_KEY}"
		export RANCHER_ENVIRONMENT="${RANCHER_FRONTEND_ENV_ID}"

		jq -cr '.frontend[]' ${WORKSPACE}/apps.json | while read i; do
			push_templates frontend $i
		done
	fi

	if [ -f "${WORKSPACE}/app-manifest.json" ]
	then
		echo "Rancher 2: This Appfamily has an app-manifest.json"
		if [ -z "$RANCHER2_DEPLOY_VARS_ENVKEY" ]
		then
			export RANCHER2_DEPLOY_VARS_ENVKEY="`get_octopusvariable 'RANCHER2_DEPLOY_VARS_ENVKEY'`"
		fi

		eval $(envkey-source -f $RANCHER2_DEPLOY_VARS_ENVKEY)
		if [ -z "$MANIFEST_ENV" ]
		then
			echo "ERROR: MANIFEST_ENV is not set for this Rancher 2 environment. Cannot proceed."
			exit 1
		fi

		git config --global credential.helper store
    	echo "https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com" > ~/.git-credentials

		update_rancher2_app_manifest
	fi
else
	validate_variables
	run_docker
fi